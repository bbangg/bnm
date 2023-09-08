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

Generates SSL for domain(s) (use `example.org www.example.org` to generate SSL for both)
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

### configuration

- Handle incoming requests on running containers?

```
location @{label_here} {
    proxy_pass          http://{container_name}:{container_port};

    # optional
    proxy_set_header    Host                        $http_host;
    proxy_set_header    X-Real-IP                   $remote_addr;
    proxy_set_header    X-Forwarded-For             $proxy_add_x_forwarded_for;
}

location / {
    try_files $uri @{label_here};
}
```

- Allow Traffic from cloudflare only

```
include /etc/nginx/conf.d/cloudflare.conf;
```

### todo

- [ ] grafana + prometheus for monitoring [check repo](https://github.com/bbangg/grafana)
- [x] logs directory
- [x] allow traffic from cloudflare only (check `cloudflare.conf`)
