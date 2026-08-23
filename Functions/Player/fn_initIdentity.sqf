if (!isServer) exitWith {};

addMissionEventHandler ["PlayerConnected", {
    params ["_id", "_uid", "_name", "_jip", "_owner", "_idstr"];
    [_owner] spawn {
        params ["_ownerId"];
        waitUntil { !isNil "TUE_g_usedPlayerNames" };
        private _fnc_sendAllIdentities = {
            params ["_ownerId2"];
            for "_i" from 0 to 3 do {
                private _unit = missionNamespace getVariable [format ["Player_%1", _i], objNull];
                if (!isNull _unit) then {
                    private _identity = _unit getVariable ["TUE_s_identity", []];
                    if (count _identity >= 5) then {
                        _identity params ["_nameData", "_faceType", "_face", "_speaker", "_pitch", ["_beard", "", [""]]];
                        [_unit, _nameData, _face, _speaker, _pitch, _beard] remoteExec ["TUE_fnc_applyIdentity", _ownerId2];
                    };
                };
            };
        };
        sleep 5;
        [_ownerId] call _fnc_sendAllIdentities;
        sleep 25;
        [_ownerId] call _fnc_sendAllIdentities;
    };
}];

private _codenames = [
    ["GHOST - 5248X", "GHOST", "5248X"], ["WRAITH - 1092Z", "WRAITH", "1092Z"], ["SPECTER - 7734K", "SPECTER", "7734K"],
    ["REAPER - 4019V", "REAPER", "4019V"], ["SHADOW - 8861A", "SHADOW", "8861A"], ["PHANTOM - 2305Y", "PHANTOM", "2305Y"],
    ["ECHO - 6190Q", "ECHO", "6190Q"], ["VOID - 0477J", "VOID", "0477J"],
    
    ["RAVEN - 3528R", "RAVEN", "3528R"], ["DAGGER - 9144M", "DAGGER", "9144M"], ["BLADE - 6083H", "BLADE", "6083H"],
    ["HAMMER - 7710L", "HAMMER", "7710L"], ["STORM - 2056W", "STORM", "2056W"], ["THUNDER - 8392P", "THUNDER", "8392P"],
    ["FROST - 1129T", "FROST", "1129T"], ["WOLF - 9960C", "WOLF", "9960C"], ["VIPER - 5581N", "VIPER", "5581N"],
    ["COBRA - 4430D", "COBRA", "4430D"],

    ["NOMAD - 3017B", "NOMAD", "3017B"], ["HUNTER - 6722F", "HUNTER", "6722F"], ["RANGER - 7855G", "RANGER", "7855G"],
    ["SCOUT - 9288S", "SCOUT", "9288S"], ["TRACKER - 1504E", "TRACKER", "1504E"], ["SEEKER - 4339U", "SEEKER", "4339U"],
    ["STALKER - 2901I", "STALKER", "2901I"], ["LURKER - 8102O", "LURKER", "8102O"], ["WATCHER - 5673X", "WATCHER", "5673X"],
    ["JOKER - 3441Z", "JOKER", "3441Z"],

    ["BRICK - 7033K", "BRICK", "7033K"], ["TANK - 1266V", "TANK", "1266V"], ["BOULDER - 8920A", "BOULDER", "8920A"],
    ["ANVIL - 4318R", "ANVIL", "4318R"], ["FLINT - 6599M", "FLINT", "6599M"], ["ASH - 0173L", "ASH", "0173L"],
    ["SMOKE - 9844Q", "SMOKE", "9844Q"], ["DUST - 5721J", "DUST", "5721J"],

    ["GLACIER - 2460H", "GLACIER", "2460H"], ["TUNDRA - 3188P", "TUNDRA", "3188P"], ["ARCTIC - 7055W", "ARCTIC", "7055W"],
    ["NORD - 9401N", "NORD", "9401N"], ["SIBER - 8812C", "SIBER", "8812C"], ["YUKON - 5329D", "YUKON", "5329D"],
    ["ICE - 1107B", "ICE", "1107B"], ["SNOW - 4992F", "SNOW", "4992F"], ["ZERO - 0001G", "ZERO", "0001G"],
    ["DEAD - 6669S", "DEAD", "6669S"], ["GRAVE - 1313E", "GRAVE", "1313E"], ["COLD - 0420U", "COLD", "0420U"],
    ["NIGHT - 2011I", "NIGHT", "2011I"], ["UNSEEN - 7399O", "UNSEEN", "7399O"]
];

TUE_g_allNamesTyped = _codenames;
TUE_g_usedPlayerNames = [];

private _unitRoles = [];
for "_i" from 0 to 3 do {
    private _varName = format ["Player_%1", _i];
    private _unit = missionNamespace getVariable [_varName, objNull];
    if (!isNull _unit) then {
        private _rank = "PRIVATE";
        if (_varName == "Player_0") then { _rank = "CORPORAL"; };
        if (_varName == "Player_1") then { _rank = "SERGEANT"; };
        _unitRoles pushBack [_varName, _rank];
    };
};

private _fnc_processUnit = {
    params ["_unit", "_pool", "_roles"];
    private _available = _pool select { !((_x select 0) in TUE_g_usedPlayerNames) };
    if (_available isEqualTo []) then { TUE_g_usedPlayerNames = []; _available = _pool; };
    private _nameData = selectRandom _available;
    private _faceType = selectRandom ["Black", "Arab", "Asian", "Pacific", "White", "White"];
    TUE_g_usedPlayerNames pushBack (_nameData select 0);

    private _faces = switch (_faceType) do {
        case "Black": { ["AfricanHead_01","AfricanHead_02","AfricanHead_03"] };
        case "Arab": { ["PersianHead_A3_01","PersianHead_A3_02","PersianHead_A3_03","GreekHead_A3_01","GreekHead_A3_02","GreekHead_A3_03","GreekHead_A3_04","GreekHead_A3_05","GreekHead_A3_06"] };
        case "Asian": { ["AsianHead_A3_01","AsianHead_A3_02","AsianHead_A3_03"] };
        case "Pacific": { ["TanoanHead_A3_01","TanoanHead_A3_02","TanoanHead_A3_03","TanoanHead_A3_04","TanoanHead_A3_05"] };
        default { ["WhiteHead_01","WhiteHead_02","WhiteHead_03","WhiteHead_04","WhiteHead_05","WhiteHead_06","WhiteHead_07","WhiteHead_08","WhiteHead_09","WhiteHead_10","WhiteHead_11","WhiteHead_12","WhiteHead_13","WhiteHead_14","WhiteHead_15","WhiteHead_16","WhiteHead_17","WhiteHead_18","WhiteHead_19","WhiteHead_20","WhiteHead_21"] };
    };
    private _face = selectRandom _faces;

    private _speaker = switch (_faceType) do {
        case "White": { selectRandom ["Male01ENG", "Male02ENG", "Male03ENG", "Male04ENG"] };
        case "Black": { selectRandom ["Male05ENG", "Male06ENG", "Male07ENG"] };
        default { selectRandom ["Male08ENG", "Male09ENG", "Male10ENG", "Male11ENG", "Male12ENG"] };
    };
    private _pitch = 0.90 + random 0.20;

    {
        if ((missionNamespace getVariable [_x select 0, objNull]) isEqualTo _unit) exitWith {
            _unit setUnitRank (_x select 1);
        };
    } forEach _roles;

    private _beard = "";

    [_unit, _nameData, _face, _speaker, _pitch, _beard] remoteExec ["TUE_fnc_applyIdentity", 0, _unit];

    _unit setVariable ["TUE_s_identity", [_nameData, _faceType, _face, _speaker, _pitch, _beard], true];
    _unit setVariable ["TUE_IdentitySet", true, true];

    if (!isNil "TUE_fnc_setupUVO") then { [_unit] call TUE_fnc_setupUVO; };
};

private _endTime = time + 300;
while { time < _endTime } do {
    private _unprocessed = _unitRoles select {
        private _u = missionNamespace getVariable [_x select 0, objNull];
        !isNull _u && alive _u && !(_u getVariable ["TUE_IdentitySet", false])
    };
    if (_unprocessed isEqualTo []) exitWith {};
    {
        private _unit = missionNamespace getVariable [_x select 0, objNull];
        if (!isNull _unit) then {
            [_unit, _codenames, _unitRoles] call _fnc_processUnit;
        };
    } forEach _unprocessed;

    private _remaining = _unitRoles select {
        private _u = missionNamespace getVariable [_x select 0, objNull];
        !isNull _u && alive _u && !(_u getVariable ["TUE_IdentitySet", false])
    };
    if (_remaining isEqualTo []) exitWith {};
    sleep 2;
};

[_unitRoles] spawn {
    params ["_roles"];
    sleep 60;
    {
        private _unit = missionNamespace getVariable [_x select 0, objNull];
        if (!isNull _unit) then {
            private _identity = _unit getVariable ["TUE_s_identity", []];
            if (count _identity >= 5) then {
                _identity params ["_nameData", "_faceType", "_face", "_speaker", "_pitch", ["_beard", "", [""]]];
                [_unit, _nameData, _face, _speaker, _pitch, _beard] remoteExec ["TUE_fnc_applyIdentity", 0];
            };
        };
    } forEach _roles;
};

