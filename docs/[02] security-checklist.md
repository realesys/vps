# Security Checklist

Once the server is up and running it's time to make sure it's production ready. This checklist will walk you through the bare minimum on making the vps really `robust`.

--- 

## Changing the SSH Port:
It is a default practice for us to change the SSH port on our servers to improve security. If you modify the SSH port (for example, to port 2222), you will need to update the Fail2Ban, iptables, and any other configurations that rely on the default port (22) to reflect the new port number.
- Fail2Ban: Update the /etc/fail2ban/jail.local configuration file to specify the new SSH port:
```bash 
[sshd]
enabled = true
port = 2222  # Change to the new SSH port
filter = sshd
logpath = /var/log/auth.log
maxretry = 3

```
- iptables: Modify the iptables rules to allow traffic on the new SSH port:
```bash 
# Replace 2222 with your custom SSH port number
sudo iptables -A INPUT -p tcp --dport 2222 -j ACCEPT
sudo iptables -A INPUT -p tcp --dport 22 -j DROP  # Optional: block default SSH port
```
- Firewall Settings: After changing the SSH port, remember to update the firewall (UFW or iptables) to allow connections on the new port:
```bash 
sudo ufw allow 2222/tcp  # Allow the new SSH port through UFW
sudo ufw delete allow 22/tcp  # Optional: block default SSH port through UFW
```

--- 

## Disallowing root login: 

Disabling root login for SSH access is a good security practice. This forces attackers to guess both a username and a password, reducing the attack surface for brute force attacks.
- Edit the SSH configuration file /etc/ssh/sshd_config and ensure the following line is set:

```bash
PermitRootLogin no
```

- After making this change, restart SSH for the settings to take effect:

```bash
sudo systemctl restart ssh
```

--- 

## Setting Up SSH Key Authentication:

Password-based SSH login should be disabled in favor of SSH key authentication. This provides a more secure way of accessing the server, as private keys are significantly more difficult to guess or brute-force than passwords.

- Generate SSH Keys (if you don't already have them) on your local machine:

```bash
ssh-keygen -t rsa -b 4096 -C "your_company_alias@orde.uk"
```

- Copy the SSH Public Key to the Server:
```bash
ssh-copy-id -i ~/.ssh/id_rsa.pub user@server_ip
```

---

## Disable Password Authentication: 

Once SSH keys are working, disable password authentication by editing the SSH config file:
Set the line `PasswordAuthentication yes` to `PasswordAuthentication no` 
```bash
sudo nano /etc/ssh/sshd_config
```

- Restart SSH:

```bash
sudo systemctl restart ssh
```

