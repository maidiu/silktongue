#!/bin/bash

echo "==========================================="
echo "VPS SETUP ANALYSIS FOR MAXVOCAB DEPLOYMENT"
echo "==========================================="
echo ""

echo "1. CHECKING PM2 PROCESSES"
echo "-------------------------"
pm2 list 2>/dev/null || echo "PM2 not installed"
echo ""

echo "2. CHECKING NODE PROCESSES"
echo "-------------------------"
ps aux | grep node | grep -v grep | head -10
echo ""

echo "3. CHECKING PYTHON PROCESSES"
echo "-----------------------------"
ps aux | grep python | grep -v grep | head -10
echo ""

echo "4. CHECKING POSTGRESQL STATUS"
echo "-----------------------------"
systemctl status postgresql 2>/dev/null | head -10 || service postgresql status 2>/dev/null || echo "Service manager not available"
echo ""

echo "5. CHECKING NGINX STATUS"
echo "------------------------"
systemctl status nginx 2>/dev/null | head -10 || service nginx status 2>/dev/null || echo "Service manager not available"
echo ""

echo "6. CHECKING WEB SERVER CONFIGURATION"
echo "-----------------------------------"
ls -la /etc/nginx/sites-available/ 2>/dev/null || echo "No /etc/nginx/sites-available/"
echo ""

echo "7. CHECKING DATABASE ACCESS"
echo "-------------------------"
psql --version 2>/dev/null || echo "PostgreSQL not in PATH"
sudo -u postgres psql -l 2>/dev/null || echo "Cannot list databases"
echo ""

echo "8. CHECKING PORT USAGE"
echo "---------------------"
lsof -i -P -n | grep LISTEN | head -20 2>/dev/null || echo "lsof not available"
echo ""

echo "9. CHECKING PROJECT DIRECTORIES"
echo "-------------------------------"
ls -la /var/www/ 2>/dev/null || echo "/var/www not found"
ls -la /home/*/www 2>/dev/null || echo "No /home/*/www"
echo ""

echo "10. CHECKING DISK SPACE"
echo "----------------------"
df -h | grep -E "Filesystem|/$"
echo ""

echo "==========================================="
echo "Analysis complete!"
echo "Copy this output and share it for deployment help"
echo "==========================================="

