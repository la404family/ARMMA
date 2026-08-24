params [["_taskPos", [0,0,0], [[]]]];

if (!isServer) exitWith {};

if (missionNamespace getVariable ["LL_g_extractionActive", false]) exitWith {};
missionNamespace setVariable ["LL_g_extractionActive", true, true];

if (_taskPos isEqualTo [0,0,0]) then {
    private _players = allPlayers select { alive _x };
    if (count _players > 0) then {
        _taskPos = getPosATL (_players select 0);
    } else {
        _taskPos = getPosATL player;
    };
};

private _heliports = allMissionObjects "HeliH";
{ _heliports pushBackUnique _x; } forEach (allMissionObjects "Land_HelipadEmpty_F");
{ _heliports pushBackUnique _x; } forEach (allMissionObjects "HeliHSquare_F");

private _closestLZ = objNull;
private _minDist = 99999;
{
    private _d = _x distance2D _taskPos;
    if (_d < _minDist) then {
        _minDist = _d;
        _closestLZ = _x;
    };
} forEach _heliports;

private _lzPos = if (!isNull _closestLZ) then { getPos _closestLZ } else { _taskPos };
_lzPos set [2, 0];

[
    independent,
    ["task_extraction"],
    [
        localize "STR_LL_Task_Extraction_Desc",
        localize "STR_LL_Task_Extraction_Title",
        localize "STR_LL_Task_Extraction_Marker"
    ],
    _lzPos,
    "ASSIGNED",
    1,
    true,
    "takeoff",
    false
] call BIS_fnc_taskCreate;

private _mkrLZ = createMarker ["mkr_extraction_lz", _lzPos];
_mkrLZ setMarkerType "hd_pickup";
_mkrLZ setMarkerColor "ColorGreen";
_mkrLZ setMarkerText "EXTRACTION";

private _heliClass = "B_Heli_Transport_01_F";
if (!isNil "heli_BLUFOR" && { !isNull heli_BLUFOR }) then {
    _heliClass = typeOf heli_BLUFOR;
};

private _startDir = random 360;
private _startPos = [
    (_lzPos select 0) + 2500 * sin _startDir,
    (_lzPos select 1) + 2500 * cos _startDir,
    200
];

private _heli = createVehicle [_heliClass, _startPos, [], 0, "FLY"];
_heli setPos _startPos;
_heli setDir (_startPos getDir _lzPos);
_heli flyInHeight 150;
_heli allowDamage false;

[_heli] spawn {
    params ["_heli"];
    private _mkrHeli = createMarker ["mkr_extraction_heli", getPos _heli];
    _mkrHeli setMarkerType "b_air";
    _mkrHeli setMarkerColor "ColorBlue";
    _mkrHeli setMarkerText "HELI";
    
    while { alive _heli && missionNamespace getVariable ["LL_g_extractionActive", false] } do {
        _mkrHeli setMarkerPos (getPos _heli);
        sleep 0.5;
    };
    deleteMarker _mkrHeli;
};

createVehicleCrew _heli;
private _crew = crew _heli;
{ _x allowDamage false; } forEach _crew;

private _grp = group driver _heli;
_grp setBehaviour "AWARE";
_grp setCombatMode "YELLOW";
driver _heli disableAI "TARGET";
driver _heli disableAI "AUTOTARGET";
driver _heli disableAI "AUTOCOMBAT";
driver _heli disableAI "FSM";
driver _heli disableAI "SUPPRESSION";
driver _heli setBehaviour "CARELESS";

_heli doMove _lzPos;
_heli flyInHeight 150;
_heli limitSpeed 250;

private _lzApproach = time + 300;
waitUntil { (_heli distance2D _lzPos) < 400 || time > _lzApproach };

[_heli, ["doorLB", 1]] remoteExec ["animateDoor", 0, _heli];
[_heli, ["doorRB", 1]] remoteExec ["animateDoor", 0, _heli];
_heli animateDoor ["doorLB", 1];
_heli animateDoor ["doorRB", 1];

_heli limitSpeed 120;
_heli land "GET IN";

waitUntil { isTouchingGround _heli || (getPosATL _heli select 2) < 2.5 };

_heli setFuel 0;
_heli setVelocity [0, 0, 0];
driver _heli disableAI "MOVE";
driver _heli disableAI "PATH";

{
    if (_x != driver _heli) then {
        _x setBehaviour "COMBAT";
        _x setCombatMode "RED";
        _x enableAI "AUTOTARGET";
        _x enableAI "TARGET";
        _x enableAI "WEAPONAIM";
        _x setSkill ["aimingAccuracy", 0.70];
        _x setSkill ["spotDistance", 1.0];
        _x setSkill ["spotTime", 1.0];
    };
} forEach (crew _heli);

private _allBoarded = false;
while { !_allBoarded } do {
    sleep 2;
    private _alivePlayers = allPlayers select { alive _x };
    if (count _alivePlayers == 0 && !isNull player) then { _alivePlayers = [player]; };
    
    private _teamUnits = [];
    {
        if (alive _x) then {
            _teamUnits append (units group _x);
        };
    } forEach _alivePlayers;
    
    private _uniqueTeam = _teamUnits arrayIntersect _teamUnits;
    _uniqueTeam = _uniqueTeam select { alive _x };

    {
        if (alive _x && vehicle _x != _heli) then {
            _x assignAsCargo _heli;
            [_x] orderGetIn true;
        };
    } forEach _uniqueTeam;

    private _nearEnemies = allUnits select { side group _x == east && alive _x && (_x distance2D _heli < 700) };
    {
        private _e = _x;
        { _x reveal [_e, 4]; } forEach (crew _heli);
    } forEach _nearEnemies;
    
    private _boardedCount = 0;
    {
        if (vehicle _x == _heli) then {
            _boardedCount = _boardedCount + 1;
            private _hostage = missionNamespace getVariable ["LL_Task00_Hostage", objNull];
            if (_x == _hostage && {group _x != group driver _heli}) then {
                [_x] joinSilent (group driver _heli);
                _x allowDamage false;
                _x disableAI "MOVE";
                _x disableAI "PATH";
                _x disableAI "FSM";
                _x disableAI "TARGET";
                _x disableAI "AUTOTARGET";
                _x disableAI "AUTOCOMBAT";
                _x setBehaviour "CARELESS";
                _x setCombatMode "BLUE";
                {
                    if (_x != driver _heli && _x != _hostage) then {
                        _x setBehaviour "COMBAT";
                        _x setCombatMode "RED";
                        _x enableAI "AUTOTARGET";
                        _x enableAI "TARGET";
                        _x enableAI "WEAPONAIM";
                    };
                } forEach (crew _heli);
            };
        };
    } forEach _uniqueTeam;

    if (_boardedCount >= count _uniqueTeam && count _uniqueTeam > 0) then {
        _allBoarded = true;
    };
};

sleep 2;

[_heli, ["doorLB", 0]] remoteExec ["animateDoor", 0, _heli];
[_heli, ["doorRB", 0]] remoteExec ["animateDoor", 0, _heli];
_heli animateDoor ["doorLB", 0];
_heli animateDoor ["doorRB", 0];

_heli setFuel 1;
_heli engineOn true;

driver _heli enableAI "MOVE";
driver _heli enableAI "PATH";
driver _heli enableAI "FSM";
driver _heli disableAI "AUTOCOMBAT";
driver _heli disableAI "SUPPRESSION";
driver _heli disableAI "TARGET";
driver _heli disableAI "AUTOTARGET";
driver _heli setBehaviour "CARELESS";

_heli land "NONE";
_heli flyInHeight 150;
_heli limitSpeed 300;

private _endDir = random 360;
private _endPos = [
    (_lzPos select 0) + 3000 * sin _endDir,
    (_lzPos select 1) + 3000 * cos _endDir,
    200
];

private _grpPilot = group driver _heli;
while { count waypoints _grpPilot > 0 } do { deleteWaypoint [_grpPilot, 0]; };
private _wp = _grpPilot addWaypoint [_endPos, 0];
_wp setWaypointType "MOVE";
_wp setWaypointSpeed "FULL";
_wp setWaypointBehaviour "CARELESS";
_wp setWaypointCombatMode "BLUE";
_heli doMove _endPos;

[_heli] spawn {
    params ["_heli"];
    sleep 3;
    if (alive _heli && isTouchingGround _heli) then {
        _heli engineOn true;
        _heli setVelocity [0, 0, 3];
    };
};

["task_extraction", "SUCCEEDED", true] call BIS_fnc_taskSetState;

private _tTimeout = time + 60;
waitUntil {
    sleep 1;
    (_heli distance2D _lzPos) > 1200 || time > _tTimeout
};

["End1", true, 5] remoteExec ["BIS_fnc_endMission", 0];
