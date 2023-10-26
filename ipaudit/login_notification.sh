
telegram_script_path="$local_path/ipaudit/send_telegram_message.sh"
login_ip="$(echo $SSH_CONNECTION | cut -d " " -f 1)"
login_date=$(date '+%m/%d/%Y %H:%M')
login_name="$(whoami)"

message="New login detected!
    - user: $login_name
    - ip:   $login_ip
    - date: $login_date"

bash $telegram_script_path "$message"
