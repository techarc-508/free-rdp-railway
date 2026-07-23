#!/bin/bash
# Install bore client on Linux Mint / Ubuntu
# Run this on your LOCAL VM

set -e

echo "=== Installing bore client ==="

# Download latest bore release
BORE_VERSION=$(curl -s https://api.github.com/repos/ekzhang/bore/releases/latest | grep tag_name | cut -d '"' -f4)
echo "Latest bore version: ${BORE_VERSION}"

curl -sL "https://github.com/ekzhang/bore/releases/download/${BORE_VERSION}/bore-${BORE_VERSION}-x86_64-unknown-linux-musl.tar.gz" \
    | sudo tar xz -C /usr/local/bin

chmod +x /usr/local/bin/bore

echo "=== bore installed ==="
bore --version

echo ""
echo "=== Verify NoMachine is running ==="
systemctl status nxserver --no-pager | head -5

echo ""
echo "============================================"
echo "  Done! Next steps:"
echo ""
echo "  1. Deploy bore server on Railway"
echo "  2. Run this command to start tunnel:"
echo ""
echo "     bore local 4000 --to <BORE_SERVER_IP>:7835 --secret railwayfree2026"
echo ""
echo "  3. Connect NoMachine client → <BORE_SERVER_IP>:<PORT>"
echo "============================================"
