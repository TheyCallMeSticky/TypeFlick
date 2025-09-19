# 🎵 TypeFlick Monorepo - Complete Music Production Platform

> **A comprehensive music production ecosystem combining video generation, artist discovery, and beat creation tools.**

![TypeFlick Architecture](https://img.shields.io/badge/Architecture-Microservices-blue)
![Docker](https://img.shields.io/badge/Docker-Compose-2496ED?logo=docker)
![Next.js](https://img.shields.io/badge/Next.js-15.5-black?logo=next.js)
![FastAPI](https://img.shields.io/badge/FastAPI-Python-009688?logo=fastapi)
![PostgreSQL](https://img.shields.io/badge/PostgreSQL-16.4-336791?logo=postgresql)

Cette architecture combine la plateforme TypeFlick avec le système Artists Collector pour créer une solution complète de génération de vidéos et d'analyse d'artistes émergents.

## 🏗️ Architecture des Services

### 🎬 **Services TypeFlick** (Plateforme principale)
- **🏠 TypeFlick Site** (Next.js) - **Site web principal** pour créer et gérer des type beats avec génération de vidéos
- **🎥 TypeFlick Core** (FastAPI) - **Générateur de vidéos** automatique à partir d'audio et d'images
- **⚙️ Python Worker** (RQ) - Worker pour le traitement vidéo en arrière-plan
- **📝 Beat Metadata API** (Node.js) - **Générateur de SEO** automatique pour optimiser le référencement des type beats

### 🎯 **Services Artists Intelligence** (Recherche d'artistes)
- **🔍 Artists Collector** (FastAPI) - **Recherche intelligente d'artistes** pour type beats via APIs Spotify/YouTube
- **🎨 Artists Dashboard** (Next.js) - **Interface optionnelle** pour visualiser et gérer les artistes trouvés par le collector

### 🗄️ **Infrastructure**
- **PostgreSQL Principal** - Base de données TypeFlick (utilisateurs, projets, type beats)
- **PostgreSQL Artists** - Base de données dédiée aux artistes découverts
- **Redis** - Cache et queues pour les workers de traitement

## 🚀 Démarrage Rapide

### 1. **Prérequis**
```bash
# Docker et Docker Compose requis
docker --version
docker-compose --version
```

### 2. **Configuration**
```bash
# Cloner le repo
git clone https://github.com/votre-username/typeflick-monorepo.git
cd typeflick-monorepo

# Copier le fichier d'environnement
cp .env.example .env

# Éditer .env avec vos clés API
nano .env
```

### 3. **Démarrage**
```bash
# Construire et démarrer tous les services
docker compose up -d --build

# Voir les logs en temps réel
docker compose logs -f
```

### 4. **Initialisation des bases de données**
```bash
# Initialiser la base TypeFlick
./scripts/db-reset.sh

# Initialiser la base Artists (optionnel)
./scripts/db-reset-artists.sh
```

### 5. **Accès aux services**
- 🏠 **TypeFlick Site**: http://localhost:3000
- 🎨 **Artists Dashboard**: http://localhost:3002
- 📊 **APIs Documentation**: http://localhost:8000/docs & http://localhost:8001/docs

## 🔑 Configuration des Clés API

### 🎵 **Spotify API** (pour Artists Collector)
```bash
# 1. Aller sur https://developer.spotify.com/dashboard
# 2. Créer une nouvelle application
# 3. Récupérer les clés et les ajouter au .env
SPOTIFY_CLIENT_ID=your_spotify_client_id
SPOTIFY_CLIENT_SECRET=your_spotify_client_secret
```

### 📺 **YouTube API** (pour Artists Collector)
```bash
# 1. Aller sur https://console.cloud.google.com/
# 2. Activer l'API YouTube Data v3
# 3. Créer jusqu'à 12 clés API pour la rotation des quotas
YOUTUBE_API_KEY_1=your_first_youtube_key
YOUTUBE_API_KEY_2=your_second_youtube_key
# ... jusqu'à YOUTUBE_API_KEY_12 (optionnel)
```

### 💳 **Stripe** (pour TypeFlick Payments)
```bash
# 1. Aller sur https://dashboard.stripe.com/
# 2. Récupérer les clés de test ou production
STRIPE_SECRET_KEY=sk_test_your_stripe_secret
STRIPE_WEBHOOK_SECRET=whsec_your_webhook_secret
```

### ⚙️ **Configuration avancée**
- **Système adaptatif**: YouTube utilise automatiquement entre 1 et 12 clés selon disponibilité
- **Rate limiting**: Rotation automatique des clés YouTube pour éviter les quotas
- **Sécurité**: Variables sensibles dans .env (jamais committées)

## 🌐 URLs des Services

| Service | Port | URL | Description |
|---------|------|-----|-------------|
| 🏠 **TypeFlick Site** | 3000 | http://localhost:3000 | **Site web principal** - Création et gestion de type beats |
| 🎨 **Artists Dashboard** | 3002 | http://localhost:3002 | **Interface optionnelle** - Visualisation des artistes découverts |
| 🎥 **TypeFlick Core API** | 8000 | http://localhost:8000 | **Générateur de vidéos** - Traitement audio → vidéo |
| 🔍 **Artists Collector API** | 8001 | http://localhost:8001 | **Recherche d'artistes** - Intelligence Spotify/YouTube |
| 📝 **Beat Metadata API** | 3001 | http://localhost:3001 | **Générateur SEO** - Optimisation référencement |
| 🗄️ PostgreSQL (TypeFlick) | 54322 | localhost:54322 | Base de données principale (users, beats) |
| 🎪 PostgreSQL (Artists) | 54323 | localhost:54323 | Base de données artistes découverts |
| 🔴 Redis | 6379 | localhost:6379 | Cache et queues de traitement |

## 📚 Documentation API

- 🎥 **TypeFlick Core API**: http://localhost:8000/docs - Documentation du générateur de vidéos
- 🔍 **Artists Collector API**: http://localhost:8001/docs - Documentation de la recherche d'artistes
- 📝 **Beat Metadata API**: http://localhost:3001/docs - Documentation du générateur SEO

## 🔧 Gestion des Services

### **Logs et Monitoring**
```bash
# Voir les logs de tous les services
docker compose logs -f

# Voir les logs d'un service spécifique
docker compose logs -f artists-collector

# Suivre les logs avec filtrage
docker compose logs -f --tail=100 artists-dashboard
```

### **Contrôle des Services**
```bash
# Redémarrer un service spécifique
docker compose restart artists-collector

# Rebuilder et redémarrer un service
docker compose up -d --build artists-dashboard

# Arrêter tous les services
docker compose down

# Arrêter et supprimer les volumes (⚠️ perte de données)
docker compose down -v
```

### **Développement**
```bash
# Mode développement avec hot-reload
docker compose up -d

# Accéder au shell d'un container
docker compose exec artists-collector bash
docker compose exec artists-dashboard sh

# Exécuter des commandes dans un container
docker compose exec artists-collector python migrations/init_db.py
```

### **Nettoyage Docker**
```bash
# Nettoyer les images inutilisées (SANS supprimer les volumes)
docker system prune -a

# Voir l'espace utilisé
docker system df
```

## Structure du Projet

```
.
├── TypeFlick-core/          # API FastAPI de traitement vidéo
├── TypeFlick-site/          # Interface Next.js principale
├── artists-collector/       # API FastAPI de collecte d'artistes
├── artists-dashboard/       # Interface Next.js pour les artistes
├── beat-metadata-api/       # API Node.js de métadonnées
├── scripts/                 # Scripts utilitaires
├── docker-compose.yml       # Configuration Docker complète
└── .env.example            # Variables d'environnement exemple
```

## Intégration entre Services

### Communication Inter-Services
- **TypeFlick Site** ↔ **TypeFlick Core API** : Traitement des vidéos
- **TypeFlick Site** ↔ **Metadata API** : Récupération des métadonnées
- **Artists Dashboard** ↔ **Artists Collector API** : Gestion des artistes
- **TypeFlick Site** ↔ **Artists Collector API** : Intégration des données d'artistes

### Bases de Données
- **PostgreSQL Principal** : Données TypeFlick (utilisateurs, projets, etc.)
- **PostgreSQL Artists** : Données d'artistes (profils, scores, historique)

### Cache et Queues
- **Redis** : Cache partagé et queues pour les workers

## Développement

### Ajout de Nouvelles Fonctionnalités
1. Modifier le code source dans le répertoire approprié
2. Les volumes Docker permettent le hot-reload automatique
3. Redémarrer le service si nécessaire

### Tests
```bash
# Tests du service Artists Collector
cd artists-collector
./scripts/run_tests.py

# Tests des autres services
# (suivre les instructions spécifiques à chaque service)
```

### Sauvegarde
```bash
# Sauvegarde de la base Artists
cd artists-collector
./scripts/backup_db.py backup

# Sauvegarde manuelle avec Docker
docker-compose exec artists-postgres pg_dump -U artists_user artists_collector > backup.sql
```

## Production

Pour un déploiement en production, considérez :

1. **Sécurité** : Utiliser des secrets Docker, changer les mots de passe par défaut
2. **Performance** : Configurer des reverse proxy (Nginx), load balancers
3. **Monitoring** : Ajouter des outils de monitoring (Prometheus, Grafana)
4. **Sauvegarde** : Automatiser les sauvegardes des bases de données
5. **SSL/TLS** : Configurer HTTPS pour tous les services publics

## Support

Pour toute question ou problème :
1. Vérifier les logs : `docker-compose logs -f`
2. Consulter la documentation des APIs
3. Vérifier la configuration des variables d'environnement
