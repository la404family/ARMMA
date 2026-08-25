if (!hasInterface) exitWith {};

player createDiaryRecord ["diary", [localize "STR_TUE_Briefing_Title", localize "STR_TUE_Briefing_Text"]];

if ({ _x == "FirstAidKit" } count (items player) < 2) then {
    player addItem "FirstAidKit";
    player addItem "FirstAidKit";
};

[] spawn {
    private _timeout = 0;
    waitUntil {
        sleep 0.5;
        _timeout = _timeout + 0.5;
        (!isNull player && {!isNil { player getVariable "TUE_s_identity" }}) || { _timeout >= 30 }
    };

    private _playerUnit = player;
    if (!isNull _playerUnit) then {
        private _identity = _playerUnit getVariable ["TUE_s_identity", []];
        if (count _identity >= 5) then {
            _identity params ["_nameData", "_faceType", "_face", "_speaker", "_pitch", ["_beard", "", [""]]];
            [_playerUnit, _nameData, _face, _speaker, _pitch, _beard] call TUE_fnc_applyIdentity;
            showHUD false;
            sleep 0.5;
            showHUD true;
        };
    };
};
