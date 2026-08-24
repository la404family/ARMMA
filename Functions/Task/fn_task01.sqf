params [["_mode", "init", [""]], ["_args", [], [[]]]];

if (!isServer) exitWith {};

if (_mode == "init") exitWith {

    private _allLogics = allMissionObjects "Logic";
    if (count _allLogics == 0) exitWith {
        missionNamespace setVariable ["LL_g_taskInProgress", false, true];
    };

    private _targetNumSpawns = 2 + floor (random 3);
    private _selectedLogics = [];
    private _logicsPool = _allLogics call BIS_fnc_arrayShuffle;
    private _alivePlayers = allPlayers select { alive _x };
    private _minDistPlayers = 550;
    private _maxDist = 1500;

    while { count _selectedLogics < 2 && _maxDist <= 15000 } do {
        _selectedLogics = [];
        {
            private _candidate = _x;
            private _candidatePos = getPosASL _candidate;
            private _valid = true;

            { private _d = _x distance2D _candidatePos; if (_d < _minDistPlayers || _d > _maxDist) exitWith { _valid = false; }; } forEach _alivePlayers;

            if (_valid) then {
                { if ((getPosASL _x) distance2D _candidatePos < 250) exitWith { _valid = false; }; } forEach _selectedLogics;
            };

            if (_valid) then { _selectedLogics pushBack _candidate; };
            if (count _selectedLogics >= _targetNumSpawns) exitWith {};
        } forEach _logicsPool;

        if (count _selectedLogics < 2) then { _maxDist = _maxDist + 500; };
    };

    private _numSpawns = count _selectedLogics;

    if (_numSpawns < 2) exitWith {
        [[], "LL_fnc_task01"] spawn {
            sleep 15;
            ["init"] spawn LL_fnc_task01;
        };
    };

    missionNamespace setVariable ["LL_Task01_NumZones", _numSpawns, true];

    private _targetIndex = floor random _numSpawns;

    missionNamespace setVariable ["LL_Task01_AllUnits", [], true];

    for "_i" from 0 to (_numSpawns - 1) do {
        private _logic = _selectedLogics select _i;
        private _spawnPos = getPosASL _logic;
        _spawnPos set [2, (_spawnPos select 2) + 0.2];

        private _numPatrols = 3 + floor (random 3);
        private _patrolRadii = [15, 35, 55, 100, 150];
        private _zoneGuards = [];

        for "_p" from 0 to (_numPatrols - 1) do {
            private _radius = _patrolRadii select _p;
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
                _zoneGuards pushBack _guard;
            };

            [_grp, _spawnPos, _radius] call BIS_fnc_taskPatrol;
        };

        sleep 1.5;
        private _grpOfficer = createGroup [east, true];
        _grpOfficer setBehaviour "SAFE";
        _grpOfficer setCombatMode "RED";
        private _officer = _grpOfficer createUnit ["O_Officer_F", _spawnPos, [], 0, "NONE"];
        _officer setPosASL _spawnPos;
        _officer allowDamage false;
        [_officer] spawn { sleep 3; (_this select 0) allowDamage true; };
        [_officer] call TUE_fnc_applyEnemyEquipment;
        _officer setRank "COLONEL";
        [_grpOfficer, _spawnPos, 50] call BIS_fnc_taskPatrol;

        private _mkrName = format ["mkr_task01_target_%1", _i];
        createMarker [_mkrName, _spawnPos];
        _mkrName setMarkerType "mil_objective";
        _mkrName setMarkerColor "ColorOrange";
        _mkrName setMarkerText format ["%1 %2", localize "STR_LL_Task_01_Marker", _i + 1];

        private _allUnits = missionNamespace getVariable ["LL_Task01_AllUnits", []];
        _allUnits append _zoneGuards;
        _allUnits pushBack _officer;
        missionNamespace setVariable ["LL_Task01_AllUnits", _allUnits, true];

        _officer setVariable ["LL_Task01_Marker", _mkrName];

        if (_i == _targetIndex) then {
            _officer setVariable ["LL_hasDocuments", true, true];
        } else {
            _officer setVariable ["LL_hasDocuments", false, true];
        };

        _officer addEventHandler ["Killed", {
            params ["_unit", "_killer", "_instigator", "_useEffects"];

            private _mkr = _unit getVariable ["LL_Task01_Marker", ""];
            if (_mkr != "") then {
                deleteMarker _mkr;
            };

            if (_unit getVariable ["LL_hasDocuments", false]) then {
                private _pos = getPosATL _unit; 

                ["task_01_assassinat", _pos] call BIS_fnc_taskSetDestination;

                private _mkrDoc = createMarker ["mkr_task01_doc", _pos];
                _mkrDoc setMarkerType "mil_objective";
                _mkrDoc setMarkerColor "ColorYellow";
                _mkrDoc setMarkerText (localize "STR_LL_Task_01_MarkerDoc");

                private _varCorpse = format ["LL_Task01_Corpse_%1", round(random 100000)];
                _unit setVehicleVarName _varCorpse;
                missionNamespace setVariable [_varCorpse, _unit, true];

                [_unit, netId _unit, _varCorpse] remoteExec ["LL_fnc_task01_addAction", 0, true];

                private _alivePlayers = allPlayers select { alive _x };
                private _allTaskUnits = missionNamespace getVariable ["LL_Task01_AllUnits", []];
                private _guards = _allTaskUnits select { alive _x && _x != _unit };
                if (count _guards > 0 && count _alivePlayers > 0) then {
                    private _grpsProcessed = [];
                    {
                        private _guard = _x;
                        _guard setBehaviour "COMBAT";
                        _guard setCombatMode "RED";
                        _guard setSpeedMode "FULL";
                        { _guard reveal [_x, 4]; } forEach _alivePlayers;

                        private _grp = group _guard;
                        if !(_grp in _grpsProcessed) then {
                            _grpsProcessed pushBack _grp;
                            private _grpPos = getPosATL (leader _grp);
                            private _nearest = _alivePlayers select 0;
                            private _nearestDist = _nearest distance2D _grpPos;
                            { private _d = _x distance2D _grpPos; if (_d < _nearestDist) then { _nearestDist = _d; _nearest = _x; }; } forEach _alivePlayers;

                            while { count waypoints _grp > 0 } do { deleteWaypoint [_grp, 0]; };
                            private _wp = _grp addWaypoint [getPosATL _nearest, 10];
                            _wp setWaypointType "SAD";
                            _wp setWaypointSpeed "FULL";
                            _wp setWaypointBehaviour "COMBAT";
                        };
                    } forEach _guards;
                };
            };
        }];
    };

    [
        independent,
        ["task_01_assassinat"],
        [
            localize "STR_LL_Task_01_Desc",
            localize "STR_LL_Task_01_Title",
            localize "STR_LL_Task_01_Marker"
        ],
        objNull,
        "AUTOASSIGNED",
        5,
        true,
        "kill",
        false
    ] call BIS_fnc_taskCreate;

    [[], { player createDiaryRecord ["diary", [localize "STR_LL_Diary_Task01_Title", localize "STR_LL_Diary_Task01_Text"]]; }] remoteExec ["spawn", 0, true];
};

if (_mode == "collect") exitWith {
    _args params ["_corpse", ["_doc", objNull, [objNull]]];

    if (missionNamespace getVariable ["LL_Task01_Completed", false]) exitWith {};
    missionNamespace setVariable ["LL_Task01_Completed", true, true];

    if (!isNull _doc) then { deleteVehicle _doc; };

    ["task_01_assassinat", "SUCCEEDED", true] call BIS_fnc_taskSetState;
    missionNamespace setVariable ["LL_g_taskInProgress", false, true];
    deleteMarker "mkr_task01_doc";

    private _nz = missionNamespace getVariable ["LL_Task01_NumZones", 4];
    for "_i" from 0 to (_nz - 1) do {
        deleteMarker format ["mkr_task01_target_%1", _i];
    };

    private _allUnits = missionNamespace getVariable ["LL_Task01_AllUnits", []];
    private _alive = _allUnits select { alive _x };
    [_alive] spawn LL_fnc_taskCleanup;
};
