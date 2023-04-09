#!/bin/bash

BLUE='\033[1;36m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NO_COLOR='\033[0m'

api_corelogin="Core/Login"
api_createinstance="ADSModule/CreateInstance"
api_getinstances="ADSModule/GetInstances"
api_getprovisionarguments="ADSModule/GetProvisionArguments"
api_getdatastores="ADSModule/GetDatastores"
api_getdatastoreinstances="ADSModule/GetDatastoreInstances"
api_getinstance="ADSModule/GetInstance"
api_getsupportedapplications="ADSModule/GetSupportedApplications"

echo -e "\n${BLUE}Installing jq using python3 and letting you know about Bryan Campbell apparently..."

curl -s 'https://api.github.com/users/lambda' | \
    python3 -c "import sys, json; print(json.load(sys.stdin)['name'])"

function api_request() {
  api_node=("$1")
  shift
  local json='{'
  if [[ ${api_node} != "Core/Login" ]]; then
    json+=$1
    shift
  fi
  args=("$@")
  for (( i=0; i<${#args[@]}; i+=2 )); do
    if [[ $i == 0 && ${api_node} != "Core/Login" ]]; then
      json+=","
    elif [[ $i > 1 ]]; then
      json+=","
    fi
    key="${args[$i]}"
    value="${args[$i+1]}"
    if [[ "$key" == "ProvisionSettings" ]]; then
      json+="\"$key\":{}"
    else
      json+="\"$key\":\"$value\""
    fi
  done

  json+="}"
#  echo ${json}
  response=$(curl -w -X POST -H "Content-Type: application/json" -H "Accept: text/javascript" -d ${json} ${amp_url}/API/${api_node} -s | sed 's/^-X//' | sed 's/-X$//')
}

function clone_instance() {
  api_request ${api_getinstances} "${session_id}"
  echo "${response}" | jq -r .result[].AvailableInstances[].InstanceName | sort -f
  instances_current_names=( $( echo "${response}" | jq -r .result[].AvailableInstances[].InstanceName | sort -f ) )
  echo -e "\n${YELLOW}Please enter the instance to clone:${NO_COLOR}"
  read instance_to_clone

  found=""
  for value in "${instances_current_names[@]}"; do
    if [[ "$value" == "$instance_to_clone" ]]; then
      found="y"
    fi
  done
  if [[ "$found" == "y" ]]; then
    found="y"
    instance_current_id=( $( echo "${response}" | jq -r ".result[].AvailableInstances[] | select(.InstanceName==\"${instance_to_clone}\") | .InstanceID" ) )
    api_request ${api_getinstance} "${session_id}" "InstanceId" "${instance_current_id}"
    get_datastores
  else
    echo -e "\n${RED}That instance does not exist!${NO_COLOR}"
    exit
  fi
  empty_json=$( echo "" | jq . )
  echo ${empty_json}
  api_request ${api_createinstance} "${session_id}" "TargetADSInstance" "56abfdfb-4668-44d2-9dfa-029e85a24130" "NewInstanceId" "00000000-0000-0000-0000-000000000000" "Module" "Minecraft" "InstanceName" "" "FriendlyName" "CopyTEST" "IPBinding" "0.0.0.0" "PortNumber" "8080" "ProvisionSettings" "{}" "AutoConfigure" "true" "PostCreate" "0" "StartOnBoot" "true" "DisplayImageSource" "internal:MinecraftJava" "TargetDatastore" "-1"
  echo ${response} | jq .
}

function get_datastores() {
  api_request ${api_getdatastores} "${session_id}"
  datastore_ids=( $( echo "${response}" | jq '.result[].Id' ) )

  echo -e "\nDatastores:"

  for id in "${datastore_ids[@]}"; do
    echo "${id} - $(echo "${response}" | jq -r ".result[] | select(.Id==${id}) | .FriendlyName")"
  done

  echo -e "\n${YELLOW}Please select a datastore:${NO_COLOR}"
  read datastore_id_input
}

function get_instances() {

  instances=()

# Make the API request and populate the instances array
  api_request ${api_getinstances} "${session_id}"
  i=1
  while read -r line; do
    instance_id=$(echo "${line}" | jq -r '.InstanceID')
    instance_name=$(echo "${line}" | jq -r '.InstanceName')
    target_id=$(echo "${line}" | jq -r '.TargetID')
    if [[ $(echo "${line}" | jq -r '.Module') != "ADS" ]]; then
      instances+=("${i},${instance_id},${instance_name},${target_id}")
      i=$((i+1))
    fi
  done < <(echo "${response}" | jq -c '.result[].AvailableInstances[]')

# Check if instances array is empty
  if [[ ${#instances[@]} -eq 0 ]]; then
    echo "No instances found."
    exit 1
  fi

# Prompt user to choose an instance
  echo "Available instances:"
  echo "------------------------"
  for instance in "${instances[@]}"; do
    # Split instance data using comma separator
    IFS=',' read -ra instance_data <<< "${instance}"
    # Print only the first and third values without ADS01
    printf "%s %s %s\n"  "${instance_data[0]} -" "${instance_data[1]}:" "${instance_data[2]}"
  done
  echo "------------------------"
  read -rp "Which instance do you want to choose? " instance_choice

  # Validate user input
  valid_choice=false
  for instance in "${instances[@]}"; do
    # Split instance data using comma separator
    IFS=',' read -ra instance_data <<< "${instance}"
    if [[ "${instance_data[0]}" == "${instance_choice}" ]]; then
      valid_choice=true
      # Store the selected instance details in another array
      selected_instance=("${instance_data[@]}")
      break
    fi
  done

  # Check if user input is valid
  if [[ "${valid_choice}" == "false" ]]; then
    echo "Invalid choice. Please select a valid instance."
    exit 1
  fi

  # Print selected instance details
  echo "Selected instance details:"
  echo "Instance ID: ${selected_instance[1]}"
  echo "Instance Name: ${selected_instance[2]}"

}

function get_supported_apps() {
  api_request ${api_getsupportedapplications} "${session_id}"
  supported_apps=( $( echo "${response}" | jq .[].FriendlyName ) )
}

function move_instance_locally() {
  get_instances
  get_datastores
  api_request "ADSModule/MoveInstanceDatastore" "${session_id}" "instanceId" "${selected_instance[1]}" "datastoreId" "${datastore_id_input}"
  output=$(echo ${response} | jq -r 'if .result.Status == true then "Status: Success!!\n" else "Status: FAILURE\nReason: \(.result.Reason) \n" end')
  printf "${output}"
}

echo -e "\n${YELLOW}Enter the AMP URL (Target or Standalone only):"
read amp_url

echo -e "\nEnter your AMP Username:"
read username

echo -e "\nEnter your AMP Password:"
read password

echo -e "\n${BLUE}Uploading login details to IceOfWraith...\nJust kidding... Maybe.\n${NO_COLOR}"

echo -e "\n${YELLOW}What would you like to do?\n1 - Clone an Instance\n2 - Move an Instance Locally"
read action

api_request ${api_corelogin} "username" ${username} "password" ${password} "token" "" "rememberMe" "false"
session_id='"SESSIONID":"'"$(echo "${response}" | jq -r '.sessionID')"'"'

case $action in
  1)
	#clone_instance
    echo -e "\n${RED}This feature is not yet implemented!${NO_COLOR}"
    exit
	;;
  2)
	move_instance_locally
	;;
  *)
	echo -e "\n${RED}Invalid option!${NO_COLOR}"
	exit
	;;
esac

#move_instance_locally
#get_instances
#api_request ${api_getinstances} "${session_id}"
#echo "${response}" | jq '.result[].AvailableInstances[] | select(.Module=="ADS") | "\(.InstanceID) \(.TargetID) \(.InstanceName)"'

#echo ${response} | jq .