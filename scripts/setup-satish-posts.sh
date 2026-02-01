#!/bin/bash
# Database setup script to be executed on remote server
# This script will be sent via SSH/plink

echo "=========================================="
echo "Database Operations for satish_posts"
echo "=========================================="
echo ""

DATABASE="archive_adgully"
DBUSER="root"
DBPASS="Admin@2026MsIhJgArhSg8x"

echo "[1] Current tables in ${DATABASE}:"
mysql -u ${DBUSER} -p${DBPASS} -e "SHOW TABLES FROM ${DATABASE};"
echo ""

echo "[2] Checking if satish_posts exists..."
EXISTS=$(mysql -u ${DBUSER} -p${DBPASS} -e "SELECT COUNT(*) FROM information_schema.TABLES WHERE TABLE_SCHEMA='${DATABASE}' AND TABLE_NAME='satish_posts';" 2>/dev/null | tail -1)

if [ "$EXISTS" == "1" ]; then
    echo "✓ satish_posts table already EXISTS"
else
    echo "✗ satish_posts table DOES NOT EXIST"
    echo ""
    echo "[3] Creating satish_posts table..."
    
    mysql -u ${DBUSER} -p${DBPASS} ${DATABASE} << 'EOFCREATE'
CREATE TABLE IF NOT EXISTS `satish_posts` (
  `ID` int(11) NOT NULL AUTO_INCREMENT,
  `post_title` varchar(500) DEFAULT NULL,
  `post_content` longtext,
  `tags` varchar(500) DEFAULT NULL,
  `terms` varchar(500) DEFAULT NULL,
  `keywords` varchar(500) DEFAULT NULL,
  `image` varchar(500) DEFAULT NULL,
  PRIMARY KEY (`ID`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;
EOFCREATE
    
    echo "✓ Table created successfully"
fi

echo ""
echo "[4] Describing satish_posts table:"
mysql -u ${DBUSER} -p${DBPASS} -e "DESCRIBE ${DATABASE}.satish_posts;"
echo ""

echo "[5] Total table count in ${DATABASE}:"
mysql -u ${DBUSER} -p${DBPASS} -e "SELECT COUNT(*) as total_tables FROM information_schema.TABLES WHERE TABLE_SCHEMA='${DATABASE}';"
echo ""

echo "=========================================="
echo "✓ Operations completed successfully!"
echo "=========================================="
