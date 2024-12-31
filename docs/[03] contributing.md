## Contributing

Orde is a private company and reserves the right to review and decline any contributions that do not meet our criteria or align with our objectives.

### Contribution Guidelines:
1. **Purpose**: Contributions should align with the needs of VPS customers, prioritizing security, stability and usability.
2. **Security**: All updates must adhere to best practices for server security, including compliance with the existing setup's security standards.
3. **Testing**: Test your changes thoroughly on supported Ubuntu versions (e.g., 24.04 LTS) to ensure compatibility and stability.

### Steps to Contribute:
- **Fork the Repository**: Create your own copy of the repository.
- **Implement Changes**: Make your modifications, adhering to the contribution guidelines.
- **Submit a Pull Request**: Provide a clear and detailed description of your changes, including:
    - The purpose of the update.
    - Any relevant testing results or steps to verify functionality.
    - Why the changes are necessary and beneficial.

### Note:
Orde values high-quality contributions that enhance the script's functionality, security, or usability. Contributions that fail to meet these criteria or are unrelated to the script's purpose may be declined.

### If you modify a script, generate a new checksum file to reflect the changes:

Linux:
```bash
sha256sum setup-ubuntu-2404lts-v1.sh > setup-ubuntu-2404lts-v1.sh.sha256
```

Windows:
```bash
Get-FileHash setup-ubuntu-2404lts-v1.sh -Algorithm SHA256 | ForEach-Object { $_.Hash } > setup-ubuntu-2404lts-v1.sh.sha256
```