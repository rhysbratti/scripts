download_path="~/downloads"
music_directory="~/music/"
script_dir=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )

mkdir "$script_dir/temp"

echo "Unzipping files..."

for i in $download_path/*.zip; do
    [ -f "$i" ] || break
    unzip $i -d "$script_dir/temp/" > /dev/null
done

echo "Unzipped!"

mapfile -t albums < <( find $script_dir/temp -maxdepth 1 -mindepth 1 -type d -printf '%f\n')

for album in "${albums[@]}"
do
    echo "Importing $album..."
    artist_name="$(echo $album | awk -F' - ' '{print $1}')"
    artist_folder=$(find $music_directory -maxdepth 1 -mindepth 1 -type d -name "$artist_name")
    if [[ -z "$artist_folder" ]]; then
        echo "$artist_name folder does not exist, creating..."
        mkdir "$music_directory/$artist_name"
        artist_folder="$music_directory/$artist_name"
    fi
    cp -r "$script_dir/temp/$album" "$artist_folder"
    echo "Import of $album complete"
done

rm -rf "$script_dir/temp"

for i in $download_path/*.zip; do 
    [ -f "$i" ] || break
    rm -rf $i
done
