if (!isServer) exitWith {};

[] spawn {

    waitUntil { time > 0 };
    sleep 2;

    while {true} do {
        sleep 5;
        
        if (missionNamespace getVariable ["LL_g_extractionActive", false]) exitWith {};

        private _squad = [];
        for "_i" from 0 to 3 do {
            private _u = missionNamespace getVariable [format["Player_%1", _i], objNull];
            if (!isNull _u && {alive _u} && {lifeState _u != "INCAPACITATED"}) then {
                _squad pushBack _u;
            };
        };

        if (_squad isNotEqualTo []) then {
            private _mainGrp = group (_squad select 0);

            {
                if (group _x != _mainGrp) then {
                    [_x] joinSilent _mainGrp;
                };
            } forEach _squad;

            private _currentLeader = leader _mainGrp;
            private _humanPlayers = _squad select { isPlayer _x };

            private _desiredLeader = if (_humanPlayers isNotEqualTo []) then { _humanPlayers select 0 } else { _squad select 0 };

            if (_currentLeader != _desiredLeader) then {
                _mainGrp selectLeader _desiredLeader;
            };
        };
    };
};
