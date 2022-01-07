#! /bin/bash
#  для импорта свежесозданного /etc/kubernetes/admin.conf себе в локальные конфиги. Предполагается, что:
# - сертификаты-ключи встроенны (embedded) (поддержку в отдельных файлах тоже можно дописать)
# - на локальном хосте и на свежей контрол-ноде установлены утилиты jq и yq
# - на контрол-ноду можно ходить по SSH и там доступна sudo
# Особых проверок и защит нету, аккуратней. Новая конфигурация на всякий случай пишется в stdout.

# $1 - current kubectl config (e.g. ~/.kube/config)
# $2 - name for context
# $3 - control node ssh URI
# Requires yq & jq utilities both on control node and localhost


err_ex() {
  echo $1 >&2
  exit 1
}

[[ $1 ]] || err_ex "Please provide path for kubectl config (e.g. ~/.kube/config)"
[[ $2 ]] || err_ex "Please provide name for a new context"
[[ $3 ]] || err_ex "Please provide SSH URI for a control node with /etc/kubernetes/admin.conf"

CONF=$1
NAME=$2
SSH_URI=$3

CLUSTER_INFO=$(ssh -t -o LogLevel=QUIET $SSH_URI sudo yq -M -c .clusters /etc/kubernetes/admin.conf)
USER_INFO=$(ssh -t -o LogLevel=QUIET $SSH_URI sudo yq -M -c .users /etc/kubernetes/admin.conf)

LOCAL_CLUSTER_NAME=${NAME}-cluster
LOCAL_USER_NAME=${NAME}-admin
EXT_ADDR=$(echo $SSH_URI |cut -f2 -d '@')
CLUSTER_EXT_ADDR=$(echo $CLUSTER_INFO | jq -r '.[].cluster.server' |sed -r -e "s|//.*:|//${EXT_ADDR}:|")

LOCAL_CLUSTER_INFO=$(echo $CLUSTER_INFO |tr -d '\r'|jq ".[].name=\"$LOCAL_CLUSTER_NAME\"| .[].cluster.server=\"$CLUSTER_EXT_ADDR\"")
LOCAL_USER_INFO=$(echo $USER_INFO |tr -d '\r'|jq ".[].name=\"$LOCAL_USER_NAME\"")
LOCAL_CONTEXT_INFO="[ {\"context\":{\"cluster\":\"$LOCAL_CLUSTER_NAME\",\"user\":\"$LOCAL_USER_NAME\"},\"name\":\"$NAME\"} ]"

yq -y ".clusters += $LOCAL_CLUSTER_INFO | .users += $LOCAL_USER_INFO | .contexts += $LOCAL_CONTEXT_INFO" $CONF
