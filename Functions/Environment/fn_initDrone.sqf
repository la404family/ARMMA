params ["_drone"];
if (!isServer) exitWith {};
if (isNil "_drone" || {isNull _drone}) exitWith {};

_drone allowDamage false;
_drone setCaptive true;

waitUntil {
    sleep 1;
    private _f = false;
    {
        if (isPlayer _x && {(_x distance _drone) < 12}) exitWith { _f = true; };
    } forEach allPlayers;
    _f
};

if (count crew _drone == 0) then {
    createVehicleCrew _drone;
};

[_drone] spawn {
    params ["_drone"];
    private _grp = group _drone;
    
    _drone engineOn true;
    while {(count (waypoints _grp)) > 0} do {
        deleteWaypoint ((waypoints _grp) select 0);
    };
    
    _drone flyInHeight 5;
    private _wp = _grp addWaypoint [getPos _drone, 0];
    _wp setWaypointType "HOLD";
    
    sleep 15;
    
    [_drone] remoteExec ["TUE_fnc_droneRadar", 0, "DroneRadar_JIP"];
    
    _drone flyInHeight 12;
    private _leaderStoppedTime = 0;
    private _currentState = "NONE";
    
    while {alive _drone} do {
        sleep 2;
        
        private _squad = [];
        for "_i" from 0 to 3 do {
            private _u = missionNamespace getVariable [format["Player_%1", _i], objNull];
            if (!isNull _u && {alive _u}) then { _squad pushBack _u; };
        };
        
        private _leader = if (_squad isNotEqualTo []) then { leader group (_squad select 0) } else { objNull };
        
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
