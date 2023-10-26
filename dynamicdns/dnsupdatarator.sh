update_dns_records() {
    local NAMES=( "local-name-here" "local-name-here" )
    SUCCESSFUL=true
    ZONE_ID=$(cat zoneid.txt)
    for NAME in "${NAMES[@]}"
    do
        DNS_RECORD_ID=$(curl -s GET "https://api.cloudflare.com/client/v4/zones/$ZONE_ID/dns_records?name=$NAME" -H "X-Auth-Email: $EMAIL" -H "X-Auth-Key: $API_KEY" -H "Content-Type: application/json" | jq -r .result[0].id)
        RESPONSE=$(curl -s --request PUT --url https://api.cloudflare.com/client/v4/zones/$ZONE_ID/dns_records/$DNS_RECORD_ID --header 'Content-Type: application/json' --header "X-Auth-Email: $EMAIL" --header "X-Auth-Key: $API_KEY" --data '{
        "content": "'$SERVER_IP'",
        "proxied": true,
        "name": "'$NAME'",
        "type": "A"}')
        SUCCESS=$(echo $RESPONSE | jq .success)
        RESPONSE_MESSAGE=$(echo $RESPONSE | jq .messages)
        echo "Updating $NAME success: $SUCCESS"
        echo "Messages: $RESPONSE_MESSAGE"
        [[ $SUCCESS != true ]] && SUCCESSFUL=false
    done
}

update_fail2ban() {
    echo "Replacing old IP with new IP in fail2ban ignore list"
    sed -i -e "s/$PREV_IP/$SERVER_IP/g" $LOCAL_PATH/fail2ban/data/jail.d/npm-docker.local
    echo "Checking new server IP in list of banned IPs"
    FIREWALL_RULES=$(curl -s -X GET "https://api.cloudflare.com/client/v4/user/firewall/access_rules/rules?per_page=1000" -H "X-Auth-Email: $EMAIL" -H "X-Auth-Key: $API_KEY" -H "Content-Type: application/json" | jq -r .result[])
    SERVER_IP_RULE_ID=$(echo $FIREWALL_RULES | jq '. | select(.configuration.value == "'$SERVER_IP'")' | jq -r .id)
    if [[ -n $SERVER_IP_RULE_ID ]]; then
        echo "Server IP was banned, unbanning..."
        DELETE_RESPONSE=$(curl -s -X DELETE "https://api.cloudflare.com/client/v4/user/firewall/access_rules/rules/$SERVER_IP_RULE_ID" -H "X-Auth-Email: $EMAIL" -H "X-Auth-Key: $API_KEY" -H "Content-Type: application/json" | jq -r .success)
        echo "Server IP unban success: $DELETE_RESPONSE"
    fi
    echo "Restarting fail2ban docker container..."
    docker container restart fail2ban_docker
}

SCRIPT_PATH="$LOCAL_PATH/scripts/dynamicdns"
SERVER_IP="$(curl -s ifconfig.me)"
PREV_IP="$(cat $SCRIPT_PATH/.ip.txt)"

if [[ $SERVER_IP != $PREV_IP ]]; then
    TELEGRAM_PATH="$LOCAL_PATH/scripts/ipaudit"
    ENCRYPT_PASS=$(cat $SCRIPT_PATH/.encrypt.txt)
    EMAIL=$(cat $SCRIPT_PATH/.email.txt)
    API_KEY=$(cat $SCRIPT_PATH/.openssl.txt | openssl enc -aes-256-cbc -md sha512 -a -d -pbkdf2 -iter 100000 -salt -pass pass:"${ENCRYPT_PASS}")
    TELEGRAM_MESSAGE="Hello! I detected a change in your home IP. Cloudflare DNS records have been successfully updated accordingly. Please check the logs for more info"
    ERROR_MESSAGE="Hello! I detected a change in your home IP. Unfortunately there was an error in updating DNS records. Please check the logs for more info"
    echo "IP change detected, updating DNS records"
    update_dns_records
    update_fail2ban
    if [[ $SUCCESSFUL = true ]]; then
        bash "$TELEGRAM_PATH/send_telegram_message.sh" "$TELEGRAM_MESSAGE"
        echo "Success telegram message sent"
        echo $SERVER_IP > $SCRIPT_PATH/.ip.txt
    else
        bash "$TELEGRAM_PATH/send_telegram_message.sh" "$ERROR_MESSAGE"
        echo "Error message sent"
    fi
fi
