if (!isServer) exitWith {};

setDate [2035, 6, 29, (date select 3), (date select 4)];

TUE_hasUVO = isClass (configFile >> "CfgPatches" >> "UVO") || !isNil "UVO_fnc_init";
TUE_hasUVO_Expanded = isClass (configFile >> "CfgPatches" >> "UVO_Expanded") || isClass (configFile >> "CfgPatches" >> "UVO_factions_plus") || isClass (configFile >> "CfgPatches" >> "UVO_RHS");

["init"] call LL_fnc_taskManager;

[] spawn TUE_fnc_initSkills;
[] spawn TUE_fnc_randomWeather;
[] spawn TUE_fnc_aiHealSelf;
[] spawn TUE_fnc_initEquipment;
[] spawn TUE_fnc_initIdentity;
[] spawn TUE_fnc_assignLeader;

if (!isNil "drone_BLUFOR") then {
    [drone_BLUFOR] spawn TUE_fnc_initDrone;
};

[false] spawn LL_fnc_intro;
[] spawn LL_fnc_spawnStartArsenal;

[] spawn {
    waitUntil { sleep 1; missionNamespace getVariable ["MISSION_intro_finished", false] };
    
    // Délai de grâce pour s'équiper à l'arsenal
    sleep 15;

    // Lancement automatique d'une tâche aléatoire
    ["REQUEST"] call LL_fnc_taskManager;
};
