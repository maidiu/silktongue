#!/bin/bash

# MaxVocab Deployment Script for VPS
# Run this from your LOCAL machine after you SSH into the VPS

echo "========================================="
echo "DEPLOYING MAXVOCAB TO VPS"
echo "========================================="
echo ""

# Variables (adjust these)
PROJECT_NAME="maxvocab"
PORT=3006
DB_NAME="maxvocab"
DB_USER="maxvocab_user"

echo "Step 1: Navigate to deployment directory"
cd /var/www

echo "Step 2: Create project directory"
mkdir -p ${PROJECT_NAME}
cd ${PROJECT_NAME}

echo "Step 3: Clone or upload your code"
echo "   Option A: If using Git, run: git clone https://github.com/yourusername/MaxVocab.git ."
echo "   Option B: Upload files using SCP/SFTP from your local machine"
echo ""
echo "Pausing for you to get the code in place..."
echo "Press Enter when code is in /var/www/${PROJECT_NAME}"
read

echo "Step 4: Install dependencies"
cd client && npm install
cd ../server && npm install

echo "Step 5: Build React app"
cd ../client && npm run build
cp -r dist ../server/

echo "Step 6: Create database"
echo "Run this SQL in PostgreSQL (sudo -u postgres psql):"
echo "CREATE DATABASE ${DB_NAME};"
echo "CREATE USER ${DB_USER} WITH PASSWORD 'your_secure_password_here';"
echo "GRANT ALL PRIVILEGES ON DATABASE ${DB_NAME} TO ${DB_USER};"
echo ""
echo "Press Enter after creating the database"
read

echo "Step 7: Create .env file"
cd ../server
cat > .env << EOF
DATABASE_URL=postgresql://${DB_USER}:your_secure_password_here@localhost:5432/${DB_NAME}
JWT_SECRET=$(node -e "console.log(require('crypto').randomBytes(32).toString('hex'))")
PORT=${PORT}
NODE_ENV=production
EOF
echo ".env file created!"

echo "Step 8: Run database migrations"
echo "Run this command manually:"
echo "psql -U ${DB_USER} -d ${DB_NAME} -h localhost -f schema.sql"
echo ""
echo "Press Enter after running migrations"
read

echo "Step 9: Install PM2 globally"
npm install -g pm2

echo "Step 10: Start the application"
pm2 start src/index.js --name maxvocab
pm2 save
pm2 startup

echo "Step 11: Create nginx config"
cat > /etc/nginx/sites-available/${PROJECT_NAME} << 'NGINX_EOF'
server {
    listen 80;
    server_name yourdomain.com;  # CHANGE THIS

    location / {
        proxy_pass http://localhost:3006;
        proxy_http_version 1.1;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection 'upgrade';
        proxy_set_header Host $host;
        proxy_cache_bypass $http_upgrade;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
    }
}
NGINX_EOF

echo "Creating nginx symlink..."
ln -s /etc/nginx/sites-available/${PROJECT_NAME} /etc/nginx/sites-enabled/
nginx -t
systemctl reload nginx

echo "========================================="
echo "DEPLOYMENT COMPLETE!"
echo "========================================="
echo ""
echo "Next steps:"
echo "1. Edit /etc/nginx/sites-available/${PROJECT_NAME} and change 'yourdomain.com'"
echo "2. Set up SSL: sudo certbot --nginx -d yourdomain.com"
echo "3. Check logs: pm2 logs maxvocab"
echo ""

