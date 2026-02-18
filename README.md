# PQC Gateway Skill

OpenClaw skill for managing [pqc-gateway](https://github.com/pqfif-oss/pqc-gateway) - a Post-Quantum Cryptography Gateway.

## What is PQC Gateway?

**PQC Gateway** is a PQC-enabled reverse proxy and API gateway built on [pipy](https://github.com/flomesh-io/pipy) with OpenSSL 3.5+. It implements the Kubernetes **Gateway API** standard for configuration.

## ⚡ Quick Start

```bash
# Install pqc-gateway
git clone https://github.com/pqfif-oss/pqc-gateway.git
cd pqc-gateway
make && sudo make install

# Start the gateway
gw -c examples/pqc-termination/config.yaml
```

## 🔧 Using Gateway API to Configure the Gateway

PQC Gateway uses the standard **Kubernetes Gateway API** for all configuration. No proprietary syntax - just standard Kubernetes resources!

### Example: HTTPS with PQC TLS Termination

```yaml
resources:
  # Define the Gateway listener
  - kind: Gateway
    metadata:
      name: https-pqc
    spec:
      listeners:
        - name: https
          port: 443
          protocol: HTTPS
          tls:
            mode: Terminate
            pqc:
              keyExchange: X25519:X25519MLKEM768
            certificates:
              - tls.crt: server.crt
                tls.key: server.key

  # Define routing rules
  - kind: HTTPRoute
    spec:
      parentRefs:
        - kind: Gateway
          name: https-pqc
      hostnames:
        - example.com
      rules:
        - backendRefs:
            - kind: Backend
              name: my-service

  # Define backend service
  - kind: Backend
    metadata:
      name: my-service
    spec:
      targets:
        - address: 127.0.0.1
          port: 8080
```

### Key Gateway API Resources

| Resource | Purpose |
|----------|---------|
| `Gateway` | Define listeners (HTTP/HTTPS ports, TLS settings) |
| `HTTPRoute` | Define HTTP routing rules (path matching, filters) |
| `TCPRoute` | Define TCP routing rules |
| `Backend` | Define upstream services |
| `BackendTLSPolicy` | Configure TLS to backends |
| `GRPCRoute` | Define gRPC routing rules |

### Available Filters

- **RequestHeaderModifier** - Modify request headers
- **ResponseHeaderModifier** - Modify response headers  
- **RequestRedirect** - Redirect requests
- **RequestTermination** - Terminate with custom response
- **RateLimit** - Rate limiting
- **FileLog** - Access logging

## 📁 Included Configurations

This skill includes ready-to-use configuration templates:

| File | Description |
|------|-------------|
| `scripts/basic.yaml` | HTTP → HTTPS redirect |
| `scripts/pqc-termination.yaml` | PQC TLS termination with routing |
| `scripts/rate-limit.yaml` | Rate limiting example |

## 🚀 Usage with OpenClaw

Once installed, you can:

1. **Install pqc-gateway**: `bash scripts/install.sh`
2. **Start gateway**: `gw -c scripts/pqc-termination.yaml`
3. **Configure routes**: Edit YAML files using Gateway API

## Requirements

- [pipy](https://github.com/flomesh-io/pipy) (built-in)
- OpenSSL 3.5+ (for PQC algorithms)
- Kubernetes Gateway API understanding

## Learn More

- [pqc-gateway GitHub](https://github.com/pqfif-oss/pqc-gateway)
- [Gateway API Documentation](https://gateway-api.sigs.k8s.io/)
- [pipy Documentation](https://flomesh.io/pipy)

## License

Same as pqc-gateway - Apache 2.0
