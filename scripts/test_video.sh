#!/usr/bin/env bash
set -euo pipefail

audio=${1:-test.mp3}
image=${2:-cover.jpg}

payload=$(cat <<JSON
{
  "primary_beatmaker": "STKF",
  "beat_name": "DemoBeat",
  "type_beat_name": "Drake Type Beat",
  "producer_name": "STKF",
  "colab": "",
  "template": "vinyl",
  "format": "9_16",
  "audio_filename": "$audio",
  "image_filename": "$image",
  "max_duration" : "60"
}
JSON
)

job_id=$(curl -s -X POST http://localhost:8000/generate \
         -H "Content-Type: application/json" \
         -d "$payload" | jq -r .job_id)

[[ "$job_id" == "null" || -z "$job_id" ]] && {
  echo "❌  Erreur d’enqueue"
  exit 1
}

echo "✅  Job $job_id — ouverture du suivi…"
watch -n2 "curl -s http://localhost:8000/status/$job_id | jq"
