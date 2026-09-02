if (!hasInterface) exitWith {};

player addAction [
    format ["<t color='#FFFF00'>%1</t>", localize "STR_LL_Task_07_Action_CAS"],
    {
        params ["_target", "_caller", "_actionId", "_arguments"];
        
        if (missionNamespace getVariable ["LL_Task07_PlaneTriggered", false]) exitWith {};
        missionNamespace setVariable ["LL_Task07_PlaneTriggered", true, true];
        
        _target removeAction _actionId;
        
        [] remoteExec ["LL_fnc_task07_plane", 2];
    },
    [],
    1.5,
    true,
    true,
    "",
    "private _tank = missionNamespace getVariable ['LL_Task07_TargetTank', objNull]; !isNull _tank && {alive _tank} && {(_this distance _tank) < 200} && {(_this distance _tank) > 150} && {!(missionNamespace getVariable ['LL_Task07_PlaneTriggered', false])}"
];
