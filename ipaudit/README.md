# IP Audit Tools

These are a collection of tools I use to help me monitor a few of my services. They help give me not only peace of mind but also a bit of a rough "security report" so I know who is accessing what on my server

## The Get IP Access List tool

This script is used to audit the Nginx Proxy Manager logs for new activity daily!
It is called from a CRON job that runs every morning at 9am.

The script:
  1. Scrapes the log files for IPs - sorts by 200 response codes and 400 response codes
  2. Compares them against the list from the previous day
  3. Counts the new occurrences of each IP
  4. Sends me a telegram message with the count
  5. Updates the access list so it can be used the next day

The script as it stands could definitely be streamlined a bit. However, it works as its supposed to and helps me keep an eye out for any suspicious activity on my sites.
I use this in tandem with Fail2Ban to protect my public-facing services from any bad actors.

## The Get Paths for IP tool

This is a tiny script I use every once in a while. It scrapes the log files for a specific IP and outputs the specific URLs that IP accessed.
This can be a quick and helpful way to manually audit the access logs for suspicious activity. It also helps me keep an eye out for any URL patterns being used by malicious bots that I haven't blocked in Cloudflare.
I've been meaning to move this into part of the daily IP audit flow listed above, but for now I just use it when I notice anything out of the ordinary.

## The Login Notification tool

This is another small but powerful script. If placed in the `/etc/profile.d/` directory, it sends a telegram notification (using the `send_telegram_notification.sh` script) whenever a user logs into the system.
Its a great tool that helps keep peace of mind, knowing that nobody else is logging into my system but me.

## Send Telegram Notification Script

Short but sweet, sends a Telegram message via Telegram bot to a group chat. You might have seen this one being used in other scripts here, I use it to keep up to date on what's happening on my machine. Very versatile and really easy to set up.
