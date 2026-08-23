# The Unseen Element [SP/COOP]

Ce fichier documente l'architecture technique et les fonctionnalités de la mission **The Unseen Element (TUE)**, conçue pour être jouable en Solo ou en Coopératif (jusqu'à 4 joueurs).

## Philosophie de Conception
- **Immersif & Silencieux** : Le code est purement fonctionnel. Aucun commentaire, aucun log de debug (`diag_log`), aucun message système (`systemChat`) ni popup (`hint`) n'est toléré pour garantir une immersion absolue.
- **Architecture Modulaire** : Le code est divisé en modules enregistrés via `cfgFunctions.hpp` (Medical, Environment, Equipment) pour garantir des performances optimales et une clarté de structure.

## Modules Techniques

### 1. Module Médical (Medical)
- **Auto-soin IA** : Les IA (alliées et ennemies) s'auto-soignent si elles sont gravement blessées (animation de secourisme de 6 secondes) et possèdent une trousse de soin.

### 2. Module Environnement (Environment)
- **Météo Dynamique** : Le climat évolue de façon aléatoire et progressive toutes les 40 minutes, garantissant des conditions de combat toujours renouvelées et imprévisibles.
- **Gestion de la Fatigue** : La stamina et le tressaillement des joueurs humains sont optimisés via une boucle dédiée pour garantir une expérience de tir fluide.
- **Compétences IA (Skills)** : 
  - IA BLUFOR (Alliés) : Précision Élite et tactiques maximales.
  - IA OPFOR/Indépendants (Ennemis) : Compétences réduites (Low/Med) pour équilibrer les affrontements.

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
Gestion dynamique et asymétrique de l'escouade jouable (Player_0 à Player_3).
- **Génération d'Identité** : Attribution automatique et aléatoire de noms, visages, et voix (mod UVO) cohérentes avec différentes ethnies.
- **Continuité de Commandement** : Le poste de Leader de l'escouade est intelligemment maintenu. Si le chef humain meurt, le prochain joueur (ou à défaut, la prochaine IA alliée en vie) prend automatiquement le commandement.
- **Respawn Tactique (Possession)** : En cas de mort, le joueur ne retourne pas au lobby mais "possède" instantanément le corps de l'IA alliée survivante de son groupe pour poursuivre la mission (Respawn type `GROUP` / `4`). La mission n'échoue que si l'escouade entière est anéantie.
- **Règles d'Engagement (ROE)** : Les joueurs disposent d'un menu d'action (molette) pour changer la posture tactique de leur escouade IA (Stealth, Normal, Assault) de façon instantanée et totalement silencieuse.

### 5. Module Tâches, Cinématique & Extraction (Task)
- **Introduction Dynamique** : Une cinématique d'introduction gérant intelligemment le point d'atterrissage des joueurs via un hélicoptère IA de transport. Les positions sont générées dynamiquement en fonction de la mission.
- **Arsenal de Départ** : Génération d'une caisse d'arsenal optimisée et contextuelle au point d'atterrissage, équipée du drone allié et balisée temporairement, pour permettre aux joueurs de se préparer.
- **Scénario 100% Automatisé** :
  - **Lancement** : 45 secondes après l'atterrissage, le serveur sélectionne et lance automatiquement une tâche aléatoire (Assassiner, Saboter, Libérer, etc.).
  - **Génération Dynamique** : Fini les cibles placées à la main. Le script analyse dynamiquement la carte, filtre les lieux par distance de sécurité avec les joueurs, puis génère les objectifs, les PNJ, les patrouilles (via `BIS_fnc_taskPatrol`) et les marqueurs de carte. 
  - **Extraction Auto** : Dès que l'objectif est accompli (ou échoué), la mission lance automatiquement une séquence d'extraction (`fn_extraction.sqf`). Un hélicoptère cherche l'héliport invisible le plus proche, vient chercher les joueurs survivants sous le feu d'une contre-attaque ennemie (via `fn_taskCleanup.sqf`), puis valide la victoire (`End1`) une fois l'escouade hors de danger.

## Documentation Complémentaire
La conception de nouvelles tâches ou interactions suit des règles extrêmement strictes détaillées dans des fichiers séparés :
- **[INFO_EDITOR.md](file:///c:/Users/kevin/Documents/Arma%203/missions/TheUnseenElement.Enoch/INFO_EDITOR.md)** : Référence sur les entités placées dans l'éditeur et l'armement.
- **[INFO_ETAPES.md](file:///c:/Users/kevin/Documents/Arma%203/missions/TheUnseenElement.Enoch/INFO_ETAPES.md)** : Suivi et consignes des étapes de développement.
- **[INFO_STRINGABLE.md](file:///c:/Users/kevin/Documents/Arma%203/missions/TheUnseenElement.Enoch/INFO_STRINGABLE.md)** : Méthode d'intégration non destructive des textes et traductions de la mission.

## Outils de Nettoyage & Maintenance
La mission intègre des outils de développement Python pour automatiser les tâches complexes et garantir le respect des standards :
- **`strip_comments.py`** & **`strip_logs.py`** : Nettoient automatiquement l'intégralité du code source (retrait des commentaires et des logs) avant tout déploiement.
- **`compile_stringtable.py`** : Génère automatiquement le fichier `stringtable.xml` final à partir de petits fichiers XML modulaires répartis dans les dossiers de développement.
