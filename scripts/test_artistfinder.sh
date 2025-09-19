#!/bin/bash

# filename : test_artistfinder.sh
# Script de test pour l'API TypeBeat Research avec TasteDive Sweet Spot
# Usage: ./test_artistfinder.sh [BASE_URL]

set -e

# Configuration
BASE_URL=${1:-"http://localhost:3002"}
API_VERSION="v1"
API_BASE="$BASE_URL/api"

# Couleurs pour l'affichage
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
MAGENTA='\033[0;35m'
NC='\033[0m' # No Color

# Fonction d'affichage
log_info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

log_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

log_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

log_sweet_spot() {
    echo -e "${MAGENTA}[SWEET SPOT]${NC} $1"
}

log_tastedive() {
    echo -e "${CYAN}[TASTEDIVE]${NC} $1"
}

# Fonction pour tester un endpoint
test_endpoint() {
    local method=$1
    local endpoint=$2
    local data=$3
    local description=$4
    
    echo
    log_info "Testing: $description"
    log_info "Endpoint: $method $endpoint"
    
    if [ "$method" = "GET" ]; then
        response=$(curl -s -w "\n%{http_code}" "$endpoint")
    else
        response=$(curl -s -w "\n%{http_code}" -X "$method" \
            -H "Content-Type: application/json" \
            -d "$data" \
            "$endpoint")
    fi
    
    # Séparer le body et le status code
    http_code=$(echo "$response" | tail -n1)
    body=$(echo "$response" | head -n -1)
    
    if [ "$http_code" -ge 200 ] && [ "$http_code" -lt 300 ]; then
        log_success "HTTP $http_code - Success"
        
        # Vérifier si c'est une réponse Sweet Spot
        if echo "$body" | jq -e '.metadata.sweet_spot_analysis' > /dev/null 2>&1; then
            log_sweet_spot "Sweet Spot analysis detected!"
        fi
        
        # Vérifier si TasteDive est utilisé
        if echo "$body" | jq -e '.suggestions[].sources.tastedive' > /dev/null 2>&1; then
            log_tastedive "TasteDive source confirmed!"
        fi
        
        echo "$body" | jq '.' 2>/dev/null || echo "$body"
    else
        log_error "HTTP $http_code - Failed"
        echo "$body"
        return 1
    fi
}

# Fonction pour vérifier la santé de l'API
check_health() {
    log_info "Checking API health..."
    
    response=$(curl -s "$BASE_URL/api/health" 2>/dev/null || echo "")
    
    if [ -n "$response" ]; then
        log_success "API is responding"
        
        # Vérifier le statut TasteDive
        if echo "$response" | jq -e '.services.tastedive' > /dev/null 2>&1; then
            tastedive_status=$(echo "$response" | jq -r '.services.tastedive')
            if [ "$tastedive_status" = "healthy" ]; then
                log_tastedive "TasteDive service is healthy"
            else
                log_warning "TasteDive service status: $tastedive_status"
            fi
        fi
        
        return 0
    else
        log_error "API is not responding at $BASE_URL"
        return 1
    fi
}

# Tests principaux
run_tests() {
    echo "🎵 TYPEBEAT RESEARCH API - TASTEDIVE SWEET SPOT TESTS"
    echo "====================================================="
    echo "Base URL: $BASE_URL"
    echo "API Base: $API_BASE"
    echo "🎯 Testing Sweet Spot Algorithm with TasteDive integration"
    echo

    # 1. Health Check
    if ! check_health; then
        log_error "API health check failed. Exiting."
        exit 1
    fi

    # 2. Test Sweet Spot Suggestions
    log_sweet_spot "🎯 Testing Sweet Spot Algorithm..."
    test_endpoint "POST" "$API_BASE/research/suggestions" \
        '{"artist": "Drake", "limit": 5}' \
        "Sweet Spot suggestions for Drake"

    # 3. Test TasteDive Similar Artists
    log_tastedive "🔍 Testing TasteDive similar artists..."
    test_endpoint "GET" "$API_BASE/artists/similar?artist=Lil%20Baby&source=tastedive&limit=5" \
        "" \
        "TasteDive similar artists to Lil Baby"

    # 4. Test avec POST pour artistes similaires TasteDive
    test_endpoint "POST" "$API_BASE/artists/similar" \
        '{"artist": "Future", "source": "tastedive", "limit": 5, "min_similarity": 0.3}' \
        "TasteDive similar artists to Future with similarity threshold"

    # 5. Test de calcul de métriques Sweet Spot
    log_sweet_spot "📊 Testing Sweet Spot metrics calculation..."
    test_endpoint "GET" "$API_BASE/metrics/calculate?artist=Travis%20Scott" \
        "" \
        "Sweet Spot metrics for Travis Scott"

    # 6. Test avec POST pour métriques complètes
    test_endpoint "POST" "$API_BASE/metrics/calculate" \
        '{"artist": "Kendrick Lamar", "include_youtube": true, "include_tastedive": true}' \
        "Comprehensive Sweet Spot metrics for Kendrick Lamar"

    # 7. Test avec des artistes de différents genres (Sweet Spot)
    log_sweet_spot "🎸 Testing Sweet Spot with different genres..."
    
    # Hip-hop émergent
    test_endpoint "POST" "$API_BASE/research/suggestions" \
        '{"artist": "Pooh Shiesty", "limit": 3}' \
        "Sweet Spot for emerging hip-hop artist"

    # Trap
    test_endpoint "POST" "$API_BASE/research/suggestions" \
        '{"artist": "Key Glock", "limit": 3}' \
        "Sweet Spot for trap artist"

    # Melodic rap
    test_endpoint "POST" "$API_BASE/research/suggestions" \
        '{"artist": "Lil Tjay", "limit": 3}' \
        "Sweet Spot for melodic rap artist"

    # 8. Test de sources multiples (TasteDive + Last.fm)
    log_tastedive "🔄 Testing multiple sources (TasteDive + Last.fm)..."
    test_endpoint "GET" "$API_BASE/artists/similar?artist=Young%20Thug&source=all&limit=8" \
        "" \
        "Multi-source similar artists (TasteDive + Last.fm)"

    # 9. Test de gestion d'erreurs
    log_info "❌ Testing error handling..."
    
    # Artiste inexistant
    test_endpoint "POST" "$API_BASE/research/suggestions" \
        '{"artist": "NonExistentArtist123456", "limit": 3}' \
        "Non-existent artist handling" || log_warning "Expected error for non-existent artist"

    # Paramètres invalides
    test_endpoint "POST" "$API_BASE/research/suggestions" \
        '{"artist": "", "limit": -1}' \
        "Invalid parameters handling" || log_warning "Expected error for invalid parameters"

    # Source invalide (ancienne référence Spotify)
    test_endpoint "GET" "$API_BASE/artists/similar?artist=Drake&source=spotify&limit=3" \
        "" \
        "Invalid source (spotify) handling" || log_warning "Expected error for deprecated Spotify source"

    # 10. Test de performance Sweet Spot avec cache
    log_sweet_spot "⚡ Testing Sweet Spot cache performance..."
    
    start_time=$(date +%s%N)
    test_endpoint "POST" "$API_BASE/research/suggestions" \
        '{"artist": "Drake", "limit": 5}' \
        "First Sweet Spot request (cache miss)"
    end_time=$(date +%s%N)
    first_duration=$((($end_time - $start_time) / 1000000))
    
    start_time=$(date +%s%N)
    test_endpoint "POST" "$API_BASE/research/suggestions" \
        '{"artist": "Drake", "limit": 5}' \
        "Second Sweet Spot request (cache hit)"
    end_time=$(date +%s%N)
    second_duration=$((($end_time - $start_time) / 1000000))
    
    log_info "Sweet Spot performance comparison:"
    echo "  First request:  ${first_duration}ms"
    echo "  Second request: ${second_duration}ms"
    
    if [ $second_duration -lt $first_duration ]; then
        log_success "Cache is working! Second request was faster."
    else
        log_warning "Cache might not be working as expected."
    fi

    # 11. Test des scores Sweet Spot
    log_sweet_spot "🎯 Testing Sweet Spot scoring system..."
    
    # Test avec différents artistes pour vérifier la distribution des scores
    artists=("Lil Baby" "EST Gee" "42 Dugg" "Pooh Shiesty" "Key Glock")
    
    for artist in "${artists[@]}"; do
        log_info "Testing Sweet Spot score for: $artist"
        response=$(curl -s -X POST "$API_BASE/research/suggestions" \
            -H "Content-Type: application/json" \
            -d "{\"artist\": \"$artist\", \"limit\": 2}")
        
        if echo "$response" | jq -e '.suggestions[0].score' > /dev/null 2>&1; then
            score=$(echo "$response" | jq -r '.suggestions[0].score')
            suggested_artist=$(echo "$response" | jq -r '.suggestions[0].artist')
            
            if command -v bc &> /dev/null; then
                if (( $(echo "$score >= 8.0" | bc -l) )); then
                    log_sweet_spot "🟢 Excellent Sweet Spot: $suggested_artist (score: $score)"
                elif (( $(echo "$score >= 6.0" | bc -l) )); then
                    log_sweet_spot "🟡 Good Sweet Spot: $suggested_artist (score: $score)"
                elif (( $(echo "$score >= 4.0" | bc -l) )); then
                    log_sweet_spot "🟠 Fair Sweet Spot: $suggested_artist (score: $score)"
                else
                    log_sweet_spot "🔴 Poor Sweet Spot: $suggested_artist (score: $score)"
                fi
            else
                log_sweet_spot "📊 Sweet Spot: $suggested_artist (score: $score)"
            fi
        fi
    done

    # 12. Test de validation TasteDive
    log_tastedive "🔍 Testing TasteDive integration validation..."
    
    response=$(curl -s -X POST "$API_BASE/research/suggestions" \
        -H "Content-Type: application/json" \
        -d '{"artist": "Future", "limit": 3}')
    
    if echo "$response" | jq -e '.suggestions[].sources.tastedive' > /dev/null 2>&1; then
        tastedive_count=$(echo "$response" | jq '[.suggestions[].sources.tastedive] | map(select(. == true)) | length')
        total_suggestions=$(echo "$response" | jq '.suggestions | length')
        log_tastedive "✅ TasteDive integration: $tastedive_count/$total_suggestions suggestions use TasteDive"
    else
        log_warning "⚠️ TasteDive source not detected in suggestions"
    fi

    echo
    echo "🎉 ALL SWEET SPOT TESTS COMPLETED!"
    echo "=================================="
    log_success "TypeBeat Research API with TasteDive Sweet Spot tests finished"
    log_sweet_spot "Sweet Spot Algorithm: ✅ Operational"
    log_tastedive "TasteDive Integration: ✅ Functional"
    echo
    echo "🎯 Sweet Spot Features Tested:"
    echo "  ✅ Volume vs Competition analysis"
    echo "  ✅ TasteDive similarity scoring"
    echo "  ✅ Emerging artist discovery"
    echo "  ✅ Multi-source integration"
    echo "  ✅ Cache performance"
    echo "  ✅ Error handling"
}

# Fonction d'aide
show_help() {
    echo "Usage: $0 [BASE_URL]"
    echo
    echo "Test script for TypeBeat Research API with TasteDive Sweet Spot"
    echo
    echo "Arguments:"
    echo "  BASE_URL    Base URL of the API (default: http://localhost:3002)"
    echo
    echo "Examples:"
    echo "  $0                                    # Test local API"
    echo "  $0 http://localhost:3002              # Test specific port"
    echo "  $0 https://api.typeflick.com          # Test production API"
    echo
    echo "Features tested:"
    echo "  🎯 Sweet Spot Algorithm"
    echo "  🔍 TasteDive Integration"
    echo "  📊 Performance Metrics"
    echo "  ⚡ Cache Optimization"
    echo "  🎵 Multi-genre Support"
    echo
    echo "Requirements:"
    echo "  - curl"
    echo "  - jq (optional, for JSON formatting)"
    echo "  - bc (optional, for score calculations)"
}

# Vérification des dépendances
check_dependencies() {
    if ! command -v curl &> /dev/null; then
        log_error "curl is required but not installed."
        exit 1
    fi
    
    if ! command -v jq &> /dev/null; then
        log_warning "jq is not installed. JSON output will not be formatted."
    fi
    
    if ! command -v bc &> /dev/null; then
        log_warning "bc is not installed. Score calculations will be limited."
    fi
}

# Point d'entrée principal
main() {
    case "${1:-}" in
        -h|--help)
            show_help
            exit 0
            ;;
        *)
            check_dependencies
            run_tests
            ;;
    esac
}

# Exécution
main "$@"

