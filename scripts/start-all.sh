#!/bin/bash

# Script de démarrage pour l'ensemble du projet TypeFlick + Artists Collector

set -e

echo "🚀 Démarrage de l'environnement complet TypeFlick + Artists Collector"
echo "=" * 70

# Vérifier que Docker est installé
if ! command -v docker &> /dev/null; then
    echo "❌ Docker n'est pas installé. Veuillez l'installer d'abord."
    exit 1
fi

if ! command -v docker-compose &> /dev/null; then
    echo "❌ Docker Compose n'est pas installé. Veuillez l'installer d'abord."
    exit 1
fi

# Vérifier que le fichier .env existe
if [ ! -f .env ]; then
    echo "📝 Création du fichier .env à partir de .env.example"
    cp .env.example .env
    echo "⚠️  IMPORTANT: Configurez vos clés API dans le fichier .env avant de continuer"
    echo "   - Clés Stripe (STRIPE_SECRET_KEY, STRIPE_WEBHOOK_SECRET)"
    echo "   - Clés Spotify (SPOTIFY_CLIENT_ID, SPOTIFY_CLIENT_SECRET)"
    echo "   - Clés YouTube (YOUTUBE_API_KEY_1 à YOUTUBE_API_KEY_12)"
    echo ""
    read -p "Appuyez sur Entrée une fois la configuration terminée..."
fi

# Créer les répertoires nécessaires
echo "📁 Création des répertoires nécessaires..."
mkdir -p artists-collector/backups
mkdir -p artists-collector/logs

# Démarrer tous les services
echo "🐳 Démarrage de tous les conteneurs..."
docker-compose up -d

echo ""
echo "📋 Services démarrés avec succès!"
echo ""
echo "🌐 Services disponibles:"
echo "  • TypeFlick Site:        http://localhost:3000"
echo "  • TypeFlick API:         http://localhost:8000"
echo "  • Artists Collector API: http://localhost:8001"
echo "  • Artists Dashboard:     http://localhost:3002"
echo "  • Metadata API:          http://localhost:3001"
echo ""
echo "🗄️  Bases de données:"
echo "  • PostgreSQL TypeFlick:  localhost:54322"
echo "  • PostgreSQL Artists:    localhost:54323"
echo "  • Redis:                  localhost:6379"
echo ""
echo "📊 Documentation API:"
echo "  • TypeFlick API Docs:     http://localhost:8000/docs"
echo "  • Artists API Docs:       http://localhost:8001/docs"
echo ""
echo "📝 Commandes utiles:"
echo "  • Voir les logs:          docker-compose logs -f"
echo "  • Arrêter les services:   docker-compose down"
echo "  • Redémarrer un service:  docker-compose restart <service-name>"
echo ""

# Optionnel: afficher les logs en temps réel
read -p "Voulez-vous voir les logs en temps réel? (y/N): " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
    docker-compose logs -f
fi
