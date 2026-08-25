# 🚀 GHOSTS 2035 — PLAN DE FINALISATION & GUIDE STEAM WORKSHOP

Ce document recense l'intégralité des éléments techniques, visuels, textuels et organisationnels nécessaires pour finaliser la mission **GHOSTS 2035** et assurer une publication professionnelle sur le **Steam Workshop d'Arma 3**.

---

## 📊 DIAGNOSTIC ACTUEL DU PROJET

| Composant | Statut Actuel | Ce qui reste à faire |
| :--- | :---: | :--- |
| **Logique Serveur & SP/COOP** | ✅ 100% | Rotation active des 7 missions opérationnelles (Task 00 à Task 06). |
| **Modules CfgFunctions** | ✅ 100% | Nettoyé et aligné sur les fichiers existants (aucun résidu de tâche annulée). |
| **Métadonnées & Menus (`description.ext`)** | ⚠️ 60% | Ajouter les balises d'aperçu (`overviewPicture`, `overviewText`, `loadScreen`). |
| **Assets Graphiques (UI & Workshop)** | ❌ 20% | Créer la vignette Workshop, l'écran de chargement et les captures d'écran promotionnelles. |
| **Localisation & Textes (`stringtable.xml`)** | ✅ 95% | Exécuter `compile_stringtable.py` pour valider la synchronisation multi-langues. |
| **Page Steam Workshop (BBCode / Présentation)** | ⚠️ 50% | Rédiger la mise en page finale en BBCode Steam avec la modlist exacte et les crédits. |
| **Validation & Packaging PBO** | ⏳ 0% | Tests QA finaux (Solo + Multi/JIP) et export via l'Éditeur 3DEN ou Arma 3 Tools. |

---

## 🛠️ 1. CONFIGURATION TECHNIQUE & MÉTADONNÉES (`description.ext`)

Pour qu'un scénario apparaisse proprement dans le menu des missions d'Arma 3 et sur le Workshop, `description.ext` doit être complété :

### Éléments à ajouter dans `description.ext` :
- **`overviewPicture`** : Image au format `.paa` ou `.jpg` (1024x512 / ratio 2:1) affichée dans la liste des scénarios solo/multi.
- **`overviewText`** : Description courte et percutante affichée avant de lancer la partie.
- **`loadScreen`** : Image plein écran (1920x1080 / ratio 16:9) affichée pendant le chargement.
- **`disabledAI = 1;`** : Empêche les slots multijoueur non occupés de spawner en IA statiques non contrôlées (la gestion d'escouade restant assurée par le script).
- **`saving = 0;`** : Désactive la sauvegarde automatique SP pour éviter toute corruption des scripts asynchrones.

---

## 🧩 2. HARMONISATION DU CODE & DES TÂCHES

### A. Périmètre Final des Tâches (Task 00 à Task 06)
- [cfgFunctions.hpp](file:///c:/Users/kevin/Documents/Arma%203/missions/TheUnseenElement.Enoch/Functions/cfgFunctions.hpp) est 100% propre et ne contient aucune référence orpheline.
- La rotation active comprend **7 opérations complètes et testées** :
  - **Task 00** : *Opération Broken Cage* (Sauvetage d'Otage)
  - **Task 01** : *Opération Black Ledger* (Assassinat & Renseignement)
  - **Task 02** : *Opération Defused Shadow* (Désamorçage Multiple)
  - **Task 03** : *Opération Blind Signal* (Destruction de Relais)
  - **Task 04** : *Opération Crimson Hazard* (Interception Chimique & Slingload)
  - **Task 05** : *Opération Decapitation* (Élimination des Chefs de Milice)
  - **Task 06** : *Opération Live Asset* (Capture d'HVT & Reddition)

### B. Scripts de Build & Nettoyage Final
Avant tout packaging, exécuter impérativement dans l'ordre :
1. `python compile_stringtable.py` (Met à jour `stringtable.xml`).
2. `python strip_logs.py` (Supprime les traces de debug).
3. `python strip_comments.py` (Garantit un code SQF 100% silencieux sans commentaires).

---

## 🎨 3. ASSETS VISUELS & MARKETING WORKSHOP

Pour maximiser l'impact visuel et le taux de téléchargement sur le Steam Workshop :

1. **Vignette Principale Workshop (Icon/Cover)** :
   - *Format* : Carré `512x512` px (JPG ou PNG < 2 Mo).
   - *Visuel* : Logo "GHOSTS 2035", sniper camouflé avec optique thermique, ambiance sombre/nocturne d'Enoch/Livonia avec le drone Darter en surimpression.
2. **Écran de Chargement In-Game (`loadScreen.paa` / `.jpg`)** :
   - *Format* : `1920x1080` ou `2048x1024` px.
3. **Galerie de Captures d'Écran Steam (5 à 8 images clés)** :
   - *Capture 1* : Insertion cinématique en Ghost Hawk (vue travelling & cockpit NVG).
   - *Capture 2* : Overwatch sniper avec spotter et désignation laser/drone Darter.
   - *Capture 3* : Infiltration silencieuse dans les forêts denses d'Enoch sous la pluie.
   - *Capture 4* : Intervention sur camion chimique (nuage de gaz toxique).
   - *Capture 5* : Pose de charge C4 sur relais de communication.
   - *Capture 6* : Évacuation d'urgence sous le feu d'un hélicoptère lourd.

---

## 📝 4. FICHE STEAM WORKSHOP (MODÈLE BBCODE PRÊT À L'EMPLOI)

Voici la structure optimisée à copier-coller dans la description Steam Workshop :

```bbcode
[h1]🦅 GHOSTS 2035 — UNITE DE SNIPERS D'ELITE [SP / COOP 1-4][/h1]

[b]GHOSTS 2035[/b] est une mission tactique d'opérations spéciales nouvelle génération, conçue pour être jouée en [b]Solo[/b] ou en [b]Coopératif (1 à 4 joueurs)[/b]. Infiltrez les forêts denses et hostiles d'Enoch aux commandes d'une micro-cellule de tireurs d'élite hautement qualifiés.

[hr][/hr]

[h2]⚡ CARACTÉRISTIQUES PRINCIPALES[/h2]

[list]
[*] [b]Génération Dynamique Universelle[/b] : Rotation automatisée de 7+ scénarios chirurgicaux à haute tension (Sauvetage d'otage, Traque d'état-major, Sabotage de relais radio, Neutralisation de charges explosives, Interception de convoi chimique avec risques toxiques, Capture d'HVT).
[*] [b]Synergie Drone ISR & Sniper[/b] : Soutien aérien dynamique via le drone autonome Darter allié (couverture radar temps réel et désignation).
[*] [b]Immersion Totale & Silencieuse[/b] : Zéro spam d'interface, zéro hint intrusif. Dialogues radio immersifs, cinématique d'insertion 4 plans avec passage fluide en vue 1ère personne et vision nocturne adaptative.
[*] [b]Météo & Ambiance Vivante[/b] : Cycle météo dynamique réaliste à chaînes de Markov (aube brumeuse, après-midi orageux, opérations nocturnes sous JVN).
[*] [b]Système Médical & Revive Natif[/b] : Réanimation d'urgence par n'importe quel coéquipier et continuité absolue du commandement d'escouade.
[*] [b]Exfiltration & Contre-Attaque Agressive[/b] : Extraction lourde par hélicoptère d'assaut avec appui-feu de sabord sur zone d'atterrissage chaude.
[/list]

[hr][/hr]

[h2]📦 MODS REQUIS & DÉPENDANCES[/h2]

[b]Obligatoires :[/b]
[list]
[*] [b]Arma 3 Contact[/b] (DLC / Map Enoch)
[*] [b]CBA_A3[/b] (Community Base Addons)
[*] [b]VSM - All-In-One Collection[/b] (Équipements, tenues et vestes tactiques)
[*] [b]NIArms / HLC Weapons[/b] (Pack d'armement moderne)
[/list]

[b]Optionnels (Fortement recommandés pour une immersion audio maximale) :[/b]
[list]
[*] [b]UVO (Unit Voice-Overs)[/b] & [b]UVO Expanded[/b] (Voix dynamiques immersives US/UK/FR pour BLUFOR et 100% Russe pour OPFOR).
[/list]

[hr][/hr]

[h2]🎮 GUIDE DE LANCEMENT[/h2]

[b]En Solo :[/b]
Menu Principal ➔ Scénarios ➔ Sélectionner "GHOSTS 2035".

[b]En Multijoueur / Serveur Dédié :[/b]
Menu Multijoueur ➔ Héberger / Serveur ➔ Carte "Livonia / Enoch" ➔ Sélectionner "GHOSTS 2035".
[/bbcode]
```

---

## 🧪 5. PROTOCOLE D'ASSURANCE QUALITÉ (CHECKLIST DE TEST)

Avant de publier le fichier `.pbo`, tester les points suivants :

- [ ] **Séquence d'Introduction** : Vérifier que les 4 caméras s'enchaînent sans accroc, que la vue cockpit permet le freelook, et que le skip (Espace 1.2s) fonctionne.
- [ ] **Arsenal Initial** : Caisse d'arsenal bien accessible au sol, drone Darter correctement initialisé.
- [ ] **Lancement de Tâche** : Vérifier que les objectifs spawnent à $\ge 400\text{ m}$ des joueurs, sans collision d'objets (`Z + 0.2`).
- [ ] **Task 04 (Convoi Chimique)** : Vérifier que les dégâts sur la citerne déclenchent la fuite progressive et que l'hélicoptère effectue correctement l'élingage / repli.
- [ ] **Extraction Finale** : Vérifier que l'hélicoptère atterrit sur la LZ la plus proche, embarque les joueurs (et otages/HVT) et valide la fin victorieuse `End1`.
- [ ] **Multijoueur / JIP** : Tester la connexion d'un joueur en cours de partie (vérifier qu'il reçoit l'arsenal, les tâches et les marqueurs carte).

---

## 📦 6. PROCÉDURE D'EXPORTATION & PUBLICATION

1. Ouvrir la mission dans l'éditeur **3DEN**.
2. Menu **Scénario** ➔ **Exporter** ➔ **Exporter en multijoueur** (génère le `.pbo` dans le dossier `MPMissions`).
3. Pour la publication Workshop :
   - Menu **Scénario** ➔ **Publier sur Steam Workshop**.
   - Renseigner le titre : `GHOSTS 2035 [SP/COOP]`.
   - Sélectionner la vignette `512x512` créée.
   - Coller la description rédigée ci-dessus.
   - Taguer : `Scenario`, `Coop`, `Singleplayer`, `Modded`.
   - Mettre la visibilité en **Non listé (Unlisted)** ou **Amis uniquement** pour un test initial sur Steam, puis passer en **Public**.

---

## 🖼️ 7. RÉPERTOIRE DÉTAILLÉ DES ASSETS IMAGES REQUIS

Pour garantir une finition professionnelle en jeu et une attractivité maximale sur le Steam Workshop, voici la liste exhaustive des visuels à produire :

| Fichier Recommandé | Emplacement | Format & Dimensions | Rôle & Affichage | Ce que l'image doit montrer précisément |
| :--- | :--- | :--- | :--- | :--- |
| **`preview.jpg`** | Racine du projet / 3DEN | **JPG / PNG**<br>`512x512` px<br>(Ratio 1:1, < 2 Mo) | **Vignette Steam Workshop** (Couverture principale de la page) | • Logo percutant **"GHOSTS 2035"** avec sous-titre **"[SP/COOP 1-4]"**.<br>• Gros plan sur un sniper d'élite équipé d'un casque moderne, lunettes balistiques ou NVG relevées.<br>• Ambiance sombre/tactique aux teintes vert olive et anthracite avec réticule balistique et silhouette du drone Darter. |
| **`overview.paa`** *(ou `.jpg`)* | Racine du projet<br>`description.ext` | **PAA / JPG**<br>`1024x512` px<br>(Ratio 2:1, puissance de 2) | **Aperçu Menu du Jeu** (Menu Scénarios Solo & Liste des serveurs Multijoueur) | • Binôme tactique (Sniper en ghillie / tenue VSM + Spotter) en lisière de forêt observant la plaine.<br>• Hélicoptère Ghost Hawk allié survolant la zone à basse altitude.<br>• Typographie discrète et élégante *"GHOSTS 2035 - ENOCH"*. |
| **`loadScreen.paa`** *(ou `.jpg`)* | Racine du projet<br>`description.ext` | **PAA / JPG**<br>`1920x1080` ou `2048x1024` px<br>(Ratio 16:9 ou 2:1) | **Écran de Chargement In-Game** (Affiché en plein écran avant d'entrer dans la mission) | • Vue panoramique cinématographique d'une nuit d'orage sur la région de Livonia/Enoch.<br>• Opérateur Ghost vu de dos observant une base ennemie à travers des jumelles télémétriques.<br>• Éclair lointain illuminant la silhouette du drone Darter en vol stationnaire. |
| **`screenshot_01_insertion.jpg`** | Galerie Steam Workshop | **JPG**<br>`1920x1080` px (16:9) | Galerie promotionnelle (Image 1 : Infiltration) | • L'hélicoptère allié (MH-80 Ghost Hawk) en vol rasant au-dessus des cimes des pins sous une brume matinale dense. |
| **`screenshot_02_cockpit_nvg.jpg`** | Galerie Steam Workshop | **JPG**<br>`1920x1080` px (16:9) | Galerie promotionnelle (Image 2 : Immersion) | • Vue première personne depuis la cabine intérieure de l'hélico en vol nocturne avec vision nocturne (NVG) active et coéquipiers assis. |
| **`screenshot_03_sniper_drone.jpg`** | Galerie Steam Workshop | **JPG**<br>`1920x1080` px (16:9) | Galerie promotionnelle (Image 3 : Renseignement) | • Tireur d'élite en position d'overwatch dominant un complexe ennemi, avec le drone Darter en surimpression radar. |
| **`screenshot_04_chemical_hazard.jpg`** | Galerie Steam Workshop | **JPG**<br>`1920x1080` px (16:9) | Galerie promotionnelle (Image 4 : Convoi Chimique) | • Intervention tactique autour du camion-citerne (Task 04) avec dégagement volumétrique du nuage de gaz toxique jaune-vert. |
| **`screenshot_05_c4_sabotage.jpg`** | Galerie Steam Workshop | **JPG**<br>`1920x1080` px (16:9) | Galerie promotionnelle (Image 5 : Sabotage) | • Opérateur en posture accroupie posant une charge de démolition C4 sur un terminal de transmission ou désamorçant un IED. |
| **`screenshot_06_hostage_rescue.jpg`** | Galerie Steam Workshop | **JPG**<br>`1920x1080` px (16:9) | Galerie promotionnelle (Image 6 : Action Directe) | • Assaut d'un bâtiment en milieu hostile, neutralisation des gardes et sécurisation de l'otage allié (Task 00). |
| **`screenshot_07_hot_extraction.jpg`** | Galerie Steam Workshop | **JPG**<br>`1920x1080` px (16:9) | Galerie promotionnelle (Image 7 : Exfiltration) | • Zone d'atterrissage chaude : mitrailleurs de sabord ouvrant le feu pour couvrir la montée à bord des opérateurs sous la pression ennemie. |

