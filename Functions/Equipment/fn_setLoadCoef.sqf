/*
    Description : 
    Réduit artificiellement le poids de l'équipement porté par l'unité, 
    et désactive la fatigue pour lui permettre de courir sans s'épuiser.
    
    Paramètres :
    0: OBJECT - L'unité ciblée
    1: SCALAR - (Optionnel) Le coefficient de charge (0.1 par défaut, soit 10% du poids réel)
*/
params [
    ["_target", objNull, [objNull, []]],
    ["_coef", 0.1, [0]]
];

// Si la fonction est appelée sans paramètre `[] call TUE_fnc_setLoadCoef;`
if (_target isEqualType objNull && {isNull _target}) then {
    // On sélectionne TOUTES les I.A. BLUFOR (non-joueurs)
    _target = allUnits select {side group _x == west && !isPlayer _x};
};

// Si la cible est un tableau d'unités (escouade, etc.)
if (_target isEqualType []) exitWith {
    {
        [_x, _coef] call TUE_fnc_setLoadCoef;
    } forEach _target;
};

private _unit = _target;
if (!alive _unit) exitWith {};

if (local _unit) then {
    // Réduit drastiquement l'impact du poids de l'équipement
    _unit setUnitTrait ["loadCoef", _coef];
    
    // Désactive l'endurance et la fatigue
    _unit enableStamina false;
    _unit enableFatigue false;
    
    // Force l'IA à utiliser sa vitesse de sprint (FULL)
    (group _unit) setSpeedMode "FULL";
    
    // Accélère légèrement l'animation de course pour garantir qu'ils ne soient plus distancés
    _unit setAnimSpeedCoef 1.15;
} else {
    [_unit, _coef] remoteExec ["TUE_fnc_setLoadCoef", _unit];
};
