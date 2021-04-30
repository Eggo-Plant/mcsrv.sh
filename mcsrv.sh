#!/bin/sh

############################################
#     DEFINE ANSI COLOR CODE VARIABLES     #
############################################

BLACK='\033[0;30m'
RED='\033[0;31m'
GREEN='\033[0;32m'
ORANGE='\033[0;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
LIGHTGRAY='\033[0;37m'
DARKGRAY='\033[1;30m'
LIGHTRED='\033[1;31m'
LIGHTGREEN='\033[1;32m'
YELLOW='\033[1;33m'
LIGHTBLUE='\033[1;34m'
LIGHTPURPLE='\033[1;35m'
LIGHTCYAN='\033[1;36m'
WHITE='\033[1;37m'
NC='\033[0m'
BOLD=$(tput bold)
NORM=$(tput sgr0)

###########################################
#     DEFINING SCRIPT FUNCTIONS/MENUS     #
###########################################

# Main menu, duh
main_menu()
{
    PS3='Please select an option [1-2]: '
    options=("Begin install wizard" "Exit script")
    select opt in "${options[@]}"
    do
        case $opt in
            "Begin install wizard")
                echo -e "${ORANGE}OK, launching server install process!${NC}"
                eula_menu
                ;;
            "Exit script")
                echo -e "${ORANGE}OK, quitting script now!${NC}"
                exit
                ;;
            *) echo "Invalid option '$REPLY'";;
        esac
    done
}

eula_menu()
{
    echo -e "By continuing to run this script you agree to the Minecraft EULA found at https://account.mojang.com/documents/minecraft_eula"
    while :
    do
        read -p "Do you agree to the Minecraft EULA? [y/n] " eula_agree
        case $eula_agree in
            [Yy]* ) server_software_select; break;;
            [Nn]* ) echo -e "${RED}${BOLD}You must agree to the Minecraft EULA to use this script!${NC}${NORM}";;
            * ) echo -e "${ORANGE}${BOLD}Please provide a valid answer";;
        esac
    done
}

# Menu for picking which server software to use
server_software_select()
{
    echo -e "${GREEN}${BOLD}Select the server software that you'd like to use.${NC}${NORM}"
    PS3='Please select an option [1-4]: '
    options=("Paper" "Spigot" "Bukkit" "Exit script")
    select software in "${options[@]}"
    do
        case $software in
            "Paper")
                echo "You chose Paper"
                paper_server_install
                ;;
            "Spigot")
                echo "You chose Spigot"
                ;;
            "Craftbukkit")
                echo "You chose Craftbukkit"
                ;;
            "Exit script")
                echo -e "${ORANGE}OK, quitting script now!"
                exit
                ;;
            *) echo "Invalid option '$REPLY'";;
        esac
    done
}

paper_server_install()
{
    echo -e "${GREEN}${BOLD}Which major version of Paper would you like to install?${NC}${NORM}"
    # Print major versions of Paper
    echo -e "${ORANGE} $(curl -s https://papermc.io/api/v2/projects/paper/ | jq -c .version_groups | tr -d '[]"' | sed 's/,/, /g')${NC}"
    while :
    do
        read -p "Enter a Minecraft Version: " selected_major_version
        if [ "$(curl -s https://papermc.io/api/v2/projects/paper/version_group/${selected_major_version} | jq -c .project_id)" != '"paper"' ]; then
            echo -e "${RED}This is not a valid version!${NC}"
        else
            break
        fi
    done

    echo -e "${GREEN}${BOLD}What minor version of Paper ${selected_major_version} would you like to install?${NC}${NORM}"
    # Print minor versions of Paper
    echo -e "${ORANGE} $(curl -s https://papermc.io/api/v2/projects/paper/version_group/${selected_major_version} | jq -c .versions | tr -d '[]"' | sed 's/,/, /g')${NC}"
    while :
    do
        read -p "Enter a Minecraft Version: " selected_minor_version
        if [ "$(curl -s https://papermc.io/api/v2/projects/paper/versions/${selected_minor_version} | jq -c .project_id)" != '"paper"' ]; then
            echo -e "${RED}This is not a valid version!"
        else
            builds="$(curl -s https://papermc.io/api/v2/projects/paper/versions/${selected_minor_version} | jq -c .builds | tr -d '[]"')"
            build_id="$(echo $builds | awk -F "," '{print $NF}')"
            echo $build_id
            paper_server_download="https://papermc.io/api/v2/projects/paper/versions/${selected_minor_version}/builds/${build_id}/downloads/paper-${selected_minor_version}-${build_id}.jar"
            echo $paper_server_download
            curl -LO $paper_server_download
            break
        fi
    done
}

##############################
#    MAIN SCRIPT CONTENT     #
##############################

echo -e "${GREEN}${BOLD}Welcome to mcsrv.sh!${NC}${NORM}"
main_menu
