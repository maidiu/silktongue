#!/bin/bash

# Script to analyze your existing VPS setup
# Run this on your VPS to understand current configuration

echo "==========================================="
echo "VPS Configuration Analysis"
echo "==========================================="
echo ""

echo "📋 PROCESSES"
echo "-------------"
pm2 list
echo ""

echo "🌐 NGINX CONFIGURATION"
echo "---------------------"
echo "Available sites:"
ls -la /etc/nginx/sites-available/ 2>/dev/null || echo "Nginx not configured or different location"
echo ""
echo "Enabled sites:"
ls -la /etc/nginx/sites-enabled/ 2>/dev/null || echo "Nginx not configured or different location"
echo ""

echo "🔌 PORT USAGE"
echo "-------------"
netstat -tlnp | grep LISTEN | grep -E ":(80|443|3000|3001|3002|5432|8000|8080)" || echo "No common ports in use"
echo ""

echo "🗄️  DATABASES"
echo "-------------"
echo "PostgreSQL databases:"
sudo -u postgres psql -l 2>/dev/null || echo "PostgreSQL not accessible or not running"
echo ""

echo "📁 PROJECT LOCATIONS"
echo "-------------------"
echo "/var/www contents:"
ls -la /var/www/ 2>/dev/null || echo "/var/www not accessible"
echo ""
echo "/home/*/www contents:"
ls -la /home/*/www/ 2>/dev/null || echo "No /home/*/www"
echo ""

echo "🐳 DOCKER CONTAINERS (if applicable)"
echo "-----------------------------------"
docker ps 2>/dev/null || echo "Docker not installed or not running"
echo ""

echo "==========================================="
echo "✅ Analysis complete!"
echo "Use this information to choose ports and configure MaxVocab"
echo "==========================================="

