## bnm (basic nginx manager)

BNM is built to run an NGINX container (with certbot), making it easy to deploy and manage across multiple domains. 

This will not work properly with multiple servers (at least not unless optimized, giving no opportunity for scalability).
BNW can be improved but is not needed at the moment. You can try other projects or work with k8s.

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

```bash
./bnm.sh create <domain>
./bnm.sh enable <domain>
./bnm.sh disable <domain>
./bnm.sh ssl <mail> <staging> <domains>
```

### todo

- [ ] grafana + prometheus for monitoring
- [ ] cloudflare integration
