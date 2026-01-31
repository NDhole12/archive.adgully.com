#!/bin/bash
# Database Backup Script
# Usage: bash backup-database.sh

# Configuration
DB_USER="archive_user"
DB_NAME="archive_db"
BACKUP_DIR="/var/backups/mysql"
DATE=$(date +%Y%m%d_%H%M%S)
BACKUP_FILE="$BACKUP_DIR/${DB_NAME}_${DATE}.sql"
RETENTION_DAYS=7

# Create backup directory if it doesn't exist
mkdir -p $BACKUP_DIR

echo "========================================"
echo "Database Backup"
echo "========================================"
echo "Database: $DB_NAME"
echo "Backup file: $BACKUP_FILE"
echo ""

# Prompt for password
echo -n "Enter database password for $DB_USER: "
read -s DB_PASS
echo ""

# Create backup
echo "Creating backup..."
mysqldump -u $DB_USER -p"$DB_PASS" \
  --single-transaction \
  --routines \
  --triggers \
  --events \
  --add-drop-database \
  --quick \
  --lock-tables=false \
  $DB_NAME > $BACKUP_FILE

if [ $? -eq 0 ]; then
    echo "✓ Backup created successfully"
    
    # Compress backup
    echo "Compressing backup..."
    gzip $BACKUP_FILE
    BACKUP_FILE="${BACKUP_FILE}.gz"
    
    # Get file size
    SIZE=$(du -h $BACKUP_FILE | cut -f1)
    echo "✓ Backup compressed: $SIZE"
    
    # Set permissions
    chmod 600 $BACKUP_FILE
    
    # Clean up old backups
    echo "Cleaning up old backups (keeping last $RETENTION_DAYS days)..."
    find $BACKUP_DIR -name "${DB_NAME}_*.sql.gz" -mtime +$RETENTION_DAYS -delete
    
    REMAINING=$(ls -1 $BACKUP_DIR/${DB_NAME}_*.sql.gz 2>/dev/null | wc -l)
    echo "✓ $REMAINING backup(s) remaining"
    
    echo ""
    echo "Backup complete: $BACKUP_FILE"
else
    echo "✗ Backup failed!"
    exit 1
fi

echo "========================================"
