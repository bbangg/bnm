## bnm (basic nginx manager)

BNM simplifies deployment and management across multiple domains.

### requirements

- docker
- docker-compose

### installation

```
sudo apt update
sudo apt upgrade
sudo apt install docker docker-compose -y

git clone https://github.com/bbangg/bnm.git
cd bnm

chmod +x ./bnm.sh && chmod +x ./recreate.sh
```

### commands

Create new domain:
```bash
./bnm.sh create <domain>
```

Enable domain (creates symlink to `sites-enabled`)
```bash
./bnm.sh enable <domain>
```

Disable domain (deletes symlink from `sites-enabled`)
```bash
./bnm.sh disable <domain>
```

Generates SSL for domain
> Set staging to 1 if you're testing your setup to avoid hitting request limits
```bash
./bnm.sh ssl <mail> <staging> <domains>
```

Reload nginx service
```bash
./bnm.sh reload
```

Purge everything
```bash
./bnm.sh purge
```

### todo

- [ ] logs directory
- [ ] grafana + prometheus for monitoring
- [x] allow cloudflare from cloudflare only (check `cloudflare.conf`)
