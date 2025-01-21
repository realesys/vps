# Security Checklist

Once the server is up and running it's time to make sure it's production ready. This checklist will walk you through the bare minimum on making the vps really `robust`.

--- 

## Changing the SSH Port:
It is a default practice for us to change the SSH port on our servers to improve security. If you modify the SSH port (for example, to port 2222), you will need to update the Fail2Ban, iptables, and any other configurations that rely on the default port (22) to reflect the new port number.

1. Edit the SSH Configuration File
Open the SSH configuration file using a text editor:

```bash
sudo nano /etc/ssh/sshd_config
```
Look for the line:

```bash
#Port 22
```
Remove the # and change 22 to your desired port number (e.g., 2222):

```bash
Port 2222
```

2. Allow the New Port in the Firewall 
If you are using ufw, allow the new SSH port:

```bash
sudo ufw allow 2222/tcp
```

3. Restart the SSH Service
Apply the changes by restarting the SSH service:

```bash
sudo systemctl restart sshd
```
(For older systems, use sudo service ssh restart.)

4. Test the New SSH Port
Before logging out, open a new terminal and try connecting using the new port:

```bash
ssh -p 2222 user@your-server-ip
```


### Fail2Ban: 

- Update the /etc/fail2ban/jail.local configuration file to specify the new SSH port:
```bash
sudo nano /etc/fail2ban/jail.local
```
```bash 
[sshd]
enabled = true
port = 2222  # Change to the new SSH port
filter = sshd
logpath = /var/log/auth.log
maxretry = 3

```
### iptables: 

- Modify the iptables rules to allow traffic on the new SSH port:
```bash 
# Replace 2222 with your custom SSH port number
sudo iptables -A INPUT -p tcp --dport 2222 -j ACCEPT
sudo iptables -A INPUT -p tcp --dport 22 -j DROP  # Optional: block default SSH port
```

### Use iptables to Drop Stealth Scans
To block stealth scanning techniques like NULL, Xmas, and FIN scans:

- Create iptables rules:

```bash
sudo iptables -A INPUT -p tcp --tcp-flags ALL NONE -j DROP
sudo iptables -A INPUT -p tcp --tcp-flags ALL ALL -j DROP
sudo iptables -A INPUT -p tcp --tcp-flags ALL FIN,PSH,URG -j DROP
sudo iptables -A INPUT -p tcp --tcp-flags SYN,RST SYN,RST -j DROP
```

- In order to persist rules we need to install iptables-persistent:

```bash
sudo apt install iptables-persistent -y
```

- Save iptables rules:

```bash
sudo netfilter-persistent save
```

- Make sure iptables-persistent is enabled:
```bash
sudo systemctl enable netfilter-persistent
sudo systemctl start netfilter-persistent
```

### Firewall Settings: 
After changing the SSH port, remember to update the firewall (UFW or iptables) to allow connections on the new port:
- Check if UFW is active:
```bash 
sudo ufw status verbose
```
- Allow the new SSH port through UFW
```bash 
sudo ufw allow 2222/tcp  
```


- Verify the SSH is now on the new port:
```bash
sudo sshd -T | grep port
```
- Block default SSH port through UFW
```bash
sudo ufw deny 22/tcp
```

--- 

## Adding new user: 

- First, create a new user that you can use for administrative tasks:

```bash 
sudo adduser <username>
```

- Add the User to the Sudo Group:

```bash 
sudo usermod -aG sudo <username>
```

- Test the Sudo Privileges:

```bash 
su - <username>
sudo whoami
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

## Disable ICMP Ping Requests 
Attackers often use ping sweeps to discover live hosts.

- Disable ICMP (ping) responses:

```bash
echo "net.ipv4.icmp_echo_ignore_all = 1" | sudo tee -a /etc/sysctl.conf
sudo sysctl -p
```

- From another machine, check if ICMP is disabled:

```bash
ping <SERVER_IP>
```

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

