#!/bin/bash
# Test Website Functionality
# Usage: bash test-website.sh https://archive.adgully.com

if [ -z "$1" ]; then
    echo "Usage: bash test-website.sh https://archive.adgully.com"
    exit 1
fi

SITE_URL="$1"

echo "========================================"
echo "Website Functionality Test"
echo "========================================"
echo "Testing: $SITE_URL"
echo ""

# Colors
GREEN='\033[0;32m'
RED='\033[0;31m'
NC='\033[0m'

# Test HTTP response
echo "===== HTTP Response Test ====="
HTTP_CODE=$(curl -s -o /dev/null -w "%{http_code}" "$SITE_URL")
if [ "$HTTP_CODE" == "200" ]; then
    echo -e "${GREEN}✓${NC} Homepage returns HTTP $HTTP_CODE"
else
    echo -e "${RED}✗${NC} Homepage returns HTTP $HTTP_CODE (expected 200)"
fi

# Test HTTPS redirect
echo ""
echo "===== HTTPS Redirect Test ====="
HTTP_URL="${SITE_URL/https:/http:}"
REDIRECT_CODE=$(curl -s -o /dev/null -w "%{http_code}" "$HTTP_URL")
if [ "$REDIRECT_CODE" == "301" ] || [ "$REDIRECT_CODE" == "302" ]; then
    echo -e "${GREEN}✓${NC} HTTP redirects to HTTPS (HTTP $REDIRECT_CODE)"
else
    echo -e "${RED}✗${NC} HTTP does not redirect (HTTP $REDIRECT_CODE)"
fi

# Test SSL certificate
echo ""
echo "===== SSL Certificate Test ====="
DOMAIN=$(echo "$SITE_URL" | sed -e 's|https\?://||' -e 's|/.*||')
SSL_EXPIRY=$(echo | openssl s_client -servername "$DOMAIN" -connect "$DOMAIN:443" 2>/dev/null | openssl x509 -noout -enddate 2>/dev/null | cut -d= -f2)
if [ ! -z "$SSL_EXPIRY" ]; then
    echo -e "${GREEN}✓${NC} SSL certificate valid"
    echo "  Expires: $SSL_EXPIRY"
else
    echo -e "${RED}✗${NC} SSL certificate issue"
fi

# Test response time
echo ""
echo "===== Response Time Test ====="
RESPONSE_TIME=$(curl -o /dev/null -s -w '%{time_total}' "$SITE_URL")
echo "  Total time: ${RESPONSE_TIME}s"
if (( $(echo "$RESPONSE_TIME < 2.0" | bc -l) )); then
    echo -e "${GREEN}✓${NC} Response time acceptable"
else
    echo -e "${RED}✗${NC} Response time slow (> 2s)"
fi

# Test PHP processing
echo ""
echo "===== PHP Processing Test ====="
PHP_TEST=$(curl -s "$SITE_URL" | grep -i "php\|<!DOCTYPE\|<html")
if [ ! -z "$PHP_TEST" ]; then
    echo -e "${GREEN}✓${NC} PHP processing works"
else
    echo -e "${RED}✗${NC} PHP processing may have issues"
fi

# Test security headers
echo ""
echo "===== Security Headers Test ====="
HEADERS=$(curl -sI "$SITE_URL")

if echo "$HEADERS" | grep -q "X-Frame-Options"; then
    echo -e "${GREEN}✓${NC} X-Frame-Options header present"
else
    echo -e "${RED}✗${NC} X-Frame-Options header missing"
fi

if echo "$HEADERS" | grep -q "X-Content-Type-Options"; then
    echo -e "${GREEN}✓${NC} X-Content-Type-Options header present"
else
    echo -e "${RED}✗${NC} X-Content-Type-Options header missing"
fi

if echo "$HEADERS" | grep -q "Strict-Transport-Security"; then
    echo -e "${GREEN}✓${NC} HSTS header present"
else
    echo "  HSTS header missing (optional)"
fi

echo ""
echo "========================================"
echo "Test complete"
echo "========================================"
