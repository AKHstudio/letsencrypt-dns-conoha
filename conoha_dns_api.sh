#!/bin/bash

set -e # エラーが出たらスクリプトを終了する
set -u # 未定義変数があったらスクリプトを終了する

# -------- #
# VARIABLE #
# -------- #
SCRIPT_PATH=$(dirname $(readlink -f $0))
source ${SCRIPT_PATH}/.env

# -------- #
# FUNCTION #
# -------- #
get_conoha_token(){
  curl -sS -i https://identity.${CNH_REGION}.conoha.io/v3/auth/tokens \
  -X POST \
  -H "Accept: application/json" \
  -d '{"auth":{"identity":{"methods":["password"],"password":{"user":{"name":"'${CNH_USERNAME}'","password":"'${CNH_PASSWORD}'"}}},"scope":{"project":{"id":"'${CNH_TENANT_ID}'"}}}}' \
  | grep -i "x-subject-token" | awk '{print $2}'
}

get_conoha_domain_id(){
  curl -sS https://dns-service.${CNH_REGION}.conoha.io/v1/domains \
  -H "Accept: application/json" \
  -H "Content-Type: application/json" \
  -H "X-Auth-Token: ${CNH_TOKEN}" \
  | jq -r '.domains[] | select(.name == "'${CNH_DNS_DOMAIN_ROOT}'") | .uuid'
}

create_conoha_dns_record(){
  curl -sS https://dns-service.${CNH_REGION}.conoha.io/v1/domains/${CNH_DOMAIN_ID}/records \
  -X POST \
  -H "Accept: application/json" \
  -H "Content-Type: application/json" \
  -H "X-Auth-Token: ${CNH_TOKEN}" \
  -d '{ "name": "'${CNH_DNS_NAME}'", "type": "'${CNH_DNS_TYPE}'", "data": "'${CNH_DNS_DATA}'", "ttl": 30 }'
}

get_conoha_dns_record_id(){
  curl -sS https://dns-service.${CNH_REGION}.conoha.io/v1/domains/${CNH_DOMAIN_ID}/records \
  -X GET \
  -H "Accept: application/json" \
  -H "Content-Type: application/json" \
  -H "X-Auth-Token: ${CNH_TOKEN}" \
  | jq -r '.records[] | select(.name == "'${CNH_DNS_NAME}'" and .data == "'${CNH_DNS_DATA}'") | .uuid'
}

delete_conoha_dns_record(){
  local delete_id=$1
  curl -sS https://dns-service.${CNH_REGION}.conoha.io/v1/domains/${CNH_DOMAIN_ID}/records/${delete_id} \
  -X DELETE \
  -H "Accept: application/json" \
  -H "Content-Type: application/json" \
  -H "X-Auth-Token: ${CNH_TOKEN}"
}

# ----------- #
# GET A TOKEN #
# ----------- #
CNH_TOKEN=$(echo $(get_conoha_token) | tr -d '\r')

# echo "CNH_TOKEN: ${CNH_TOKEN}"

# ----------------- #
# GET THE DOMAIN ID #
# ----------------- #
CNH_DOMAIN_ID=$(get_conoha_domain_id)

# echo "CNH_DOMAIN_ID: ${CNH_DOMAIN_ID}"
