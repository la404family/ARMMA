if (!hasInterface) exitWith {};

if (isNil "TUE_fnc_applyRoE") then {
    TUE_fnc_applyRoE = {
        params [
            ["_grp", grpNull, [grpNull]],
            ["_combatMode", "YELLOW", [""]],
            ["_behaviour", "AWARE", [""]],
            ["_speedMode", "NORMAL", [""]],
            ["_formation", "WEDGE", [""]],
            ["_unitPos", "AUTO", [""]],
            ["_disableAutocombat", false, [true]],
            ["_name", "NORMAL", [""]]
        ];

        if (isNull _grp) exitWith {};

        _grp setCombatMode _combatMode;
        _grp setBehaviourStrong _behaviour;
        _grp setSpeedMode _speedMode;
        _grp setFormation _formation;

        {
            if (!isPlayer _x && { alive _x } && { vehicle _x == _x }) then {

                if (_unitPos == "MIDDLE") then {
                    _x setUnitPos _unitPos;
                } else {
                    _x setUnitPosWeak _unitPos;
                };

                if (_disableAutocombat) then {
                    _x disableAI "AUTOCOMBAT";
                    _x disableAI "SUPPRESSION";
                } else {
                    _x enableAI "AUTOCOMBAT";
                    _x enableAI "SUPPRESSION";
                };

                _x setVariable ["TUE_CurrentRoE", _name, false];
            };
        } forEach (units _grp);

        // Changement appliqué de façon silencieuse
    };
};

private _fnc_addRoeActions = {
    params [["_unit", objNull, [objNull]]];

    if (isNull _unit || { _unit getVariable ["TUE_Action_Roe_Added", false] }) exitWith {};
    _unit setVariable ["TUE_Action_Roe_Added", true, false];

    private _cond = "alive _target && { leader group _target == _target } && { {!isPlayer _x && { alive _x } && { vehicle _x == _x }} count (units group _target) > 0 }";

    _unit addAction [
        localize "STR_TUE_RoeAction_Infiltration",
        { ([group (_this select 1)] + (_this select 3)) call TUE_fnc_applyRoE; },
        ["BLUE", "STEALTH", "LIMITED", "STAG COLUMN", "MIDDLE", true, "STEALTH"],
        7.2, false, true, "", _cond
    ];

    _unit addAction [
        localize "STR_TUE_RoeAction_Reset",
        { ([group (_this select 1)] + (_this select 3)) call TUE_fnc_applyRoE; },
        ["YELLOW", "AWARE", "NORMAL", "WEDGE", "AUTO", false, "NORMAL"],
        7.1, false, true, "", _cond
    ];

    _unit addAction [
        localize "STR_TUE_RoeAction_Assault",
        { ([group (_this select 1)] + (_this select 3)) call TUE_fnc_applyRoE; },
        ["RED", "COMBAT", "FULL", "WEDGE", "AUTO", false, "ASSAULT"],
        7.0, false, true, "", _cond
    ];
};

[_fnc_addRoeActions] spawn {
    params [["_fnc_addRoeActions", {}, [{}]]];
    private _lastPlayer = objNull;
    while {true} do {
        waitUntil { sleep 1; player != _lastPlayer && { !isNull player } };
        _lastPlayer = player;
        [_lastPlayer] call _fnc_addRoeActions;
    };
};

