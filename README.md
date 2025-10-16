# Setup WordPress + WooCommerce dengan Nginx

<div align="center">

![WordPress](https://img.shields.io/badge/WordPress-6.4+-blue.svg)
![WooCommerce](https://img.shields.io/badge/WooCommerce-8.0+-purple.svg)
![Nginx](https://img.shields.io/badge/Nginx-1.18+-green.svg)
![PHP](https://img.shields.io/badge/PHP-8.1+-777BB4.svg)
![MySQL](https://img.shields.io/badge/MySQL-8.0+-4479A1.svg)

</div>

## 📑 Daftar Isi

- [Sekilas Tentang WooCommerce](#-sekilas-tentang-woocommerce)
- [Fitur](#-fitur)
- [Kebutuhan Sistem](#-kebutuhan-sistem)
- [Instalasi Manual](#-instalasi-manual)
- [Instalasi Otomatis](#-instalasi-otomatis)
- [Troubleshooting](#-troubleshooting)
- [Optimasi Performa](#-optimasi-performa)
- [Referensi](#-referensi)

## 🎯 Sekilas Tentang WooCommerce

**WooCommerce** adalah plugin e-commerce open-source paling populer untuk **WordPress**, mendukung lebih dari 30% toko online di seluruh dunia. Ditulis dalam PHP, WooCommerce menyediakan solusi lengkap untuk membangun toko online yang powerful, fleksibel, dan dapat disesuaikan sepenuhnya.

**WordPress** sendiri adalah sistem manajemen konten (CMS) yang menggerakkan lebih dari 40% website di internet, menawarkan kemudahan penggunaan dengan ekosistem plugin dan tema yang sangat luas.

Proyek ini mendokumentasikan proses instalasi dan konfigurasi WordPress dengan plugin WooCommerce di server Ubuntu menggunakan **Nginx** sebagai web server berkinerja tinggi.

### Mengapa Nginx?

- ⚡ Performa tinggi untuk melayani konten statis
- 🔄 Reverse proxy yang efisien
- 💪 Mampu menangani ribuan koneksi simultan
- 📉 Penggunaan resource yang lebih rendah dibanding Apache

## ✨ Fitur

- ✅ Instalasi WordPress terbaru secara otomatis
- ✅ Konfigurasi Nginx yang dioptimasi
- ✅ Setup database MySQL/MariaDB
- ✅ Konfigurasi PHP-FPM untuk performa maksimal
- ✅ Firewall (UFW) yang sudah dikonfigurasi
- ✅ SSL/TLS ready (dengan Let's Encrypt)
- ✅ Integrasi WooCommerce
- ✅ Backup script included
- ✅ Security hardening

## 💻 Kebutuhan Sistem

### Minimum Requirements

| Komponen      | Spesifikasi Minimum          |
| ------------- | ---------------------------- |
| OS            | Ubuntu 20.04 LTS / 22.04 LTS |
| CPU           | 1 vCPU                       |
| RAM           | 512 MB                       |
| Storage       | 10 GB                        |
| Nginx         | 1.18+                        |
| PHP           | 8.1+                         |
| MySQL/MariaDB | 8.0+ / 10.5+                 |

### Recommended Requirements

| Komponen | Spesifikasi Recommended |
| -------- | ----------------------- |
| OS       | Ubuntu 22.04 LTS        |
| CPU      | 2+ vCPU                 |
| RAM      | 2 GB+                   |
| Storage  | 20 GB+ SSD              |
| Nginx    | Latest stable           |
| PHP      | 8.2+                    |
| MySQL    | 8.0+                    |

### Ekstensi PHP yang Dibutuhkan

```
php-fpm
php-mysql
php-xml
php-xmlrpc
php-curl
php-gd
php-imagick
php-mbstring
php-zip
php-intl
php-soap
```

## 🚀 Instalasi Manual

### Langkah 1: Persiapan Server

Login ke server menggunakan SSH:

```bash
ssh user@your_server_ip
```

Update sistem dan install dependencies:

```bash
sudo apt update && sudo apt upgrade -y
sudo apt install nginx mysql-server php8.1-fpm php8.1-mysql php8.1-xml \
  php8.1-xmlrpc php8.1-curl php8.1-gd php8.1-imagick php8.1-mbstring \
  php8.1-zip php8.1-intl php8.1-soap git unzip curl -y
```

### Langkah 2: Konfigurasi Firewall

```bash
sudo ufw allow OpenSSH

sudo ufw allow 'Nginx Full'

sudo ufw --force enable

sudo ufw status
```

### Langkah 3: Setup MySQL Database

Amankan instalasi MySQL:

```bash
sudo mysql_secure_installation
```

Buat database dan user untuk WordPress:

```bash
sudo mysql -u root -p
```

Jalankan query berikut di MySQL prompt:

```sql
CREATE DATABASE woocommerce_db CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
CREATE USER 'woo_user'@'localhost' IDENTIFIED BY 'password_yang_sangat_aman';
GRANT ALL PRIVILEGES ON woocommerce_db.* TO 'woo_user'@'localhost';
FLUSH PRIVILEGES;
EXIT;
```

### Langkah 4: Install WordPress

Download WordPress:

```bash
cd /tmp
wget https://wordpress.org/latest.tar.gz
```

Ekstrak dan pindahkan ke direktori web:

```bash
sudo tar -xzf latest.tar.gz -C /var/www/
sudo mv /var/www/wordpress /var/www/woocommerce
```

Set permission yang tepat:

```bash
sudo chown -R www-data:www-data /var/www/woocommerce
sudo find /var/www/woocommerce -type d -exec chmod 755 {} \;
sudo find /var/www/woocommerce -type f -exec chmod 644 {} \;
```

### Langkah 5: Konfigurasi WordPress

Buat file konfigurasi WordPress:

```bash
sudo cp /var/www/woocommerce/wp-config-sample.php /var/www/woocommerce/wp-config.php
sudo chown www-data:www-data /var/www/woocommerce/wp-config.php
```

Edit file wp-config.php:

```bash
sudo nano /var/www/woocommerce/wp-config.php
```

Update informasi database:

```php
define( 'DB_NAME', 'woocommerce_db' );
define( 'DB_USER', 'woo_user' );
define( 'DB_PASSWORD', 'password_yang_sangat_aman' );
define( 'DB_HOST', 'localhost' );
define( 'DB_CHARSET', 'utf8mb4' );
define( 'DB_COLLATE', 'utf8mb4_unicode_ci' );
```

### Langkah 6: Konfigurasi Nginx

Buat file konfigurasi Nginx:

```bash
sudo nano /etc/nginx/sites-available/woocommerce
```

Tambahkan konfigurasi berikut:

```nginx
server {
    listen 80;
    listen [::]:80;

    server_name your_domain.com www.your_domain.com;
    root /var/www/woocommerce;

    index index.php index.html index.htm;

    # Logging
    access_log /var/log/nginx/woocommerce_access.log;
    error_log /var/log/nginx/woocommerce_error.log;

    # Max upload size
    client_max_body_size 128M;

    # Root location
    location / {
        try_files $uri $uri/ /index.php?$args;
    }

    # PHP processing
    location ~ \.php$ {
        include snippets/fastcgi-php.conf;
        fastcgi_pass unix:/var/run/php/php8.1-fpm.sock;
        fastcgi_param SCRIPT_FILENAME $document_root$fastcgi_script_name;
        include fastcgi_params;
        fastcgi_intercept_errors on;
        fastcgi_buffer_size 128k;
        fastcgi_buffers 256 16k;
        fastcgi_busy_buffers_size 256k;
        fastcgi_temp_file_write_size 256k;
    }

    # Security headers
    add_header X-Frame-Options "SAMEORIGIN" always;
    add_header X-Content-Type-Options "nosniff" always;
    add_header X-XSS-Protection "1; mode=block" always;

    # Deny access to hidden files
    location ~ /\. {
        deny all;
        access_log off;
        log_not_found off;
    }

    # Deny access to wp-config.php
    location = /wp-config.php {
        deny all;
    }

    # Cache static files
    location ~* \.(jpg|jpeg|png|gif|ico|css|js|svg|woff|woff2|ttf|eot)$ {
        expires 365d;
        add_header Cache-Control "public, immutable";
    }

    # Gzip compression
    gzip on;
    gzip_vary on;
    gzip_min_length 1000;
    gzip_types text/plain text/css text/xml text/javascript
               application/x-javascript application/xml+rss
               application/javascript application/json;
}
```

Enable site dan test konfigurasi:

```bash
sudo ln -s /etc/nginx/sites-available/woocommerce /etc/nginx/sites-enabled/
sudo nginx -t
sudo systemctl restart nginx
```

### Langkah 7: Instalasi WordPress via Browser

1. Buka browser dan akses `http://your_server_ip` atau `http://your_domain.com`
2. Pilih bahasa instalasi
3. Klik "Let's go!" atau "Mari kita mulai!"
4. Verifikasi informasi database (seharusnya sudah terisi otomatis)
5. Isi informasi situs:
   - Site Title: Nama toko Anda
   - Username: Username admin (jangan gunakan 'admin')
   - Password: Password yang kuat
   - Email: Email admin Anda
6. Klik "Install WordPress"

### Langkah 8: Install dan Konfigurasi WooCommerce

Setelah login ke WordPress Dashboard:

1. Navigasi ke **Plugins > Add New**
2. Cari "WooCommerce"
3. Klik **Install Now** pada plugin WooCommerce
4. Setelah terinstal, klik **Activate**
5. Ikuti Setup Wizard WooCommerce:
   - Store Details (informasi toko)
   - Industry (jenis industri)
   - Product Types (tipe produk yang dijual)
   - Business Details (detail bisnis)
   - Theme (pilih tema)
   - Extensions (pilih ekstensi tambahan jika diperlukan)

## 🤖 Instalasi Otomatis

Untuk instalasi yang lebih cepat, gunakan skrip otomatis yang telah disediakan.

### Download Script

```bash
wget https://raw.githubusercontent.com/yourusername/yourrepo/main/setupDolTuku.sh
chmod +x setupDolTuku.sh
```

### Jalankan Script

```bash
sudo ./setupDolTuku.sh
```

Script akan otomatis:

- Update sistem
- Install semua dependencies
- Setup database MySQL
- Download dan install WordPress
- Konfigurasi Nginx
- Setup firewall
- Generate wp-config.php

Setelah selesai, buka browser dan akses IP server Anda untuk melanjutkan instalasi WordPress.

## 🔧 Troubleshooting

### Error: "502 Bad Gateway"

Penyebab umum: PHP-FPM tidak berjalan atau sock file tidak ditemukan.

Solusi:

```bash
sudo systemctl status php8.1-fpm

sudo systemctl restart php8.1-fpm

ls -la /var/run/php/php8.1-fpm.sock
```

### Error: "White Screen of Death"

Aktifkan debug mode:

```php
define( 'WP_DEBUG', true );
define( 'WP_DEBUG_LOG', true );
define( 'WP_DEBUG_DISPLAY', false );
```

Cek log:

```bash
tail -f /var/www/woocommerce/wp-content/debug.log
```

### Upload File Gagal

Cek permission:

```bash
sudo chown -R www-data:www-data /var/www/woocommerce/wp-content/uploads
sudo chmod -R 755 /var/www/woocommerce/wp-content/uploads
```

Tingkatkan upload limit di Nginx:

```nginx
client_max_body_size 128M;
```

### Database Connection Error

Verifikasi kredensial database di wp-config.php dan test koneksi:

```bash
mysql -u woo_user -p woocommerce_db
```

## ⚡ Optimasi Performa

### Enable OPcache

Edit php.ini:

```bash
sudo nano /etc/php/8.1/fpm/php.ini
```

Aktifkan OPcache:

```ini
opcache.enable=1
opcache.memory_consumption=128
opcache.interned_strings_buffer=8
opcache.max_accelerated_files=4000
opcache.revalidate_freq=60
opcache.fast_shutdown=1
```

### CDN Integration

Gunakan CDN seperti:

- Cloudflare (gratis)
- StackPath
- KeyCDN
- BunnyCDN

### Database Optimization

Jalankan secara berkala:

```bash
wp db optimize --all-tables
```

Atau install plugin **WP-Optimize**.

## 📚 Referensi

### Dokumentasi Official

- [WordPress Documentation](https://wordpress.org/support/)
- [WooCommerce Documentation](https://woocommerce.com/documentation/)
- [Nginx Documentation](https://nginx.org/en/docs/)
- [PHP Manual](https://www.php.net/manual/en/)

---

<div align="center">

**Dibuat dengan ❤️ untuk komunitas Ilkomerz Sejati**

[⬆ Kembali ke atas](#setup-wordpress--woocommerce-dengan-nginx)

</div>
