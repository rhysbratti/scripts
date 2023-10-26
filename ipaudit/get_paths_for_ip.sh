echo "$1: "
grep "$1" ~/nginxproxymanager/data/logs/proxy-host-*_access.log | awk '{print $9 $10}' | sed 's/"//g'
