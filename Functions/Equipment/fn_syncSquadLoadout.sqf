if (isMultiplayer || !hasInterface) exitWith {};

if (missionNamespace getVariable ["TUE_arsenalSync_init", false]) exitWith {};
missionNamespace setVariable ["TUE_arsenalSync_init", true];

[missionNamespace, "arsenalClosed", {
    if (isMultiplayer || isNull player || !alive player) exitWith {};

    private _leader = leader (group player);
    if (player != _leader) exitWith {};

    private _loadout = getUnitLoadout player;
    private _aiUnits = (units (group player)) select { !isPlayer _x && alive _x };

    {
        _x setUnitLoadout _loadout;
    } forEach _aiUnits;
}] call BIS_fnc_addScriptedEventHandler;
