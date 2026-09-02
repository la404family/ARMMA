params ["_player", "_didJIP"];

[] spawn TUE_fnc_initLocal;
[] spawn TUE_fnc_addRoeActions;
[] spawn TUE_fnc_syncSquadLoadout;
[_didJIP] spawn LL_fnc_intro;
