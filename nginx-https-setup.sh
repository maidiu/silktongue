#!/bin/bash
# Quick HTTPS setup for MaxVocab app

echo "🔐 HTTPS Setup for MaxVocab"
echo ""
echo "This script will:"
echo "1. Create Nginx config"
echo "2. Get SSL certificate with Let's Encrypt"
echo "3. Configure HTTPS"
echo ""
echo "You need a domain name that points to your VPS IP: 142.171.47.157"
echo ""
read -p "Enter your domain name (e.g., maxvocab.yourdomain.com): " DOMAIN

if [ -z "$DOMAIN" ]; then
    echo "❌ No domain provided"
    exit 1
fi

# Create Nginx config
sudo tee /etc/nginx/sites-available/maxvocab > /dev/null <<EOF
server {
    listen 80;
    server_name $DOMAIN;

    # For Let's Encrypt
    location /.well-known/acme-challenge/ {
        root /var/www/html;
    }

    # Redirect all HTTP to HTTPS
    location / {
        return 301 https://\$server_name\$request_uri;
    }
}

server {
    listen 443 ssl http2;
    server_name $DOMAIN;

    ssl_certificate /etc/letsencrypt/live/$DOMAIN/fullchain.pem;
    ssl_certificate_key /etc/letsencrypt/live/$DOMAIN/privkey.pem;

    location / {
        proxy_pass http://localhost:3006;
        proxy_http_version 1.1;
        proxy_set_header Upgrade \$http_upgrade;
        proxy_set_header Connection 'upgrade';
        proxy_set_header Host \$host;
        proxy_set_header X-Real-IP \$remote_addr;
        proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto \$scheme;
        proxy_cache_bypass \$http_upgrade;
    }
}
EOF

# Enable the site
sudo ln -sf /etc/nginx/sites-available/maxvocab /etc/nginx/sites-enabled/

# Test Nginx config
sudo nginx -t

# Get SSL certificate
sudo certbot --nginx -d $DOMAIN --non-interactive --agree-tos --email $(whoami)@$(hostname)

# Restart Nginx
sudo systemctl restart nginx

echo ""
echo "✅ HTTPS setup complete!"
echo "Visit: https://$DOMAIN"
echo ""
echo "📝 Note: Update your DNS A record for $DOMAIN to point to 142.171.47.157"

