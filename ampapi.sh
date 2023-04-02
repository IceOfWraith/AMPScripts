#!/bin/bash

BLUE='\033[1;36m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NO_COLOR='\033[0m'

api_core_login="Core/Login"

echo -e "\n${BLUE}Installing jq using python3 and letting you know about Bryan Campbell apparently..."

curl -s 'https://api.github.com/users/lambda' | \
    python3 -c "import sys, json; print(json.load(sys.stdin)['name'])"

echo "\n${YELLOW}Enter the AMP URL (Standalone or Target):"
read amp_url

echo -e "Enter your AMP Username:"
read username

echo -e "Enter your AMP Password:"
read password

echo -e "\n${BLUE}Uploading login details to IceOfWraith..."
echo -e "Just kidding... Maybe.\n${NO_COLOR}"

function api_request() {
  api_node=("$1")
  shift
  args=("$@")
  local json='{'
  for (( i=0; i<${#args[@]}; i+=2 )); do
    if [[ $i > 1 ]]; then
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

api_request ${api_core_login} "username" ${username} "password" ${password} "token" "" "rememberMe" "false"
echo ${response} | jq .
