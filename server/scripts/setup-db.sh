#!/bin/bash
# Database setup script for Vocabulary Atlas
# This script creates the database and runs all migrations

set -e  # Exit on error

DB_NAME="vocab_atlas"
DB_USER="${DB_USER:-postgres}"

echo "🗄️  Setting up Vocabulary Atlas Database..."

# Check if PostgreSQL is running
if ! pg_isready -q; then
    echo "❌ PostgreSQL is not running. Please start PostgreSQL and try again."
    exit 1
fi

# Create database if it doesn't exist
echo "📝 Creating database '$DB_NAME'..."
if psql -U "$DB_USER" -lqt | cut -d \| -f 1 | grep -qw "$DB_NAME"; then
    echo "   Database already exists."
else
    createdb -U "$DB_USER" "$DB_NAME"
    echo "   ✅ Database created."
fi

# Run migrations
echo "📊 Running migrations..."

echo "   → 001_init.sql (extensions)"
psql -U "$DB_USER" -d "$DB_NAME" -f "$(dirname "$0")/../sql/001_init.sql" > /dev/null

echo "   → 002_vocab_schema.sql (schema)"
psql -U "$DB_USER" -d "$DB_NAME" -f "$(dirname "$0")/../sql/002_vocab_schema.sql" > /dev/null

# Ask about sample data
read -p "📚 Load sample vocabulary data? (y/n) " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
    echo "   → 003_sample_data.sql (sample data)"
    psql -U "$DB_USER" -d "$DB_NAME" -f "$(dirname "$0")/../sql/003_sample_data.sql" > /dev/null
    echo "   ✅ Sample data loaded."
fi

echo ""
echo "✨ Database setup complete!"
echo ""
echo "Database: $DB_NAME"
echo "Connection string: postgresql://$DB_USER@localhost:5432/$DB_NAME"
echo ""
echo "Next steps:"
echo "1. Update server/.env with your database connection string"
echo "2. Run 'npm run dev' from the project root to start the app"
echo ""

