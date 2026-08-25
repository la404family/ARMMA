params [["_mode", "init", [""]], ["_args", [], [[]]]];

if (!isServer) exitWith {};

if (_mode == "init") exitWith {
    private _heliports = allMissionObjects "HeliH";
    { _heliports pushBackUnique _x; } forEach (allMissionObjects "Land_HelipadEmpty_F");
    { _heliports pushBackUnique _x; } forEach (allMissionObjects "HeliHSquare_F");
    private _allLogics = _heliports;

    if (count _allLogics < 1) exitWith {
        missionNamespace setVariable ["LL_g_taskInProgress", false, true];
    };

    private _numTrucks = 2 + floor(random 2); 
    private _selectedLogics = [];
    private _alivePlayers = allPlayers select { alive _x };
    private _logicsPool = _allLogics call BIS_fnc_arrayShuffle;
    private _minDistPlayers = 400;
    private _maxDist = 450;

    while { count _selectedLogics < _numTrucks && _maxDist <= 15000 } do {
        _selectedLogics = [];
        {
            private _candidate = _x;
            private _candidatePos = getPosASL _candidate;
            private _valid = true;
            { private _d = _x distance2D _candidatePos; if (_d < _minDistPlayers || _d > _maxDist) exitWith { _valid = false; }; } forEach _alivePlayers;
            { if (_x distance2D _candidatePos < 250) exitWith { _valid = false; }; } forEach _selectedLogics;
            if (_valid) then { _selectedLogics pushBack _candidate; };
            if (count _selectedLogics == _numTrucks) exitWith {};
        } forEach _logicsPool;

        if (count _selectedLogics < _numTrucks) then { _maxDist = _maxDist + 50; };
    };

    if (count _selectedLogics < 1) exitWith {
        [[], "LL_fnc_task04"] spawn { sleep 15; ["init"] spawn LL_fnc_task04; };
    };

    missionNamespace setVariable ["LL_Task04_RemainingTrucks", [], true];
    missionNamespace setVariable ["LL_Task04_AllUnits", [], true];
    missionNamespace setVariable ["LL_Task04_Failed", false, true];

    private _allTrucks = [];
    private _allUnits = [];

    {
        private _selectedLogic = _x;
        private _spawnPos = getPosASL _selectedLogic;
        _spawnPos set [2, (_spawnPos select 2) + 0.2];

        private _numPatrols = 4 + floor (random 3);
        private _step = (475 - 15) / (_numPatrols - 1 max 1);

        for "_p" from 0 to (_numPatrols - 1) do {
            private _radius = round (15 + (_p * _step) + (random 20 - 10)) max 15 min 475;
            private _grp = createGroup [east, true];
            _grp setBehaviour "SAFE";
            _grp setCombatMode "RED";

            private _numGuards = 2 + floor (random 3);
            for "_g" from 1 to _numGuards do {
                sleep 1.5;
                private _guardClass = "O_Soldier_F";
                private _guard = _grp createUnit [_guardClass, _spawnPos, [], 0, "NONE"];
                _guard setPosASL _spawnPos;
                _guard allowDamage false;
                [_guard] spawn { sleep 3; (_this select 0) allowDamage true; };
                [_guard] call TUE_fnc_applyEnemyEquipment;
                _allUnits pushBack _guard;
            };

            [_grp, _spawnPos, _radius] call BIS_fnc_taskPatrol;
        };

        sleep 1.5;
        private _truckClasses = ["O_Truck_02_fuel_F", "O_Truck_03_fuel_F", "I_Truck_02_fuel_F"];
        private _truck = createVehicle [selectRandom _truckClasses, _spawnPos, [], 0, "CAN_COLLIDE"];
        _truck setPosASL _spawnPos;
        _truck setDir (random 360);

        _truck setFuel 0;

        clearWeaponCargoGlobal _truck;
        clearItemCargoGlobal _truck;
        clearMagazineCargoGlobal _truck;
        clearBackpackCargoGlobal _truck;

        _allTrucks pushBack _truck;
        _allUnits pushBack _truck;

        _truck addEventHandler ["HandleDamage", {
            params ["_unit", "_selection", "_damage", "_source", "_projectile", "_hitPartIndex", "_instigator", "_hitPoint"];
            if (!alive _unit) exitWith { 0 };

            private _partDmg = if (_selection != "") then { _unit getHit _selection } else { damage _unit };
            if (isNil "_partDmg") then { _partDmg = damage _unit; };

            private _delta = _damage - _partDmg;
            if (_delta <= 0) exitWith { _partDmg };

            private _rawDmg = (_unit getVariable ["LL_Raw_Damage", 0]) + _delta;
            _unit setVariable ["LL_Raw_Damage", _rawDmg];

            private _newDmg = 0;
            if (_rawDmg >= 0.36) then {
                _newDmg = 0.50;
            } else {
                if (_rawDmg >= 0.16) then {
                    _newDmg = 0.35;
                } else {
                    if (_rawDmg >= 0.01) then {
                        _newDmg = 0.15;
                    } else {
                        _newDmg = _rawDmg;
                    };
                };
            };

            if (_newDmg >= 0.50) then {
                _newDmg = 1;
            };

            private _level = if (_newDmg >= 0.35) then { 6 } else { if (_newDmg >= 0.15) then { 3 } else { 0 } };
            if (_level >= 1) then {
                _unit setVariable ["LL_Toxic_Level", _level max (_unit getVariable ["LL_Toxic_Level", 0]), true];
                private _emitter = _unit getVariable ["LL_Toxic_Smoke1", objNull];
                if (isNull _emitter) then {
                    _emitter = "#particlesource" createVehicle (getPos _unit);
                    _unit setVariable ["LL_Toxic_Smoke1", _emitter];

                    [_unit] spawn {
                        params ["_truck"];
                        private _startTime = time;
                        while { alive _truck && !isNull (_truck getVariable ["LL_Toxic_Smoke1", objNull]) } do {
                            private _elapsed = time - _startTime;
                            private _emitter = _truck getVariable ["LL_Toxic_Smoke1", objNull];

                            if (_elapsed >= 600) exitWith {
                                if (!isNull _emitter) then { deleteVehicle _emitter; };
                                _truck setVariable ["LL_Toxic_Smoke1", objNull];
                            };

                            private _timeFactor = (1 - (_elapsed / 600)) max 0;
                            private _lvl = _truck getVariable ["LL_Toxic_Level", 0];

                            if (_lvl >= 1 && !isNull _emitter) then {
                                private _radius = (4 + (_lvl * 0.8)) * _timeFactor;
                                private _dmg = (0.0015 * _lvl) * _timeFactor;

                                {
                                    if (alive _x && _x distance2D _truck < _radius) then {
                                        _x setDamage ((damage _x) + _dmg);
                                    };
                                } forEach allUnits;

                                private _dropInterval = (0.35 / _lvl) / (_timeFactor max 0.05);
                                _emitter setDropInterval _dropInterval;

                                private _sizeMultiplier = (1 + (_lvl * 0.15)) * _timeFactor;
                                _emitter setParticleParams [
                                     ["\A3\data_f\ParticleEffects\Universal\Universal", 16, 7, 48, 1], "", "Billboard", 1, 12,
                                     [0, 0, 0.2], [0, 0, 0.3], 0, 1.28, 1, 0.05, [1.5 * _sizeMultiplier, 3 * _sizeMultiplier, 5 * _sizeMultiplier],
                                     [[0.9, 0.85, 0.1, 0.25 * _timeFactor], [0.8, 0.75, 0.08, 0.15 * _timeFactor], [0.6, 0.55, 0.05, 0]], [0.125], 1, 0, "", "", _truck
                                ];
                                _emitter setParticleRandom [3, [2, 2, 0.2], [0.8, 0.8, 0.3], 1, 0.3, [0, 0, 0, 0.05], 0, 0];
                            };
                            sleep 1;
                        };
                    };
                };
            };

            if (_selection == "") then {
                _unit setDamage _newDmg;
            } else {
                _unit setHitPointDamage [_hitPoint, _newDmg];
            };

            _newDmg
        }];

        _truck setHitPointDamage ["HitEngine", 1];

        _truck addEventHandler ["Killed", {
            params ["_unit"];
            if (missionNamespace getVariable ["LL_Task04_Failed", false]) exitWith {};
            missionNamespace setVariable ["LL_Task04_Failed", true, true];

            ["task_04_convoy", "FAILED", true] call BIS_fnc_taskSetState;
            missionNamespace setVariable ["LL_g_taskInProgress", false, true];

            private _remaining = missionNamespace getVariable ["LL_Task04_RemainingTrucks", []];
            {
                private _mkr = _x getVariable ["LL_Task04_Marker", ""];
                if (_mkr != "") then { deleteMarker _mkr; };
            } forEach _remaining;

            {
                private _t = _x;
                if (!isNull _t && _t != _unit) then {
                    [_t] spawn {
                        params ["_t"];
                        waitUntil {
                            sleep 5;
                            isNull _t || !alive _t || ({ _x distance2D _t <= 800 } count (allPlayers select { alive _x })) == 0
                        };
                        if (!isNull _t) then {
                            private _emitter = _t getVariable ["LL_Toxic_Smoke1", objNull];
                            if (!isNull _emitter) then { deleteVehicle _emitter; };
                            deleteVehicle _t;
                        };
                    };
                };
            } forEach _remaining;

            private _posATL = getPosATL _unit;
            private _posASL = getPosASL _unit;

            [_posATL, 80, 8, [0.9, 0.85, 0.1, 0.8]] remoteExec ["LL_fnc_createSmokeRing", 0];

            [_posASL] spawn {
                params ["_pos"];
                private _maxRadius = 80;
                private _duration = 8;
                private _startTime = time;
                private _damagedUnits = [];

                while { (time - _startTime) < _duration } do {
                    private _progress = (time - _startTime) / _duration;
                    private _currentRadius = _maxRadius * _progress;

                    {
                        if (alive _x && !(_x in _damagedUnits)) then {
                            private _dist = _x distance _pos;
                            if (_dist <= _currentRadius) then {
                                _damagedUnits pushBack _x;
                                private _damageFactor = 1 - (_dist / _maxRadius);
                                if (_damageFactor > 0) then {

                                    private _dmg = 1.2 * _damageFactor;
                                    _x setDamage (damage _x + _dmg);

                                    if (_x isKindOf "Man") then {
                                        private _dir = _pos vectorFromTo (getPosASL _x);
                                        _dir set [2, 0.15]; 
                                        private _vel = velocity _x;
                                        _x setVelocity (_vel vectorAdd (_dir vectorMultiply (15 * _damageFactor)));
                                    };
                                };
                            };
                        };
                    } forEach (allUnits select { alive _x });

                    sleep 0.05;
                };
            };

            private _allUnits = missionNamespace getVariable ["LL_Task04_AllUnits", []];
            private _guards = _allUnits select { alive _x && _x isKindOf "Man" };
            [_guards] spawn LL_fnc_taskCleanup;
        }];

        private _idx = count _allTrucks;
        private _mkrName = format ["mkr_task04_truck_%1", _idx];
        createMarker [_mkrName, getPosASL _truck];
        _mkrName setMarkerType "mil_objective";
        _mkrName setMarkerColor "ColorOrange";
        _mkrName setMarkerText (format ["%1 (%2/%3)", localize "STR_LL_Task_04_MarkerMain", _idx, _numTrucks]);

        _truck setVariable ["LL_Task04_Marker", _mkrName, true];

        private _varName = format ["LL_Task04_Truck_%1_%2", _idx, round(random 100000)];
        _truck setVehicleVarName _varName;
        missionNamespace setVariable [_varName, _truck, true];

        [_truck, netId _truck, _varName] remoteExec ["LL_fnc_task04_addAction", 0, true];

    } forEach _selectedLogics;

    missionNamespace setVariable ["LL_Task04_RemainingTrucks", _allTrucks, true];
    missionNamespace setVariable ["LL_Task04_AllUnits", _allUnits, true];

    [
        independent,
        ["task_04_convoy"],
        [
            localize "STR_LL_Task_04_Desc",
            localize "STR_LL_Task_04_Title",
            ""
        ],
        objNull,
        "AUTOASSIGNED",
        5,
        true,
        "danger",
        false
    ] call BIS_fnc_taskCreate;

    [[], { player createDiaryRecord ["diary", [localize "STR_LL_Diary_Task04_Title", localize "STR_LL_Diary_Task04_Text"]]; }] remoteExec ["spawn", 0, true];
};

if (_mode == "extract") exitWith {
    _args params ["_truck", "_caller"];

    if (!alive _truck) exitWith {};

    [_truck] spawn {
        params ["_cargo"];

        private _spawnPosHeli = (getPosATL _cargo) getPos [1500, random 360];
        if (_spawnPosHeli select 0 < 50 || { _spawnPosHeli select 0 > (worldSize - 50) || { _spawnPosHeli select 1 < 50 || { _spawnPosHeli select 1 > (worldSize - 50) } } }) then {
            _spawnPosHeli = [15, 15, 250];
        } else {
            _spawnPosHeli set [2, 250];
        };

        private _dropPos = _spawnPosHeli getPos [1500, random 360];
        if (_dropPos select 0 < 50 || { _dropPos select 0 > (worldSize - 50) || { _dropPos select 1 < 50 || { _dropPos select 1 > (worldSize - 50) } } }) then {
            _dropPos = [worldSize - 50, worldSize - 50, 150];
        } else {
            _dropPos set [2, 150];
        };

        private _grp = createGroup [independent, true];
        private _heli = createVehicle ["B_Heli_Transport_03_F", _spawnPosHeli, [], 0, "FLY"];
        _heli setPosATL _spawnPosHeli;

        private _pilot = _grp createUnit ["B_Helipilot_F", _spawnPosHeli, [], 0, "NONE"];
        _pilot moveInDriver _heli;
        private _copilot = _grp createUnit ["B_Helipilot_F", _spawnPosHeli, [], 0, "NONE"];
        _copilot moveInTurret [_heli, [0]];
        private _gunner1 = _grp createUnit ["B_Helipilot_F", _spawnPosHeli, [], 0, "NONE"];
        _gunner1 moveInTurret [_heli, [1]];
        private _gunner2 = _grp createUnit ["B_Helipilot_F", _spawnPosHeli, [], 0, "NONE"];
        _gunner2 moveInTurret [_heli, [2]];

        private _crew = [_pilot, _copilot, _gunner1, _gunner2];
        { _x allowDamage false; } forEach _crew;
        _heli allowDamage false;

        _grp setBehaviour "CARELESS";
        _grp setCombatMode "BLUE";

        {
            _x disableAI "FSM";
            _x disableAI "TARGET";
            _x disableAI "AUTOTARGET";
            _x disableAI "AUTOCOMBAT";
            _x disableAI "CHECKVISIBLE";
            _x disableAI "COVER";
        } forEach _crew;

        _heli disableCollisionWith _cargo;
        _cargo disableCollisionWith _heli;

        while { count (waypoints _grp) > 0 } do { deleteWaypoint [_grp, 0]; };

        private _targetPos = getPos _cargo;
        _heli flyInHeight 40;

        private _wp = _grp addWaypoint [_targetPos, 0];
        _wp setWaypointType "MOVE";
        _wp setWaypointBehaviour "CARELESS";
        _wp setWaypointSpeed "FULL";
        _heli doMove _targetPos;

        private _apTimer = 0;
        waitUntil {
            sleep 0.5;
            _apTimer = _apTimer + 0.5;
            (_heli distance2D _targetPos < 120) || _apTimer > 120 || !alive _heli || !alive _cargo
        };

        if (!alive _heli || !alive _cargo) exitWith {};

        private _nearEnemies = allUnits select { side group _x == east && alive _x && (_x distance2D _targetPos < 500) };

        if (count _nearEnemies > 0) then {
            _heli flyInHeight 30;
            _heli limitSpeed 90;
            _heli setVehicleAmmo 1;

            private _wpCombat = _grp addWaypoint [_targetPos, 0];
            _wpCombat setWaypointType "LOITER";
            _wpCombat setWaypointLoiterRadius 130;
            _wpCombat setWaypointLoiterType "CIRCLE_L";
            _wpCombat setWaypointSpeed "LIMITED";

            _grp setBehaviour "AWARE";
            _grp setCombatMode "RED";

            _pilot setBehaviour "CARELESS";
            _pilot disableAI "AUTOCOMBAT";
            _pilot disableAI "TARGET";
            _pilot disableAI "AUTOTARGET";
            _pilot disableAI "FSM";

            private _gunners = _crew select { _x != _pilot };

            {
                _x setBehaviour "COMBAT";
                _x setCombatMode "RED";
                _x enableAI "TARGET";
                _x enableAI "AUTOTARGET";
                _x enableAI "AUTOCOMBAT";
                _x enableAI "FSM";
                _x enableAI "WEAPONAIM";
                _x enableAI "CHECKVISIBLE";
                _x setSkill ["aimingAccuracy", 0.95];
                _x setSkill ["aimingSpeed", 1.0];
                _x setSkill ["aimingShake", 0.05];
                _x setSkill ["spotDistance", 1.0];
                _x setSkill ["spotTime", 1.0];
                _x setSkill ["courage", 1.0];
                _x setSkill ["commanding", 1.0];
                _x setSkill ["general", 1.0];
            } forEach _gunners;

            private _combatTimer = 0;
            while { _combatTimer < 65 && alive _heli && alive _cargo } do {
                private _enemies = allUnits select { side group _x == east && alive _x && (_x distance2D _targetPos < 500 || _x distance2D _heli < 500) };
                if (count _enemies == 0) exitWith {};

                _heli setVehicleAmmo 1;

                {
                    _heli reveal [_x, 4];
                    private _e = _x;
                    { _x reveal [_e, 4]; } forEach _gunners;
                } forEach _enemies;

                {
                    private _gunner = _x;
                    private _turret = _heli unitTurret _gunner;
                    private _bestTarget = objNull;
                    private _minD = 99999;

                    {
                        private _relDir = _heli getRelDir _x;
                        private _validArc = true;
                        if (_turret isEqualTo [1]) then {
                            _validArc = (_relDir >= 180 && _relDir <= 355);
                        };
                        if (_turret isEqualTo [2]) then {
                            _validArc = (_relDir >= 5 && _relDir <= 180);
                        };
                        if (_validArc) then {
                            private _d = _gunner distance2D _x;
                            if (_d < _minD) then {
                                _minD = _d;
                                _bestTarget = _x;
                            };
                        };
                    } forEach _enemies;

                    if (isNull _bestTarget && count _enemies > 0) then {
                        _bestTarget = _enemies select 0;
                    };

                    if (!isNull _bestTarget) then {
                        _gunner doWatch (getPosATL _bestTarget);
                        _gunner doTarget _bestTarget;
                        _gunner doFire _bestTarget;
                        _gunner doSuppressiveFire _bestTarget;
                    };
                } forEach _gunners;

                sleep 2;
                _combatTimer = _combatTimer + 2;
            };

            while { count (waypoints _grp) > 0 } do { deleteWaypoint [_grp, 0]; };
        };

        _grp setBehaviour "CARELESS";
        _grp setCombatMode "BLUE";

        {
            _x disableAI "FSM";
            _x disableAI "TARGET";
            _x disableAI "AUTOTARGET";
            _x disableAI "AUTOCOMBAT";
            _x disableAI "CHECKVISIBLE";
            _x disableAI "COVER";
        } forEach _crew;

        private _hoverHeight = 15;
        _heli flyInHeight _hoverHeight;
        private _cargoASL = (getPosASL _cargo) select 2;
        _heli flyInHeightASL [_cargoASL + _hoverHeight, _cargoASL + _hoverHeight, _cargoASL + _hoverHeight];

        private _wpHov = _grp addWaypoint [_targetPos, 0];
        _wpHov setWaypointType "MOVE";
        _wpHov setWaypointBehaviour "CARELESS";
        _wpHov setWaypointSpeed "FULL";
        _heli doMove _targetPos;

        private _hoverTimer = 0;
        waitUntil {
            sleep 0.5;
            _hoverTimer = _hoverTimer + 0.5;
            (_heli distance2D _targetPos < 15) || _hoverTimer > 40 || !alive _heli || !alive _cargo
        };

        while { count (waypoints _grp) > 0 } do { deleteWaypoint [_grp, 0]; };

        if (!alive _heli || !alive _cargo) exitWith {};

        doStop _heli;

        private _minH = 9.5;
        private _heliThresh = 10;
        private _descTimer = 0;

        waitUntil {
            sleep 0.5;
            _descTimer = _descTimer + 0.5;
            private _newH = (_hoverHeight - _descTimer) max _minH;
            _heli flyInHeight _newH;

            private _targetASL = _cargoASL + _newH;
            _heli flyInHeightASL [_targetASL, _targetASL, _targetASL];

            private _heliH = getPosATL _heli select 2;
            _heliH < _heliThresh || _descTimer > 30 || !alive _heli || !alive _cargo
        };

        if (!alive _heli || !alive _cargo) exitWith {};

        _cargo allowDamage false;
        _cargo setMass 1;

        private _attachedWithRopes = false;
        private _ropes = [];

        _heli setSlingLoad _cargo;
        sleep 2;

        if (isNull (getSlingLoad _heli)) then {
            _attachedWithRopes = true;
            _cargo attachTo [_heli, [0, 0, -9]];
            _cargo setVectorUp [0, 0, 1];

            private _r1 = ropeCreate [_heli, [-1.5, 0, -1], _cargo, [-1.2, 2.5, 1.2], 9];
            private _r2 = ropeCreate [_heli, [1.5, 0, -1], _cargo, [1.2, 2.5, 1.2], 9];
            private _r3 = ropeCreate [_heli, [-1.5, 0, -1], _cargo, [-1.2, -2.5, 1.2], 9];
            private _r4 = ropeCreate [_heli, [1.5, 0, -1], _cargo, [1.2, -2.5, 1.2], 9];
            _ropes = [_r1, _r2, _r3, _r4];
        };

        _cargo removeAllEventHandlers "Killed";
        _cargo removeAllEventHandlers "HandleDamage";

        _heli flyInHeight 60;
        private _escapeASL = _cargoASL + 60;
        _heli flyInHeightASL [_escapeASL, _escapeASL, _escapeASL];
        _heli limitSpeed 100;

        private _wp2 = _grp addWaypoint [_dropPos, 0];
        _wp2 setWaypointType "MOVE";
        _wp2 setWaypointSpeed "NORMAL";
        _heli doMove _dropPos;

        private _remaining = missionNamespace getVariable ["LL_Task04_RemainingTrucks", []];
        _remaining = _remaining - [_cargo];
        missionNamespace setVariable ["LL_Task04_RemainingTrucks", _remaining, true];

        private _mkr = _cargo getVariable ["LL_Task04_Marker", ""];
        if (_mkr != "") then { deleteMarker _mkr; };

        if (count _remaining == 0) then {
            ["task_04_convoy", "SUCCEEDED", true] call BIS_fnc_taskSetState;
            missionNamespace setVariable ["LL_g_taskInProgress", false, true];
        };

        waitUntil { sleep 1; (_heli distance2D _dropPos < 200) || !alive _heli };

        if (_attachedWithRopes) then {
            detach _cargo;
            { ropeDestroy _x; } forEach _ropes;
        } else {
            _heli setSlingLoad objNull;
        };

        sleep 2;

        waitUntil {
            sleep 1;
            private _players = allPlayers select { alive _x };
            ({ _x distance2D _cargo <= 800 } count _players) == 0
        };
        deleteVehicle _cargo;

        sleep 5;
        { deleteVehicle _x; } forEach crew _heli;
        deleteVehicle _heli;
        deleteGroup _grp;
    };
};
