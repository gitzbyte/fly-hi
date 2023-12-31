#!/bin/bash
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
echo "Running the server..."
echo "This is going to take a while...grab a coffee"
send_warning_message "If this part of installation stops due to port conflicts on your system"
send_warning_message "or some other reason, correct the yaml and env files and run reinstall.sh script"
source env.reinstall
docker network create fly-hi || true
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
sudo chown -R "$puid":"$pgid" "$install_location/media/calibreweb" || true
sudo chown -R "$puid":"$pgid" "$install_location/media/calibre" || true
sudo chown -R "$puid":"$pgid" "$install_location/media/tubesync" || true
sudo chown -R "$puid":"$pgid" "$install_location/media/linkding" || true
sudo chown -R "$puid":"$pgid" "$install_location/media/linkwarden" || true
sudo chown -R "$puid":"$pgid" "$install_location/media/joplin" || true
sudo chown -R "$puid":"$pgid" "$install_location/media/freshrss" || true
sudo chown -R "$puid":"$pgid" "$install_location/media/stirling-pdf" || true
sudo chown -R "$puid":"$pgid" "$install_location/media/filebrowser" || true
#sudo chown -R "$puid":"$pgid" "$install_location/media/photoprism" || true
#sudo chown -R "$puid":"$pgid" "$install_location/media/nextcloud" || true
# #starrs
# sudo chown -R "$puid":"$pgid" "$install_location/starrs/qbittorrent" || true
# sudo chown -R "$puid":"$pgid" "$install_location/starrs/qbittorrentpub" || true
# sudo chown -R "$puid":"$pgid" "$install_location/starrs/radarr" || true
# sudo chown -R "$puid":"$pgid" "$install_location/starrs/sonarr" || true
# sudo chown -R "$puid":"$pgid" "$install_location/starrs/lidarr" || true
# sudo chown -R "$puid":"$pgid" "$install_location/starrs/readarr" || true
# sudo chown -R "$puid":"$pgid" "$install_location/starrs/bazarr" || true
# sudo chown -R "$puid":"$pgid" "$install_location/starrs/prowlarr" || true
# #management
# sudo chown -R "$puid":"$pgid" "$install_location/management/heimdall" || true
# sudo chown -R "$puid":"$pgid" "$install_location/management/glances" || true
# sudo chown -R "$puid":"$pgid" "$install_location/management/uptime-kuma" || true
# sudo chown -R "$puid":"$pgid" "$install_location/management/scrutiny" || true
# sudo chown -R "$puid":"$pgid" "$install_location/management/vaultwarden" || true
# sudo chown -R "$puid":"$pgid" "$install_location/management/ntfy" || true
# ============================================================================================

# ============================================================================================
# Cleaning up...
# ============================================================================================


# Tweaks that should be done for some apps to work properly

# Sometimes starrs have difficulty discovering qBittorrent if the webui port is not open
sudo /usr/sbin/ufw allow 8080
sudo /usr/sbin/ufw allow 8822
# Sometimes jellyseer has difficulty discovering jellyfin if the webui port is not open
sudo /usr/sbin/ufw allow 443
# BOTH OF THESE should be replaced with ufw allow from "docker.network.ip.address" to any port 443,8080

# Add photoprism indexing crontab as user
if [ "$photoprism" == "y" ]; then
echo "27 11 * * * docker exec -t photoprism photoprism index --cleanup > /home/$USER/photoprism.log 2>&1 && date >> $install_location/cron-logs/photoprism-scan.log 2>&1" | sudo tee -a /var/spool/cron/crontabs/$USER
fi

# Add nextcloud scan all files to crontab and correct config for traefik
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
echo "Calibre-web:       username: admin             password: admin123"  >> ~/fly-hi-links.txt
echo "Linkding           username: admin             password: adminadmin"  >> ~/fly-hi-links.txt
echo "Airsonic:          username: admin             password: admin"  >> ~/fly-hi-links.txt
echo "==================================================================================="
echo "To configure Fly-Hi, check the documentation at"
echo "https://yams.media/config"
echo "==================================================================================="
exit 0
