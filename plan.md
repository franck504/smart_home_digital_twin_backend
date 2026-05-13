# TITRE : Conception d'un Jumeau Numérique pour l'Optimisation du Smart Building
## Sous-titre : Connectivité IoT, efficacité énergétique, confort thermique et sécurité des occupants

---

# INTRODUCTION

# PARTIE 1 : CADRE THÉORIQUE ET ANALYSE DES ENJEUX DU SMART BUILDING

## Chapitre 1 : Fondements théoriques et paradigme du Jumeau Numérique
### 1.1 Défis énergétiques et cadre réglementaire du bâtiment moderne
#### 1.1.1 Enjeux de la transition énergétique et décarbonation
#### 1.1.2 Évolution des normes environnementales (Focus sur la RE2020)
### 1.2 Le Digital Twin : Pilier de la transformation numérique du bâtiment
#### 1.2.1 Concepts fondamentaux et architecture de référence
#### 1.2.2 Apports du jumeau numérique à la gestion du cycle de vie des édifices

## Chapitre 2 : Étude préliminaire et spécifications du système
### 2.1 Analyse de la problématique et scénarios d'usage
#### 2.1.1 Identification des gaspillages énergétiques et besoins de confort
#### 2.1.2 Définition des scénarios de vie (Présence, Absence, Mode Nuit)
### 2.2 Définition des piliers fonctionnels du projet
#### 2.2.1 Bâtiments connectés : Interopérabilité et écosystème IoT
#### 2.2.2 Gestion énergétique : Monitoring et stratégies d'optimisation
#### 2.2.3 Confort et sécurité : Automatisation et contrôle intelligent du milieu

# PARTIE 2 : CONCEPTION ARCHITECTURALE ET MODÉLISATION DU SYSTÈME

## Chapitre 3 : Architecture système et protocoles de communication
### 3.1 Conception globale et schéma bloc-fonctionnel
#### 3.1.1 Architecture logicielle conteneurisée (Docker)
#### 3.1.2 Flux de données entre les couches physique et applicative
### 3.2 Protocoles d'échanges et diagrammes de flux
#### 3.2.1 Messagerie asynchrone via MQTT (HiveMQ/Mosquitto)
#### 3.2.2 Flux bidirectionnels et temps réel via WebSockets

## Chapitre 4 : Implémentation de l'infrastructure logicielle et matérielle
### 4.1 Couche physique et instrumentation IoT
#### 4.1.1 Configuration matérielle de l'unité de calcul ESP32
#### 4.1.2 Programmation des capteurs et actuateurs en MicroPython (Wokwi)
### 4.2 Moteur décisionnel, modèle de données et algorithmes
#### 4.2.1 Développement de l'API REST décisionnelle (FastAPI)
#### 4.2.2 Modélisation de la persistance des données (Pydantic, InfluxDB)

# PARTIE 3 : RÉALISATION ET VALIDATION DES RÉSULTATS

## Chapitre 5 : Conception des interfaces de monitoring et de visualisation
### 5.1 Interface mobile et gestion des flux de données
#### 5.1.1 Architecture de l'application et Design UI (Flutter)
#### 5.1.2 Gestion d'état réactive et synchronisation (Riverpod)
### 5.2 Visualisation spatiale et immersion 3D
#### 5.2.1 Modélisation de la scène et rendu (Three.js / React Three Fiber)
#### 5.2.2 Mapping de l'état du jumeau sur les assets 3D

## Chapitre 6 : Évaluation expérimentale et discussion des résultats
### 6.1 Validation des performances par indicateur de succès
#### 6.1.1 Fiabilité de la connectivité et synchronisation temps réel
#### 6.1.2 Évaluation de l'efficacité des algorithmes d'économie d'énergie
#### 6.1.3 Mesure de la réactivité des systèmes de confort et sécurité
### 6.2 Analyse critique, limites du prototype et perspectives d'évolution
#### 6.2.1 Analyse de la scalabilité et de la cybersécurité
#### 6.2.2 Perspectives d'intégration de l'Intelligence Artificielle

# CONCLUSION

---

# RÉFÉRENCES

### Bibliographie (Biblio)
*   **[1]** : Grieves, M., & Vickers, J. (2017). "*Digital Twin: Mitigating Cyclical Trajectories of Industrial Production*". Springer. (Théorie fondamentale du Jumeau Numérique).
*   **[2]** : Ministère de la Transition Écologique. "*Règlementation Environnementale RE2020 : Éco-construire pour le futur*". (Normes et cadre légal du bâtiment intelligent).
*   **[3]** : Fuller, A., et al. (2020). "*Digital Twin: Enabling Technologies, Challenges and Open Research*". IEEE Access. (Analyse des technologies IoT et Cloud).
*   **[4]** : Al-Sakran, H. (2015). "*Intelligent Building Management Systems Based on Cloud Computing and MQTT*". (Étude sur l'efficacité du protocole MQTT).

### Webographie (Web)
*   **[5]** : Eclipse Foundation. "*MQTT: The Standard for IoT Messaging*". [https://mqtt.org/](https://mqtt.org/)
*   **[6]** : FastAPI Documentation. "*Modern, high-performance web framework*". [https://fastapi.tiangolo.com/](https://fastapi.tiangolo.com/)
*   **[7]** : Flutter.dev. "*Build apps for any screen*". [https://flutter.dev/](https://flutter.dev/)
*   **[8]** : Wokwi Documentation. "*Simulator for Arduino, ESP32, and STM32*". [https://docs.wokwi.com/](https://docs.wokwi.com/)
*   **[9]** : InfluxData. "*InfluxDB: Time Series Data Platform*". [https://www.influxdata.com/](https://www.influxdata.com/)

