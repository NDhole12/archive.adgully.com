#!/bin/bash
# Application Files Backup Script
# Usage: bash backup-files.sh

# Configuration
WEB_ROOT="/var/www/archive.adgully.com/public_html"
BACKUP_DIR="/var/backups/files"
DATE=$(date +%Y%m%d_%H%M%S)
BACKUP_FILE="$BACKUP_DIR/archive_files_${DATE}.tar.gz"
RETENTION_DAYS=7

# Create backup directory if it doesn't exist
mkdir -p $BACKUP_DIR

echo "========================================"
echo "Application Files Backup"
echo "========================================"
echo "Source: $WEB_ROOT"
echo "Backup file: $BACKUP_FILE"
echo ""

# Create backup
echo "Creating backup..."
tar -czf $BACKUP_FILE \
  --exclude='cache/*' \
  --exclude='tmp/*' \
  --exclude='*.log' \
  -C $(dirname $WEB_ROOT) \
  $(basename $WEB_ROOT)

if [ $? -eq 0 ]; then
    echo "✓ Backup created successfully"
    
    # Get file size
    SIZE=$(du -h $BACKUP_FILE | cut -f1)
    echo "  Size: $SIZE"
    
    # Set permissions
    chmod 600 $BACKUP_FILE
    
    # Clean up old backups
    echo "Cleaning up old backups (keeping last $RETENTION_DAYS days)..."
    find $BACKUP_DIR -name "archive_files_*.tar.gz" -mtime +$RETENTION_DAYS -delete
    
    REMAINING=$(ls -1 $BACKUP_DIR/archive_files_*.tar.gz 2>/dev/null | wc -l)
    echo "✓ $REMAINING backup(s) remaining"
    
    echo ""
    echo "Backup complete: $BACKUP_FILE"
else
    echo "✗ Backup failed!"
    exit 1
fi

echo "========================================"
