#!/bin/bash
# Deploy cafelulaid.com clone ke VPS (Ubuntu/Debian) — static, nginx
# Usage: tar -xzf lula-clone.tar.gz && sudo ./lula-clone/DEPLOY.sh [domain]
set -e
DOMAIN="${1:-lula.example.com}"
SRC="$(cd "$(dirname "$0")/cafelulaid.com" && pwd)"
apt-get update -qq && apt-get install -y -qq nginx
mkdir -p /var/www/lula
cp -r "$SRC"/. /var/www/lula/
chown -R www-data:www-data /var/www/lula
cat > /etc/nginx/sites-available/lula << EOF
server {
    listen 80;
    server_name $DOMAIN;
    root /var/www/lula;
    index index.html;
    location / { try_files \$uri \$uri/ =404; }
    location ~* \.(jpg|jpeg|png|gif|webp|svg|css|js|woff2?|ttf|eot|cur|ico)$ { expires 30d; }
}
EOF
ln -sf /etc/nginx/sites-available/lula /etc/nginx/sites-enabled/lula
nginx -t && systemctl reload nginx
echo "LIVE: http://$DOMAIN (HTTPS: apt install certbot + certbot --nginx -d $DOMAIN)"
