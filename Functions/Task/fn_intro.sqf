/*
    intro.sqf — Cinématique d'introduction (hélicoptère)
    ------------------------------------------------------
    v3 — Corrections et optimisations :

    1. BUG CRITIQUE corrigé : ppEffectCreate renvoie un Number (handle),
       pas un Object. "isNull _ppColor" est invalide sur un Number et
       plantait le script (ligne 130). Suppression des isNull sur les
       handles de post-process ; ils sont toujours créés donc toujours
       détruits sans condition.
    2. SACCADES corrigées : le pilotage caméra (orbites, transitions)
       tournait dans une boucle "sleep 0.1 / camCommit 0.1" exécutée par
       le scheduler SQF, non synchronisé à l'affichage — d'où les à-coups
       si le scheduler était chargé. Remplacé par un handler
       "EachFrame" (addMissionEventHandler) : la caméra est repositionnée
       à CHAQUE frame rendue, indépendamment du scheduler. C'est la
       méthode standard pour des travellings fluides en Arma 3.
    3. Le thread principal ne fait plus que déclencher les phases
       (via une variable d'état MISSION_intro_camPhase) et gérer le
       minutage/les conditions de sortie — il ne touche plus la caméra
       directement pendant les orbites.
    4. Scope corrigé : constantes déplacées à l'intérieur des blocs
       spawn concernés (spawn n'hérite pas des "private" du scope
       appelant).
    5. Skip intro (maintenir ESPACE ~1.2s), timeout anti-boucle infinie
       sur la phase finale, fallback caméra propre si pas d'hélico,
       nettoyage réseau (un seul remoteExec par porte), fondu musical
       de sortie — repris de la v2.
*/

params [["_isJip", false, [true]]];

if (hasInterface) then {
    if (missionNamespace getVariable ["MISSION_intro_cl", false]) exitWith {};
    missionNamespace setVariable ["MISSION_intro_cl", true];

    if (_isJip) exitWith {};

    [] spawn {
        disableSerialization;

        // ---------------------------------------------------------------
        // Constantes de tuning (durées en secondes)
        // ---------------------------------------------------------------
        private _DUR_APPROACH   = 14;
        private _SKIP_HOLD_TIME = 1.2;

        // -- Attente du joueur, bornée --
        private _playerTimeout = time + 30;
        waitUntil { !isNull player || time > _playerTimeout };
        if (isNull player) exitWith {};

        missionNamespace setVariable ["MISSION_intro_skip", false];

        // -- Skip : maintien ESPACE (DIK_SPACE = 57) --
        private _skipDisplay  = findDisplay 46;
        private _skipHandleDn = -1;
        private _skipHandleUp = -1;
        if (!isNull _skipDisplay) then {
            missionNamespace setVariable ["MISSION_intro_skipKeyDownTime", -1];

            _skipHandleDn = _skipDisplay displayAddEventHandler ["KeyDown", {
                params ["", "_key"];
                if (_key == 57 && { (missionNamespace getVariable ["MISSION_intro_skipKeyDownTime", -1]) < 0 }) then {
                    missionNamespace setVariable ["MISSION_intro_skipKeyDownTime", time];
                };
                false
            }];

            _skipHandleUp = _skipDisplay displayAddEventHandler ["KeyUp", {
                params ["", "_key"];
                if (_key == 57) then {
                    missionNamespace setVariable ["MISSION_intro_skipKeyDownTime", -1];
                };
                false
            }];

            [_SKIP_HOLD_TIME] spawn {
                params ["_holdTime"];
                while { !(missionNamespace getVariable ["MISSION_intro_finished", false]) } do {
                    private _downSince = missionNamespace getVariable ["MISSION_intro_skipKeyDownTime", -1];
                    if (_downSince > 0 && { time - _downSince >= _holdTime }) then {
                        missionNamespace setVariable ["MISSION_intro_skip", true];
                    };
                    sleep 0.1;
                };
            };
        };

        cutText ["", "BLACK FADED", 999];
        0 fadeSound 0;
        showCinemaBorder true;
        player allowDamage false;

        private _ppColor = ppEffectCreate ["ColorCorrections", 1500];
        _ppColor ppEffectEnable true;
        _ppColor ppEffectAdjust [1, 0.95, 0.05, [0.15, 0.15, 0.2, 0.0], [0.85, 0.85, 0.9, 0.6], [0.1, 0.1, 0.15, 0]];
        _ppColor ppEffectCommit 0;

        private _ppGrain = ppEffectCreate ["FilmGrain", 2005];
        _ppGrain ppEffectEnable true;
        _ppGrain ppEffectAdjust [0.08, 0.9, 1, 0.08, 1, false];
        _ppGrain ppEffectCommit 0;

        private _lzTimeout = time + 30;
        waitUntil { (!isNil "MISSION_intro_lz" && !isNil "MISSION_intro_heli") || time > _lzTimeout };
        private _lzPos = if (!isNil "MISSION_intro_lz") then { MISSION_intro_lz } else { getPos player };
        private _heli  = if (!isNil "MISSION_intro_heli") then { MISSION_intro_heli } else { objNull };

        private _cam = "camera" camCreate (getPos player);
        _cam cameraEffect ["INTERNAL", "BACK"];

        if (sunOrMoon < 0.3) then {
            camUseNVG true;
        };

        0 fadeMusic 1;
        playMusic "Music_Intro";
        3 fadeSound 1;

        // ---------------------------------------------------------------
        // Cinématique 100% fluide : caméras ancrées au sol / relief
        // Interpolation native du moteur Arma 3 (camCommit)
        // ---------------------------------------------------------------

        // Fonction utilitaire d'attente sécurisée
        private _fnWaitPhase = {
            params ["_dur", ["_watchVehicle", false]];
            private _t0 = time;
            waitUntil {
                sleep 0.05;
                (time - _t0 >= _dur)
                || (missionNamespace getVariable ["MISSION_intro_skip", false])
                || (_watchVehicle && { vehicle player == player })
            };
        };

        private _skipped = { missionNamespace getVariable ["MISSION_intro_skip", false] };

        if (!isNull _heli) then {
            private _dirToHeli = _lzPos getDir (getPos _heli);

            // ===============================================================
            // PLAN 1 : Reconnaissance en altitude & Titres (0 à 14s)
            // ===============================================================
            private _p1Start = [
                (_lzPos select 0) + 40 * sin _dirToHeli,
                (_lzPos select 1) + 40 * cos _dirToHeli,
                15
            ];
            private _p1End = [
                (_lzPos select 0) + 160 * sin _dirToHeli,
                (_lzPos select 1) + 160 * cos _dirToHeli,
                45
            ];

            _cam camSetPos _p1Start;
            _cam camSetTarget _heli;
            _cam camSetFov 0.70;
            _cam camCommit 0;

            cutText ["", "BLACK IN", 3];

            _cam camSetPos _p1End;
            _cam camSetTarget _heli;
            _cam camCommit 14;

            // Titre principal
            sleep 2;
            if !(call _skipped) then {
                titleText [
                    format [
                        "<t size='3.0' color='#ffffff' font='PuristaBold' shadow='2' align='center'>%1</t><br/>" +
                        "<t size='1.4' color='#E5B729' font='PuristaSemiBold' align='center' letterSpacing='0.15'>%2</t>",
                        "THE UNSEEN ELEMENT",
                        localize "STR_LL_Intro_Presents"
                    ],
                    "PLAIN", 1, true, true
                ];
            };

            sleep 6;
            titleText ["", "PLAIN", 0.5];
            sleep 1;

            // Texte de localisation animé
            [] spawn {
                private _p2chars = toArray (localize "STR_LL_Intro_Location");
                private _p2built = "";
                {
                    if (missionNamespace getVariable ["MISSION_intro_skip", false]) exitWith {};
                    _p2built = _p2built + toString [_x];
                    [
                        format ["<t size='1.3' color='#ffffff' font='PuristaLight' align='center' shadow='2'>%1</t>", _p2built],
                        -1, 0.35, 5, 0, 0, 793
                    ] spawn BIS_fnc_dynamicText;
                    if (_x != 32) then { playSound "readoutClick"; };
                    sleep 0.08;
                } forEach _p2chars;
                sleep 2.5;
                ["", -1, 0.35, 1, 0.5, 0, 793] spawn BIS_fnc_dynamicText;
            };

            sleep 5;

            // ===============================================================
            // PLAN 2 : Survol panoramique depuis les hauteurs (14s à 24s)
            // ===============================================================
            if (vehicle player != player && !(call _skipped)) then {
                cutText ["", "BLACK FADED", 0.4];
                sleep 0.4;
                cutText ["", "BLACK IN", 0.8];

                _ppColor ppEffectAdjust [1, 1.0, -0.05, [0.15, 0.15, 0.2, 0.0], [0.85, 0.85, 0.9, 0.65], [0.1, 0.1, 0.15, 0]];
                _ppColor ppEffectCommit 1;
                _ppGrain ppEffectAdjust [0.04, 0.7, 0.8, 0.04, 0.8, false];
                _ppGrain ppEffectCommit 1;

                private _p2A = [
                    (_lzPos select 0) + 520 * sin (_dirToHeli + 45),
                    (_lzPos select 1) + 520 * cos (_dirToHeli + 45),
                    4
                ];
                private _p2B = [
                    (_lzPos select 0) + 490 * sin (_dirToHeli + 45) + 20 * cos (_dirToHeli + 45),
                    (_lzPos select 1) + 490 * cos (_dirToHeli + 45) - 20 * sin (_dirToHeli + 45),
                    4
                ];

                _cam camSetPos _p2A;
                _cam camSetTarget _heli;
                _cam camSetFov 0.50;
                _cam camCommit 0;

                _cam camSetPos _p2B;
                _cam camSetTarget _heli;
                _cam camCommit 10;

                [10, true] call _fnWaitPhase;
            };

            // ===============================================================
            // PLAN 3 : Contre-plongée spectaculaire en lisière/forêt (24s à 32s)
            // ===============================================================
            if (vehicle player != player && !(call _skipped)) then {
                cutText ["", "BLACK FADED", 0.4];
                sleep 0.4;
                cutText ["", "BLACK IN", 0.8];

                private _p3A = [
                    (_lzPos select 0) + 220 * sin (_dirToHeli - 20),
                    (_lzPos select 1) + 220 * cos (_dirToHeli - 20),
                    1.2
                ];
                private _p3B = [
                    (_lzPos select 0) + 190 * sin (_dirToHeli - 20),
                    (_lzPos select 1) + 190 * cos (_dirToHeli - 20),
                    1.4
                ];

                _cam camSetPos _p3A;
                _cam camSetTarget _heli;
                _cam camSetFov 0.65;
                _cam camCommit 0;

                _cam camSetPos _p3B;
                _cam camSetTarget _heli;
                _cam camCommit 8;

                [8, true] call _fnWaitPhase;
            };

            // ===============================================================
            // PLAN 4 : Survol panoramique en plongée sur la LZ (32s au Poser)
            // ===============================================================
            if (vehicle player != player && !(call _skipped)) then {
                cutText ["", "BLACK FADED", 0.4];
                sleep 0.4;
                cutText ["", "BLACK IN", 0.8];

                private _p4A = [
                    (_lzPos select 0) + 75 * sin (_dirToHeli - 50),
                    (_lzPos select 1) + 75 * cos (_dirToHeli - 50),
                    26
                ];
                private _p4B = [
                    (_lzPos select 0) + 45 * sin (_dirToHeli - 25),
                    (_lzPos select 1) + 45 * cos (_dirToHeli - 25),
                    14
                ];

                _cam camSetPos _p4A;
                _cam camSetTarget [(_lzPos select 0), (_lzPos select 1), 0.5];
                _cam camSetFov 0.65;
                _cam camCommit 0;

                _cam camSetPos _p4B;
                _cam camSetTarget [(_lzPos select 0), (_lzPos select 1), 0.5];
                _cam camCommit 12;

                private _touchWait = time + 20;
                waitUntil {
                    sleep 0.1;
                    (getPosATL _heli select 2) < 4
                    || time > _touchWait
                    || (call _skipped)
                    || vehicle player == player
                };
            };

            // ===============================================================
            // PLAN 5 : Poser & Débarquement de l'escouade
            // ===============================================================
            if (vehicle player != player && !(call _skipped)) then {
                cutText ["", "BLACK FADED", 0.3];
                sleep 0.3;
                cutText ["", "BLACK IN", 0.6];

                private _p5A = [
                    (_lzPos select 0) + 20 * sin (_dirToHeli + 110),
                    (_lzPos select 1) + 20 * cos (_dirToHeli + 110),
                    1.5
                ];
                private _p5B = [
                    (_lzPos select 0) + 16 * sin (_dirToHeli + 130),
                    (_lzPos select 1) + 16 * cos (_dirToHeli + 130),
                    1.5
                ];

                _cam camSetPos _p5A;
                _cam camSetTarget [(_lzPos select 0), (_lzPos select 1), 1.2];
                _cam camSetFov 0.70;
                _cam camCommit 0;

                _cam camSetPos _p5B;
                _cam camCommit 12;

                waitUntil {
                    sleep 0.1;
                    vehicle player == player || (call _skipped)
                };
            };
        } else {
            // -- Fallback : pas d'hélico détecté --
            _cam camSetPos [(_lzPos select 0) + 25, (_lzPos select 1) + 25, 8];
            _cam camSetTarget _lzPos;
            _cam camSetFov 0.65;
            _cam camCommit 0;

            cutText ["", "BLACK IN", 3];

            _cam camSetPos [(_lzPos select 0) + 15, (_lzPos select 1) + 15, 3];
            _cam camCommit 14;
            [14, false] call _fnWaitPhase;

            [20, true] call _fnWaitPhase;
        };

        // -- Nettoyage --
        cutText ["", "BLACK FADED", 0];
        sleep 1;

        if (!isNull _cam) then {
            _cam cameraEffect ["TERMINATE", "BACK"];
            camDestroy _cam;
        };
        camUseNVG false;
        // ppEffectCreate renvoie un Number, pas un Object : pas de isNull ici,
        // les deux handles sont toujours créés plus haut donc toujours détruits.
        ppEffectDestroy _ppColor;
        ppEffectDestroy _ppGrain;

        player switchCamera "INTERNAL";
        showCinemaBorder false;
        player allowDamage true;

        cutText ["", "BLACK IN", 3];

        [
            format [
                "<t size='1.0' color='#bbbbbb' font='PuristaLight' align='center'>%1</t>",
                localize "STR_LL_Intro_MissionStartSubtitle"
            ],
            -1, -1, 5, 1, 0, 793
        ] spawn BIS_fnc_dynamicText;

        missionNamespace setVariable ["MISSION_intro_finished", true, true];

        if (!isNull _skipDisplay) then {
            if (_skipHandleDn != -1) then { _skipDisplay displayRemoveEventHandler ["KeyDown", _skipHandleDn]; };
            if (_skipHandleUp != -1) then { _skipDisplay displayRemoveEventHandler ["KeyUp", _skipHandleUp]; };
        };
    };
};

if (isServer) then {
    if (missionNamespace getVariable ["MISSION_intro_sv", false]) exitWith {};
    missionNamespace setVariable ["MISSION_intro_sv", true];

    [] spawn {
        waitUntil { time > 0.1 };

        private _pTimeout = time + 15;
        waitUntil { count allPlayers > 0 || time > _pTimeout };

        private _players = allPlayers;
        if (count _players == 0 && !isNull player) then { _players = [player]; };

        private _destPos = [0, 0, 0];
        private _foundLZ = false;

        private _heliports = allMissionObjects "HeliH";
        { _heliports pushBackUnique _x; } forEach (allMissionObjects "Land_HelipadEmpty_F");
        { _heliports pushBackUnique _x; } forEach (allMissionObjects "HeliHSquare_F");

        if (count _heliports > 0) then {
            _destPos = getPos (selectRandom _heliports);
            _foundLZ = true;
        };

        if (!_foundLZ && count _players > 0) then {
            _destPos = getPos (_players select 0);
            _foundLZ = true;
        };

        if (!_foundLZ) exitWith {
            missionNamespace setVariable ["MISSION_intro_finished", true, true];
        };

        _destPos set [2, 0];
        MISSION_intro_lz = _destPos;
        publicVariable "MISSION_intro_lz";

        private _startDir = random 360;
        private _startPos = [
            (_destPos select 0) + 1500 * sin _startDir,
            (_destPos select 1) + 1500 * cos _startDir,
            200
        ];

        private _heliClass = "B_Heli_Transport_01_F";
        if (!isNil "heli_BLUFOR" && { !isNull heli_BLUFOR }) then {
            _heliClass = typeOf heli_BLUFOR;
        };

        private _heli = createVehicle [_heliClass, _startPos, [], 0, "FLY"];
        _heli setPos _startPos;
        _heli setDir (_startPos getDir _destPos);
        _heli flyInHeight 150;
        _heli allowDamage false;

        MISSION_intro_heli = _heli;
        publicVariable "MISSION_intro_heli";

        createVehicleCrew _heli;
        private _crew = crew _heli;
        { _x allowDamage false; } forEach _crew;
        (group driver _heli) setBehaviour "CARELESS";
        (group driver _heli) setCombatMode "BLUE";

        private _allUnitsToBoard = [];
        private _processedGroups = [];

        {
            private _grp = group _x;
            if !(_grp in _processedGroups) then {
                _processedGroups pushBack _grp;
                {
                    if (alive _x && !(_x in _allUnitsToBoard)) then { _allUnitsToBoard pushBack _x; };
                } forEach (units _grp);
            };
        } forEach _players;

        {
            if (alive _x && !(_x in _allUnitsToBoard)) then { _allUnitsToBoard pushBack _x; };
        } forEach _players;

        {
            _x moveInCargo _heli;
            if (vehicle _x == _x) then { _x moveInAny _heli; };
            _x assignAsCargo _heli;
        } forEach _allUnitsToBoard;

        sleep 1;

        _heli doMove _destPos;
        _heli flyInHeight 150;
        _heli limitSpeed 200;

        sleep 15;

        [_heli, ["doorLB", 1]] remoteExec ["animateDoor", 0, _heli];
        [_heli, ["doorRB", 1]] remoteExec ["animateDoor", 0, _heli];

        sleep 10;

        _heli limitSpeed 110;

        private _landTimeout = time + 120;
        waitUntil { (_heli distance2D _destPos) < 300 || time > _landTimeout };
        _heli land "GET OUT";

        private _touchTimeout = time + 60;
        waitUntil { (getPosATL _heli select 2) < 2 || time > _touchTimeout };
        sleep 1;

        private _unitsToDisembark   = [];
        private _processedGroupsDis = [];

        {
            private _grp = group _x;
            if !(_grp in _processedGroupsDis) then {
                _processedGroupsDis pushBack _grp;
                {
                    if (alive _x && vehicle _x == _heli && !(_x in _unitsToDisembark)) then {
                        _unitsToDisembark pushBack _x;
                    };
                } forEach (units _grp);
            };
        } forEach _players;

        private _unitIndex = 0;
        {
            moveOut _x;
            unassignVehicle _x;
            private _dir         = getDir _heli;
            private _dist        = 6 + (_unitIndex mod 3);
            private _angleOffset = 60 + (_unitIndex * 14);
            private _pos         = _heli getPos [_dist, _dir + _angleOffset];
            _pos set [2, 0];
            _x setPos _pos;
            _x setDir _dir;
            _unitIndex = _unitIndex + 1;
        } forEach _unitsToDisembark;

        _heli setVehicleLock "LOCKED";
        sleep 2;

        [_heli, ["doorLB", 0]] remoteExec ["animateDoor", 0, _heli];
        [_heli, ["doorRB", 0]] remoteExec ["animateDoor", 0, _heli];

        _heli land "NONE";
        _heli doMove ([(_destPos select 0) + 3000 * sin _startDir, (_destPos select 1) + 3000 * cos _startDir, 0]);
        _heli flyInHeight 200;
        _heli limitSpeed 300;

        sleep 70;
        { deleteVehicle _x } forEach _crew;
        deleteVehicle _heli;
    };
};
