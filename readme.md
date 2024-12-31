# Initial VPS Setup Scripts

## **What is it?**
These scripts provide a boilerplate for setting up web servers and VPS instances with the most common configurations. It is designed to accelerate deployment and ensure compatibility for running web applications on fresh servers. If you are a system administrator or developer at orde this is the first step to getting new servers up and running. Refer to the private onboarding documentation on the next steps if unsure.

Key features include:
- Automated installation of essential software (NGINX, PHP, Node.js) for web servers.
- Secure configurations for FTP (ProFTPD), firewalls (UFW), and monitoring tools (Fail2Ban).
- Ready-to-use setups for popular web development stacks.

---

## **Who is it for?**
These scripts are tailored for:
- **System administrators**: Setting up fresh Ubuntu VPS servers for web development quickly.
- **Developers**: Deploying web applications on servers with standardized configurations.
- **Small businesses**: Configuring VPS instances with enterprise-grade security.

---

# Documentation

## Summary of Packages:
- nginx: Web server.
- certbot: SSL certificate management.
- unzip: Archive extraction utility.
- nodejs & npm: JavaScript runtime and package manager.
- pm2: Process manager for Node.js applications.
- php-fpm: PHP FastCGI Process Manager.
- proftpd: FTP server.
- iptables: Firewall utility to secure server and restrict traffic.
- fail2ban: Brute force protection.
- auditd: System auditing and logging.
- clamav & clamav-daemon: Antivirus software.
- rkhunter: Rootkit detection tool.
- git: Version control tool.

## Summary of Configurations:
- NGINX: Web server configured with SSL support and firewall rules.
- ProFTPD: Secure FTP server with SSL/TLS encryption, logging, and restricted directory access.
- iptables: Configured firewall with default "DROP" policy, allowing only SSH, HTTP, and HTTPS traffic, with persistence across reboots.
- Fail2Ban: Configured for SSH protection and brute-force attack prevention.
- Auditd: Configured for system auditing and log management.
- ClamAV: Antivirus scanning with scheduled scans.
- Rootkit Hunter: Scheduled scans for rootkits and updates.
- SSL Certificates: Self-signed SSL certificate generated for ProFTPD.

## Usage and more: 

Please refer to the `/docs` directory for further information.

---

# We're hiring:
At ORDE, we believe great ideas and growth come from diverse perspectives. Our success is driven by the unique contributions of each team member. We foster a culture of inclusivity where everyone, regardless of background—minorities, people with disabilities, and underrepresented groups—is empowered to thrive. We encourage talented individuals from all over the world to apply.

Check out our available openings and more details at [orde.uk](https://orde.uk/).

--- 

# License

These scripts are licensed under the [Apache License 2.0](https://www.apache.org/licenses/LICENSE-2.0).
