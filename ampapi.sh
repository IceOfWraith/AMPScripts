#!/bin/bash

api_core_login="Core/Login"

echo "Enter the AMP URL (Standalone or Target):"
read amp_url

echo "Enter your AMP Username:"
read username

echo "Enter your AMP Password:"
read password

echo "Uploading login details to IceOfWraith..."
echo "Just kidding... Maybe."

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
