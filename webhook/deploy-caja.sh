#!/bin/bash
# Deploy script for caja.sga-sp.com
# Triggered by GitHub webhook on push to prod branch

PROJECT_DIR="/var/www/caja.sga-sp.com"
BACKUP_DIR="/tmp/caja_config_backup"
export HOME="/var/www"
export GIT_SSH_COMMAND="ssh -o StrictHostKeyChecking=accept-new -o UserKnownHostsFile=/dev/null -i /var/www/.ssh/id_ed25519"

cd "$PROJECT_DIR" || exit 1

# Backup config files that differ from repo (production-specific)
mkdir -p "$BACKUP_DIR"
for f in config/database.php config/email.php config/pusher.php; do
    if [ -f "$f" ]; then
        cp "$f" "$BACKUP_DIR/$(basename $f)" 2>/dev/null
    fi
done

# Backup webhook files (not in git)
[ -f webhook/deploy.php ] && cp webhook/deploy.php "$BACKUP_DIR/deploy.php"
[ -f webhook/deploy-caja.sh ] && cp webhook/deploy-caja.sh "$BACKUP_DIR/deploy-caja.sh"

# Pull latest from prod
git fetch origin prod 2>&1
git reset --hard origin/prod 2>&1

# Restore production configs (preserve between deploys)
for f in database.php email.php pusher.php; do
    if [ -f "$BACKUP_DIR/$f" ]; then
        cp "$BACKUP_DIR/$f" "config/$f"
    fi
done

# Restore webhook files
[ -f "$BACKUP_DIR/deploy.php" ] && cp "$BACKUP_DIR/deploy.php" webhook/deploy.php
[ -f "$BACKUP_DIR/deploy-caja.sh" ] && cp "$BACKUP_DIR/deploy-caja.sh" webhook/deploy-caja.sh

# Ensure vendor dependencies
if [ -f composer.json ]; then
    composer install --no-dev --optimize-autoloader 2>&1 || true
fi

# Set permissions
chown -R www-data:www-data "$PROJECT_DIR" 2>/dev/null
find "$PROJECT_DIR" -type d -exec chmod 755 {} \; 2>/dev/null
find "$PROJECT_DIR" -type f -exec chmod 644 {} \; 2>/dev/null
chmod -R 775 "$PROJECT_DIR/storage" 2>/dev/null
chmod -R 775 "$PROJECT_DIR/webhook" 2>/dev/null

# Clean up
rm -rf "$BACKUP_DIR"

echo "Deploy completado: $(date)"
