## bnm (basic nginx manager)

BNM is built to run an NGINX container (with certbot), making it easy to deploy and manage across multiple domains. 

This will not work properly with multiple servers (at least not unless optimized, giving no opportunity for scalability).
BNW can be improved but is not needed at the moment. You can try other projects or work with k8s.

### commands

```bash
./bnm.sh create <domain>
./bnm.sh enable <domain>
./bnm.sh disable <domain>
./bnm.sh ssl <mail> <staging> <domains>
```