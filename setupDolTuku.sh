#!/bin/bash
set -e
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

print_info() { echo -e "${BLUE}[INFO]${NC} $1"; }
print_success() { echo -e "${GREEN}[SUCCESS]${NC} $1"; }
print_warning() { echo -e "${YELLOW}[WARNING]${NC} $1"; }
print_error() { echo -e "${RED}[ERROR]${NC} $1"; }

check_root() {
    if [[ $EUID -ne 0 ]]; then
        print_error "Script ini harus dijalankan sebagai root atau dengan sudo"
        exit 1
    fi
}

check_os() {
    if [[ ! -f /etc/os-release ]]; then
        print_error "Tidak dapat mendeteksi OS"
        exit 1
    fi
    . /etc/os-release
    if [[ "$ID" != "ubuntu" ]]; then
        print_error "Script ini hanya support Ubuntu"
        exit 1
    fi
    print_success "OS terdeteksi: Ubuntu $VERSION"
}

clear
echo -e "${GREEN}"
cat << "EOF"
╔═══════════════════════════════════════════════════════════╗
║                                                           ║
║     ██████╗  ██████╗ ██╗     ████████╗██╗   ██╗██╗  ██╗ ║
║     ██╔══██╗██╔═══██╗██║     ╚══██╔══╝██║   ██║██║ ██╔╝ ║
║     ██║  ██║██║   ██║██║        ██║   ██║   ██║█████╔╝  ║
║     ██║  ██║██║   ██║██║        ██║   ██║   ██║██╔═██╗  ║
║     ██████╔╝╚██████╔╝███████╗   ██║   ╚██████╔╝██║  ██╗ ║
║     ╚═════╝  ╚═════╝ ╚══════╝   ╚═╝    ╚═════╝ ╚═╝  ╚═╝ ║
║                                                           ║
║       WordPress + WooCommerce Setup Script v2.0           ║
║                   Powered by Nginx                        ║
║                                                           ║
╚═══════════════════════════════════════════════════════════╝
EOF
echo -e "${NC}"

print_info "Melakukan pengecekan sistem..."
check_root
check_os

DB_NAME=${DB_NAME:-"woocommerce_db"}
DB_USER=${DB_USER:-"woo_user"}
DB_PASS=${DB_PASS:-"$(openssl rand -base64 16)"}
WP_DIR="/var/www/woocommerce"
PHP_VERSION="8.1"

detect_php_version() {
    if apt-cache show php8.2-fpm &>/dev/null; then
        PHP_VERSION="8.2"
    elif apt-cache show php8.1-fpm &>/dev/null; then
        PHP_VERSION="8.1"
    elif apt-cache show php8.0-fpm &>/dev/null; then
        PHP_VERSION="8.0"
    else
        PHP_VERSION="7.4"
    fi
    print_info "Menggunakan PHP versi: $PHP_VERSION"
}

echo ""
print_warning "Script ini akan menginstall WordPress + WooCommerce dengan konfigurasi berikut:"
echo "  - Database Name: $DB_NAME"
echo "  - Database User: $DB_USER"
echo "  - Database Password: $DB_PASS (Generated)"
echo "  - Install Directory: $WP_DIR"
echo "  - Web Server: Nginx"
echo ""
read -p "Lanjutkan instalasi? (y/n): " -n 1 -r
echo
if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    print_info "Instalasi dibatalkan"
    exit 0
fi

print_info "Mengupdate sistem..."
apt-get update -qq > /dev/null 2>&1
apt-get upgrade -y -qq > /dev/null 2>&1
print_success "Sistem berhasil diupdate"

detect_php_version

print_info "Menginstall dependencies..."
DEBIAN_FRONTEND=noninteractive apt-get install -y -qq \
    nginx mysql-server \
    php${PHP_VERSION}-fpm php${PHP_VERSION}-mysql php${PHP_VERSION}-xml php${PHP_VERSION}-xmlrpc \
    php${PHP_VERSION}-curl php${PHP_VERSION}-gd php${PHP_VERSION}-imagick php${PHP_VERSION}-mbstring \
    php${PHP_VERSION}-zip php${PHP_VERSION}-intl php${PHP_VERSION}-soap php${PHP_VERSION}-cli \
    git unzip curl wget ufw fail2ban > /dev/null 2>&1
print_success "Dependencies berhasil diinstall"

print_info "Mengkonfigurasi firewall..."
ufw --force reset > /dev/null 2>&1
ufw default deny incoming > /dev/null 2>&1
ufw default allow outgoing > /dev/null 2>&1
ufw allow OpenSSH > /dev/null 2>&1
ufw allow 'Nginx Full' > /dev/null 2>&1
ufw --force enable > /dev/null 2>&1
print_success "Firewall berhasil dikonfigurasi"

print_info "Mengkonfigurasi MySQL..."
mysql -e "ALTER USER 'root'@'localhost' IDENTIFIED WITH mysql_native_password BY 'root';" 2>/dev/null || true
mysql -u root -proot -e "DELETE FROM mysql.user WHERE User='';" 2>/dev/null || true
mysql -u root -proot -e "DELETE FROM mysql.user WHERE User='root' AND Host NOT IN ('localhost','127.0.0.1','::1');" 2>/dev/null || true
mysql -u root -proot -e "DROP DATABASE IF EXISTS test;" 2>/dev/null || true
mysql -u root -proot -e "DELETE FROM mysql.db WHERE Db='test' OR Db='test\\_%';" 2>/dev/null || true
mysql -u root -proot -e "FLUSH PRIVILEGES;" 2>/dev/null || true

print_info "Membuat database dan user..."
mysql -u root -proot <<MYSQL_SCRIPT
CREATE DATABASE IF NOT EXISTS $DB_NAME CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
CREATE USER IF NOT EXISTS '$DB_USER'@'localhost' IDENTIFIED BY '$DB_PASS';
GRANT ALL PRIVILEGES ON $DB_NAME.* TO '$DB_USER'@'localhost';
FLUSH PRIVILEGES;
MYSQL_SCRIPT
print_success "Database MySQL berhasil dikonfigurasi"

print_info "Mengunduh WordPress..."
cd /tmp
rm -f latest.tar.gz
wget -q https://wordpress.org/latest.tar.gz
if [[ ! -f latest.tar.gz ]]; then
    print_error "Gagal mengunduh WordPress"
    exit 1
fi
print_success "WordPress berhasil diunduh"

print_info "Mengekstrak WordPress..."
rm -rf /var/www/wordpress
tar -xzf latest.tar.gz -C /var/www/
rm -rf $WP_DIR
mv /var/www/wordpress $WP_DIR
chown -R www-data:www-data $WP_DIR
find $WP_DIR -type d -exec chmod 755 {} \;
find $WP_DIR -type f -exec chmod 644 {} \;
print_success "WordPress berhasil diekstrak"

print_info "Membuat wp-config.php..."
cp $WP_DIR/wp-config-sample.php $WP_DIR/wp-config.php
chown www-data:www-data $WP_DIR/wp-config.php
sed -i "s/database_name_here/$DB_NAME/g" $WP_DIR/wp-config.php
sed -i "s/username_here/$DB_USER/g" $WP_DIR/wp-config.php
sed -i "s/password_here/$DB_PASS/g" $WP_DIR/wp-config.php
SALT=$(curl -s https://api.wordpress.org/secret-key/1.1/salt/)
STRING='put your unique phrase here'
printf '%s\n' "g/$STRING/d" a "$SALT" . w | ed -s $WP_DIR/wp-config.php > /dev/null 2>&1
cat >> $WP_DIR/wp-config.php <<'EOF'
define('DISALLOW_FILE_EDIT', true);
define('WP_AUTO_UPDATE_CORE', true);
define('FORCE_SSL_ADMIN', false);
define('WP_MEMORY_LIMIT', '256M');
define('WP_MAX_MEMORY_LIMIT', '512M');
define('WP_DEBUG', false);
define('WP_DEBUG_LOG', false);
define('WP_DEBUG_DISPLAY', false);
EOF
print_success "wp-config.php berhasil dibuat"

print_info "Optimasi PHP-FPM..."
PHP_INI="/etc/php/${PHP_VERSION}/fpm/php.ini"
sed -i 's/upload_max_filesize = .*/upload_max_filesize = 128M/' $PHP_INI
sed -i 's/post_max_size = .*/post_max_size = 128M/' $PHP_INI
sed -i 's/memory_limit = .*/memory_limit = 256M/' $PHP_INI
sed -i 's/max_execution_time = .*/max_execution_time = 300/' $PHP_INI
sed -i 's/max_input_time = .*/max_input_time = 300/' $PHP_INI
sed -i 's/;opcache.enable=1/opcache.enable=1/' $PHP_INI
sed -i 's/;opcache.memory_consumption=128/opcache.memory_consumption=128/' $PHP_INI
sed -i 's/;opcache.interned_strings_buffer=8/opcache.interned_strings_buffer=8/' $PHP_INI
sed -i 's/;opcache.max_accelerated_files=4000/opcache.max_accelerated_files=10000/' $PHP_INI
sed -i 's/;opcache.revalidate_freq=2/opcache.revalidate_freq=60/' $PHP_INI
POOL_CONF="/etc/php/${PHP_VERSION}/fpm/pool.d/www.conf"
sed -i 's/pm.max_children = .*/pm.max_children = 50/' $POOL_CONF
sed -i 's/pm.start_servers = .*/pm.start_servers = 5/' $POOL_CONF
sed -i 's/pm.min_spare_servers = .*/pm.min_spare_servers = 5/' $POOL_CONF
sed -i 's/pm.max_spare_servers = .*/pm.max_spare_servers = 35/' $POOL_CONF
print_success "PHP-FPM dioptimasi"

print_info "Konfigurasi Nginx..."
rm -f /etc/nginx/sites-enabled/default
SERVER_IP=$(hostname -I | awk '{print $1}')
[[ -z "$SERVER_IP" ]] && SERVER_IP="localhost"
CONFIG_FILE="/etc/nginx/sites-available/woocommerce"
cat > $CONFIG_FILE <<EOF
server {
    listen 80;
    listen [::]:80;
    server_name $SERVER_IP _;
    root $WP_DIR;
    index index.php index.html index.htm;
    access_log /var/log/nginx/woocommerce_access.log;
    error_log /var/log/nginx/woocommerce_error.log;
    client_max_body_size 128M;
    client_body_timeout 300s;
    location / {
        try_files \$uri \$uri/ /index.php?\$args;
    }
    location ~ \.php$ {
        include snippets/fastcgi-php.conf;
        fastcgi_pass unix:/var/run/php/php${PHP_VERSION}-fpm.sock;
        fastcgi_param SCRIPT_FILENAME \$document_root\$fastcgi_script_name;
        include fastcgi_params;
        fastcgi_intercept_errors on;
        fastcgi_buffer_size 128k;
        fastcgi_buffers 256 16k;
        fastcgi_busy_buffers_size 256k;
        fastcgi_temp_file_write_size 256k;
        fastcgi_read_timeout 300;
    }
    add_header X-Frame-Options "SAMEORIGIN" always;
    add_header X-Content-Type-Options "nosniff" always;
    add_header X-XSS-Protection "1; mode=block" always;
    add_header Referrer-Policy "no-referrer-when-downgrade" always;
    location ~ /\. { deny all; access_log off; log_not_found off; }
    location = /wp-config.php { deny all; }
    location = /xmlrpc.php { deny all; }
    location ~ /wp-content/uploads/.*\.php$ { deny all; }
    location ~* \.(jpg|jpeg|png|gif|ico|css|js|svg|woff|woff2|ttf|eot|webp)$ {
        expires 365d;
        add_header Cache-Control "public, no-transform, immutable";
        access_log off;
    }
    gzip on;
    gzip_vary on;
    gzip_min_length 1000;
    gzip_comp_level 6;
    gzip_types text/plain text/css text/xml text/javascript application/x-javascript application/xml+rss application/javascript application/json application/xml image/svg+xml;
    gzip_disable "msie6";
}
EOF
ln -sf $CONFIG_FILE /etc/nginx/sites-enabled/
nginx -t > /dev/null 2>&1 || { print_error "Konfigurasi Nginx tidak valid"; exit 1; }
NGINX_CONF="/etc/nginx/nginx.conf"
sed -i 's/worker_connections .*/worker_connections 4096;/' $NGINX_CONF
systemctl restart php${PHP_VERSION}-fpm
systemctl restart nginx
systemctl enable nginx > /dev/null 2>&1
systemctl enable php${PHP_VERSION}-fpm > /dev/null 2>&1
print_success "Nginx & PHP-FPM aktif"

print_info "Mengkonfigurasi Fail2Ban..."
cat > /etc/fail2ban/filter.d/wordpress.conf <<'EOF'
[Definition]
failregex = ^<HOST> .* "POST /wp-login.php
            ^<HOST> .* "POST /xmlrpc.php
ignoreregex =
EOF
cat > /etc/fail2ban/jail.d/wordpress.conf <<EOF
[wordpress]
enabled = true
filter = wordpress
logpath = /var/log/nginx/woocommerce_access.log
maxretry = 5
bantime = 3600
findtime = 600
EOF
systemctl restart fail2ban > /dev/null 2>&1
systemctl enable fail2ban > /dev/null 2>&1
print_success "Fail2Ban aktif"

mkdir -p /backup/wordpress
chmod 700 /backup/wordpress
cat > /usr/local/bin/backup-wordpress.sh <<BACKUP_SCRIPT
#!/bin/bash
BACKUP_DIR="/backup/wordpress"
WP_DIR="$WP_DIR"
DB_NAME="$DB_NAME"
DB_USER="$DB_USER"
DB_PASS="$DB_PASS"
DATE=\$(date +%Y%m%d_%H%M%S)
RETENTION_DAYS=7
mkdir -p \$BACKUP_DIR
tar -czf \$BACKUP_DIR/wordpress_files_\$DATE.tar.gz \$WP_DIR 2>/dev/null
mysqldump -u \$DB_USER -p\$DB_PASS \$DB_NAME | gzip > \$BACKUP_DIR/wordpress_db_\$DATE.sql.gz 2>/dev/null
find \$BACKUP_DIR -type f -name "wordpress_*" -mtime +\$RETENTION_DAYS -delete
BACKUP_SCRIPT
chmod +x /usr/local/bin/backup-wordpress.sh
(crontab -l 2>/dev/null | grep -v backup-wordpress; echo "0 2 * * * /usr/local/bin/backup-wordpress.sh >> /var/log/wordpress-backup.log 2>&1") | crontab -
print_success "Backup otomatis diatur"

print_info "Menginstall WP-CLI..."
curl -sO https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar
chmod +x wp-cli.phar
mv wp-cli.phar /usr/local/bin/wp
wp --version > /dev/null 2>&1 && print_success "WP-CLI berhasil diinstall" || print_warning "WP-CLI gagal"

rm -f /tmp/latest.tar.gz
apt-get autoremove -y -qq > /dev/null 2>&1
apt-get clean > /dev/null 2>&1

clear
echo -e "${GREEN}"
cat << "EOF"
╔═══════════════════════════════════════════════════════════╗
║                 ✓ INSTALASI BERHASIL!                    ║
╚═══════════════════════════════════════════════════════════╝
EOF
echo -e "${NC}"
print_success "WordPress + WooCommerce berhasil diinstall!"
