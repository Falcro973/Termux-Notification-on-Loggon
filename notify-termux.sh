#!/usr/bin/env bash
# /usr/local/sbin/notify-termux.sh
# Envoi une notification Termux à chaque ouverture de session SSH uniquement

LOGFILE="/var/log/notify-termux.log"

{
    echo "===== $(date) ====="
    echo "Script appelé par PAM_TYPE=$PAM_TYPE (user=$PAM_USER, host=$PAM_RHOST)"

    # On ne notifie que lors de l'ouverture de session
    if [[ "$PAM_TYPE" != "open_session" ]]; then
        echo "Non exécuté (type=$PAM_TYPE)"
        echo ""
        exit 0
    fi

    SSH_KEY="/root/.ssh/termux_notify_key"
    SSH_USER="termux"
    SSH_HOST="192.168.1.12"
    SSH_PORT=8022

    HOSTNAME="$(hostname)"
    TIMESTAMP="$(date '+%Y-%m-%d %H:%M:%S')"

    remote_cmd="/data/data/com.termux/files/usr/bin/termux-notification \
        --title '${HOSTNAME}' \
        --content '${PAM_USER:-unknown} depuis ${PAM_RHOST:-local} à ${TIMESTAMP}'"

    echo "Commande envoyée : $remote_cmd"

    /usr/bin/ssh -i "$SSH_KEY" -p "$SSH_PORT" -o BatchMode=yes -o ConnectTimeout=5 \
        -o StrictHostKeyChecking=yes "${SSH_USER}@${SSH_HOST}" \
        "bash -lc \"$remote_cmd\"" 2>&1

    echo "Code retour SSH : $?"
    echo ""
} >> "$LOGFILE" 2>&1

