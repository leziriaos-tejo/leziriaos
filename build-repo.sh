#!/bin/bash
set -e

REPO_DIR="$(pwd)"
DIST="tejo"
ARCH="amd64"
COMP="main"
KEY="LeziriaOS"

echo "=== LeziriaOS Repository Builder ==="
echo "Diretório: $REPO_DIR"
echo "Suite: $DIST"
echo "Arquitetura: $ARCH"
echo "Componente: $COMP"
echo

# 1. Gerar Packages e Packages.gz
echo "[1/5] Gerando Packages..."
apt-ftparchive packages "$REPO_DIR/dists/$DIST/$COMP/binary-$ARCH" \
    > "$REPO_DIR/dists/$DIST/$COMP/binary-$ARCH/Packages"

gzip -c "$REPO_DIR/dists/$DIST/$COMP/binary-$ARCH/Packages" \
    > "$REPO_DIR/dists/$DIST/$COMP/binary-$ARCH/Packages.gz"

echo "Packages gerado com sucesso."
echo

# 2. Criar ficheiro de configuração Release
echo "[2/5] Criando configuração Release..."
cat > "$REPO_DIR/apt-release.conf" <<EOF
APT::FTPArchive::Release {
    Origin "LeziriaOS";
    Label "LeziriaOS";
    Suite "$DIST";
    Codename "$DIST";
    Architectures "$ARCH";
    Components "$COMP";
};
EOF

echo "Configuração Release criada."
echo

# 3. Gerar Release
echo "[3/5] Gerando Release..."
apt-ftparchive -c "$REPO_DIR/apt-release.conf" release "$REPO_DIR/dists/$DIST" \
    > "$REPO_DIR/dists/$DIST/Release"

echo "Release gerado."
echo

# 4. Assinar Release e InRelease
echo "[4/5] Assinando Release..."
gpg --default-key "$KEY" -abs \
    -o "$REPO_DIR/dists/$DIST/Release.gpg" \
    "$REPO_DIR/dists/$DIST/Release"

gpg --default-key "$KEY" --clearsign \
    -o "$REPO_DIR/dists/$DIST/InRelease" \
    "$REPO_DIR/dists/$DIST/Release"

echo "Assinatura concluída."
echo

# 5. Commit + Push
echo "[5/5] Commit + Push..."
git add .
git commit -m "Build automático do repositório LeziriaOS"
git push

echo
echo "=== Build concluído com sucesso! ==="
echo "O repositório LeziriaOS está atualizado e assinado."
