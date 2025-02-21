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

INTERVAL=20  # チェック間隔（秒）
MAX_ATTEMPTS=40  # 最大試行回数（例: 40回 = 最大20分）

CHECK_DNS_DOMAIN=_acme-challenge.${CERTBOT_DOMAIN}

echo "🔍 DNSが反映されるのを待機中... ($CHECK_DNS_DOMAIN)"

for ((i=1; i<=MAX_ATTEMPTS; i++)); do
    echo "🔍 DNS 設定を確認中... ($CHECK_DNS_DOMAIN)"

    # dig コマンドを実行し、標準エラーも表示する
    DIG_RESULT=$(dig +short TXT "$CHECK_DNS_DOMAIN")

    echo "🔍 dig の結果: $DIG_RESULT"

    # dig の結果が空でないか確認
    if [[ -z "$DIG_RESULT" ]]; then
        echo "❌ dig の結果が空白です。DNS 設定が反映されていない可能性があります。"
        echo "⏳ $i 回目の試行: もう一度試行します..."
        sleep $INTERVAL
        continue  # 次の試行に進む
    fi

    # 現在の DNS 設定を取得
    CURRENT_VALUE=$(echo "$DIG_RESULT" | tr -d '"' | tr -d '[:space:]' | tr -d '\r')
    # 期待する DNS 設定を取得
    CHECK_VALUE=$(echo "$CNH_DNS_DATA" | tr -d '"' | tr -d '[:space:]'| tr -d '\r')

    echo "🔍 現在の値: $CURRENT_VALUE"
    echo "✅ 期待する値: $CHECK_VALUE"

    # 期待する値と一致するか確認
    if [[ "$CURRENT_VALUE" == "$CHECK_VALUE" ]]; then
        echo "✅ DNS 設定が確認されました！ ($CURRENT_VALUE)"
        exit 0
    fi

    echo "⏳ $i 回目の試行: まだ反映されていません..."
    sleep $INTERVAL
done

echo "❌ DNS が指定時間内に反映されませんでした。もう少し待って試してください。"
exit 1