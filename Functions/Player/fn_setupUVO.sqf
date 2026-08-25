params [["_unit", objNull, [objNull]], ["_forcedLang", "", [""]]];

if (isNull _unit || !alive _unit) exitWith {};

private _hasUVO = missionNamespace getVariable ["TUE_hasUVO", isClass (configFile >> "CfgPatches" >> "UVO") || !isNil "UVO_fnc_init"];
if (!_hasUVO) exitWith {};

private _hasExpanded = missionNamespace getVariable ["TUE_hasUVO_Expanded", isClass (configFile >> "CfgPatches" >> "UVO_Expanded") || isClass (configFile >> "CfgPatches" >> "UVO_factions_plus") || isClass (configFile >> "CfgPatches" >> "UVO_RHS")];

private _uvoLang = "";

if (_forcedLang != "") then {
    _uvoLang = _forcedLang;
} else {
    if (side group _unit == east) then {
        _uvoLang = "Russian";
    } else {
        if (_hasExpanded) then {
            _uvoLang = selectRandom ["American English", "British English", "French"];
        } else {
            _uvoLang = selectRandom ["American English", "British English"];
        };
    };
};

_unit setVariable ["UVO_Voice", _uvoLang, true];
_unit setVariable ["UVO_Language", _uvoLang, true];

{
    _unit setVariable [_x, true, true];
} forEach [
    "uvo_disable_auto",
    "UVO_disableAuto",
    "UVO_autoAssign",
    "uvo_autoDetect"
];
