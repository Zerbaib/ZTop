#!/bin/bash

# Vérifier les dépendances nécessaires pour le script
function check_dependencies() {
    command -v top >/dev/null 2>&1 || { echo >&2 "Le programme 'top' n'est pas installé. Veuillez l'installer pour utiliser ztop."; exit 1; }
}

# Obtenir les données de performance du système
function get_system_performance() {
    # Exemple d'utilisation de la commande "top" pour obtenir des données de performance système
    cpu_usage=$(top -b -n 1 | grep "Cpu(s)" | awk '{print $2}')
    ram_usage=$(free -m | grep "Mem" | awk '{print $3}')
    total_ram=$(free -m | grep "Mem" | awk '{print $2}')

    # Récupérer le nom de l'interface réseau active
    network_interface=$(ip -o route get 1 | awk '{print $5}')

    # Vérifier si l'interface réseau existe avant de récupérer les statistiques
    if [ -e "/sys/class/net/$network_interface" ]; then
        rx_data=$(cat "/sys/class/net/$network_interface/statistics/rx_bytes")
        tx_data=$(cat "/sys/class/net/$network_interface/statistics/tx_bytes")

        # Convertir les données en Mo
        rx_data_mb=$(awk "BEGIN {printf \"%.2f\", $rx_data / 1024 / 1024}")
        tx_data_mb=$(awk "BEGIN {printf \"%.2f\", $tx_data / 1024 / 1024}")

        # Générer la chaîne de données à retourner avec les nouvelles informations
        data="CPU: ${cpu_usage}% / RAM: ${ram_usage}MB / ${total_ram}MB used / Disk: ${disk_percentage}% / Network (${network_interface}) RX: ${rx_data_mb} MB / TX: ${tx_data_mb} MB / Load Average: $(uptime | awk -F'load average:' '{print $2}')"
    else
        # Générer la chaîne de données à retourner sans les informations réseau si l'interface n'existe pas
        data="CPU: ${cpu_usage}% / RAM: ${ram_usage}MB / ${total_ram}MB used / Disk: ${disk_percentage}% / Load Average: $(uptime | awk -F'load average:' '{print $2}')"
    fi

    echo "$data"
}
