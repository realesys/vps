# Basic Auditing

## Check Users in the Sudoers or Root Group

Users in the sudo group:

```bash
getent group sudo
```

Users in the root group:

```bash
getent group root
```

## Check if iptable rules are still in place

```bash
sudo iptables -L -v -n
```

## Check Failed Login Attempts in the Audit Logs

Use auditd to check failed login attempts. Ensure the audit service is running before you execute the commands.

View failed login attempts:
```bash 
sudo ausearch -m USER_LOGIN -sv no
```
-m USER_LOGIN: Filters for login-related events.
-sv no: Shows only failed attempts.

## Check Successful Logins with Timestamps for Root or Sudoers
You can find successful logins for root or users in the sudo group using auditd or by analyzing /var/log/auth.log.

- Successful logins via auditd:
```bash 
sudo ausearch -m USER_LOGIN -sv yes
```
Look for entries where the auid or uid corresponds to 0 (root) or other users in the sudo group.

- Extracting relevant information from /var/log/auth.log:
```bash 
grep -E "session opened for user|sudo:" /var/log/auth.log
```
This will show when a session was opened for any user and when sudo commands were used.

- Filtering for root logins:
```bash 
grep "session opened for user root" /var/log/auth.log
```

## Check fail2ban Jails for Blocked IPs
fail2ban is a service that monitors log files for malicious activity, such as repeated failed login attempts, and automatically blocks the offending IP addresses.

- View the status of fail2ban jails:
```bash 
sudo fail2ban-client status
```
This will list all active jails. To get detailed information about a specific jail (e.g., sshd for SSH login attempts), run:

```bash 
sudo fail2ban-client status sshd
```
This will show information about the number of currently banned IPs, the number of failed login attempts that led to a ban, and other useful details.

- Check the fail2ban log for banned IPs:
```bash 
sudo tail -n 50 /var/log/fail2ban.log
```
This command displays the last 50 lines of the fail2ban log, where you can find information about bans, such as IP addresses, jail names, and timestamps.
