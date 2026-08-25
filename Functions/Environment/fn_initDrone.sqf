params ["_drone"];
if (!isServer) exitWith {};
if (isNil "_drone" || {isNull _drone}) exitWith {};

_drone allowDamage false;
_drone setCaptive true;

if (count crew _drone == 0) then {
    createVehicleCrew _drone;
};

private _grp = group _drone;
_grp setBehaviour "CARELESS";
_grp setCombatMode "BLUE";

_drone engineOn true;
while {(count (waypoints _grp)) > 0} do {
    deleteWaypoint ((waypoints _grp) select 0);
};

_drone flyInHeight 2;
private _wpInit = _grp addWaypoint [getPos _drone, 0];
_wpInit setWaypointType "HOLD";

[_drone, _grp] spawn {
    params ["_drone", "_grp"];

    waitUntil {
        sleep 0.5;
        missionNamespace getVariable ["MISSION_intro_finished", false]
    };

    sleep 1.5;

    private _squad = [];
    for "_i" from 0 to 3 do {
        private _u = missionNamespace getVariable [format["Player_%1", _i], objNull];
        if (!isNull _u && {alive _u}) then { _squad pushBack _u; };
    };

    if (_squad isEqualTo []) then {
        _squad = allPlayers select { alive _x };
    };

    _drone flyInHeight 3;

    {
        private _u = _x;
        if (alive _u && alive _drone) then {
            while {(count (waypoints _grp)) > 0} do { deleteWaypoint ((waypoints _grp) select 0); };
            private _wpMove = _grp addWaypoint [getPos _u, 0];
            _wpMove setWaypointType "MOVE";
            _wpMove setWaypointSpeed "NORMAL";

            for "_angle" from 0 to 360 step 90 do {
                if (!alive _u || !alive _drone) exitWith {};
                private _orbitPos = _u getPos [3.5, _angle];
                _drone doMove _orbitPos;
                sleep 1.5;
            };
        };
    } forEach _squad;

    _drone flyInHeight 12;

    [_drone] remoteExec ["TUE_fnc_droneRadar", 0, "DroneRadar_JIP"];

    private _leaderStoppedTime = 0;
    private _currentState = "NONE";

    while {alive _drone} do {
        sleep 2;

        private _squadNow = [];
        for "_i" from 0 to 3 do {
            private _u = missionNamespace getVariable [format["Player_%1", _i], objNull];
            if (!isNull _u && {alive _u}) then { _squadNow pushBack _u; };
        };

        private _leader = if (_squadNow isNotEqualTo []) then { leader group (_squadNow select 0) } else { objNull };

        if (!isNull _leader) then {
            if (speed _leader < 1) then {
                _leaderStoppedTime = _leaderStoppedTime + 2;
            } else {
                _leaderStoppedTime = 0;
            };

            private _leaderPos = getPos _leader;

            if (_leaderStoppedTime >= 12) then {
                if (_currentState != "HOLD") then {
                    _currentState = "HOLD";
                    while {(count (waypoints _grp)) > 0} do { deleteWaypoint ((waypoints _grp) select 0); };
                    private _wpH = _grp addWaypoint [_leaderPos, 0];
                    _wpH setWaypointType "HOLD";
                } else {
                    [_grp, 0] setWaypointPosition [_leaderPos, 0];
                };
            } else {
                if (_currentState != "LOITER") then {
                    _currentState = "LOITER";
                    while {(count (waypoints _grp)) > 0} do { deleteWaypoint ((waypoints _grp) select 0); };
                    private _wpL = _grp addWaypoint [_leaderPos, 0];
                    _wpL setWaypointType "LOITER";
                    _wpL setWaypointLoiterRadius 25;
                } else {
                    [_grp, 0] setWaypointPosition [_leaderPos, 0];
                };
            };
        };
    };
};
