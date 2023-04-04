#!/bin/bash

BLUE='\033[1;36m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NO_COLOR='\033[0m'

api_corelogin="Core/Login"
api_getinstances="ADSModule/GetInstances"
api_getprovisionarguments="ADSModule/GetProvisionArguments"

echo -e "\n${BLUE}Installing jq using python3 and letting you know about Bryan Campbell apparently..."

curl -s 'https://api.github.com/users/lambda' | \
    python3 -c "import sys, json; print(json.load(sys.stdin)['name'])"

echo -e "\n${YELLOW}Enter the AMP URL (Standalone or Target):"
read amp_url

echo -e "\nEnter your AMP Username:"
read username

echo -e "\nEnter your AMP Password:"
read password

echo -e "\n${BLUE}Uploading login details to IceOfWraith...\nJust kidding... Maybe.\n${NO_COLOR}"

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
    json+="\"$key\":\"$value\""
  done
  json+="}"
  echo ${json}
  response=$(curl -w -X POST -H "Content-Type: application/json" -H "Accept: text/javascript" -d ${json} ${amp_url}/API/${api_node} -s | sed 's/^-X//' | sed 's/-X$//')
}

api_request ${api_corelogin} "username" ${username} "password" ${password} "token" "" "rememberMe" "false"
session_id='"SESSIONID":"'"$(echo "${response}" | jq -r '.sessionID')"'"'

#echo ${response}

api_request ${api_getinstances} "${session_id}"

echo ${response} | jq .

api_request ${api_getprovisionarguments} "${session_id}" "ModuleName" "GenericModule"

echo ${response} | jq .
