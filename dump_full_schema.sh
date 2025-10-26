#!/bin/bash
# Dump the complete schema from your actual VPS database

echo "📊 Dumping complete schema from VPS database..."
echo ""
echo "SSH into your VPS and run:"
echo ""
echo "sudo -u postgres pg_dump -d vocab_atlas --schema-only > /tmp/vocab_atlas_schema.sql"
echo "cat /tmp/vocab_atlas_schema.sql"
echo ""
echo "Then copy that output and we can use it as the definitive schema."

