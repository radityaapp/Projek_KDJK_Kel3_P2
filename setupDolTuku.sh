#!/bin/bash

echo "--- Skrip Setup WordPress + WooCommerce untuk Nginx ---"

# Update server & Instalasi Komponen
echo "[INFO] Mengupdate server dan menginstal Nginx, MySQL, PHP, dan Git..."
sudo apt-get update > /dev/null 2>&1
sudo apt-get install -y nginx mysql-server php-fpm php-mysql php-zip php-gd php-intl php-curl php-mbstring php-xml git > /dev/null 2>&1

# Konfigurasi Firewall
echo "[INFO] Mengkonfigurasi firewall (UFW)..."
sudo ufw allow OpenSSH > /dev/null 2>&1
sudo ufw allow 'Nginx Full' > /dev/null 2>&1
sudo ufw --force enable

# Siapkan Database MySQL
DB_ROOT_PASS='root'
DB_NAME='woocommerce_db'
DB_USER='woo_user'
DB_PASS='PasswordKuat123!'

echo "[INFO] Mengamankan MySQL dan membuat database..."

# Buat database dan user
sudo mysql -u root <<MYSQL_SCRIPT
CREATE DATABASE $DB_NAME;
CREATE USER '$DB_USER'@'localhost' IDENTIFIED BY '$DB_PASS';
GRANT ALL PRIVILEGES ON $DB_NAME.* TO '$DB_USER'@'localhost';
FLUSH PRIVILEGES;
MYSQL_SCRIPT

# Download dan siapkan WordPress
echo "[INFO] Mengunduh dan menyiapkan file WordPress..."
cd /tmp
wget -q https://wordpress.org/latest.tar.gz
sudo tar -xzf latest.tar.gz -C /var/www/
sudo mv /var/www/wordpress /var/www/woocommerce
sudo chown -R www-data:www-data /var/www/woocommerce

# Buat file wp-config.php
echo "[INFO] Membuat file wp-config.php..."
sudo cp /var/www/woocommerce/wp-config-sample.php /var/www/woocommerce/wp-config.php
sudo chown www-data:www-data /var/www/woocommerce/wp-config.php
sudo sed -i "s/database_name_here/$DB_NAME/g" /var/www/woocommerce/wp-config.php
sudo sed -i "s/username_here/$DB_USER/g" /var/www/woocommerce/wp-config.php
sudo sed -i "s/password_here/$DB_PASS/g" /var/www/woocommerce/wp-config.php

# Konfigurasi Nginx
echo "[INFO] Mengkonfigurasi Nginx..."
sudo rm /etc/nginx/sites-enabled/default
SERVER_IP=$(hostname -I | awk '{print $1}')
CONFIG_FILE="/etc/nginx/sites-available/woocommerce"

sudo tee $CONFIG_FILE > /dev/null <<EOF
server {
    listen 80;
    server_name $SERVER_IP;
    root /var/www/woocommerce;

    index index.php;

    location / {
        try_files \$uri \$uri/ /index.php?\$args;
    }

    location ~ \.php\$ {
        include snippets/fastcgi-php.conf;
        fastcgi_pass unix:/var/run/php/php8.1-fpm.sock; # Sesuaikan versi PHP jika beda
    }
}
EOF

sudo ln -s $CONFIG_FILE /etc/nginx/sites-enabled/

# Restart layanan
echo "[INFO] Merestart Nginx dan PHP-FPM..."
sudo nginx -t
sudo systemctl restart nginx
sudo systemctl restart php8.1-fpm

echo ""
echo "--- INSTALASI SELESAI ---"
echo "Buka browser dan kunjungi: http://$SERVER_IP"
echo "Lanjutkan instalasi WordPress melalui web."
echo ""
echo "Detail Database:"
echo "Database Name: $DB_NAME"
echo "Database User: $DB_USER"
echo "Database Pass: $DB_PASS"
echo "--------------------------"