# Start here

## Installs
To setup a fresh server with the all the most basic configurations:

- The lazy way:
```bash
curl -sSL https://realesys.github.io/vps/ubuntu2404lts/setup-full-v1.sh | bash
```
- The secure way:
```bash

# Download the script 
curl -sSL https://realesys.github.io/vps/ubuntu2404lts/setup-full-v1.sh -o setup.sh
# Download the checksum 
curl -sSL https://realesys.github.io/vps/ubuntu2404lts/setup-full-v1.sh.sha256 -o setup.sh.sha256

# Verify its integrity (if checksum is available)
sha256sum -c setup.sh.sha256

# Make it executable and run it
chmod +x setup.sh
./setup.sh
```

---

### Security Only
To setup only the security bundle (e.g.: dockploy machine): 
```bash 
curl -sSL https://realesys.github.io/vps/ubuntu2404lts/setup-security.sh | bash
```

### Node

To setup only for node websites (no php):
```bash
curl -sSL https://realesys.github.io/vps/ubuntu2404lts/setup-node.sh | bash
```

---

### Mysql Server 

To setup mysql server as the db:
```bash
curl -sSL https://realesys.github.io/vps/db/mysql-server.sh | bash
```

### Docker

To setup only for local dokploy:
```bash
curl -sSL https://realesys.github.io/vps/docker/dokploy-local.sh | bash -s -- --advertise-addr "YOUR-LAN-IP-ADDR"
```
