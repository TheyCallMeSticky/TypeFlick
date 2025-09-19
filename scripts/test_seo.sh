#!/usr/bin/env bash
set -euo pipefail

payload=$(cat <<JSON
{
  "beat_name": "DemoBeat",
  "type_beat_name": "21 Savage Type Beat",
  "producer_name": "STKF",
  "colab" : "gogo",
  "buyLink": "https://google.com"
}
JSON
 )

# Exécute la requête et affiche la réponse complète
response=$(curl -s -X POST http://localhost:3001/api/generate-metadata \
         -H "Content-Type: application/json" \
         -d "$payload" )

# Vérifie si la réponse est vide ou contient une erreur (vous pouvez affiner cette vérification)
if [[ -z "$response" || "$response" == *"error"* ]]; then
  echo "❌ Erreur lors de la génération des métadonnées :"
  echo "$response"
  exit 1
else
  echo "✅ Métadonnées générées avec succès :"
  echo "$response" | jq .
fi
