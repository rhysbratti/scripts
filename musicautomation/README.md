# Music File Automation

## The scripts
These two scripts are used in tandem to help get music that I've purchased from sites like Qobuz, TIDAL, Bandcamp, etc, to my music server so I can listen from different devices in my home without having to copy the files to each device.

My music server runs off of a headless Ubuntu Server VM, so I can't exactly browse for music and download it directly to the server. Instead, I use my laptop for the browsing, purchasing, and downloading process of the albums I want in FLAC format.

The `copy_music.sh` script is on my laptop. It does the following:
  1. Locates all zipped albums in the download music directory of my laptop
  2. Copies them to the remote server
  3. Deletes them off my laptop
  4. Calls the `import_music_files.sh` script on the remote server

The `import_music_files.sh` script is located on the remote server. It does the following:
  1. Locates all zipped albums in the directory the `copy_music.sh` script sends them
  2. Unzips them
  3. Automatically copies the album to my music folder, using the artist name to integrate it into the existing library structure

The music directory uses the following structure:
```
/music +
       + Artist +
                + Album +
                        + Track 1
                        + Track 2
```

## Music Server
My music server is actually the thing that got me into self-hosting. I have several audio setups in my house (mostly Bowers & Wilkins for any audiophiles out there) where I like to listen to the highest quality FLAC files I can buy.
However, the methods for actually getting the music to amps in different rooms were tedious. Copy files to usb drives plugged into different amps was just too much manual work. So I set up a music server that works with all my devices. That way I can stream them from my server directly to the amps,
High quality sound, low effort!
