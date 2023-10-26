# The DNS-Updatarator

This script was thrown together rather quickly to address an issue with my own homelab: a changing home IP address.
This script is set up to be called from a CRON job that runs every 30 minutes

Since I don't have a static IP address through my ISP, I have to accept the fact that my public IP is going to change every once in a while.
The first time it happened, all of my services went down and I had a bit of a mess to clean up. This script addresses several issues I ran into:

## Cloudflare DNS A-Records need to point to my IP
I have a few services I run on my homelab that I expose to the internet. One of these is my public website! 
When my public IP changes, cloudflare is no longer routing data to the correct address. This script updates the Cloudflare DNS records through the Cloudflare API

## Fail2Ban bans new IP address

Fail2Ban is a service that can run natively on Ubuntu (I run mine in a docker container). I used it in tandem with Nginx Proxy Manager to ban IPs that look like they are up to no good.
If an IP has been causing some suspicious activity, Fail2Ban uses the Cloudflare API to ban that IP from reaching the site.
An important piece here, however, is that my public IP has to be whitelisted from Fail2Ban. Don't want to ban myself! This proves tricky with uptime monitoring systems like Uptime-Kuma.

Uptime-Kuma runs in a docker container on my Homelab to monitor my public and private services. If something goes down, it sends me a message. It monitors these services by pinging them and getting the response code

The combination of these services can prove tricky when my public IP changes. Since Uptime-Kuma is pinging my services at regular intervals, Fail2Ban (since it probably hasn't been notified of the IP change yet) is likely to see this new IP and ban it.
This can cause a lot of "Service Down" notifications from Uptime-Kuma, because it has been banned and can no longer reach my site.

This is solved by updating Fail2Ban of my new public IP, unbanning my IP from Cloudflare, and then restarting the Fail2Ban service
