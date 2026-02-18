---
name: pqc-gateway
description: Manage PQC Gateway (post-quantum cryptography gateway). Use for: (1) Installing pqc-gateway from source, (2) Starting/stopping the gateway service, (3) Configuring gateway routes with Gateway API YAML, (4) Viewing logs and status. Requires pipy and OpenSSL 3.5+ dependencies.
---

# PQC Gateway Skill

Manage a PQC (Post-Quantum Cryptography) Gateway based on pipy proxy.

## Quick Commands

```bash
# Install from source
git clone https://github.com/pqfif-oss/pqc-gateway.git
cd pqc-gateway
git submodule update --init
make && sudo make install

# Start gateway
gw -c examples/pqc-termination/config.yaml

# Check version
gw -v
```

## Common Tasks

### Installation

1. Check dependencies (pipy, OpenSSL 3.5+):
   ```bash
   pipy --version
   openssl version
   ```

2. Clone and build:
   ```bash
   git clone https://github.com/pqfif-oss/pqc-gateway.git
   cd pqc-gateway
   git submodule update --init
   make
   sudo make install
   ```

### Start/Stop

- **Start**: `gw -c <config-file>`
- **Start with watch mode**: `gw -c <config-dir> -w`
- **Start config server**: `gw -s <config-dir>`
- **Stop**: Ctrl+C or kill the process

### Configuration

Configuration uses Kubernetes Gateway API YAML format. Key resources:

- **Gateway**: Define listeners (HTTP/HTTPS ports)
- **HTTPRoute**: Route HTTP traffic
- **Backend**: Define upstream services
- **Secret**: TLS certificates

Example config structure:
```yaml
resources:
  - kind: Gateway
    metadata:
      name: https-pqc
    spec:
      listeners:
        - port: 443
          protocol: HTTPS
          tls:
            mode: Terminate
            pqc:
              keyExchange: X25519:X25519MLKEM768
            certificates:
              - tls.crt: my.crt
                tls.key: my.key

  - kind: HTTPRoute
    spec:
      parentRefs:
        - kind: Gateway
          name: https-pqc
      rules:
        - backendRefs:
            - kind: Backend
              name: my-service

secrets:
  my.crt: |
    -----BEGIN CERTIFICATE-----
    ...
```

### Logs & Status

- Check if running: `pgrep -f "gw -c"` or `ps aux | grep gw`
- View process output (when running in foreground)
- Check port listeners: `netstat -tlnp | grep -E '80|443|9443'`

## Configuration Templates

See `scripts/` for example configs:
- `basic.yaml`: Simple HTTP → HTTPS redirect
- `pqc-termination.yaml`: PQC TLS termination with routing
- `rate-limit.yaml`: Rate limiting example
