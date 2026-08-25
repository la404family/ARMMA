if (!isServer) exitWith {};

setDate [2035, 6, 29, (date select 3), (date select 4)];

TUE_hasUVO = isClass (configFile >> "CfgPatches" >> "uvo_main")
    || isClass (configFile >> "CfgPatches" >> "UVO_main")
    || isClass (configFile >> "CfgPatches" >> "UVO")
    || isClass (configFile >> "CfgPatches" >> "uvo_sounds")
    || isClass (configFile >> "CfgPatches" >> "UVO_Sounds")
    || isClass (configFile >> "CfgPatches" >> "uvo")
    || !isNil "uvo_main_fnc_add"
    || !isNil "uvo_main_fnc_speak"
    || !isNil "UVO_fnc_add"
    || !isNil "UVO_fnc_speak"
    || !isNil "uvo_main_voices";

TUE_hasUVO_Expanded = isClass (configFile >> "CfgPatches" >> "UVO_Expanded")
    || isClass (configFile >> "CfgPatches" >> "uvo_expanded")
    || isClass (configFile >> "CfgPatches" >> "UVO_factions_plus")
    || isClass (configFile >> "CfgPatches" >> "uvo_factions_plus")
    || isClass (configFile >> "CfgPatches" >> "UVO_AET_AIO")
    || isClass (configFile >> "CfgPatches" >> "uvo_aet_aio")
    || isClass (configFile >> "CfgPatches" >> "UVO_RHS")
    || isClass (configFile >> "CfgPatches" >> "uvo_rhs")
    || isClass (configFile >> "CfgPatches" >> "UVO_voices_expanded")
    || isClass (configFile >> "CfgPatches" >> "uvo_voices_expanded")
    || isClass (configFile >> "CfgPatches" >> "uvo_voices");

publicVariable "TUE_hasUVO";
publicVariable "TUE_hasUVO_Expanded";

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
    sleep 15;
    ["REQUEST"] call LL_fnc_taskManager;
};
