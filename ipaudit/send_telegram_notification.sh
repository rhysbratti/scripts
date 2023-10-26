chat_id=$(cat id.txt)
bot_token=$(cat bottoken.txt)
echo "Sending telegram notification"
curl -s --data-urlencode "text=$1" --data "chat_id=$chat_id" "https://api.telegram.org/bot${bot_token}/sendMessage" > /dev/null
