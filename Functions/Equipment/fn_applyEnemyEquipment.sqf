params ["_unit"];
if (!isServer) exitWith {};

_unit setVariable ["TUE_equipmentApplied", true, true];

removeAllWeapons _unit;
removeAllItems _unit;
removeAllAssignedItems _unit;
removeUniform _unit;
removeVest _unit;
removeBackpack _unit;
removeHeadgear _unit;
removeGoggles _unit;

if (count TUE_vsm_uniforms > 0) then {
    _unit forceAddUniform (selectRandom TUE_vsm_uniforms);
};

if (count TUE_vsm_vests > 0) then {
    _unit addVest (selectRandom TUE_vsm_vests);
};

if (random 100 <= 90 && {count TUE_vsm_headgear > 0}) then {
    _unit addHeadgear (selectRandom TUE_vsm_headgear);
};

_unit linkItem "ItemMap";
_unit linkItem "ItemCompass";
_unit linkItem "ItemWatch";
_unit linkItem "ItemRadio";

for "_i" from 1 to 2 do {_unit addItemToVest "FirstAidKit";};
for "_i" from 1 to 2 do {_unit addItemToVest "SmokeShell";};

private _hasPrimary = (random 100 > 10);
private _secondary = selectRandom TUE_enemy_secondaryWeapons;
private _secondaryMag = (getArray (configFile >> "CfgWeapons" >> _secondary >> "magazines")) select 0;

private _fnc_addFlashlight = {
    params ["_unit", "_weapon", "_isPrimary"];
    if (random 100 <= 75) then {
        private _compatible = compatibleItems _weapon;
        private _light = "";
        {
            private _nameLower = toLower _x;
            if (_nameLower find "flash" >= 0 || _nameLower find "light" >= 0 || _nameLower find "surefire" >= 0 || _nameLower find "acc_pointer" >= 0) exitWith {
                _light = _x;
            };
        } forEach _compatible;

        if (_light != "") then {
            if (_isPrimary) then { _unit addPrimaryWeaponItem _light; } else { _unit addHandgunItem _light; };
        };
    };
};

if (_hasPrimary) then {
    private _primary = selectRandom TUE_enemy_primaryWeapons;
    private _primaryMag = (getArray (configFile >> "CfgWeapons" >> _primary >> "magazines")) select 0;

    for "_i" from 1 to 6 do {_unit addItemToVest _primaryMag;};
    for "_i" from 1 to 2 do {_unit addItemToVest _secondaryMag;};

    _unit addWeapon _primary;
    [_unit, _primary, true] call _fnc_addFlashlight;
} else {
    for "_i" from 1 to 8 do {_unit addItemToVest _secondaryMag;};
};

_unit addWeapon _secondary;
[_unit, _secondary, false] call _fnc_addFlashlight;
_unit enableGunLights "forceOn";

private _nameData = selectRandom TUE_enemy_names;
_unit setName [_nameData select 0, _nameData select 1, _nameData select 2];

_unit setSpeaker (selectRandom ["Male01RUS", "Male02RUS", "Male03RUS"]);

if (count TUE_enemy_faces > 0) then {
    private _face = selectRandom TUE_enemy_faces;
    [_unit, _face] remoteExec ["setFace", 0, _unit];
};

if (!isNil "TUE_fnc_setupUVO") then {
    [_unit] call TUE_fnc_setupUVO;
};
