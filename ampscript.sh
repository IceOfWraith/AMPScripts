#!/bin/bash

BLUE='\033[1;36m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NO_COLOR='\033[0m'

echo -e "\n${BLUE}Please contact IceOfWraith with any issues using the script! :)"

echo -e "\nInstalling jq using python3 and letting you know about Bryan Campbell apparently..."

curl -s 'https://api.github.com/users/lambda' | \
    python3 -c "import sys, json; print(json.load(sys.stdin)['name'])"

echo -e "\nGathering list of currently used ports..."

ports_existing_amp=( $(cat /home/amp/.ampdata/instances.json | jq '.[].Port | select( . != null )' | sort -r -n) )
ports_existing_amp+=( $(cat /home/amp/.ampdata/instances.json | jq '.[].DeploymentArgs."ADSModule.Network.MetricsServerPort" | select( . != null )' | sed 's/"//g' | sort -r -n) )

IFS=$'\n' ports_existing_amp=( $(sort -r -n <<< "${ports_existing_amp[*]}") )
unset IFS

ports_existing_sftp=( $(cat /home/amp/.ampdata/instances.json | jq '.[].DeploymentArgs."FileManagerPlugin.SFTP.SFTPPortNumber" | select( . != null )' | sed 's/"//g' | sort -r -n) )

IFS=$'\n' ports_existing_sftp=( $(sort -r -n <<< "${ports_existing_sftp[*]}") )
unset IFS

ports_existing_apps=( $(cat /home/amp/.ampdata/instances.json | jq '.[].DeploymentArgs."GenericModule.App.Ports" | select( . != null )' | sed 's/\\//g' | sed 's/^"//' | sed 's/"$//' | jq '.[].Port' | sort -r -n) )
ports_existing_apps+=( $(cat /home/amp/.ampdata/instances.json | jq '.[].DeploymentArgs."RustModule.Rust.Port" | select( . != null )' | sed 's/"//g' | sort -r -n) )
ports_existing_apps+=( $(cat /home/amp/.ampdata/instances.json | jq '.[].DeploymentArgs."RustModule.Rust.QueryPort" | select( . != null )' | sed 's/"//g' | sort -r -n) )
ports_existing_apps+=( $(cat /home/amp/.ampdata/instances.json | jq '.[].DeploymentArgs."RustModule.Rust.RconPort" | select( . != null )' | sed 's/"//g' | sort -r -n) )
ports_existing_apps+=( $(cat /home/amp/.ampdata/instances.json | jq '.[].DeploymentArgs."RustModule.Rust.AppPlusPort" | select( . != null )' | sed 's/"//g' | sort -r -n) )
ports_existing_apps+=( $(cat /home/amp/.ampdata/instances.json | jq '.[].DeploymentArgs."srcdsModule.SRCDS.ServerPortBinding" | select( . != null )' | sed 's/"//g' | sort -r -n) )
ports_existing_apps+=( $(cat /home/amp/.ampdata/instances.json | jq '.[].DeploymentArgs."srcdsModule.SourceTV.SourceTVPort" | select( . != null )' | sed 's/"//g' | sort -r -n) )
ports_existing_apps+=( $(cat /home/amp/.ampdata/instances.json | jq '.[].DeploymentArgs."ARKModule.Network.GamePort" | select( . != null )' | sed 's/"//g' | sort -r -n) )
ports_existing_apps+=( $(cat /home/amp/.ampdata/instances.json | jq '.[].DeploymentArgs."ARKModule.Network.QueryPort" | select( . != null )' | sed 's/"//g' | sort -r -n) )
ports_existing_apps+=( $(cat /home/amp/.ampdata/instances.json | jq '.[].DeploymentArgs."ARKModule.Network.RCONPort" | select( . != null )' | sed 's/"//g' | sort -r -n) )
ports_existing_apps+=( $(cat /home/amp/.ampdata/instances.json | jq '.[].DeploymentArgs."Arma3Module.Arma3.Port" | select( . != null )' | sed 's/"//g' | sort -r -n) )
ports_existing_apps+=( $(cat /home/amp/.ampdata/instances.json | jq '.[].DeploymentArgs."Arma3Module.Arma3.RConPort" | select( . != null )' | sed 's/"//g' | sort -r -n) )
ports_existing_apps+=( $(cat /home/amp/.ampdata/instances.json | jq '.[].DeploymentArgs."FactorioModule.Startup.Port" | select( . != null )' | sed 's/"//g' | sort -r -n) )
ports_existing_apps+=( $(cat /home/amp/.ampdata/instances.json | jq '.[].DeploymentArgs."FactorioModule.Startup.RCONPort" | select( . != null )' | sed 's/"//g' | sort -r -n) )
ports_existing_apps+=( $(cat /home/amp/.ampdata/instances.json | jq '.[].DeploymentArgs."FiveMModule.ServerSettings.Port" | select( . != null )' | sed 's/"//g' | sort -r -n) )
ports_existing_apps+=( $(cat /home/amp/.ampdata/instances.json | jq '.[].DeploymentArgs."JC2MPModule.JC2MP.Port" | select( . != null )' | sed 's/"//g' | sort -r -n) )
ports_existing_apps+=( $(cat /home/amp/.ampdata/instances.json | jq '.[].DeploymentArgs."SevenDaysModule.Server.ServerPort" | select( . != null )' | sed 's/"//g' | sort -r -n) )
ports_existing_apps+=( $(cat /home/amp/.ampdata/instances.json | jq '.[].DeploymentArgs."SevenDaysModule.Server.WebServicePort" | select( . != null )' | sed 's/"//g' | sort -r -n) )
ports_existing_apps+=( $(cat /home/amp/.ampdata/instances.json | jq '.[].DeploymentArgs."SevenDaysModule.Server.TelnetPort" | select( . != null )' | sed 's/"//g' | sort -r -n) )
ports_existing_apps+=( $(cat /home/amp/.ampdata/instances.json | jq '.[].DeploymentArgs."StarBoundModule.ServerConfig.gameServerPort" | select( . != null )' | sed 's/"//g' | sort -r -n) )
ports_existing_apps+=( $(cat /home/amp/.ampdata/instances.json | jq '.[].DeploymentArgs."StarBoundModule.ServerConfig.queryServerPort" | select( . != null )' | sed 's/"//g' | sort -r -n) )
ports_existing_apps+=( $(cat /home/amp/.ampdata/instances.json | jq '.[].DeploymentArgs."StarBoundModule.ServerConfig.rconServerPort" | select( . != null )' | sed 's/"//g' | sort -r -n) )
ports_existing_apps+=( $(cat /home/amp/.ampdata/instances.json | jq '.[].DeploymentArgs."TerrariaModule.Terraria.Port" | select( . != null )' | sed 's/"//g' | sort -r -n) )
ports_existing_apps+=( $(cat /home/amp/.ampdata/instances.json | jq '.[].CustomPorts[].PortNumber | select( . != null )' | sed 's/\\//g' | sort -r -n) )
ports_existing_apps+=( $(cat /home/amp/.ampdata/instances.json | jq '.[].DeploymentArgs."SpaceEngineersModule.Config.RemoteApiPort" | select( . != null )' | sed 's/"//g' | sort -r -n) )
ports_existing_apps+=( $(cat /home/amp/.ampdata/instances.json | jq '.[].DeploymentArgs."SpaceEngineersModule.Config.ServerPort" | select( . != null )' | sed 's/"//g' | sort -r -n) )
ports_existing_apps+=( $(cat /home/amp/.ampdata/instances.json | jq '.[].DeploymentArgs."SpaceEngineersModule.Config.SteamPort" | select( . != null )' | sed 's/"//g' | sort -r -n) )
ports_existing_apps+=( $(cat /home/amp/.ampdata/instances.json | jq '.[].DeploymentArgs."TheForestModule.Config.ServerGamePort" | select( . != null )' | sed 's/"//g' | sort -r -n) )
ports_existing_apps+=( $(cat /home/amp/.ampdata/instances.json | jq '.[].DeploymentArgs."TheForestModule.Config.ServerQueryPort" | select( . != null )' | sed 's/"//g' | sort -r -n) )
ports_existing_apps+=( $(cat /home/amp/.ampdata/instances.json | jq '.[].DeploymentArgs."TheForestModule.Config.ServerSteamPort" | select( . != null )' | sed 's/"//g' | sort -r -n) )

IFS=$'\n' ports_existing_apps=( $(sort -r -n <<< "${ports_existing_apps[*]}") )
unset IFS


#ports_existing_combined=( "${ports_existing_metrics[

#while read line; do
#  echo $line
#  if [[ "$line" == *"ADSModule.Network.MetricsServerPort"* ]]; then
#    echo "THIS ONE!"
#  elif [[ "$line" == *"FileManagerPlugin.SFTP.SFTPPortNumber"* ]]; then
#    echo "THIS ONE TOO!"
#  elif [[ "$line" == *"GenericModule.App.Ports"* ]]; then
#    ports_array_line=()
#    IFS="\\\"Port\\\":" read -a ports_array_line <<< "$line"
#    for i in "${ports_array_line[@]}"
#    do
#      echo $i
#    done
#  fi
#done </home/amp/.ampdata/instances.json

if [ "${#ports_existing_amp[@]}" -eq 0 ] && "${#ports_existing_sftp[@]}" -eq 0 ] && "${#ports_existing_apps[@]}" -eq 0 ]; then
  echo -e "\n${RED}No ports found! This means I couldn't read the /home/amp/.ampdata/instances.json file properly!${NO_COLOR}"
  exit
fi

echo -e "\nChecking what ports are allowed to be used..."

port_method=$(cat /home/amp/.ampdata/instances/ADS01/ADSModule.kvp | grep "Network.PortAssignment" | cut -d = -f2)
port_ranges_amp=$(cat /home/amp/.ampdata/instances/ADS01/ADSModule.kvp | grep "Network.AMPPortRanges" | cut -d = -f2 | sed 's/^\[//' | sed 's/]$//' | sed 's/"//g')
port_ranges_apps=$(cat /home/amp/.ampdata/instances/ADS01/ADSModule.kvp | grep "Network.AppPortRanges" | cut -d = -f2 | sed 's/^\[//' | sed 's/]$//' | sed 's/"//g')

#echo ${port_ranges_amp}

#echo ${port_ranges_apps}

#port_ranges_apps=$(cat /home/amp/.ampdata/instances/ADS01/ADSModule.kvp | grep "Network.PortAssignment" | cut -d = -f2)

IFS=',' read -ra ports_allowed_amp <<< "$port_ranges_amp"
IFS=',' read -ra ports_allowed_apps <<< "$port_ranges_apps"

echo -e "\nGetting a list of instance names..."

instance_names=( $(ampinstmgr -l | grep "Instance Name" | tr '│' ',' | cut -d ',' -f4 | sed 's/^ //') )

echo -e "\n${YELLOW}Curent instance list:${BLUE}"

printf "%s\n" "${instance_names[@]}"

echo -e "\n${YELLOW}Enter the name of the instance to copy:${BLUE}"
read instance_to_copy

instance_exists=""
for i in "${instance_names[@]}"
do
  if [[ "$i" == "${instance_to_copy}" ]]; then
    instance_exists="y"
  fi
done

if [[ ! "$instance_exists" == "y" ]]; then
  echo -e "${RED}That instance does not exist.\n${NO_COLOR}"
  exit
fi

echo -e "\n${YELLOW}Enter the name for the new instance:${BLUE}"
read instance_new_name

instance_exists=""
for i in "${instance_names[@]}"
do
  if [[ "$i" == "${instance_new_name}" ]]; then
    instance_exists="y"
  fi
done

if [[ "$instance_exists" == "y" ]]; then
    echo -e "${RED}That instance already exists.\n${NO_COLOR}"
    exit
fi

#echo ${instance_to_copy}

location=$(ampinstmgr -i ${instance_to_copy} | grep "Data Path" | tr '│' ',' | cut -d ',' -f4 | sed 's/^ //' | rev | cut -d "/" -f2- | rev)
module=$(ampinstmgr -i ${instance_to_copy} | grep "Module" | tr '│' ',' | cut -d ',' -f4 | sed 's/^ //')

#echo ${location}

echo -e "\nCopying instance files from ${location}/${instance_to_copy} to ${location}/${instance_new_name}..."

#!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!cp -R "${location}/${instance_to_copy}" "${location}/${instance_new_name}"

if [[ "$module" == "GenericModule" ]]; then
  echo "GENERIC"
fi

if [[ "$port_method" == "Include" ]]; then
  echo "INCLUDE"
elif [[ "$port_method" == "Exclude" ]]; then
  echo "EXCLUDE"
fi

#echo ${ports_existing_amp[@]}

#echo ${ports_existing_sftp[@]}

#echo ${ports_existing_apps[@]}

echo -e "\n${NO_COLOR}Have a great day!\n"
