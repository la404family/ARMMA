if (!isServer) exitWith {};

private _tank = missionNamespace getVariable ["LL_Task07_TargetTank", objNull];
if (isNull _tank || !alive _tank) exitWith {};

[_tank] spawn {
    params ["_tank"];
    
    private _spawnPos = getPos _tank getPos [4000, random 360];
    _spawnPos set [2, 2000];
    
    while {alive _tank} do {
        private _planeGroup = createGroup [west, true];
        private _plane = createVehicle ["B_Plane_Fighter_01_F", _spawnPos, [], 0, "FLY"];
        _plane setDir (_plane getDir _tank);
        _plane setVelocityModelSpace [0, 200, 0];
        _plane allowDamage false;
        _plane flyInHeight 1500;
        
        private _pilot = _planeGroup createUnit ["B_Fighter_Pilot_F", _spawnPos, [], 0, "NONE"];
        _pilot moveInDriver _plane;
        _pilot allowDamage false;
        
        _planeGroup setCombatMode "RED";
        _planeGroup setBehaviour "COMBAT";
        
        _pilot setSkill 1;
        _planeGroup reveal [_tank, 4];
        _pilot doTarget _tank;
        _pilot doFire _tank;
        
        private _wp = _planeGroup addWaypoint [getPos _tank, 0];
        _wp setWaypointType "SAD";
        _wp waypointAttachVehicle _tank;
        
        private _timeout = time + 180;
        
        waitUntil {sleep 2; !alive _tank || !alive _plane || !alive _pilot || time > _timeout};
        
        if (alive _plane && alive _pilot) then {
            _planeGroup setCombatMode "BLUE";
            _planeGroup setBehaviour "CARELESS";
            private _exitPos = getPos _plane getPos [8000, getDir _plane];
            _exitPos set [2, 3000];
            private _wpExit = _planeGroup addWaypoint [_exitPos, 0];
            _wpExit setWaypointType "MOVE";
            _planeGroup setCurrentWaypoint _wpExit;
            _plane flyInHeight 3000;
            
            [_plane, _pilot] spawn {
                params ["_plane", "_pilot"];
                sleep 20;
                if (!isNull _plane) then { deleteVehicle _plane; };
                if (!isNull _pilot) then { deleteVehicle _pilot; };
            };
        };
        
        sleep 5;
    };
};
