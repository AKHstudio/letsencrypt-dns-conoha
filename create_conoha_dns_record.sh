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

INTERVAL=30  # チェック間隔（秒）
MAX_ATTEMPTS=40  # 最大試行回数（例: 40回 = 最大20分）

echo "🔍 DNSが反映されるのを待機中... ($CNH_DNS_NAME)"
echo "期待する値: $CNH_DNS_DATA"

for ((i=1; i<=MAX_ATTEMPTS; i++)); do
    CURRENT_VALUE=$(dig +short TXT "$CNH_DNS_NAME" | tr -d '"' | grep "$CNH_DNS_DATA")

    if [[ -n "$CURRENT_VALUE" ]]; then
        echo "✅ DNS 設定が確認されました！ ($CURRENT_VALUE)"
        exit 0
    fi

    echo "⏳ $i 回目の試行: まだ反映されていません..."
    sleep $INTERVAL
done

echo "❌ DNS が指定時間内に反映されませんでした。もう少し待って試してください。"
exit 1