[] spawn {
    while {true} do {

        if (hasInterface && {side player == west}) then {
            player setFatigue 0;
            player setStamina 60; 
            player setCustomAimCoef 0.1; 
        };

        {
            if (local _x && {side _x == west} && {!isPlayer _x} && {alive _x}) then {
                _x setFatigue 0;
            };
        } forEach allUnits;

        sleep 25; 
    };
};

if (!isServer) exitWith {}; 

[] spawn {
    while {true} do {
        {
            private _unit = _x;

            if (!isPlayer _unit && {alive _unit}) then {

                private _side = side _unit;

                if (_side == west) then {

                    _unit setSkill ["aimingAccuracy", 0.95 + random 0.05]; 
                    _unit setSkill ["aimingShake",    0.95 + random 0.05]; 
                    _unit setSkill ["aimingSpeed",    0.90 + random 0.10]; 
                    _unit setSkill ["spotDistance",   1.00]; 
                    _unit setSkill ["spotTime",       1.00]; 
                    _unit setSkill ["commanding",     1.00]; 
                    _unit setSkill ["courage",        1.00]; 
                    _unit setSkill ["general",        1.00];
                    _unit allowFleeing 0; 
                    _unit setSpeedMode "FULL";
                } else {

                    _unit setSkill ["aimingAccuracy", 0.10 + random 0.15]; 
                    _unit setSkill ["aimingShake",    0.10 + random 0.10]; 
                    _unit setSkill ["aimingSpeed",    0.20 + random 0.20]; 
                    _unit setSkill ["spotDistance",   0.30 + random 0.20]; 
                    _unit setSkill ["spotTime",       0.20 + random 0.20]; 
                    _unit setSkill ["commanding",     0.40 + random 0.20]; 
                    _unit setSkill ["courage",        0.40 + random 0.20]; 
                    _unit setSkill ["general",        0.40];
                    _unit allowFleeing 0.3; 
                    _unit setSpeedMode "FULL";
                };
            };
        } forEach allUnits;

        sleep 25;
    };
};
