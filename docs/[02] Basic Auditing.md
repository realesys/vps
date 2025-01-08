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

Successful logins via auditd:
```bash 
sudo ausearch -m USER_LOGIN -sv yes
```
Look for entries where the auid or uid corresponds to 0 (root) or other users in the sudo group.

Extracting relevant information from /var/log/auth.log:
```bash 
grep -E "session opened for user|sudo:" /var/log/auth.log
```
This will show when a session was opened for any user and when sudo commands were used.

Filtering for root logins:
```bash 
grep "session opened for user root" /var/log/auth.log
```