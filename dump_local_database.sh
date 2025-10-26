#!/bin/bash
# Dump your local working database

echo "Dumping local database to local_db_backup.sql..."
pg_dump -U postgres -d vocab_atlas > local_db_backup.sql

echo "✅ Dump complete!"
echo ""
echo "Size: $(du -h local_db_backup.sql)"
echo ""
echo "Now upload this to your VPS:"
echo "scp local_db_backup.sql root@<VPS_IP>:/var/www/maxvocab/"

