params [["_isJip", false, [true]]];

if (hasInterface) then {
    if (missionNamespace getVariable ["MISSION_intro_cl", false]) exitWith {};
    missionNamespace setVariable ["MISSION_intro_cl", true];

    if (_isJip && { missionNamespace getVariable ["MISSION_intro_finished", false] }) exitWith {
        showHUD [true, true, true, true, true, true, true, true, true, true, true];
        showCinemaBorder false;
        player allowDamage true;
    };

    [] spawn {
        disableSerialization;

        cutText ["", "BLACK FADED", 999];
        0 fadeSound 0;
        showHUD [false, false, false, false, false, false, false, false, false, false, false];
        showCinemaBorder true;
        player allowDamage false;

        private _SKIP_HOLD_TIME = 1.2;

        private _playerTimeout = time + 35;
        waitUntil { (!isNull player && alive player) || time > _playerTimeout };
        if (isNull player) exitWith {};

        player setVariable ["TUE_player_ready", true, true];

        missionNamespace setVariable ["MISSION_intro_skip", false];

        if (isMultiplayer) then {
            [] spawn {
                private _dotCycle = 1;
                while { !(missionNamespace getVariable ["MISSION_intro_start", false]) && !(missionNamespace getVariable ["MISSION_intro_finished", false]) } do {
                    private _dots = switch (_dotCycle) do {
                        case 1: { "." };
                        case 2: { ". ." };
                        case 3: { ". . ." };
                        default { "" };
                    };
                    [
                        format ["<t size='2.2' color='#aaaaaa' font='PuristaMedium' align='center'>%1</t>", _dots],
                        -1, -1, 0.4, 0, 0, 792
                    ] spawn BIS_fnc_dynamicText;
                    _dotCycle = if (_dotCycle >= 3) then { 1 } else { _dotCycle + 1 };
                    sleep 0.45;
                };
                ["", -1, -1, 0.1, 0, 0, 792] spawn BIS_fnc_dynamicText;
            };
        };

        private _startTimeout = time + 60;
        waitUntil {
            sleep 0.1;
            (!isNil "MISSION_intro_start" && { MISSION_intro_start } && !isNil "MISSION_intro_lz" && !isNil "MISSION_intro_heli")
            || time > _startTimeout
            || (missionNamespace getVariable ["MISSION_intro_finished", false])
        };

        if (missionNamespace getVariable ["MISSION_intro_finished", false]) exitWith {
            cutText ["", "BLACK IN", 2];
            showHUD [true, true, true, true, true, true, true, true, true, true, true];
            showCinemaBorder false;
            player allowDamage true;
        };

        private _skipDisplay  = findDisplay 46;
        private _skipHandleDn = -1;
        private _skipHandleUp = -1;
        if (!isNull _skipDisplay) then {
            missionNamespace setVariable ["MISSION_intro_skipKeyDownTime", -1];

            _skipHandleDn = _skipDisplay displayAddEventHandler ["KeyDown", {
                params ["", "_key"];
                if (missionNamespace getVariable ["MISSION_intro_finished", false]) exitWith { false };
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

        private _ppColor = ppEffectCreate ["ColorCorrections", 1500];
        _ppColor ppEffectEnable true;
        _ppColor ppEffectAdjust [1, 0.95, 0.05, [0.15, 0.15, 0.2, 0.0], [0.85, 0.85, 0.9, 0.6], [0.1, 0.1, 0.15, 0]];
        _ppColor ppEffectCommit 0;

        private _ppGrain = ppEffectCreate ["FilmGrain", 2005];
        _ppGrain ppEffectEnable true;
        _ppGrain ppEffectAdjust [0.08, 0.9, 1, 0.08, 1, false];
        _ppGrain ppEffectCommit 0;

        private _lzPos = if (!isNil "MISSION_intro_lz") then { MISSION_intro_lz } else { getPos player };
        private _heli  = if (!isNil "MISSION_intro_heli") then { MISSION_intro_heli } else { objNull };

        private _cam = "camera" camCreate (getPos player);
        _cam cameraEffect ["INTERNAL", "BACK"];

        if (sunOrMoon < 0.4) then {
            camUseNVG true;
        };

        0 fadeMusic 1;
        playMusic "Music_Intro";
        3 fadeSound 1;

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

        private _fnShowRadio = {
            params [["_sender", ""], ["_text", ""], ["_duration", 6.5], ["_fadeIn", 0.3]];
            if (call _skipped) exitWith {};

            private _content = if (_sender != "") then {
                format [
                    "<t font='PuristaMedium' shadow='2' align='left'>" +
                    "<t bgcolor='#0a0e16e6' color='#E5B729' font='PuristaBold' size='0.85'> ▌ %1 </t><br/>" +
                    "<t bgcolor='#0a0e16d9' color='#f1f5f9' size='0.78'> %2 </t>" +
                    "</t>",
                    _sender,
                    _text
                ]
            } else {
                format [
                    "<t font='PuristaMedium' shadow='2' align='left'>" +
                    "<t bgcolor='#0a0e16d9' color='#f1f5f9' size='0.78'> %1 </t>" +
                    "</t>",
                    _text
                ]
            };

            private _xPos = safeZoneX + (safeZoneW * 0.05);
            private _yPos = safeZoneY + (safeZoneH * 0.68);

            [_content, _xPos, _yPos, _duration, _fadeIn, 0, 794] spawn BIS_fnc_dynamicText;
        };

        if (!isNull _heli) then {
            private _dirToHeli = _lzPos getDir (getPos _heli);

            private _p1Start = [
                (_lzPos select 0) + 1200 * sin (_dirToHeli + 20),
                (_lzPos select 1) + 1200 * cos (_dirToHeli + 20),
                55
            ];
            private _p1End = [
                (_lzPos select 0) + 700 * sin (_dirToHeli + 10),
                (_lzPos select 1) + 700 * cos (_dirToHeli + 10),
                40
            ];

            _cam camSetPos _p1Start;
            _cam camSetTarget _heli;
            _cam camSetFov 0.70;
            _cam camCommit 0;

            cutText ["", "BLACK IN", 3];

            _cam camSetPos _p1End;
            _cam camSetTarget _heli;
            _cam camCommit 14;

            sleep 2;
            if !(call _skipped) then {
                titleText [
                    format [
                        "<t size='2.5' color='#ffffff' font='PuristaBold' shadow='2' align='center'>%1</t><br/>" +
                        "<t size='1.1' color='#E5B729' font='PuristaSemiBold' align='center' letterSpacing='0.15'>%2</t>",
                        localize "STR_TUE_Intro_Title_1",
                        localize "STR_TUE_Intro_Title_2"
                    ],
                    "PLAIN", 1, true, true
                ];
            };

            sleep 6;
            titleText ["", "PLAIN", 0.5];
            sleep 0.5;

            [] spawn {
                private _year = date select 0;
                private _month = date select 1;
                private _day = date select 2;
                private _hour = date select 3;
                private _minute = date select 4;
                private _dayStr = if (_day < 10) then { "0" + str _day } else { str _day };
                private _monthNames = ["JAN", "FEB", "MAR", "APR", "MAY", "JUN", "JUL", "AUG", "SEP", "OCT", "NOV", "DEC"];
                private _monthStr = _monthNames select ((_month - 1) max 0 min 11);
                private _timeStr = format ["%1:%2", if (_hour < 10) then { "0" + str _hour } else { str _hour }, if (_minute < 10) then { "0" + str _minute } else { str _minute }];
                private _fullText = format ["%1 %2 %3 — %4", _dayStr, _monthStr, _year, _timeStr];
                private _p2chars = toArray _fullText;
                private _p2built = "";
                {
                    if (missionNamespace getVariable ["MISSION_intro_skip", false]) exitWith {};
                    _p2built = _p2built + toString [_x];
                    [
                        format ["<t size='0.95' color='#cbd5e1' font='PuristaLight' align='center' shadow='2'>%1</t>", _p2built],
                        -1, safeZoneY + (safeZoneH * 0.60), 4, 0, 0, 793
                    ] spawn BIS_fnc_dynamicText;
                    if (_x != 32) then { playSound "readoutClick"; };
                    sleep 0.08;
                } forEach _p2chars;
                sleep 2;
                ["", -1, safeZoneY + (safeZoneH * 0.60), 0.5, 0.3, 0, 793] spawn BIS_fnc_dynamicText;
            };

            sleep 5.5;

            if !(call _skipped) then {
                cutText ["", "BLACK FADED", 0.3];
                sleep 0.3;

                _ppColor ppEffectAdjust [1, 1.0, -0.05, [0.15, 0.15, 0.2, 0.0], [0.85, 0.85, 0.9, 0.65], [0.1, 0.1, 0.15, 0]];
                _ppColor ppEffectCommit 1;
                _ppGrain ppEffectAdjust [0.04, 0.7, 0.8, 0.04, 0.8, false];
                _ppGrain ppEffectCommit 1;

                private _p2A = [
                    (_lzPos select 0) + 900 * sin (_dirToHeli - 35),
                    (_lzPos select 1) + 900 * cos (_dirToHeli - 35),
                    35
                ];
                private _p2B = [
                    (_lzPos select 0) + 600 * sin (_dirToHeli - 25),
                    (_lzPos select 1) + 600 * cos (_dirToHeli - 25),
                    25
                ];

                _cam camSetPos _p2A;
                _cam camSetTarget _heli;
                _cam camSetFov 0.50;
                _cam camCommit 0;

                _cam camSetPos _p2B;
                _cam camSetTarget _heli;
                _cam camCommit 10;

                cutText ["", "BLACK IN", 0.6];
                sleep 0.6;

                [localize "STR_TUE_Intro_Sender", localize "STR_TUE_Intro_Plan2_Radio", 7.0, 0.3] call _fnShowRadio;

                [8, false] call _fnWaitPhase;
            };

            if !(call _skipped) then {
                cutText ["", "BLACK FADED", 0.3];
                sleep 0.3;

                private _p3A = [
                    (_lzPos select 0) + 550 * sin (_dirToHeli + 40),
                    (_lzPos select 1) + 550 * cos (_dirToHeli + 40),
                    22
                ];
                private _p3B = [
                    (_lzPos select 0) + 500 * sin (_dirToHeli + 20),
                    (_lzPos select 1) + 500 * cos (_dirToHeli + 20),
                    16
                ];

                _cam camSetPos _p3A;
                _cam camSetTarget _heli;
                _cam camSetFov 0.65;
                _cam camCommit 0;

                _cam camSetPos _p3B;
                _cam camSetTarget _heli;
                _cam camCommit 9;

                cutText ["", "BLACK IN", 0.6];
                sleep 0.6;

                [localize "STR_TUE_Intro_Sender", localize "STR_TUE_Intro_Plan4_Radio", 6.5, 0.3] call _fnShowRadio;

                [7.5, false] call _fnWaitPhase;
            };

            if !(call _skipped) then {
                cutText ["", "BLACK FADED", 0.3];
                sleep 0.3;

                if (!isNull _cam) then {
                    _cam cameraEffect ["TERMINATE", "BACK"];
                    camDestroy _cam;
                };
                camUseNVG false;
                if (!isNil "_ppColor") then { ppEffectDestroy _ppColor; };
                if (!isNil "_ppGrain") then { ppEffectDestroy _ppGrain; };

                player switchCamera "INTERNAL";
                showCinemaBorder false;
                showHUD [false, false, false, false, false, false, false, false, false, false, false];

                if (sunOrMoon < 0.4) then {
                    if (hmd player == "") then { player linkItem "NVGoggles"; };
                    if (currentVisionMode player == 0) then { player action ["NVGoggles", player]; };
                };

                cutText ["", "BLACK IN", 0.6];
                sleep 0.6;

                [localize "STR_TUE_Intro_Sender", localize "STR_TUE_Intro_Plan5_Radio", 6.5, 0.3] call _fnShowRadio;

                private _plan4EndTime = time + 6.5;
                waitUntil {
                    sleep 0.05;
                    ((missionNamespace getVariable ["MISSION_players_disembarked", false]) && (time > _plan4EndTime))
                    || (vehicle player == player && (time > _plan4EndTime))
                    || (call _skipped)
                };
            };
        } else {
            _cam camSetPos [(_lzPos select 0) + 60, (_lzPos select 1) + 60, 20];
            _cam camSetTarget _lzPos;
            _cam camSetFov 0.65;
            _cam camCommit 0;

            cutText ["", "BLACK IN", 3];

            _cam camSetPos [(_lzPos select 0) + 30, (_lzPos select 1) + 30, 14];
            _cam camCommit 14;
            [14, false] call _fnWaitPhase;

            [20, true] call _fnWaitPhase;
        };

        if (call _skipped) then {
            cutText ["", "BLACK FADED", 0];
            sleep 0.5;
        };

        if (!isNull _cam) then {
            _cam cameraEffect ["TERMINATE", "BACK"];
            camDestroy _cam;
        };
        camUseNVG false;
        if (!isNil "_ppColor") then { ppEffectDestroy _ppColor; };
        if (!isNil "_ppGrain") then { ppEffectDestroy _ppGrain; };

        player switchCamera "INTERNAL";
        showCinemaBorder false;
        showHUD [true, true, true, true, true, true, true, true, true, true, true];
        player allowDamage true;

        if (sunOrMoon < 0.4) then {
            if (hmd player == "") then { player linkItem "NVGoggles"; };
            if (currentVisionMode player == 0) then { player action ["NVGoggles", player]; };
        };

        private _d46 = findDisplay 46;
        if (!isNull _d46) then {
            if (_skipHandleDn != -1) then { _d46 displayRemoveEventHandler ["KeyDown", _skipHandleDn]; };
            if (_skipHandleUp != -1) then { _d46 displayRemoveEventHandler ["KeyUp", _skipHandleUp]; };
        };

        if (call _skipped) then {
            cutText ["", "BLACK IN", 1.5];
        };

        missionNamespace setVariable ["MISSION_intro_finished", true, true];
    };
};

if (isServer) then {
    if (missionNamespace getVariable ["MISSION_intro_sv", false]) exitWith {};
    missionNamespace setVariable ["MISSION_intro_sv", true];

    [] spawn {
        private _initialWait = time + 30;
        waitUntil { count allPlayers > 0 || time > _initialWait };

        if (isMultiplayer) then {
            private _syncTimeout = time + 35;
            waitUntil {
                sleep 0.5;
                private _players = allPlayers;
                (count _players > 0 && { { !(_x getVariable ["TUE_player_ready", false]) } count _players == 0 })
                || (time > _syncTimeout && count _players > 0)
            };
            sleep 10;
        } else {
            sleep 0.5;
        };

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
            if (alive _x && !(_x in _allUnitsToBoard)) then { _allUnitsToBoard pushBack _x; };
        } forEach playableUnits;

        {
            _x moveInCargo _heli;
            if (vehicle _x == _x) then { _x moveInAny _heli; };
            _x assignAsCargo _heli;
        } forEach _allUnitsToBoard;

        _heli lockCargo true;

        sleep 0.5;

        MISSION_intro_start = true;
        publicVariable "MISSION_intro_start";

        _heli doMove _destPos;
        _heli flyInHeight 150;
        _heli limitSpeed 160;

        sleep 18;

        [_heli, ["doorLB", 1]] remoteExec ["animateDoor", 0, _heli];
        [_heli, ["doorRB", 1]] remoteExec ["animateDoor", 0, _heli];

        sleep 8;

        _heli limitSpeed 100;

        private _landTimeout = time + 120;
        waitUntil { (_heli distance2D _destPos) < 250 || time > _landTimeout || (missionNamespace getVariable ["MISSION_intro_skip", false]) };
        _heli land "GET OUT";

        private _touchTimeout = time + 60;
        waitUntil { (getPosATL _heli select 2) < 2 || isTouchingGround _heli || time > _touchTimeout || (missionNamespace getVariable ["MISSION_intro_skip", false]) };
        sleep 1.5;

        _heli lockCargo false;

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

        missionNamespace setVariable ["MISSION_players_disembarked", true, true];

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
