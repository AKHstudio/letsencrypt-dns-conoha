#!/bin/bash


# -------- #
# VARIABLE #
# -------- #
# ----- certbot ----- #
# CERTBOT_DOMAIN
# CERTBOT_VALIDATION

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

while true; do
  # 現在のTXTレコードを取得
  RESULT=$(dig +short TXT _acme-challenge.$CERTBOT_DOMAIN | tr -d '"')

  # 期待する値と一致しているか確認
  if [[ "$RESULT" == "$CERTBOT_VALIDATION" ]]; then
    echo "✅️ TXTレコードが確認できました！"
    break
  fi

  echo "⌛️ まだ確認できません。10秒後に再試行します..."
  sleep 10
done