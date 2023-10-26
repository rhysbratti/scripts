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
