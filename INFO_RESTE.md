# 🚀 GHOSTS 2035 — PLAN DE FINALISATION & GUIDE STEAM WORKSHOP

Ce document recense l'intégralité des éléments techniques, visuels, textuels et organisationnels nécessaires pour finaliser la mission **GHOSTS 2035** et assurer une publication professionnelle sur le **Steam Workshop d'Arma 3**.

---

## 📊 DIAGNOSTIC ACTUEL DU PROJET

| Composant | Statut Actuel | Ce qui reste à faire |
| :--- | :---: | :--- |
| **Logique Serveur & SP/COOP** | ✅ 100% | Rotation active des 7 missions opérationnelles (Task 00 à Task 06). |
| **Modules CfgFunctions** | ✅ 100% | Nettoyé et aligné sur les fichiers existants (aucun résidu de tâche annulée). |
| **Métadonnées & Menus (`description.ext`)** | ✅ 100% | Configuré (`overviewText`, `overviewPicture`, `disabledAI = 1`, `saving = 0`). |
| **Asset Graphique Workshop (`preview.jpg`)** | ✅ 100% | Vignette emblématique carrée créée (512x512) et liée à `overviewPicture`. |
| **Localisation & Textes (`stringtable.xml`)** | ✅ 100% | Compilé et synchronisé en multi-langues via `compile_stringtable.py`. |
| **Page Steam Workshop (BBCode / Présentation)** | ✅ 100% | Modèle BBCode rédigé et prêt à l'emploi avec la modlist exacte et les crédits. |
| **Validation & Packaging PBO** | ⏳ Prêt | Exportation du `.pbo` via l'Éditeur 3DEN ou Arma 3 Tools. |

---

## 🛠️ 1. CONFIGURATION TECHNIQUE & PORTABILITÉ MULTI-CARTES (`description.ext`)

Pour assurer une compatibilité immédiate avec toutes les cartes d'Arma 3 (Enoch/Livonia, Altis, Tanoa, Chernarus, etc.) sans créer de visuels hors-sujet :

### Paramètres recommandés dans `description.ext` :
- **`overviewText`** : Description courte et universelle affichée dans la liste des scénarios.
- **`disabledAI = 1;`** : Empêche les slots multijoueur non occupés de spawner en IA statiques (la gestion de l'escouade restant assurée par les scripts).
- **`saving = 0;`** : Désactive la sauvegarde automatique SP pour éviter toute corruption des scripts asynchrones.
- **Écrans de chargement & Aperçus** : Laissés par défaut au moteur du jeu, ce qui permet à Arma 3 d'afficher automatiquement les superbes arrière-plans officiels de la carte sélectionnée.

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

## 🎨 3. ASSET VISUEL WORKSHOP (UNIQUE & UNIVERSEL)

Pour assurer une publication rapide et une compatibilité multi-cartes totale :

1. **Vignette Principale Workshop (`preview.jpg`)** :
   - *Format* : Carré `512x512` px (JPG ou PNG < 2 Mo).
   - *Design Recommandé (Universel)* : Logo "GHOSTS 2035", fond tactique sombre (vision nocturne, carte topographique ou réticule balistique), silhouette d'un sniper et du drone Darter.
   - *Avantage* : Ce visuel sert de signature officielle et s'adapte sans modification à n'importe quelle carte (Enoch, Altis, Tanoa, etc.).
2. **Écrans In-Game (Chargement & Menus)** :
   - Laissés aux visuels par défaut du moteur Arma 3 pour afficher automatiquement les arrière-plans officiels de la carte jouée sans aucun risque de hors-sujet.

---

## 📝 4. FICHE STEAM WORKSHOP (MODÈLE BBCODE PRÊT À L'EMPLOI - EN)

Voici la structure optimisée en **Anglais** (recommandé pour le Steam Workshop international) à copier-coller dans la description Steam :

```bbcode
[h1]🦅 GHOSTS 2035 — ELITE SNIPER OPERATING CELL [SP / COOP 1-4][/h1]

[b]GHOSTS 2035[/b] is a next-generation tactical special operations scenario, designed for [b]Singleplayer[/b] and [b]Cooperative play (1 to 4 players)[/b]. Infiltrate deep behind enemy lines commanding a specialized elite sniper micro-cell.

[hr][/hr]

[h2]⚡ KEY FEATURES[/h2]

[list]
[*] [b]Universal Dynamic Generation[/b]: Automated rotation of 7 surgical high-stakes operations (Hostage Rescue, Staff HVT Hunt, Radio Relay Sabotage, Explosive Charge Disarming, Chemical Tanker Interception with progressive toxic hazards, High-Value Target Extraction & Surrender).
[*] [b]ISR Drone & Sniper Synergy[/b]: Dynamic aerial support via an autonomous allied Darter drone (real-time tactical radar coverage and target designation).
[*] [b]Total & Clean Immersion[/b]: Zero interface clutter, zero intrusive pop-up hints. Pure tactical military gameplay.
[*] [b]Dynamic Weather & Living Atmosphere[/b]: Randomized starting time and weather with a realistic dynamic weather cycle (misty dawn, stormy afternoons, overcast fronts, pitch-black night ops).
[*] [b]Native Medical & Squad Continuity[/b]: Emergency revive system usable by any teammate with seamless squad leadership failover.
[*] [b]Heavy Close Air Support & Hot Extraction[/b]: Assault helicopter exfiltration featuring automated door-gunner suppression fire on hot landing zones.
[*] [b]ACE3 Compatibility[/b]: Fully compatible with [b]ACE3[/b] advanced ballistics, environmental physics, and medical framework.
[/list]

[hr][/hr]

[h2]📦 REQUIRED MODS & DEPENDENCIES[/h2]

[b]Required :[/b]
[list]
[*] [b]Arma 3 Contact[/b] (DLC / Map Enoch / Livonia)
[*] [b]CBA_A3[/b] (Community Base Addons)
[*] [b]VSM - All-In-One Collection[/b] (Tactical uniforms, vests, and gear)
[*] [b]NIArms / HLC Weapons[/b] (Modern precision weapons & rifles)
[/list]

[b]Optional & Supported (Highly Recommended) :[/b]
[list]
[*] [b]ACE3[/b] (Advanced ballistics, wind deflection, advanced medical & interaction).
[*] [b]UVO (Unit Voice-Overs)[/b] & [b]UVO Expanded[/b] (Dynamic combat chatter in US/UK/FR for BLUFOR and 100% Russian for OPFOR).
[/list]

[hr][/hr]

[h2]🎮 HOW TO PLAY[/h2]

[b]Singleplayer :[/b]
Main Menu ➔ Scenarios ➔ Select "GHOSTS 2035".

[b]Multiplayer / Dedicated Server :[/b]
Multiplayer Menu ➔ Host Server / Dedicated Server ➔ Select Map ➔ Select "GHOSTS 2035".
[/bbcode]
```

---

## 🧪 5. PROTOCOLE D'ASSURANCE QUALITÉ (CHECKLIST DE TEST)

Avant de publier le fichier `.pbo`, tester les points suivants :

- [ ] **Séquence d'Introduction** : Vérifier que les 4 caméras s'enchaînent sans accroc, que la vue cockpit permet le freelook, et que le skip (Espace 1.2s) fonctionne.
- [ ] **Arsenal Initial** : Caisse d'arsenal bien accessible au sol, drone Darter correctement initialisé.
- [ ] **Lancement de Tâche** : Vérifier que les objectifs spawnent à $\ge 400\text{ m}$ des joueurs, sans collision d'objets (`Z + 0.2`).
- [ ] **Task 04 (Convoi Chimique)** : Vérifier que les dégâts sur la citerne déclenchent la fuite progressive et que l'hélicoptère effectue correctement l'élingage / repli.
- [ ] **Task 06 (Capture d'HVT)** : Vérifier que le HVT suit fluidement le joueur sans se bloquer et monte dans l'hélicoptère.
- [ ] **Extraction Finale** : Vérifier que l'hélicoptère effectue l'appui aérien, atterrit, embarque l'escouade et valide la fin de mission.

---

## 📦 6. PROCÉDURE D'EXPORTATION & PUBLICATION

1. Ouvrir la mission dans l'éditeur **3DEN**.
2. Menu **Scénario** ➔ **Exporter** ➔ **Exporter en multijoueur** (génère le `.pbo` dans le dossier `MPMissions`).
3. Pour la publication Workshop :
   - Menu **Scénario** ➔ **Publier sur Steam Workshop**.
   - Renseigner le titre : `GHOSTS 2035 [SP/COOP]`.
   - Sélectionner votre vignette `preview.jpg` (`512x512` px).
   - Coller la description rédigée ci-dessus.
   - Taguer : `Scenario`, `Coop`, `Singleplayer`, `Modded`.
   - Mettre la visibilité en **Non listé (Unlisted)** ou **Amis uniquement** pour un test initial, puis passer en **Public**.

---

## 🖼️ 7. FICHE UNIQUE DU VISUEL REQUIS

| Fichier Requis | Emplacement | Format & Dimensions | Rôle & Usage | Ce que l'image doit montrer |
| :--- | :--- | :--- | :--- | :--- |
| **`preview.jpg`** | Racine du projet / Sélection 3DEN | **JPG / PNG**<br>`512x512` px<br>(Ratio 1:1, < 2 Mo) | **Vignette Steam Workshop** (Couverture principale de la vitrine) | • Logo **"GHOSTS 2035"** avec sous-titre **"[SP/COOP 1-4]"**.<br>• Gros plan ou silhouette sur un sniper d'élite (casque moderne, lunettes/NVG).<br>• Fond sombre universel (teintes vert olive / anthracite, réticule balistique et silhouette du drone Darter).<br>• *Sans décor spécifique pour pouvoir être réutilisé sur n'importe quelle carte.* |


