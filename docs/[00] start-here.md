# Start here

## Installs
To setup a fresh server with the all the most basic configurations:

the lazy way:
```bash
curl -sSL https://realesys.github.io/vps/ubuntu2404lts/setup-full-v1.sh | bash
```
the secure way:
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

### Node

To setup only for node websites (no php):
```bash
curl -sSL https://realesys.github.io/vps/ubuntu2404lts/setup-node.sh | bash
```

---

### Mysql Server 

For mysql server (we recommend changing the root password later as per vps checklist):
```bash
curl -sSL https://realesys.github.io/vps/db/mysql-server.sh | bash -s -- -p "YourRootPasswordHere"
```
