#!/bin/bash
set -euo pipefail

printf "\033c"
echo "==================================================================================="
echo "==================================================================================="
echo " _____  _      __ __         __ __  ____      ___ ___    ___  ___    ____   ____ "
echo "|     || |    |  |  |       |  |  ||    |    |   |   |  /  _]|   \  |    | /    |"
echo "|   __|| |    |  |  | _____ |  |  | |  |     | _   _ | /  [_ |    \  |  | |  o  |"
echo "|  |_  | |___ |  ~  ||     ||  _  | |  |     |  \_/  ||    _]|  D  | |  | |     |"
echo "|   _] |     ||___, ||_____||  |  | |  |     |   |   ||   [_ |     | |  | |  _  |"
echo "|  |   |     ||     |       |  |  | |  |     |   |   ||     ||     | |  | |  |  |"
echo "|__|   |_____||____/        |__|__||____|    |___|___||_____||_____||____||__|__|"
echo "===================================================="
echo "Welcome to Fly-Hi Media"
echo "Installation process should be really quick"
echo "We just need you to answer some questions"
echo "We are going to ask for your sudo password in the end"
echo "To finish the installation of the CLI"
echo "===================================================================================="
echo ""

# ============================================================================================
# Functions to ease development
# ============================================================================================
send_warning_message() {
    echo -e $(printf "\e[33m$1\e[0m")
}


send_success_message() {
    echo -e $(printf "\e[32m$1\e[0m")
}

send_error_message() {
    echo -e $(printf "\e[31m$1\e[0m")
    exit 255
}
send_message_in_cyan() {
    echo -e $(printf "\e[36m$1\e[0m")
}
send_message_in_blue() {
    echo -e $(printf "\e[34m$1\e[0m")
}

check_dependencides() {
    if command -v $1 &> /dev/null; then
        send_success_message "$1 exists ✅ "
    else
        echo -e $(printf "\e[31m ⚠️ $1 not found! ⚠️\e[0m")
        read -p "Would you like Fly-Hi to install docker and docker-compose? IT ONLY WORKS ON DEBIAN AND UBUNTU! [y/N]: " install_docker
        install_docker=${install_docker:-"n"}

        if [ "$install_docker" == "y" ]; then
            send_warning_message "After installation is complete just run this script again!"
            sleep 2
            bash ./docker.sh
        else
            send_error_message "Install docker and docker-compose and come back later!"
        fi
    fi
}

add_service() {
    unset service_name
    unset comment
    local service_name="$1"
    local comment="$2"

    read -p "Would you like to install ${service_name^}? ${comment:+ ($comment)} [n/Y]:" y_n
    y_n=${y_n:-"y"}

    if [ "$y_n" == "y" ]; then
        send_success_message "Adding service: ${service_name^}"
        sed -i "/^#${service_name}start/,/^#${service_name}end$/{/^\(#${service_name}start\|#${service_name}end\)$/!s/^#//}" "$compose_media" "$compose_management" "$compose_network" "$compose_starrs"
        eval "${service_name}=y"
    else
        send_warning_message "Skipping ${service_name^} configuration!"
    fi


    send_message_in_blue "=============================================================================="
    send_message_in_blue "=============================================================================="
}


get_password() {
    local service="$1"
    local password

    unset password
    charcount=0
    prompt="What will be your ${service^} password?: "

    while IFS= read -p "$prompt" -r -s -n 1 char; do
        if [[ $char == $'\0' ]]; then
            break
        fi
        if [[ $char == $'\177' ]]; then
            if [ $charcount -gt 0 ]; then
                charcount=$((charcount - 1))
                prompt=$'\b \b'
                password="${password%?}"
            else
                prompt=''
            fi
        else
            charcount=$((charcount + 1))
            prompt='*'
            password+="$char"
        fi
    done
#    echo "$password"
     echo "${password:-"changeme"}" | sed 's/[\/&]/\\&/g'  # Escape special characters for sed
}

running_services_location() {
    host_ip=$(hostname -I | awk '{ print $1 }')
    echo
    echo "========= MANAGEMENT ========="
    echo "WhoAmI:         http://$host_ip:$(docker port whoami 2>/dev/null | awk '{ print $3 }' | head -1 | sed 's/0.0.0.0://')/"
    echo "Portainer:      http://$host_ip:$(docker port portainer 2>/dev/null | awk '{ print $3 }' | head -1 | sed 's/0.0.0.0://')/"
    echo "Dozzle:         http://$host_ip:$(docker port dozzle 2>/dev/null | awk '{ print $3 }' | head -1 | sed 's/0.0.0.0://')/"
    echo "Heimdall:       http://$host_ip:$(docker port heimdall 2>/dev/null | awk '{ print $3 }' | head -1 | sed 's/0.0.0.0://')/"
    echo "Glances:        http://$host_ip:$(docker port glances 2>/dev/null | awk '{ print $3 }' | head -1 | sed 's/0.0.0.0://')/"
    echo "Uptime-Kuma:    http://$host_ip:$(docker port uptime-kuma 2>/dev/null | awk '{ print $3 }' | head -1 | sed 's/0.0.0.0://')/"
    echo "Scrutiny:       http://$host_ip:$(docker port scrutiny 2>/dev/null | awk '{ print $3 }' | head -1 | sed 's/0.0.0.0://')/"
    echo "Ntfy:           http://$host_ip:$(docker port ntfy 2>/dev/null | awk '{ print $3 }' | head -1 | sed 's/0.0.0.0://')/"
    echo "PhpMyAdmin:     http://$host_ip:$(docker port phpmyadmin 2>/dev/null | awk '{ print $3 }' | head -1 | sed 's/0.0.0.0://')/"
    echo "PgAdmin:        http://$host_ip:$(docker port pgadmin 2>/dev/null | awk '{ print $3 }' | head -1 | sed 's/0.0.0.0://')/"
    echo "Vaultwarden:    http://$host_ip:$(docker port vaultwarden 2>/dev/null | awk '{ print $3 }' | head -1 | sed 's/0.0.0.0://')/"
    echo "Cockpit:        http://$host_ip:9090"
    echo
    echo "========= NETWORK ========="
    echo "Traefik:        http://$host_ip:80/"
    echo "Traefik:        http://$host_ip:443/"
    echo "Traefik:        http://$host_ip:8880/"
    echo "Speedtest:      http://$host_ip:$(docker port speedtest 2>/dev/null | awk '{ print $3 }' | head -1 | sed 's/0.0.0.0://')/"
    echo "Flaresolverr:   http://$host_ip:$(docker port flaresolverr 2>/dev/null | awk '{ print $3 }' | head -1 | sed 's/0.0.0.0://')/"
    echo "WG-Easy:        http://$host_ip:$(cat $install_location/network/docker-compose.yaml | grep WEB | awk '{ print $2 }' | awk -F":" '{ print $2 }' | awk -F"/" '{ print $1 }')"

    echo
    echo "========= MEDIA ========="
    echo "Jellyfin:       http://$host_ip:$(docker port jellyfin 2>/dev/null | awk '{ print $3 }' | head -1 | sed 's/0.0.0.0://')/"
    echo "Emby:           http://$host_ip:$(docker port emby 2>/dev/null | awk '{ print $3 }' | head -1 | sed 's/0.0.0.0://')/"
    echo "Plex:           http://$host_ip:$(cat $install_location/media/docker-compose.yaml | grep webUI | awk -F":" '{ print $2 }' | awk '{ print $1 }')"
    echo "Jellyseerr:     http://$host_ip:$(docker port jellyseerr 2>/dev/null | awk '{ print $3 }' | head -1 | sed 's/0.0.0.0://')/"
    echo "Overseerr:      http://$host_ip:$(docker port overseerr 2>/dev/null | awk '{ print $3 }' | head -1 | sed 's/0.0.0.0://')/"
    echo "Ombi:           http://$host_ip:$(docker port ombi 2>/dev/null | awk '{ print $3 }' | head -1 | sed 's/0.0.0.0://')/"
    echo "Airsonic:       http://$host_ip:$(docker port airsonic 2>/dev/null | awk '{ print $3 }' | head -1 | sed 's/0.0.0.0://')/"
    echo "CalibreLibrary: http://$host_ip:$(docker port calibre 2>/dev/null | awk '{ print $3 }' | head -1 | sed 's/0.0.0.0://')/"
    echo "Calibreweb:     http://$host_ip:$(docker port calibre_web 2>/dev/null | awk '{ print $3 }' | head -1 | sed 's/0.0.0.0://')/"
    echo "Audiobookshelf: http://$host_ip:$(docker port audiobookshelf 2>/dev/null | awk '{ print $3 }' | head -1 | sed 's/0.0.0.0://')/"
    echo "Photoprism:     http://$host_ip:$(docker port photoprism 2>/dev/null | awk '{ print $3 }' | head -1 | sed 's/0.0.0.0://')/"
    echo "Nextcloud:      http://$host_ip:$(docker port nextcloud 2>/dev/null | awk '{ print $3 }' | head -1 | sed 's/0.0.0.0://')/"
    echo "Linkding:       http://$host_ip:$(docker port linkding 2>/dev/null | awk '{ print $3 }' | head -1 | sed 's/0.0.0.0://')/"
    echo "Joplin-Server:  http://$host_ip:$(docker port joplin 2>/dev/null | awk '{ print $3 }' | head -1 | sed 's/0.0.0.0://')/"
    echo "FreshRSS:       http://$host_ip:$(docker port freshrss 2>/dev/null | awk '{ print $3 }' | head -1 | sed 's/0.0.0.0://')/"
    echo "Stirling-PDF:   http://$host_ip:$(docker port stirling_pdf 2>/dev/null | awk '{ print $3 }' | head -1 | sed 's/0.0.0.0://')/"
    echo "Filebrowser:    http://$host_ip:$(docker port filebrowser 2>/dev/null | awk '{ print $3 }' | head -1 | sed 's/0.0.0.0://')/"
    echo
    echo "========== STARRS =========="
    echo "qBittorrent:    http://$host_ip:$(cat $install_location/network/docker-compose.yaml | grep qbittorrentport | grep -Eo '[0-9]{1,4}' | head -1)/"
    echo "qBittorrentpub: http://$host_ip:$(cat $install_location/network/docker-compose.yaml | grep qbittorrentpubport | grep -Eo '[0-9]{1,4}' | head -1)/"
    echo "Radarr:         http://$host_ip:$(docker port radarr 2>/dev/null | awk '{ print $3 }' | head -1 | sed 's/0.0.0.0://')/"
    echo "Sonarr:         http://$host_ip:$(docker port sonarr 2>/dev/null | awk '{ print $3 }' | head -1 | sed 's/0.0.0.0://')/"
    echo "Lidarr:         http://$host_ip:$(docker port lidarr 2>/dev/null | awk '{ print $3 }' | head -1 | sed 's/0.0.0.0://')/"
    echo "Readarr:        http://$host_ip:$(docker port readarr 2>/dev/null | awk '{ print $3 }' | head -1 | sed 's/0.0.0.0://')/"
    echo "Prowlarr:       http://$host_ip:$(docker port prowlarr 2>/dev/null | awk '{ print $3 }' | head -1 | sed 's/0.0.0.0://')/"
    echo "Bazarr:         http://$host_ip:$(docker port bazarr 2>/dev/null | awk '{ print $3 }' | head -1 | sed 's/0.0.0.0://')/"
    echo "Tubesync:       http://$host_ip:$(docker port tubesync 2>/dev/null | awk '{ print $3 }' | head -1 | sed 's/0.0.0.0://')/"
    echo
    echo "Use 'fly-hi help' to see how to use the script"
    echo
if [[ $traefik == "y" ]]; then
    echo "Your services can also be reached by "service-name".$my_domain  (e. g. https://heimdall.$my_domain)"
fi
echo
if [ "$install_vpn_server" == "y" ]; then
    echo "To add or remove clients from your Private VPN Server run fly-hi vpn"
fi
echo
if [ "$tailscale" == "y" ]; then
    echo "To start up Tailscale run 'sudo tailscale up' "
fi
echo
}

running_services_management() {
echo "=============================================================================="
send_message_in_cyan "System Management Services"
echo "- Portainer      - Keep your docker containers in check! (https://www.portainer.io/)"
echo "- Watchtower     - Keep your docker containers up to date! (https://github.com/containrrr/watchtower)"
echo "- Heimdall       - Keep your services organized on a nice Dashboard (https://github.com/linuxserver/Heimdall)"
echo "- Glances        - System Information (https://nicolargo.github.io/glances/)"
echo "- Uptime-Kuma    - Real time monitoring of your services (https://github.com/louislam/uptime-kuma)"
echo "- Scrutiny       - HDD/SSD monitoring tool with a nice dashboard (https://github.com/AnalogJ/scrutiny)"
echo "- Ntfy           - Beautiful push notification server for docker services, ssh, cronjobs etc. (https://docs.ntfy.sh/)"
echo "- Vaultwarden    - Password Manager (https://hub.docker.com/r/vaultwarden/server)"
echo "- PhpMyAdmin     - WEBui for managing MySQL/MariaDB databases, tables, columns, relations, indexes, users, permissions, etc (https://hub.docker.com/r/phpmyadmin/phpmyadmin/)"
echo "- PgAdmin        - WEBui for managing Postgres databases, tables, columns, relations, indexes, users, permissions, etc (https://www.pgadmin.org/docs/pgadmin4/latest/container_deployment.html)"
echo "- CockpitProject - System Management Tool (https://cockpit-project.org)"
echo "=============================================================================="
}
running_services_network() {
echo "=============================================================================="
send_message_in_cyan "Network Services"
echo "- Flaresolverr           - Proxy server to bypass Cloudflare protection in Prowlarr (https://github.com/FlareSolverr/FlareSolverr)"
echo "- Traefik                - Reverse Proxy (https://traefik.io/traefik/)"
echo "- Gluetun                - VPN Client (https://github.com/qdm12/gluetun)"
echo "- Wireguard (wg-easy)    - Connect to your home network from anywhere in the world! (https://github.com/wg-easy/wg-easy)"
echo "- Wireguard (bash)       - Connect to your home network from anywhere in the world! (https://github.com/angristan/wireguard-install)"
echo "- OpenVPN (bash)         - Connect to your home network from anywhere in the world! (https://github.com/angristan/openvpn-install)"
echo "- Tailscale              - Easier, closed source alternative to private OpenVPN/Wireguard server for access from anywhere in the world! (https://tailscale.com/)"
echo "- DDclient (Dynamic DNS) - Keep your Domain updated at all times (Unnecessary if you are NOT exposing any of your service to public!) (https://github.com/ddclient/ddclient)"
echo "- Speedtest-tracker      - Monitor your internet speed on a scheduled basis (https://github.com/alexjustesen/speedtest-tracker)"
echo "=============================================================================="
}
running_services_media() {
echo "=============================================================================="
send_message_in_cyan "Media Services"
echo "- Jellyfin        - Media Streaming Service (open-source, fork of Emby, recommended) (https://jellyfin.org/)"
echo "- Emby            - Media Streaming Service (closed-source) (https://emby.media/)"
echo "- Plex            - Media Streaming Service (closed-source) (https://www.plex.tv/)"
echo "- Airsonic        - Music Server (https://airsonic.github.io/)"
echo "- Jellyseer       - Jellyfin Media Requests (https://github.com/Fallenbagel/jellyseerr)"
echo "- Overseerr       - Plex Media Requests (https://overseerr.dev/)"
echo "- Ombi            - Jellyfin/Plex/Emby Media Requests (https://github.com/Ombi-app/Ombi)"
echo "- Calibre Library - Manage all your books in famous Calibre Library (https://hub.docker.com/r/linuxserver/calibre)"
echo "- Calibre web     - Read your favorite Books (https://github.com/janeczku/calibre-web)"
echo "- Audiobookshelf  - Listen to your favorite Audiobooks (https://www.audiobookshelf.org/)"
echo "- Photoprism      - Browse Your Life in Pictures (https://www.photoprism.app/)"
echo "- Nextcloud       - Popular Open Source Google Cloud alternative (https://nextcloud.com/)"
echo "- Tubesync        - Manage your favorite Youtube Channels (https://github.com/meeb/tubesync)"
echo "- Linkding        - Very fancy bookmarks manager with support for tags (https://github.com/sissbruecker/linkding)"
echo "- Linkwarden      - Very fancy bookmarks manager with support for tags (https://github.com/linkwarden/linkwarden)"
echo "- Joplin-Server   - Nice and very popular Notes-taking app (https://joplinapp.org/)"
echo "- FreshRSS        - Nice RSS agregator (https://github.com/FreshRSS/FreshRSS/tree/edge/Docker#docker-compose)"
echo "- Stirling-PDF    - Your locally hosted one-stop-shop for all your PDF needs (https://github.com/Frooodle/Stirling-PDF)"
echo "- Filebrowser     - Nice WebUI for accessing and managing your files (https://filebrowser.org/)"
echo "- Samba Server    - Samba can be use as a Network Attached Storage which can be mounted on your other devices like KODI, PC, Phones etc."
echo "- Mealie          - A self-hosted recipe manager and meal planner (https://docs.mealie.io/)"
echo "=============================================================================="
}
running_services_download() {
echo "=============================================================================="
send_message_in_cyan "Download Services"
echo "- Radarr      - Manage your Movies (https://radarr.video/)"
echo "- Sonarr      - Manage your TV Shows (https://sonarr.tv/)"
echo "- Readarr     - Manage your Books (https://readarr.com/)"
echo "- Lidarr      - Manage your Music (https://lidarr.audio/)"
echo "- Bazarr      - Manage Subtitles for you Media Collection (https://www.bazarr.media/)"
echo "- Prowlarr    - Indexer aggregator for Sonarr and Radarr (https://github.com/Prowlarr/Prowlarr)"
echo "- qBittorrent - Does the actual download...(https://www.qbittorrent.org/)"
echo "- Tubesync    - Manage your favorite Youtube Channels (https://github.com/meeb/tubesync)"
echo "=============================================================================="
}
# ============================================================================================
# Check all the prerequisites are installed before continuing
# ============================================================================================
echo "Checking prerequisites..."


check_dependencides "docker"
check_dependencides "docker-compose"

if docker-compose -v &> /dev/null; then
docker-compose -v

sleep 1
fi
if [[ "$EUID" = 0 ]]; then
    send_error_message "Fly-Hi has to run without sudo! Please, run it again with regular permissions"
fi

# ============================================================================================



# Setting the preferred media service
echo
echo
echo
echo "By default, Fly-Hi supports various self-hosted management services:"
running_services_management
running_services_network
running_services_media
running_services_download
echo
send_warning_message "Unless you are sure your previous docker installation has properly setup"
send_warning_message "permissions for non-root users run permissions.sh script, otherwise continue!"
read -p "Would you like to continue? [Y/n]: " start
start=${start:-"y"}
if [ "$start" == "n" ]; then
exit 0
fi
# ============================================================================================
# Gathering information
# ============================================================================================
send_message_in_blue "=============================================================================="
echo
send_success_message "First I will need some basic information about your system like the"
send_success_message "locations of your library folders, time-zone etc. that we will need"
send_success_message "to use throughout the installation process, so lets start!"
echo
send_message_in_blue "=============================================================================="
echo
read -p "Where Would you like to install the docker-compose and .env files? [/opt/fly-hi]: " install_location

# Checking if the install_location exists
install_location=${install_location:-/opt/fly-hi}
sudo mkdir -p $install_location # or whichever directory will be used as the root folder of you docker services
sudo chown -R $USER:$USER $install_location # or whichever directory will be used as the root folder of you docker services
[[ -f "$install_location" ]] || mkdir -p "$install_location" || send_error_message "There was an error with your install location! Make sure the directory exists and the user \"$USER\" has permissions on it"
[[ -f "$install_location/media" ]] || mkdir -p "$install_location/media" || send_error_message "There was an error with your install location! Make sure the directory exists and the user \"$USER\" has permissions on it"
[[ -f "$install_location/starrs" ]] || mkdir -p "$install_location/starrs" || send_error_message "There was an error with your install location! Make sure the directory exists and the user \"$USER\" has permissions on it"
[[ -f "$install_location/network" ]] || mkdir -p "$install_location/network" || send_error_message "There was an error with your install location! Make sure the directory exists and the user \"$USER\" has permissions on it"
[[ -f "$install_location/management" ]] || mkdir -p "$install_location/management" || send_error_message "There was an error with your install location! Make sure the directory exists and the user \"$USER\" has permissions on it"
install_location=$(realpath "$install_location")

compose_media="$install_location/media/docker-compose.yaml"
compose_starrs="$install_location/starrs/docker-compose.yaml"
compose_network="$install_location/network/docker-compose.yaml"
compose_management="$install_location/management/docker-compose.yaml"
env_media="$install_location/media/.env"
env_starrs="$install_location/starrs/.env"
env_network="$install_location/network/.env"
env_management="$install_location/management/.env"

wireguard="$install_location/wireguard-install.sh"
openvpn="$install_location/openvpn-install.sh"

# Set fly-hi script
send_warning_message "I need your sudo password to install the fly-hi CLI and correct permissions on it"
sudo cp fly-hi /usr/local/bin/fly-hi && sudo chmod +x /usr/local/bin/fly-hi
sudo sed -i -e "s;<install_location>;$install_location;g" /usr/local/bin/fly-hi

# Checking that the user exists
username=${username:-$USER}

if id -u "$username" &>/dev/null; then
    puid=$(id -u "$username");
    pgid=$(id -g "$username");
else
    send_error_message "The user \"$username\" doesn't exist!"
fi
# Copy the docker-compose and .env.example file from the examples to the real one
echo
echo "Configuring the docker-compose file for the user \"$username\" on \"$install_location\"..."
echo "Copying docker-compose files..."
echo "Copying environment files..."
cp docker-compose.example.media.yaml "$compose_media" || send_error_message "Your user ($USER) needs to have permissions on the installation folder!"
cp docker-compose.example.starrs.yaml "$compose_starrs" || send_error_message "Your user ($USER) needs to have permissions on the installation folder!"
cp docker-compose.example.network.yaml "$compose_network" || send_error_message "Your user ($USER) needs to have permissions on the installation folder!"
cp docker-compose.example.management.yaml "$compose_management" || send_error_message "Your user ($USER) needs to have permissions on the installation folder!"
cp env.example.media "$env_media" || send_error_message "Your user ($USER) needs to have permissions on the installation folder!"
cp env.example.starrs "$env_starrs" || send_error_message "Your user ($USER) needs to have permissions on the installation folder!"
cp env.example.network "$env_network" || send_error_message "Your user ($USER) needs to have permissions on the installation folder!"
cp env.example.management "$env_management" || send_error_message "Your user ($USER) needs to have permissions on the installation folder!"

# Set config folder
sed -i -e "s;<install_location>;$install_location;g" "$env_media" "$env_starrs" "$env_network" "$env_management"



echo
read -p "What's the user that is going to own the media server files? [$USER]: " username
username=${username:-$USER}
# Set PUID
sed -i -e "s/<your_PUID>/$puid/g" "$env_media" "$env_starrs" "$env_network" "$env_management"
# Set PGID
sed -i -e "s/<your_PGID>/$pgid/g" "$env_media" "$env_starrs" "$env_network" "$env_management"


#Choose Time Zone
echo
read -p "Please, input your timezone in format Region/City or leave system default: " timezone
timezone=${timezone:-"$(timedatectl | grep zone | awk -F":" '{ print $2 }' | awk '{ print $1 }')"}
# Set timezone
sed -i -e "s;<timezone>;$timezone;g" "$env_media" "$env_starrs" "$env_network" "$env_management"
echo
read -p "Please, input your DATA ROOT folder [/media/data]: " data_root
data_root=${data_root:-"/media/data"}
data_root=$(realpath "$data_root")
# Set data_root
sed -i -e "s;<data_root>;$data_root;g" "$env_media" "$env_starrs" "$env_network"
echo
send_success_message "User: $username"
send_success_message "Timezone: $timezone"
send_success_message "Install location: $install_location"
send_success_message "Data root folder: $data_root"
send_warning_message "If something doesnt look right please start over!"
sleep 2


send_message_in_blue "=============================================================================="
#databases
echo "We will need to install Postgres and MariaDB databases in order for some containers to properly work. This can also be managed post installation in docker-compose and .env files."
echo
password=$(get_password "mysqlroot")

sed -i -e "s;<mysql_root_password>;$password;g" "$env_network" "$env_management" "$env_media" "$env_starrs"
echo
password=$(get_password "mysql")

sed -i -e "s;<mysql_password>;$password;g" "$env_network" "$env_management" "$env_media" "$env_starrs"
echo
password=$(get_password "postgres")
sed -i -e "s;<postgres_password>;$password;g" "$env_network" "$env_management" "$env_media" "$env_starrs"



clear
running_services_management
echo
send_message_in_blue "=============================================================================="
echo
send_success_message "Time to choose your Management Services."
send_success_message "Management Services are supposed to make your Self-Hosting life easier!"
echo
send_message_in_blue "=============================================================================="
echo
add_service "whoami" "Gives you basic information about your Host - Used for testing and troubleshooting"
add_service "portainer" "Keep your docker containers in check! (https://www.portainer.io/)"
add_service "dozzle" "All docker logs in one place on a nice WEB-UI (https://dozzle.dev/)"
add_service "heimdall" "Keep your services organized on a nice Dashboard (https://github.com/linuxserver/Heimdall)"
add_service "watchtower" "Keep your docker containers up to date! (https://github.com/containrrr/watchtower)"
add_service "glances" "System Information (https://nicolargo.github.io/glances/)"
add_service "uptimekuma" "Real time monitoring of your services (https://github.com/louislam/uptime-kuma)"
add_service "scrutiny" "HDD/SSD monitoring tool with a nice dashboard (https://github.com/AnalogJ/scrutiny)"
add_service "nfty" "Beautiful push notification server for docker services, ssh, cronjobs etc. (https://docs.ntfy.sh/)"
add_service "vaultwarden" "Password Manager (https://hub.docker.com/r/vaultwarden/server)"
add_service "phpmyadmin" "WEBui for managing MySQL databases, tables, columns, relations, indexes, users, permissions, etc (https://hub.docker.com/r/phpmyadmin/phpmyadmin/)"
add_service "pgadmin" "WEBui for managing Postgres databases, tables, columns, relations, indexes, users, permissions, etc (https://www.pgadmin.org/docs/pgadmin4/latest/container_deployment.html)"


#COCKPIT PROJECT
echo "Would you like to add Cockpit Project? [y/N]: "
send_warning_message "Note: This will require your sudo password!:"
read -p "" cockpit
cockpit=${cockpit:-"n"}
if [ "$cockpit" == "y" ]; then
. /etc/os-release
sudo apt install -t ${VERSION_CODENAME}-backports cockpit
sudo systemctl enable --now cockpit.socket
fi
send_message_in_blue "=============================================================================="
send_message_in_blue "=============================================================================="
clear
running_services_network
echo
send_message_in_blue "=============================================================================="
echo
send_success_message "Time to choose your Network Services."
send_success_message "Network services are here to make your server safer, accessible from outside or simply easier to navigate!"
echo
send_message_in_blue "=============================================================================="
echo
add_service "flaresolverr" "Proxy server to bypass Cloudflare protection in Prowlarr https://github.com/FlareSolverr/FlareSolverr"
add_service "ddclient" "Keep your Domain updated at all times (Unnecessary if you are NOT exposing any of your service to public!) https://github.com/ddclient/ddclient"
add_service "speedtest" "Monitor your internet speed on a scheduled basis https://github.com/alexjustesen/speedtest-tracker"


echo "Would you like to install Traefik? "
echo "Traefik can serve as a reverse-proxy and make your running service easily reachable through hostnames instead of IPs and Port numbers!"
echo
echo "If you dont have a Static IP or any private Domain name it might be better to skip traefik installation!!!"
echo "At the momemnt, this script supports obtaining certificates either with DNS challege over cloudflare"
echo "which doesnt require opening your ports or classic HTTP challenge"
echo "which needs to have ports 80 and 443 open and forwarded to your Host (Dangerous) which will expose"
echo "ALL of your service behind traefik to the public until you close those ports ON THE ROUTER itself due to"
echo "docker security flaws: docker automatically opens all ports required by cointainers through iptables"
echo "Check https://github.com/chaifeng/ufw-docker and https://github.com/shinebayar-g/ufw-docker-automated"
echo "However, you can always resort to default self-signed certificates generated by traefik"
echo "If you choose to install traefik, know that this is a pretty basic setup just to make things work, no extra tweaks"
echo "which could make it more secure etc., really... use this at your own risk!"
echo
echo
read -p "Would you like to proceed with installation of Traefik? [y/N]:" traefik
traefik=${traefik:-"n"}
if [[ $traefik == "y" ]]; then
    # Uncomment lines between #traefikstart and #traefikend
    sed -i '/^#traefikstart$/,/^#traefikend$/{/^\(#traefikstart\|#traefikend\)$/!s/^#//}' "$compose_network"
    # delete lines with #localhost#
    sed -i '/#localhost#/d' "$compose_media" # this is used only for joplin and linkwarden because of some APP_URL conflicts when running behind reverse-proxy
    echo "Would you prefer to use DNS (only cloudflare supported at the momemnt - you can manually switch the"
    echo "provider after the installation to any other you can find here: https://go-acme.github.io/lego/dns/) "
    echo "or would you prefer to use HTTP challenge (any provider)?"
    echo
    echo "Extra info can be found here https://doc.traefik.io/traefik/user-guides/docker-compose/acme-http/"
    echo "and here https://doc.traefik.io/traefik/user-guides/docker-compose/acme-dns/"
    echo
    read -rp "[DNS/http]:" -e -i dns traefik_tls
    if [ "$traefik_tls" == "dns" ]; then
        read -p "Please, input your let's encrypt email address: " letsencrypt_email
        read -p "Please, input your cloudflare email address [$letsencrypt_email]: " cloudflare_email
        cloudflare_email=${cloudflare_email:-"$letsencrypt_email"}
        read -p "Please, input your cloudflare API token: " cloudflare_api
        read -p "Please, input your your domain name: " my_domain
        else
        read -p "Please, input your let's encrypt email address: " letsencrypt_email
        read -p "Please, input your your domain name: " my_domain
    fi
    # Set Traefik config
    if [ "$traefik_tls" == "dns" ]; then
        sed -i -e "s;<letsencrypt_email>;$letsencrypt_email;g" "$env_network"
        sed -i -e "s;<cloudflare_email>;$cloudflare_email;g" "$env_network"
        sed -i -e "s;<cloudflare_api>;$cloudflare_api;g" "$env_network"
        sudo sed -i -e "s;<my_domain>;$my_domain;g" "$env_network" "$env_management" "$env_media" "$env_starrs" "/usr/local/bin/fly-hi"
        sed -i '/#dnschallenge#/s/^#//' "$compose_network" "$compose_starrs" "$compose_management" "$compose_media"

    else
        sed -i -e "s;<letsencrypt_email>;$letsencrypt_email;g" "$env_network"
        sudo sed -i -e "s;<my_domain>;$my_domain;g" "$env_media" "$env_starrs" "$env_network" "$env_management" "/usr/local/bin/fly-hi"
        sed -i '/#httpchallenge#/s/^#//' "$compose_network" "$compose_starrs" "$compose_management" "$compose_media"
    fi
else
  sudo sed -i '/#traefik#/d' "$compose_network" "$compose_starrs" "$compose_management" "$compose_media" "/usr/local/bin/fly-hi"
  echo "Skipping Traefik configuration"
  localhostip=$(hostname -I | awk '{ print $1 }')
  sed -i -e "s;<localhostip>;$localhostip;g" "$env_media"
fi
send_message_in_blue "=============================================================================="
send_message_in_blue "=============================================================================="


add_service "wgeasy" "Connect to your home network from anywhere in the world! https://github.com/wg-easy/wg-easy"
if [[ $wgeasy == "y" ]]; then
password=$(get_password "wgeasy")
sed -i -e "s;<wgeasy_password>;$password;g" "$env_network"
#primary_dns=$(nmcli dev show | grep 'IP4.DNS' | awk '{ print $2 }')
#read -rp "You can change the primary DNS wgeasy will use: " -e -i $(nmcli dev show | grep 'IP4.DNS' | awk '{ print $2 }') primary_dns
sudo apt install curl -y
echo
#read -rp "Please, input your your domain name or Statis IP address [You can also leave your current public IP]: " -e -i $(curl ifconfig.me) my_domain
read -p "Please, input your your domain name or Statis IP address (Your current public IP address is:[$(curl ifconfig.me)]): " my_domain
if [[ $traefik == "n" ]]; then
    my_domain=${my_domain:-$(curl ifconfig.me)}
    sudo sed -i -e "s;<my_domain>;$my_domain;g" "$env_network" "$env_management" "$env_media" "$env_starrs" "/usr/local/bin/fly-hi"
fi
read -rp "Please, input the port you forwarded from your router to your wg-easy VPN server: " -e -i 51820 portfwd_wgeasy
sed -i -e "s;<forwarded_port_wgeasy>;$portfwd_wgeasy;g" "$env_network"
sed -i '/#port_forwarding_wgeasy#/s/^#//' "$env_network"

fi

#VPN CLIENT
read -p "Would you like to configure a VPN Clinet (Used for qBittorrent but with a few tweaks it can be used for any of your services)? [Y/n]: " gluetun
gluetun=${gluetun:-"y"}
if [[ $gluetun == "y" ]]; then
    # Uncomment lines between #gluetunstart and #gluetunend
    sed -i '/^#gluetunstart$/,/^#gluetunend$/{/^\(#gluetunstart\|#gluetunend\)$/!s/^#//}' "$compose_network"
    # Comment lines with #yes_gluetun#
    sed -i '/#yes_gluetun#/s/^/#/' "$compose_starrs"
    send_message_in_cyan "You can check the supported VPN list here: https://yams.media/advanced/vpn."
    read -rp "What's your VPN service? (with spaces): " -e -i "mullvad" vpn_service
    echo
    echo "You should read $vpn_service's documentation in case it has different configurations for username and password."
    send_message_in_cyan "The documentation for $vpn_service is here: https://github.com/qdm12/gluetun/wiki/${vpn_service// /-}"
    echo
    read -p "What's your VPN username? (without spaces)(if you are using mullvad your mullvad password is your username): " vpn_user

    get_password "$vpn_service VPN"
    echo
    echo "What country Would you like to use? "
    send_message_in_cyan "You can check more info and the countries/regions list for your VPN here: https://github.com/qdm12/gluetun-wiki/tree/main/setup/providers"
    send_message_in_cyan "and here: https://github.com/qdm12/gluetun-wiki/blob/main/setup/servers.md"
    read -rp "If you are using: NordVPN, Perfect Privacy, Private Internet Access, VyprVPN, WeVPN or Windscribe, then input a region: " -e -i USA vpn_country
    #vpn_country=${vpn_country:-"USA"}
    read -rp "What city Would you like to use (If it is two words put it in double quotes and check the github page for detailed lists)?: " -e -i '"Chicago IL"' vpn_city
    #vpn_city=${vpn_city:-"london"}
    echo
    echo "Recently popular services such as Mullvad removed their option to use port forwarding, if you have a service which provides such a"
    read -p "feature and you would like to use it, answer yes [N/y]: " portfwd_y_n
    portfwd_y_n=${portfwd_y_n:-"n"}
    if [[ $portfwd_y_n == "y" ]]; then
    read -rp "Please, input your forwarded port for seeding: " -e -i 57778 portfwd
    sed -i -e "s;<forwarded_port>;$portfwd;g" "$env_network" "$env_starrs" "$env_media"
    sed -i '/#port_forwarding#/s/^#//' "$env_network" "$env_starrs" "$env_media" "$compose_network" "$compose_starrs" "$compose_media"
    fi
    #Set docker-compose file
    sed -i -e "s;<vpn_service>;$vpn_service;g" "$env_network"
    sed -i -e "s;<vpn_user>;$vpn_user;g" "$env_network"
    sed -i -e "s;<vpn_country>;$vpn_country;g" "$env_network"
    sed -i -e "s;<vpn_city>;$vpn_city;g" "$env_network"
    sed -i -e "s;<vpn_password>;$password;g" "$env_network"
    if echo "nordvpn perfect privacy private internet access vyprvpn wevpn windscribe" | grep -qw "$vpn_service"; then
        sed -i -e "s;SERVER_COUNTRIES;SERVER_REGIONS;g" "$env_network"
    fi
else
  # Comment lines with #no_gluetun#
  sed -i '/#no_gluetun#/s/^/#/' "$compose_starrs"
  echo "Skipping Gluetun configuration"
fi
send_message_in_blue "=============================================================================="
send_message_in_blue "=============================================================================="

#VPN SERVER
send_warning_message " =============  FOR ADVANCED USERS ONLY !!! ============="
echo "Would you like to install an alternative to wg-easy (bash version) personal VPN server to help you access your media from the outside of your home? [y/N]: "
send_warning_message "Note: This will require your sudo password! "
send_warning_message "Note: If you already chose docker version of wireguard 'WG-Easy' which is recommended you can skip this step unless you want to run OpenVPN also!"
read -p "" install_vpn_server
install_vpn_server=${install_vpn_server:-"n"}
if [ "$install_vpn_server" == "y" ]; then
    echo
    echo
    echo
    read -rp "Would you prefer to use Wireguard or OpenVPN: " -e -i wireguard vpn_choice
        if [ "$vpn_choice" == "wireguard" ]; then
            cp wireguard-install.sh "$wireguard" || send_error_message "Your user ($USER) needs to have permissions on the installation folder!"
            chmod +x $install_location/wireguard-install.sh
            sudo bash $install_location/wireguard-install.sh
        else
            cp openvpn-install.sh "$openvpn" || send_error_message "Your user ($USER) needs to have permissions on the installation folder!"
            chmod +x $install_location/openvpn-install.sh
            sudo bash $install_location/openvpn-install.sh
        fi
    send_warning_message "Remember to forward the chosen port (UDP) on your router to this device and you are good to go"
    send_warning_message "If you have a dynamic IP you can use Dynamic DNS update clinet such as No-IP"
else
    sudo sed -i '/#private_vpn#/d' /usr/local/bin/fly-hi
fi
send_message_in_blue "=============================================================================="
send_message_in_blue "=============================================================================="

#TAILSCALE
echo "Would you like to install Tailscale (Not open source)? [y/N]: "
read -p "" tailscale
tailscale=${tailscale:-"n"}
#INSTALL TAILSCALE
if [ "$tailscale" == "y" ]; then
sudo -s <<EOF
curl -fsSL https://tailscale.com/install.sh | sh
EOF
else
    sudo sed -i '/#tailscale#/d' "/usr/local/bin/fly-hi"
fi
send_message_in_blue "=============================================================================="
send_message_in_blue "=============================================================================="
sleep 1

clear
running_services_media
echo
echo
send_message_in_blue "=============================================================================="
echo
send_success_message "Time to choose your media services."
send_success_message "Your media service is the one responsible for serving your files to your network."
echo
send_message_in_blue "=============================================================================="

add_service "jellyfin" "Media Streaming Service (open-source, fork of Emby, recommended) (https://jellyfin.org/)"
add_service "emby" "Media Streaming Service (closed-source) (https://emby.media/)"
add_service "plex" "Media Streaming Service (closed-source) (https://www.plex.tv/)"
add_service "airsonic" "Music Server (https://airsonic.github.io/)"
add_service "ombi" "Jellyfin/Plex/Emby Media Requests (https://github.com/Ombi-app/Ombi)"
add_service "calibre_library" "Manage all your books in famous Calibre Library (https://hub.docker.com/r/linuxserver/calibre)"
add_service "calibre_web" "Web based Front End for Calibre-Library (https://github.com/janeczku/calibre-web)"
add_service "audiobookshelf" "Listen to your favorite Audiobooks (https://www.audiobookshelf.org/)"
add_service "nextcloud" "Popular Open Source Google Cloud alternative (https://nextcloud.com/)"
add_service "linkding" "Very fancy bookmarks managers with support for tags (https://github.com/sissbruecker/linkding)"
add_service "linkwarden" "Very fancy bookmarks manager with support for tags (https://github.com/linkwarden/linkwarden)"
add_service "joplin" "Nice and very popular Notes-taking app - This is only a Server (https://joplinapp.org/)"
add_service "freshrss" "Nice RSS agregator (https://github.com/FreshRSS/FreshRSS/tree/edge/Docker#docker-compose)"
add_service "stirling_pdf" "Your locally hosted one-stop-shop for all your PDF needs (https://github.com/Frooodle/Stirling-PDF)"
add_service "filebrowser" "Nice WebUI for accessing and managing your files (https://filebrowser.org/)"
add_service "mealie" "A self-hosted recipe manager and meal planner (https://docs.mealie.io/)"

#PHOTOPRISM
read -p "Would you like to install PhotoPrism for managing, indexing and organizing your photos? [Y/n]: " photoprism
photoprism=${photoprism:-"y"}
if [ "$photoprism" == "y" ]; then

        send_warning_message "In this script Photoprism assumes youre Photos are in located in $data_root/Photos"
        send_warning_message "Note that photoprism could create a huge amount of cached thumbnails which can fill up your OS drive if there"
        send_warning_message "is not enough space, 64GB is minimum recommended disk for photoprism to work properly. Would you like to install it anyway? "
        read -p "If you are not sure, answer no. [Y/n]: " make_sure
        make_sure=${make_sure:-"y"}

        if [ "$make_sure" == "y" ]; then
            # Uncomment lines between #photoprismstart and #photoprismend
            sed -i '/^#photoprismstart$/,/^#photoprismend$/{/^\(#photoprismstart\|#photoprismend\)$/!s/^#//}' "$compose_media"
            read -rp "What will be your admin username?:" -e -i admin admin_username
            echo
            password=$(get_password "photoprism")
            echo
            # Set photoprism passwords
            sed -i -e "s;<admin_username>;$admin_username;g" "$env_media"
            sed -i -e "s;<admin_password>;$password;g" "$env_media"
        fi
else
    echo "Skipping photoprism configuration"

fi
send_message_in_blue "=============================================================================="
send_message_in_blue "=============================================================================="

#SAMBA SERVER
echo "Would you like to install Samba server? "
read -p "Samba can be use as a Network Attached Storage which can be mounted on your other devices like KODI, PC, Phones etc.s [n/Y]:" samba
samba=${samba:-"y"}
if [[ $samba == "y" ]]; then
sudo apt update
sudo apt install samba
send_success_message " This is your samba share config which you can modify at /etc/samba/smb.conf"
send_success_message "=============================================================================="
echo [data] | sudo tee -a /etc/samba/smb.conf
echo     path = $data_root | sudo tee -a /etc/samba/smb.conf
echo     browsable = yes | sudo tee -a /etc/samba/smb.conf
echo     read only = no | sudo tee -a /etc/samba/smb.conf
echo     guest ok = no | sudo tee -a /etc/samba/smb.conf
echo     force user = $username | sudo tee -a /etc/samba/smb.conf
echo     force group = $username | sudo tee -a /etc/samba/smb.conf
echo     create mask = 0776 | sudo tee -a /etc/samba/smb.conf
echo     directory mask = 0775 | sudo tee -a /etc/samba/smb.conf
echo     unix extensions = yes | sudo tee -a /etc/samba/smb.conf
echo     follow symlinks=yes | sudo tee -a /etc/samba/smb.conf
echo     wide links=yes | sudo tee -a /etc/samba/smb.conf
echo     allow insecure wide links=yes | sudo tee -a /etc/samba/smb.conf
echo     server multi channel support = yes | sudo tee -a /etc/samba/smb.conf
echo     aio read size = 1 | sudo tee -a /etc/samba/smb.conf
echo     aio write size = 1 | sudo tee -a /etc/samba/smb.conf
echo     inherit permissions = yes | sudo tee -a /etc/samba/smb.conf
send_success_message "=============================================================================="
sudo service smbd restart
sudo ufw allow samba
sudo smbpasswd -a $username
else
  echo "Skipping Samba configuration"
fi
send_message_in_blue "=============================================================================="
send_message_in_blue "=============================================================================="
clear


running_services_download
echo
send_message_in_blue "=============================================================================="
echo
send_success_message "Time to choose your Starrs and Download Services!"
send_success_message "Starrs are making Netflix go bankrupt!"
echo
send_message_in_blue "=============================================================================="

add_service "radarr" "Manage your Movies https://radarr.video/"
add_service "sonarr" "Manage your TV Shows https://sonarr.tv/"
add_service "readarr" "Manage your Books https://readarr.com/"
add_service "lidarr" "Manage your Music https://lidarr.audio/"
add_service "bazarr" "Manage Subtitles for you Media Collection https://www.bazarr.media/"
add_service "prowlarr" "Indexer aggregator for Sonarr and Radarr https://github.com/Prowlarr/Prowlarr"
add_service "qbittorrent" "Does the actual download...https://www.qbittorrent.org/"
add_service "qbittorrentpub" "This is just a second instance of qbittorrent that can be used to separate public from private torrent!"
add_service "tubesync" "Manage your favorite Youtube Channels (https://github.com/meeb/tubesync)"





send_success_message 🎉🎉🎉🎉🎉"Everything installed correctly! 🎉🎉🎉🎉🎉"

echo "compose_management=$compose_management" > env.reinstall
echo "compose_network=$compose_network" >> env.reinstall
echo "compose_media=$compose_media" >> env.reinstall
echo "compose_starrs=$compose_starrs" >> env.reinstall
echo "install_location=$install_location" >> env.reinstall
echo "data_root=$data_root" >> env.reinstall
echo "my_domain=$my_domain" > env.reinstall
echo "photoprism=$photoprism" >> env.reinstall
echo "nextcloud=$nextcloud" >> env.reinstall
echo "tailscale=$tailscale" >> env.reinstall
echo "traefik=$traefik" >> env.reinstall
echo "install_vpn_server=$install_vpn_server" >> env.reinstall
echo "puid=$puid" >> env.reinstall
echo "pgid=$pgid" >> env.reinstall
echo "Running the server..."
echo "This is going to take a while...grab a coffee"
send_warning_message "If this part of installation stops due to port conflicts on your system"
send_warning_message "or some other reason, correct the yaml and env files and run reinstall.sh script"
sleep 6
docker network create --subnet=${DOCKER_SUBNET:-172.22.0.0/24} fly-hi || true
docker-compose -f "$compose_network" up -d
docker-compose -f "$compose_management" up -d
docker-compose -f "$compose_media" up -d
docker-compose -f "$compose_starrs" up -d





send_success_message "If we need your sudo password to install the fly-hi CLI and correct permissions you will be prompted for it..."
send_warning_message "If you have a large library this might take a long time, but it WILL finish so hang in there!! "
[[ -f "$data_root" ]] || sudo mkdir -p "$data_root" || send_error_message "There was an error with your install location!"
if sudo chown -R "$puid":"$pgid" "$data_root"; then
    send_success_message "Media directory ownership and permissions set successfully ✅"
else
    send_error_message "Failed to set ownership and permissions for the media directory. Check permissions ❌"
fi

#media
sudo chown -R "$puid":"$pgid" "$install_location/media/jellyfin" || true
sudo chown -R "$puid":"$pgid" "$install_location/media/emby" || true
sudo chown -R "$puid":"$pgid" "$install_location/media/plex" || true
sudo chown -R "$puid":"$pgid" "$install_location/media/overseerr" || true
sudo chown -R "$puid":"$pgid" "$install_location/media/ombi" || true
sudo chown -R "$puid":"$pgid" "$install_location/media/jellyseerr" || true
sudo chown -R "$puid":"$pgid" "$install_location/media/airsonic" || true
sudo chown -R "$puid":"$pgid" "$install_location/media/audiobookshelf" || true
sudo chown -R "$puid":"$pgid" "$install_location/media/calibre_web" || true
sudo chown -R "$puid":"$pgid" "$install_location/media/calibre" || true
sudo chown -R "$puid":"$pgid" "$install_location/media/tubesync" || true
sudo chown -R "$puid":"$pgid" "$install_location/media/linkding" || true
sudo chown -R "$puid":"$pgid" "$install_location/media/linkwarden" || true
sudo chown -R "$puid":"$pgid" "$install_location/media/joplin" || true
sudo chown -R "$puid":"$pgid" "$install_location/media/freshrss" || true
sudo chown -R "$puid":"$pgid" "$install_location/media/stirling_pdf" || true
sudo chown -R "$puid":"$pgid" "$install_location/media/filebrowser" || true


# ============================================================================================
# Cleaning up...
# ============================================================================================

send_success_message "Fixing firewall rules..."
sleep 1
# Tweaks that should be done for some apps to work properly
#allow forwarded ports on router for wgeasy and vpn client
if [ "$wgeasy" == "y" ]; then
sudo /usr/sbin/ufw allow $portfwd_wgeasy
fi
if [[ $portfwd_y_n == "y" ]]; then
sudo /usr/sbin/ufw allow $portfwd
fi
# this is used so docker containers can easily access each other
sudo /usr/sbin/ufw allow from ${DOCKER_SUBNET:-172.22.0.0/24}
# Sometimes starrs have difficulty discovering qBittorrent if the webui port is not open
sudo /usr/sbin/ufw allow 8833
sudo /usr/sbin/ufw allow 8822
# Sometimes jellyseer has difficulty discovering jellyfin if the webui port is not open
sudo /usr/sbin/ufw allow 443
# BOTH OF THESE should be replaced with ufw allow from "docker.network.ip.address" to any port 443,8080
send_success_message "Done!✅"


send_success_message "Adding tweaks to crontabs..."
sleep 1
# Add photoprism indexing crontab as user
if [ "$photoprism" == "y" ]; then
echo "27 11 * * * docker exec -t photoprism photoprism index --cleanup > /home/$USER/photoprism.log 2>&1 && date >> $install_location/cron-logs/photoprism-scan.log 2>&1" | sudo tee -a /var/spool/cron/crontabs/$USER
fi

# Add nextcloud scan all files to crontab and correct config for traefik to work properly
if [[ $nextcloud == "y" ]]; then
# For nextcloud image
#sudo echo "50 11 * * * sudo docker exec --user www-data nextcloud php occ files:scan --all >> $install_location/cron-logs/nextcloud-scan.log 2>&1" | sudo tee -a /var/spool/cron/crontabs/root

# For linuxserver image
sudo echo "50 11 * * * sudo docker exec nextcloud sudo -u abc php /config/www/nextcloud/occ files:scan --all >> $install_location/cron-logs/nextcloud-scan.log 2>&1"  | sudo tee -a /var/spool/cron/crontabs/root
    # If traefik is enabled accessing nextcloud over https wont be easy unless an override rule is added to the config
    #  * When generating URLs, Nextcloud attempts to detect whether the server is
    #  * accessed via ``https`` or ``http``. However, if Nextcloud is behind a proxy
    #  * and the proxy handles the ``https`` calls, Nextcloud would not know that
    #  * ``ssl`` is in use, which would result in incorrect URLs being generated.
    #  * Valid values are ``http`` and ``https``.
    #  */
    if [[ $traefik == "y" ]]; then
    # Nextcloud image
    #sudo sed -i -e "s|'overwriteprotocol' => '',|'overwriteprotocol' => 'https',|g" "$install_location/media/nextcloud/config.php"
    # Nextcloud linuxserver image
    sudo sed -i -e "s|'overwriteprotocol' => '',|'overwriteprotocol' => 'https',|g" "$install_location/media/nextcloud/config/www/nextcloud/config/config.php"
    fi
fi
send_success_message "Done!✅"


sleep 3
#printf "\033c"

echo "==================================================================================="
echo " _____  _      __ __         __ __  ____      ___ ___    ___  ___    ____   ____ "
echo "|     || |    |  |  |       |  |  ||    |    |   |   |  /  _]|   \  |    | /    |"
echo "|   __|| |    |  |  | _____ |  |  | |  |     | _   _ | /  [_ |    \  |  | |  o  |"
echo "|  |_  | |___ |  ~  ||     ||  _  | |  |     |  \_/  ||    _]|  D  | |  | |     |"
echo "|   _] |     ||___, ||_____||  |  | |  |     |   |   ||   [_ |     | |  | |  _  |"
echo "|  |   |     ||     |       |  |  | |  |     |   |   ||     ||     | |  | |  |  |"
echo "|__|   |_____||____/        |__|__||____|    |___|___||_____||_____||____||__|__|"
echo "==================================================================================="
send_success_message "All done!✅  Enjoy Fly-Hi!"
echo "You can check the installation on $install_location"
echo "==================================================================================="
echo "Everything should be running now! To check everything running, go to:"
echo
running_services_location
echo "==================================================================================="
send_warning_message "You might need to wait for a couple of minutes while everything gets up and running"
echo "All the services location and some default passwords to save you time are also saved in ~/fly-hi_media.txt"
running_services_location > ~/fly-hi-links.txt
echo "Speedtest tracker: username: admin@example.com password: password" >> ~/fly-hi-links.txt
echo "Qbittorrrent:      username: admin             password: adminadmin"  >> ~/fly-hi-links.txt
echo "FileBrowser:       username: admin             password: admin"  >> ~/fly-hi-links.txt
echo "Calibre web:       username: admin             password: admin123"  >> ~/fly-hi-links.txt
echo "Linkding           username: admin             password: adminadmin"  >> ~/fly-hi-links.txt
echo "Airsonic:          username: admin             password: admin"  >> ~/fly-hi-links.txt
echo "==================================================================================="
echo "To configure Fly-Hi, check the documentation at"
echo "https://yams.media/config"
echo "==================================================================================="
exit 0






