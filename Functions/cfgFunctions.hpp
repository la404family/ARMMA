class TUE
{
    tag = "TUE";

    class Environment
    {
        file = "Functions\Environment";
        class initSkills {};
        class randomWeather {};
        class initDrone {};
        class droneRadar {};
    };

    class Medical
    {
        file = "Functions\Medical";
        class aiHealSelf {};
    };
    class Equipment
    {
        file = "Functions\Equipment";
        class initEquipment {};
        class applyEnemyEquipment {};
    };
    class Player
    {
        file = "Functions\Player";
        class initIdentity {};
        class applyIdentity {};
        class initLocal {};
        class assignLeader {};
        class addRoeActions {};
        class setupUVO {};
    };
};

class LL
{
    tag = "LL";
    class Task
    {
        file = "Functions\Task";
        class task00 {};
        class task00_addAction {};
        class task01 {};
        class task01_addAction {};
        class task02 {};
        class task02_addAction {};
        class task03 {};
        class task03_addAction {};
        class task04 {};
        class task04_addAction {};
        class task05 {};
        class task06 {};
        class task06_addAction {};
        class taskCleanup {};
        class taskManager {};
        class addTaskAction {};
        class createSmokeRing {};
        class intro {};
        class spawnStartArsenal {};
        class extraction {};
    };
};
