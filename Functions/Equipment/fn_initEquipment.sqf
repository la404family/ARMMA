if (!isServer) exitWith {};

TUE_vsm_uniforms = [];
TUE_vsm_vests = [];
TUE_vsm_headgear = [];

private _cfgWeapons = configFile >> "CfgWeapons";
for "_i" from 0 to (count _cfgWeapons - 1) do {
    private _class = _cfgWeapons select _i;
    if (isClass _class) then {
        private _className = configName _class;
        private _classNameLower = toLower _className;

        if (_className select [0, 4] == "VSM_") then {
            if (!(_classNameLower find "black" >= 0) && {!(_classNameLower find "white" >= 0)} && {!(_classNameLower find "alpine" >= 0)} && {!(_classNameLower find "wtf" >= 0)}) then {
                private _itemInfo = _class >> "ItemInfo";
                if (isClass _itemInfo) then {
                    private _type = getNumber (_itemInfo >> "type");

                    if (_type == 801) then {
                        TUE_vsm_uniforms pushBack _className;
                    } else {
                        if (_type == 701) then {
                            TUE_vsm_vests pushBack _className;
                        } else {
                            if ((_classNameLower find "backwardshat" >= 0) || (_classNameLower find "beanie" >= 0) || (_classNameLower find "boonie" >= 0) || (_classNameLower find "cap" >= 0) || (_classNameLower find "shemagh" >= 0)) then {
                                TUE_vsm_headgear pushBack _className;
                            };
                        };
                    };
                };
            };
        };
    };
};

TUE_enemy_primaryWeapons = [
    "hlc_rifle_auga3_bl",
    "hlc_rifle_sg553RSB_TAC",
    "hlc_rifle_ACR68_SBR_black",
    "hlc_rifle_M27IAR",
    "hlc_rifle_aku12",
    "hlc_smg_mp5N_tac",
    "hlc_rifle_honeybadger",
    "arifle_MSBS65_black_F",
    "SMG_03C_TR_black"
];

TUE_enemy_secondaryWeapons = [
    "hgun_ACPC2_F",
    "hgun_P07_blk_F",
    "hlc_pistol_P226WestGerman",
    "hlc_pistol_Mk25D",
    "hlc_pistol_P226R_357"
];

TUE_enemy_names = [
    ["Ivan Ivanov","Ivan","Ivanov"],["Dmitry Smirnov","Dmitry","Smirnov"],["Sergey Kuznetsov","Sergey","Kuznetsov"],
    ["Alexey Popov","Alexey","Popov"],["Nikolay Sokolov","Nikolay","Sokolov"],["Mikhail Lebedev","Mikhail","Lebedev"],
    ["Igor Kozlov","Igor","Kozlov"],["Vladimir Novikov","Vladimir","Novikov"],["Andrey Morozov","Andrey","Morozov"],
    ["Artem Petrov","Artem","Petrov"],["Yuri Volkov","Yuri","Volkov"],["Pavel Solovyov","Pavel","Solovyov"],
    ["Viktor Vasiliev","Viktor","Vasiliev"],["Roman Zaytsev","Roman","Zaytsev"],["Denis Pavlov","Denis","Pavlov"],
    ["Ilya Semenov","Ilya","Semenov"],["Anton Golubev","Anton","Golubev"],["Oleg Vinogradov","Oleg","Vinogradov"],
    ["Maksim Bogdanov","Maksim","Bogdanov"],["Kirill Vorobyov","Kirill","Vorobyov"],["Stepan Fedorov","Stepan","Fedorov"],
    ["Boris Mikhailov","Boris","Mikhailov"],["Gleb Belyaev","Gleb","Belyaev"],["Leonid Tarasov","Leonid","Tarasov"],
    ["Timur Belov","Timur","Belov"],["Artur Komarov","Artur","Komarov"],["Vadim Orlov","Vadim","Orlov"],
    ["Vitaly Kiselev","Vitaly","Kiselev"],["Slava Makarov","Slava","Makarov"],["Yevgeny Andreev","Yevgeny","Andreev"],
    ["Anatoly Kovalev","Anatoly","Kovalev"],["Grigory Ilyin","Grigory","Ilyin"],["Valery Gusev","Valery","Gusev"],
    ["Stanislav Titov","Stanislav","Titov"],["Eduard Kuzmin","Eduard","Kuzmin"],["Ruslan Kudryavtsev","Ruslan","Kudryavtsev"],
    ["Pyotr Baranov","Pyotr","Baranov"],["Taras Kulikov","Taras","Kulikov"],["Vsevolod Alekseev","Vsevolod","Alekseev"],
    ["Nikita Stepanov","Nikita","Stepanov"]
];

TUE_enemy_faces = [
    "WhiteHead_01","WhiteHead_02","WhiteHead_03","WhiteHead_04","WhiteHead_05","WhiteHead_06",
    "WhiteHead_07","WhiteHead_08","WhiteHead_09","WhiteHead_10","WhiteHead_11","WhiteHead_12",
    "WhiteHead_13","WhiteHead_14","WhiteHead_15","WhiteHead_16","WhiteHead_17","WhiteHead_18",
    "WhiteHead_19","WhiteHead_20","WhiteHead_21", "RussianHead_1", "RussianHead_2", "RussianHead_3", "RussianHead_4", "RussianHead_5"
];

[] spawn {
    while {true} do {
        {
            if (!isPlayer _x && {side _x == east} && {alive _x} && {!(_x getVariable ["TUE_equipmentApplied", false])}) then {
                [_x] call TUE_fnc_applyEnemyEquipment;
            };
        } forEach allUnits;
        sleep 3;
    };
};
