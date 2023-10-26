home_ip="$(curl -s ifconfig.me)"

script_path="$local_path/scripts/ipaudit/"

grep -E '2[[:digit:]]{2} ' $local_path/nginxproxymanager/data/logs/proxy-host-*_access.log | awk '{print substr($12, 1, length($12)-1)}' | sort | uniq -c > temp_200_ips

grep -E '4[[:digit:]]{2} ' $local_path/nginxproxymanager/data/logs/proxy-host-*_access.log | awk '{print substr($12, 1, length($12)-1)}' | sort | uniq -c > temp_400_ips

right_now=$(date '+%m/%d/%Y %H:%M')

declare -A reported_200_count
declare -A reported_400_count

declare -A new_ips_count_200; while read -r v k; do new_ips_count_200[$k]=$v; done < temp_200_ips
declare -A new_ips_count_400; while read -r v k; do new_ips_count_400[$k]=$v; done < temp_400_ips

reported_200_count="2xx ips: "
reported_400_count="4xx ips: "

daily_greeting_new_ips="Good morning! New ips have been detected in the nginx logs since yesterday
This data was grabbed at $right_now UTC"

daily_greeting_no_new_ips="Good morning! No new ips were found in the nginx logs!
This data was grabbed at $right_now UTC"

echo "-----------------------------------"
echo "Executed at $right_now UTC"

ips_updated_200=false
ips_updated_400=false

for ip in "${!new_ips_count_200[@]}"
do
    if [[ $ip != $home_ip ]]; then
        previous_count=$(grep $ip $script_path/ips_200.txt | awk '{print $1}')
        current_count=${new_ips_count_200[$ip]}
        if [[ -n $previous_count ]]; then
            new_count=$(($current_count - $previous_count))
        else
            new_count=$current_count
        fi
        if [[ $new_count != 0 ]]; then
            ips_updated_200=true
            reported_200_count="$reported_200_count
            - $ip - $new_count new"
        fi
    fi
done


for ip in "${!new_ips_count_400[@]}"
do
    if [[ "$ip" != "$home_ip" ]]; then
        previous_count=$(grep $ip $script_path/ips_400.txt | awk '{print $1}')
        current_count=${new_ips_count_400[$ip]}
        if [[ -n $previous_count ]]; then
            new_count=$(($current_count - $previous_count))
        else
            new_count=$current_count
        fi
        if [[ $new_count != 0 ]]; then
            ips_updated_400=true
            reported_400_count="$reported_400_count
            - $ip - $new_count new"
        fi
    fi
done


##Send telegram message
if [[ "$ips_updated_400" != "true" && "$ips_updated_200" != true ]]; then
    echo "No new ips found"
    bash "$script_path/send_telegram_message.sh" "$daily_greeting_no_new_ips"
else
    echo "New ips found"
    bash "$script_path/send_telegram_message.sh" "$daily_greeting_new_ips"
    if [[ "$ips_updated_200" == "true" ]]; then
        bash "$script_path/send_telegram_message.sh" "$reported_200_count"
    fi
    if [[ "$ips_updated_400" == "true" ]]; then
        bash "$script_path/send_telegram_message.sh" "$reported_400_count"
    fi
fi

cat > $script_path/daily_200_ips.txt <<EOL
${reported_200_count}
... 
EOL

echo -n $reported_200_count > "$script_path/daily_200_ips.txt"
echo -e $reported_400_count > "$script_path/daily_400_ips.txt"

##Save
cp -fr temp_200_ips "$script_path/ips_200.txt"
cp -fr temp_400_ips "$script_path/ips_400.txt"
rm -rf temp_200_ips
rm -rf temp_400_ips


