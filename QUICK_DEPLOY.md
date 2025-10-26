# Quick Deployment Guide

## TL;DR - The Smoothest Path

This project is **ready to deploy** with minimal changes needed. Here's the shortest path to success:

### On Your Local Machine

1. **Push to GitHub** (if you haven't already):
```bash
git add .
git commit -m "Ready for production deployment"
git push origin main
```

### On Your VPS (SSH in)

```bash
# 1. Find a good deployment location
cd /var/www  # or wherever your other projects are

# 2. Clone your repo
git clone https://github.com/yourusername/MaxVocab.git

# 3. Install dependencies
cd MaxVocab
cd client && npm install
cd ../server && npm install

# 4. Build the React app
cd ../client
npm run build
cp -r dist ../server/

# 5. Set up environment
cd ../server
nano .env  # Create this file
```

**Add to `.env` file:**
```env
DATABASE_URL=postgresql://maxvocab_user:yourpassword@localhost:5432/maxvocab
JWT_SECRET=<generate-with-command-below>
PORT=3001
NODE_ENV=production
```

Generate JWT secret:
```bash
node -e "console.log(require('crypto').randomBytes(32).toString('hex'))"
```

```bash
# 6. Set up database
sudo -u postgres psql
CREATE DATABASE maxvocab;
CREATE USER maxvocab_user WITH PASSWORD 'yourpassword';
GRANT ALL PRIVILEGES ON DATABASE maxvocab TO maxvocab_user;
\q

# 7. Run migrations
psql -U maxvocab_user -d maxvocab -f schema.sql
# Or run the SQL files in order from server/sql/

# 8. Install PM2 globally (if not already installed)
npm install -g pm2

# 9. Start the app
pm2 start src/index.js --name maxvocab
pm2 save
pm2 startup  # Follow the instructions it outputs
```

### Configure Nginx

```bash
sudo nano /etc/nginx/sites-available/maxvocab
```

**Add this config (replace yourdomain.com):**
```nginx
server {
    listen 80;
    server_name yourdomain.com;

    location / {
        proxy_pass http://localhost:3001;
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
```

```bash
# Enable site
sudo ln -s /etc/nginx/sites-available/maxvocab /etc/nginx/sites-enabled/
sudo nginx -t
sudo systemctl reload nginx

# Add SSL
sudo certbot --nginx -d yourdomain.com
```

## What This Project Has Already

✅ **Production-ready server** - Serves React build automatically  
✅ **Database connection** - Uses DATABASE_URL from environment  
✅ **API endpoints** - All routes configured  
✅ **Static file serving** - Serve React app on non-API routes  
✅ **CORS configured** - Ready for production  
✅ **Environment variables** - Uses .env pattern  

## What You Need to Provide

1. **Database** - PostgreSQL with credentials
2. **Environment variables** - .env file (created above)
3. **Domain** - Point DNS to your VPS IP
4. **Port** - Pick an unused port (like 3001, 3002, etc.)

## Check Your Existing Setup

Before deploying, understand your current VPS:

```bash
# What's running?
pm2 list

# What ports are used?
netstat -tlnp | grep LISTEN

# What's in nginx?
ls /etc/nginx/sites-available/
ls /etc/nginx/sites-enabled/

# What databases exist?
sudo -u postgres psql -l
```

## Update After Initial Deploy

When you make changes:

```bash
cd /var/www/MaxVocab
git pull
cd client && npm run build && cp -r dist ../server/
cd ../server
pm2 restart maxvocab
```

## Port Conflicts?

If port 3001 is taken, change it in your `.env` file and nginx config, then restart:

```bash
pm2 restart maxvocab
sudo systemctl reload nginx
```

## Troubleshooting

**Can't connect to database:**
```bash
# Test connection
psql -U maxvocab_user -d maxvocab -h localhost

# Check PostgreSQL is running
sudo systemctl status postgresql
```

**502 Bad Gateway:**
```bash
# Check if app is running
pm2 list
pm2 logs maxvocab

# Check port is listening
netstat -tlnp | grep 3001
```

**Build fails:**
```bash
cd client
rm -rf node_modules package-lock.json
npm install
npm run build
```

