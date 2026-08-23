# Informations sur les variables et objets présents dans l'éditeur

## Variables présentes dans l'éditeur:

- Player_0 à Player_3 sont les unités jouables du jeu 
- MH-80 Ghost Hawk : Hélicoptère allié (transport des joueurs BLUFOR) variable : "heli_BLUFOR"
- AR-2 Darter : Drone allié variable : "drone_BLUFOR"
- des heliport invisible détermine les places des atterrissages.
- des "logic game" sont présents à différentes positions pour le spawn des ennemis, des alliés et des civils

## Règles de Spawn et Équipement:

- **Ennemis (OPFOR)** : Lors du spawn, utiliser des uniformes/vêtements du mod **VSM**.
  - **Condition stricte (Générale)** : Exclure tout vêtement ou équipement dont le nom de classe contient `black`, `white`, `alpine` ou `WTF`. Tous les autres motifs VSM sont autorisés.
  - **Langue** : Les ennemis parlent obligatoirement **Russe** (modifier les configs UVO et utiliser `O_R_Soldier_F` pour les voix natives).
- **Couvre-chefs Ennemis** : 90% des ennemis devront obligatoirement porter un chapeau de type : `BackwardsHat`, `Beanie`, `Boonie`, `Cap` ou `Shemagh` du mod VSM (en respectant la condition d'exclusion des couleurs ci-dessus).
- **Armement Ennemi** : Les ennemis (OPFOR) seront équipés aléatoirement avec l'une des armes suivantes :
  - **Steyr AUGA3 (Bleu)** : `hlc_rifle_auga3_bl`
  - **SIG SG553R-SB (TAC)** : `hlc_rifle_sg553RSB_TAC`
  - **Remington ACR-E 6.8mm (Compact/Black)** : `hlc_rifle_ACR68_SBR_black`
  - **M27 IAR** : `hlc_rifle_M27IAR`
  - **Izhmash AK12U** : `hlc_rifle_aku12`
  - **H&K MP5A5 (TAC)** : `hlc_smg_mp5N_tac`
  - **AAC "Honey-Badger" Carbine** : `hlc_rifle_honeybadger`
  - **Promet 6,5 mm (noir)** : `arifle_MSBS65_black_F`
  - **ADR-97C TR 5,7 mm (noir)** : `SMG_03C_TR_black`
- **Armement Secondaire (Pistolets)** :
  - **ACP-C2 .45 ACP** : `hgun_ACPC2_F`
  - **P07 9 mm (noir)** : `hgun_P07_blk_F`
  - **SIG P226 (West German)** : `hlc_pistol_P226WestGerman`
  - **SigSauer Mk25-D** : `hlc_pistol_Mk25D`
  - **SigSauer P226R (.357 SIG)** : `hlc_pistol_P226R_357`
- **Accessoires d'armes** : 75% des armes générées doivent obligatoirement être équipées d'une lampe torche.
- **Gilets et Sacs** : 
  - Aucun sac à dos.
  - Veste obligatoire du mod VSM (avec la règle stricte d'exclusion : pas de black/white/alpine/WTF).
- **Inventaire (dans la veste)** :
  - 2x `FirstAidKit`
  - 2x Grenade fumigène blanche (`SmokeShell`)
  - S'ils ont une arme principale : 6 chargeurs principaux + 2 chargeurs secondaires.
  - S'ils n'ont pas d'arme principale : 8 chargeurs secondaires.
- **Règle d'armement** : 10% des ennemis spawneront sans arme principale et se battront uniquement avec leur arme secondaire.