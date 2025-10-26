# Deployment Guide for MaxVocab

## Prerequisites

Your VPS should have:
- Node.js 18+ 
- PostgreSQL
- Nginx (reverse proxy)
- PM2 (process manager) - install with `npm install -g pm2`
- Git

## Step 1: Analyze Your Existing Setup

SSH into your VPS and run these commands to understand your current setup:

```bash
# See what processes are running
pm2 list

# See what ports are in use
netstat -tlnp | grep LISTEN

# Check nginx configuration
ls -la /etc/nginx/sites-available/
cat /etc/nginx/sites-available/*

# Check PostgreSQL status
sudo systemctl status postgresql
# Or
sudo service postgresql status

# See current projects
ls -la /var/www/  # or wherever your projects are
```

## Step 2: Database Setup

This project needs its own PostgreSQL database:

```bash
# Connect to PostgreSQL
sudo -u postgres psql

# Create database (adjust name as needed)
CREATE DATABASE maxvocab;

# Create user (replace 'yourpassword' with a strong password)
CREATE USER maxvocab_user WITH PASSWORD 'yourpassword';

# Grant privileges
GRANT ALL PRIVILEGES ON DATABASE maxvocab TO maxvocab_user;

# Exit PostgreSQL
\q
```

## Step 3: Deploy the Code

### Option A: Direct Git Clone (Recommended for first deployment)

```bash
# Navigate to your web directory (usually /var/www or /home/username)
cd /var/www  # or wherever your other projects are
git clone https://github.com/yourusername/MaxVocab.git maxvocab
cd maxvocab

# Install dependencies
cd server && npm install
cd ../client && npm install

# Build the React app for production
npm run build

# Copy the built files to server directory
cp -r dist ../server/
```

### Option B: Using GitHub Actions (For automatic deployments)

See `.github/workflows/deploy.yml` for automated deployment setup.

## Step 4: Environment Configuration

Create environment file in the project root:

```bash
# From the server directory
cd /var/www/maxvocab
nano .env
```

Add this content (replace with your actual values):

```env
# Database - use the credentials you created
DATABASE_URL=postgresql://maxvocab_user:yourpassword@localhost:5432/maxvocab

# JWT Secret - Generate a secure random string
JWT_SECRET=your-secure-random-string-here-min-32-characters

# Server Port
PORT=3001  # Use a port different from your existing apps

# Environment
NODE_ENV=production
```

Generate a secure JWT secret:
```bash
node -e "console.log(require('crypto').randomBytes(32).toString('hex'))"
```

## Step 5: Database Migration

```bash
cd server
# Run the SQL schema files
psql -U maxvocab_user -d maxvocab -f sql/000_simple_schema.sql
psql -U maxvocab_user -d maxvocab -f sql/001_init.sql
psql -U maxvocab_user -d maxvocab -f sql/002_vocab_schema.sql
# ... continue with all schema files in order

# Or use the combined schema
psql -U maxvocab_user -d maxvocab -f schema.sql
```

## Step 6: Start with PM2

```bash
cd /var/www/maxvocab/server

# Start the application
pm2 start src/index.js --name maxvocab

# Save PM2 configuration
pm2 save

# Enable PM2 to start on boot
pm2 startup
# (Run the command it outputs)
```

## Step 7: Configure Nginx

Create a new nginx configuration:

```bash
sudo nano /etc/nginx/sites-available/maxvocab
```

Add this configuration (adjust domain and port):

```nginx
server {
    listen 80;
    server_name yourdomain.com www.yourdomain.com;

    # Redirect HTTP to HTTPS (after SSL setup)
    # return 301 https://$server_name$request_uri;

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

Enable the site:
```bash
sudo ln -s /etc/nginx/sites-available/maxvocab /etc/nginx/sites-enabled/
sudo nginx -t  # Test configuration
sudo systemctl reload nginx
```

## Step 8: SSL Setup (Let's Encrypt)

```bash
sudo apt install certbot python3-certbot-nginx
sudo certbot --nginx -d yourdomain.com -d www.yourdomain.com
```

## Step 9: Monitoring

Check logs:
```bash
pm2 logs maxvocab
pm2 monit
```

Check status:
```bash
pm2 status
pm2 info maxvocab
```

## Troubleshooting

### Database Connection Issues
```bash
# Test database connection
psql -U maxvocab_user -d maxvocab -h localhost
```

### Check if port is available
```bash
sudo netstat -tlnp | grep 3001
```

### View application logs
```bash
pm2 logs maxvocab --lines 100
```

## Update Process

When you push changes to GitHub:

```bash
cd /var/www/maxvocab
git pull origin main
cd client && npm run build
cp -r dist ../server/
cd ../server
pm2 restart maxvocab
```

## Port Conflicts

If your existing app uses port 3000, change MaxVocab to use a different port in your `.env` file and nginx configuration.

