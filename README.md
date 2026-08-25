# GHOSTS 2035 [SP/COOP]

Ce fichier documente l'architecture technique et les fonctionnalités de la mission **GHOSTS 2035 (Unité de snipers d'élite)**, conçue pour être jouable en Solo ou en Coopératif (jusqu'à 4 joueurs).

## Philosophie de Conception
- **Contexte Temporel & Univers** : 2035 (Canon Arma 3) — Cadre futuriste proche, équipements militaires de pointe et opérations spéciales contemporaines/2035.
- **Immersif & Silencieux** : Le code est purement fonctionnel. Aucun commentaire, aucun log de debug (`diag_log`), aucun message système (`systemChat`) ni popup (`hint`) n'est toléré pour garantir une immersion absolue.
- **Opérations Spéciales Tactiques** : Scénarios orientés action directe, infiltration, sabotage, capture de cibles et contre-guérilla en milieu hostile (sans présence de population civile passive).
- **Architecture Modulaire** : Le code est divisé en modules enregistrés via [cfgFunctions.hpp](file:///c:/Users/kevin/Documents/Arma%203/missions/TheUnseenElement.Enoch/Functions/cfgFunctions.hpp) (Medical, Environment, Equipment, Player, Task) pour garantir des performances optimales et une clarté de structure.

---

## Modules Techniques

### 1. Module Médical (Medical)
- **Auto-soin IA** : Les IA (alliées et ennemies) s'auto-soignent si elles sont gravement blessées (animation de secourisme de 6 secondes) et possèdent une trousse de soin.

### 2. Module Environnement (Environment)
- **Météo Dynamique** : Le climat évolue de façon aléatoire et progressive toutes les 40 minutes, garantissant des conditions de combat toujours renouvelées et imprévisibles.
- **Gestion de la Fatigue** : La stamina et le tressaillement des joueurs humains sont optimisés via une boucle dédiée pour garantir une expérience de tir fluide.
- **Compétences IA (Skills)** : 
  - IA BLUFOR (Alliés) : Précision Élite et tactiques maximales.
  - IA OPFOR/Indépendants (Ennemis) : Compétences réduites (Low/Med) pour équilibrer les affrontements.
- **Drone Allié Radar** : Système de surveillance aérienne dynamique via le drone darter allié.

### 3. Module d'Équipement (Equipment)
Générateur d'équipement dynamique OPFOR (détection automatique par scan du serveur en temps réel).
- **Camouflage Strict** : Habillage aléatoire intégralement issu du mod VSM, avec exclusion formelle des couleurs inadaptées (Black, White, Alpine, WTF).
- **Inventaire Tactique** : Pas de sacs à dos. Vestes VSM obligatoires contenant 2 Trousses de secours et 2 Fumigènes blancs.
- **Armement Varié & Asymétrique** : 
  - 10% des ennemis n'ont pas d'arme principale (armes de poing uniquement).
  - Les armes compatibles reçoivent dynamiquement une lampe torche dans 75% des cas, avec allumage forcé de nuit (`forceOn`).
  - Répartition intelligente des munitions : 6 chargeurs principaux, 2 secondaires (ou 8 secondaires si pas d'arme principale).
- **Couvre-chefs** : 90% des troupes portent un couvre-chef tactique VSM (BackwardsHat, Beanie, Boonie, Cap, Shemagh).

### 4. Module Joueur (Player)
Gestion dynamique et asymétrique de l'escouade jouable (`Player_0` à `Player_3`).
- **Génération d'Identité & Voix Immersives** : Attribution automatique et aléatoire de noms, visages et profils vocaux natifs. Support dynamique et optionnel des mods **UVO (Unit Voice-Overs)** et **UVO Expanded** (voix immersives US, UK, FR pour BLUFOR / 100% Russe pour OPFOR, sans dépendance obligatoire).
- **Continuité de Commandement** : Le poste de Leader de l'escouade est intelligemment maintenu. Si le chef humain meurt, le prochain joueur (ou à défaut, la prochaine IA alliée en vie) prend automatiquement le commandement.
- **Respawn Tactique (Possession)** : En cas de mort, le joueur ne retourne pas au lobby mais "possède" instantanément le corps de l'IA alliée survivante de son groupe pour poursuivre la mission (Respawn type `GROUP` / `4`). La mission n'échoue que si l'escouade entière est anéantie.
- **Règles d'Engagement (ROE)** : Les joueurs disposent d'un menu d'action (molette) pour changer la posture tactique de leur escouade IA (Stealth, Normal, Assault) de façon instantanée et totalement silencieuse.

### 5. Module Tâches, Cinématique & Extraction (Task)
- **Introduction Dynamique** : Une cinématique d'introduction gérant intelligemment le point d'atterrissage des joueurs via un hélicoptère IA de transport. Les positions de caméra respectent strictement une altitude minimale de $12\text{ m}$ du sol et un espacement de $\ge 500\text{ m}$ pour une perspective et profondeur optimales.
- **Arsenal de Départ** : Génération d'une caisse d'arsenal optimisée et contextuelle au point d'atterrissage, équipée du drone allié et balisée temporairement, pour permettre aux joueurs de se préparer.
- **Scénario 100% Automatisé** :
  - **Lancement** : 15 secondes après l'arrivée à l'arsenal, le serveur sélectionne et lance automatiquement une tâche aléatoire parmi les missions disponibles.
  - **Génération Dynamique** : Analyse dynamique de la carte, filtrage des Game Logics à une distance de sécurité stricte ($\ge 400\text{ m}$) de tout joueur vivant par paliers progressifs ($+50\text{ m}$), puis génération des objectifs, des patrouilles ennemies échelonnées (via `BIS_fnc_taskPatrol`) et des marqueurs de carte. 
  - **Extraction Auto** : Dès que l'objectif est accompli (ou échoué), la mission lance automatiquement une séquence d'extraction ([fn_extraction.sqf](file:///c:/Users/kevin/Documents/Arma%203/missions/TheUnseenElement.Enoch/Functions/Task/fn_extraction.sqf)). Un hélicoptère atterrit sur l'héliport invisible le plus proche pour embarquer l'escouade sous le feu d'une contre-attaque ennemie ([fn_taskCleanup.sqf](file:///c:/Users/kevin/Documents/Arma%203/missions/TheUnseenElement.Enoch/Functions/Task/fn_taskCleanup.sqf)), puis valide la victoire (`End1`) une fois hors de danger.

---

## 🎯 Liste des Tâches Actives en Rotation

| Tâche | Fichier SQF | Description Opérationnelle |
| :--- | :--- | :--- |
| **Task 00** | [fn_task00.sqf](file:///c:/Users/kevin/Documents/Arma%203/missions/TheUnseenElement.Enoch/Functions/Task/fn_task00.sqf) | **Libération d'Otage** : Infiltration d'un complexe sous haute surveillance, neutralisation des gardes et libération d'un captif allié avant exfiltration. |
| **Task 01** | [fn_task01.sqf](file:///c:/Users/kevin/Documents/Arma%203/missions/TheUnseenElement.Enoch/Functions/Task/fn_task01.sqf) | **Assassinat & Renseignement** : Élimination d'un officier supérieur ennemi dans l'un des secteurs cibles et récupération de documents confidentiels sur sa dépouille. |
| **Task 02** | [fn_task02.sqf](file:///c:/Users/kevin/Documents/Arma%203/missions/TheUnseenElement.Enoch/Functions/Task/fn_task02.sqf) | **Désamorçage Multiple** : Localisation et désamorçage tactique de plusieurs engins explosifs sous pression d'un compte à rebours. |
| **Task 03** | [fn_task03.sqf](file:///c:/Users/kevin/Documents/Arma%203/missions/TheUnseenElement.Enoch/Functions/Task/fn_task03.sqf) | **Destruction de Relais Radio** : Pose de charges explosives sur les terminaux de transmission ennemis pour paralyser leurs réseaux de communication. |
| **Task 04** | [fn_task04.sqf](file:///c:/Users/kevin/Documents/Arma%203/missions/TheUnseenElement.Enoch/Functions/Task/fn_task04.sqf) | **Interception de Convoi Chimique** : Sécurisation d'un camion-citerne toxique immobilisé sans le détruire, élimination de son escorte et extraction par élingue (slingload). |
| **Task 05** | [fn_task05.sqf](file:///c:/Users/kevin/Documents/Arma%203/missions/TheUnseenElement.Enoch/Functions/Task/fn_task05.sqf) | **Élimination des Chefs de Milice** : Traque et élimination coordonnée de commandants ennemis dispersés dans la zone d'opérations. |
| **Task 06** | [fn_task06.sqf](file:///c:/Users/kevin/Documents/Arma%203/missions/TheUnseenElement.Enoch/Functions/Task/fn_task06.sqf) | **Capture d'HVT & Reddition** : Neutralisation de la garde rapprochée d'un officier de haut rang, capture au corps-à-corps et escorte du prisonnier jusqu'au point d'évacuation. |

---

## Documentation Complémentaire
La conception de nouvelles tâches ou interactions suit des règles extrêmement strictes détaillées dans les fichiers suivants :
- **[INFO_EDITOR.md](file:///c:/Users/kevin/Documents/Arma%203/missions/TheUnseenElement.Enoch/INFO_EDITOR.md)** : Référence sur les entités placées dans l'éditeur, l'équipement et les règles de spawn.
- **[INFO_TASKS.md](file:///c:/Users/kevin/Documents/Arma%203/missions/TheUnseenElement.Enoch/INFO_TASKS.md)** : Référentiel technique obligatoire pour la création de tâches, addActions, synchronisation multijoueur et nettoyage.
- **[INFO_STRINGABLE.md](file:///c:/Users/kevin/Documents/Arma%203/missions/TheUnseenElement.Enoch/INFO_STRINGABLE.md)** : Méthode d'intégration modulaire des textes et traductions via XML.

---

## Outils de Nettoyage & Maintenance
La mission intègre des outils de développement Python pour automatiser les tâches complexes et garantir le respect des standards :
- **`strip_comments.py`** & **`strip_logs.py`** : Nettoient automatiquement l'intégralité du code source (retrait des commentaires et des logs) avant tout déploiement.
- **`compile_stringtable.py`** : Génère automatiquement le fichier `stringtable.xml` final à partir de petits fichiers XML modulaires répartis dans les dossiers de développement.
