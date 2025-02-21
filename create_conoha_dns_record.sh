#!/bin/bash


# -------- #
# VARIABLE #
# -------- #
# ----- certbot ----- #
# CERTBOT_DOMAIN
# CERTBOT_VALIDATION
# CERTBOT_REMAINING_CHALLENGES
# CERTBOT_ALL_DOMAINS

echo "CERTBOT_DOMAIN: ${CERTBOT_DOMAIN}"
echo "CERTBOT_VALIDATION: ${CERTBOT_VALIDATION}"
echo "CERTBOT_REMAINING_CHALLENGES: ${CERTBOT_REMAINING_CHALLENGES}"
echo "CERTBOT_ALL_DOMAINS: ${CERTBOT_ALL_DOMAINS}"

# ----- script ----- # 
SCRIPT_NAME=$(basename $0)
SCRIPT_PATH=$(dirname $(readlink -f $0))

# ----- conoha_dns_api.sh  ----- #
CNH_DNS_DOMAIN=${CERTBOT_DOMAIN}'.'
CNH_DNS_DOMAIN_ROOT=`echo ${CNH_DNS_DOMAIN} | sed -r 's/^.*?\.([a-zA-Z0-9]+\.[a-zA-Z0-9]+)/\1/g'`
CNH_DNS_NAME='_acme-challenge.'${CNH_DNS_DOMAIN}
CNH_DNS_TYPE="TXT"
CNH_DNS_DATA=${CERTBOT_VALIDATION}

# -------- #
# FUNCTION #
# -------- #
source ${SCRIPT_PATH}/conoha_dns_api.sh

# ----------------- #
# CREATE DNS RECORD # 
# ----------------- #
create_conoha_dns_record



if [[ $CERTBOT_REMAINING_CHALLENGES -eq 0 ]]; then
  sleep 120
fi
