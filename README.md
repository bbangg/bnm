## nginx-manager

a simple, easy-to-use tool for managing nginx hosts.

### requirements

- docker
- docker-compose

### installation

```
git clone https://github.com/bbangg/nginx-manager.git
cd nginx-manager

chmod +x ./nginx-manager.sh && chmod +x ./recreate.sh
```

### commands

Create new domain:
```bash
./nginx-manager.sh create <domain>
```

Enable domain (creates symlink to `sites-enabled`)
```bash
./nginx-manager.sh enable <domain>
```

Disable domain (deletes symlink from `sites-enabled`)
```bash
./nginx-manager.sh disable <domain>
```

Generates SSL for domain(s) (use `example.org www.example.org` to generate SSL for both)
> Set staging to 1 if you're testing your setup to avoid hitting request limits
```bash
./nginx-manager.sh ssl <mail> <staging> <domains>
```

Reload nginx service
```bash
./nginx-manager.sh reload
```

Purge everything
```bash
./nginx-manager.sh purge
```

### configuration

- Use same network with other containers

```yml
services:
  example_service:
    ...
    networks:
    - nginx_manager_network

networks:
  nginx_manager_network:
    external: true
    driver: bridge
```

- Handle incoming requests on running containers

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

- Allow traffic from cloudflare only

```
include /etc/nginx/conf.d/cloudflare.conf;
```

### custom scripts

```
cat > "scripts/custom-script.sh" <<EOF
# Your description here (will be shown on the console)

echo "Hi"
EOF

chmod +x ./scripts/custom-script.sh
```

![screenshot-custom-script](/docs/resources/custom-script.png)

### todo

- [ ] grafana + prometheus for monitoring [check repo](https://github.com/bbangg/grafana)
- [ ] cron job or command to handle massive log files (compress and upload somewhere or delete directly)
- [x] logs directory
- [x] allow traffic from cloudflare only (check `cloudflare.conf`)
