# TypeFlick + Artists Collector - Architecture Complète

Cette architecture combine la plateforme TypeFlick avec le système Artists Collector pour créer une solution complète de génération de vidéos et d'analyse d'artistes émergents.

## Architecture des Services

### Services TypeFlick (Existants)
- **TypeFlick Site** (Next.js) - Interface utilisateur principale sur le port 3000
- **TypeFlick Core API** (FastAPI) - API de traitement vidéo sur le port 8000
- **Python Worker** (RQ) - Worker pour les tâches de traitement en arrière-plan
- **Metadata API** (Node.js) - API de métadonnées sur le port 3001

### Services Artists Collector (Nouveaux)
- **Artists Collector API** (FastAPI) - API de collecte et scoring d'artistes sur le port 8001
- **Artists Dashboard** (Next.js) - Interface de gestion des artistes sur le port 3002

### Infrastructure
- **PostgreSQL Principal** - Base de données TypeFlick (port 54322)
- **PostgreSQL Artists** - Base de données dédiée aux artistes (port 54323)
- **Redis** - Cache et queue pour les workers (port 6379)

## Démarrage Rapide

1. **Prérequis**
   ```bash
   # Docker et Docker Compose requis
   docker --version
   docker-compose --version
   ```

2. **Configuration**
   ```bash
   # Copier le fichier d'environnement
   cp .env.example .env
   
   # Éditer .env avec vos clés API
   nano .env
   ```

3. **Démarrage**
   ```bash
   # Démarrer tous les services
   ./scripts/start-all.sh
   ```

## Configuration des Clés API

### Clés Spotify
1. Aller sur [Spotify Developer Dashboard](https://developer.spotify.com/dashboard)
2. Créer une nouvelle application
3. Récupérer `Client ID` et `Client Secret`

### Clés YouTube
1. Aller sur [Google Cloud Console](https://console.cloud.google.com/)
2. Activer l'API YouTube Data v3
3. Créer 12 clés API pour la rotation des quotas

### Clés Stripe (pour TypeFlick)
1. Aller sur [Stripe Dashboard](https://dashboard.stripe.com/)
2. Récupérer les clés de test ou production

## URLs des Services

| Service | URL | Description |
|---------|-----|-------------|
| TypeFlick Site | http://localhost:3000 | Interface utilisateur principale |
| TypeFlick API | http://localhost:8000 | API de traitement vidéo |
| Artists Collector API | http://localhost:8001 | API de collecte d'artistes |
| Artists Dashboard | http://localhost:3002 | Interface de gestion des artistes |
| Metadata API | http://localhost:3001 | API de métadonnées |

## Documentation API

- **TypeFlick API**: http://localhost:8000/docs
- **Artists Collector API**: http://localhost:8001/docs

## Gestion des Services

```bash
# Voir les logs de tous les services
docker-compose logs -f

# Voir les logs d'un service spécifique
docker-compose logs -f artists-collector

# Redémarrer un service
docker-compose restart artists-collector

# Arrêter tous les services
docker-compose down

# Arrêter et supprimer les volumes
docker-compose down -v
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
