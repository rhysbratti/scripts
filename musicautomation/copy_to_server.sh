local_download_path="~/Downloads/music"
remote_download_path="~/downloads/"
remote_host="user-here@123.456.7.89"
remote_command="bash ~/scripts/musicautomation/import_music_files.sh"

for i in $local_download_path/*.zip; do
    [ -f "$i" ] || break
    rsync $i $remote_host:$remote_download_path
    rm -rf $i
done

ssh $remote_host $remote_command
