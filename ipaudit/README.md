# The IP Audit Tool

This script is used to audit the Nginx Proxy Manager logs for new activity daily!
It is called from a CRON job that runs every morning at 9am.

The script:
  1. Scrapes the log files for IPs - sorts by 200 response codes and 400 response codes
  2. Compares them against the list from the previous day
  3. Counts the new occurences of each IP
  4. Sends me a telegram message with the count
  5. Updates the access list so it can be used the next day

The script as it stands is a bit of a mess, could definitely be streamlined a bit. However, it works as its supposed to and helps me keep an eye out for any suspicous activity on my sites.
I use this in tandem with Fail2Ban to protect my public-facing services from any bad actors.

# The Get Paths for IP tool

This is a tiny script I use every once in a while. It scrapes the log files for a specific IP and outputs the specific URLs that IP accessed.
This can be a quick and helpful way to manually audit the access logs for suspicious activity. It also helps me keep an eye out for any URL patterns being used by malicious bots that I haven't blocked in Cloudflare.
I've been meaning to move this into part of the daily IP audit flow listed above, but for now I just use it when I notice anything out of the ordinary.