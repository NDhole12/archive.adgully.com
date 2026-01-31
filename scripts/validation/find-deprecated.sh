#!/bin/bash
# Find Deprecated PHP Functions
# Usage: bash find-deprecated.sh /path/to/code

if [ -z "$1" ]; then
    echo "Usage: bash find-deprecated.sh /path/to/code"
    exit 1
fi

CODE_PATH="$1"
REPORT_FILE="deprecated_functions_report_$(date +%Y%m%d_%H%M%S).txt"

echo "========================================"
echo "PHP Deprecated Function Scanner"
echo "========================================"
echo "Scanning: $CODE_PATH"
echo "Report: $REPORT_FILE"
echo ""

# Create report
cat > $REPORT_FILE << 'EOF'
========================================
PHP Deprecated Function Report
========================================
Generated: $(date)
Path: $CODE_PATH

EOF

echo "Searching for deprecated functions..."

# mysql_* functions (removed in PHP 7.0)
echo "=== mysql_* Functions (Removed in PHP 7.0) ===" >> $REPORT_FILE
grep -rn --include="*.php" "\bmysql_\w\+(" "$CODE_PATH" >> $REPORT_FILE 2>/dev/null
COUNT_MYSQL=$(grep -r --include="*.php" "\bmysql_\w\+(" "$CODE_PATH" 2>/dev/null | wc -l)
echo "Found $COUNT_MYSQL mysql_* function calls" | tee -a $REPORT_FILE
echo "" >> $REPORT_FILE

# mcrypt_* functions (removed in PHP 7.2)
echo "=== mcrypt_* Functions (Removed in PHP 7.2) ===" >> $REPORT_FILE
grep -rn --include="*.php" "\bmcrypt_\w\+(" "$CODE_PATH" >> $REPORT_FILE 2>/dev/null
COUNT_MCRYPT=$(grep -r --include="*.php" "\bmcrypt_\w\+(" "$CODE_PATH" 2>/dev/null | wc -l)
echo "Found $COUNT_MCRYPT mcrypt_* function calls" | tee -a $REPORT_FILE
echo "" >> $REPORT_FILE

# ereg* functions (removed in PHP 7.0)
echo "=== ereg* Functions (Removed in PHP 7.0) ===" >> $REPORT_FILE
grep -rn --include="*.php" "\b\(ereg\|eregi\|ereg_replace\|split\)(" "$CODE_PATH" >> $REPORT_FILE 2>/dev/null
COUNT_EREG=$(grep -r --include="*.php" "\b\(ereg\|eregi\|ereg_replace\|split\)(" "$CODE_PATH" 2>/dev/null | wc -l)
echo "Found $COUNT_EREG ereg* function calls" | tee -a $REPORT_FILE
echo "" >> $REPORT_FILE

# each() function (removed in PHP 8.0)
echo "=== each() Function (Removed in PHP 8.0) ===" >> $REPORT_FILE
grep -rn --include="*.php" "\beach(" "$CODE_PATH" >> $REPORT_FILE 2>/dev/null
COUNT_EACH=$(grep -r --include="*.php" "\beach(" "$CODE_PATH" 2>/dev/null | wc -l)
echo "Found $COUNT_EACH each() function calls" | tee -a $REPORT_FILE
echo "" >> $REPORT_FILE

# create_function() (removed in PHP 8.0)
echo "=== create_function() (Removed in PHP 8.0) ===" >> $REPORT_FILE
grep -rn --include="*.php" "create_function(" "$CODE_PATH" >> $REPORT_FILE 2>/dev/null
COUNT_CREATE=$(grep -r --include="*.php" "create_function(" "$CODE_PATH" 2>/dev/null | wc -l)
echo "Found $COUNT_CREATE create_function() calls" | tee -a $REPORT_FILE
echo "" >> $REPORT_FILE

# @ error suppression (not deprecated but problematic)
echo "=== @ Error Suppression (Review Recommended) ===" >> $REPORT_FILE
grep -rn --include="*.php" "@\$\|@\w\+(" "$CODE_PATH" | head -100 >> $REPORT_FILE 2>/dev/null
COUNT_AT=$(grep -r --include="*.php" "@\$\|@\w\+(" "$CODE_PATH" 2>/dev/null | wc -l)
echo "Found $COUNT_AT uses of @ error suppression (showing first 100)" | tee -a $REPORT_FILE
echo "" >> $REPORT_FILE

# Summary
echo "" >> $REPORT_FILE
echo "========================================"  >> $REPORT_FILE
echo "Summary"  >> $REPORT_FILE
echo "========================================"  >> $REPORT_FILE
echo "mysql_* functions: $COUNT_MYSQL"  >> $REPORT_FILE
echo "mcrypt_* functions: $COUNT_MCRYPT"  >> $REPORT_FILE
echo "ereg* functions: $COUNT_EREG"  >> $REPORT_FILE
echo "each() calls: $COUNT_EACH"  >> $REPORT_FILE
echo "create_function() calls: $COUNT_CREATE"  >> $REPORT_FILE
echo "@ error suppressions: $COUNT_AT"  >> $REPORT_FILE
echo ""  >> $REPORT_FILE

TOTAL=$(($COUNT_MYSQL + $COUNT_MCRYPT + $COUNT_EREG + $COUNT_EACH + $COUNT_CREATE))
echo "TOTAL CRITICAL ISSUES: $TOTAL"  >> $REPORT_FILE

echo ""
echo "========================================"
echo "Scan complete!"
echo "Report saved to: $REPORT_FILE"
echo "========================================"
echo ""
echo "Summary:"
echo "  mysql_* functions: $COUNT_MYSQL (CRITICAL)"
echo "  mcrypt_* functions: $COUNT_MCRYPT (CRITICAL)"
echo "  ereg* functions: $COUNT_EREG (CRITICAL)"
echo "  each() calls: $COUNT_EACH (HIGH)"
echo "  create_function() calls: $COUNT_CREATE (HIGH)"
echo "  Total critical issues: $TOTAL"
echo ""

if [ $TOTAL -gt 0 ]; then
    echo "⚠️  WARNING: Found $TOTAL critical compatibility issues!"
    echo "Review the report and update code before migration."
else
    echo "✓ No critical compatibility issues found!"
fi
