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

  # 最大試行回数 (120秒)
  MAX_RETRIES=120
  RETRY_COUNT=0
  
  while [[ $RETRY_COUNT -lt $MAX_RETRIES ]]; do
    echo "[$RETRY_COUNT/$MAX_RETRIES] DNS 伝播確認中..."

    # `dig` で取得した TXT レコードが空でなければ OK
    RESULT=$(dig @8.8.8.8 +short TXT _acme-challenge.${CERTBOT_DOMAIN})

    if [[ -z "$RESULT" ]]; then
      echo "❌ DNS 伝播中..."
      RETRY_COUNT=$(expr $RETRY_COUNT + 1)
      sleep 1
      continue
    fi

    echo "✅ DNS 伝播完了: $RESULT"
    break
  done

  # タイムアウト処理
  if [[ $RETRY_COUNT -ge $MAX_RETRIES ]]; then
    echo "❌ DNS 伝播が確認できませんでした。"
    exit 1
  fi
fi
