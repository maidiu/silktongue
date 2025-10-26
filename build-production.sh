#!/bin/bash

# Build script for MaxVocab production deployment
# Usage: ./build-production.sh

set -e  # Exit on error

echo "🔨 Building MaxVocab for production..."

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Check if we're in the right directory
if [ ! -f "package.json" ]; then
    echo -e "${RED}❌ Error: Must run from project root${NC}"
    exit 1
fi

# Check if client directory exists
if [ ! -d "client" ]; then
    echo -e "${RED}❌ Error: client directory not found${NC}"
    exit 1
fi

echo -e "${GREEN}✅ Building React app...${NC}"
cd client
npm install
npm run build

# Check if build was successful
if [ ! -d "dist" ]; then
    echo -e "${RED}❌ Error: Build failed - dist directory not created${NC}"
    exit 1
fi

echo -e "${GREEN}✅ Build successful!${NC}"

# Copy dist to server
echo -e "${YELLOW}📦 Copying build to server directory...${NC}"
rm -rf ../server/dist
cp -r dist ../server/dist

echo -e "${GREEN}✅ Production build complete!${NC}"
echo ""
echo "Next steps:"
echo "1. Make sure .env file is configured in the server directory"
echo "2. Ensure database is set up and migrations are run"
echo "3. Deploy with: pm2 start ecosystem.config.js --env production"
echo ""

