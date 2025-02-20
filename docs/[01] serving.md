## Node App

To add a new node website:
```bash
curl -sSL https://realesys.github.io/vps/nginx/new-node-site.sh | bash -s -- -d "example.com www.example.com" -p 3000 -e admin@example.com -u "siteUser"
```

## Mysql user and db

For a new site user and db:
```bash
curl -sSL https://realesys.github.io/vps/db/new-mysql-siteuser.sh | bash -s -- -u "siteUser" -d "databaseName"
```

## S3 with MinIO

```bash
curl -sSL https://realesys.github.io/vps/S3/setup-MinIO-S3-v1.sh | bash -s -- -d "/mnt/storage" -u "your-username"
```
