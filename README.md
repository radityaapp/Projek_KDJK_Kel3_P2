<h1 align="center">Setup WordPress + WooCommerce dengan Nginx</h1>

| [Sekilas Tentang](#sekilas-tentang) | [Instalasi Manual](#instalasi-manual) | [Otomatisasi](#otomatisasi) | [Referensi](#referensi) |
| :---------------------------------: | :-----------------------------------: | :-------------------------: | :---------------------: |

## Sekilas Tentang

[`^ kembali ke atas ^`](#)

**WooCommerce** adalah sebuah plugin _e-commerce open-source_ untuk **WordPress**. Ditulis dalam PHP, WooCommerce memungkinkan pemilik situs untuk membuat toko online yang fungsional dan dapat disesuaikan dengan mudah. Proyek ini mendokumentasikan proses instalasi dan konfigurasi WordPress dengan plugin WooCommerce di server Ubuntu menggunakan Nginx sebagai web server.

## Instalasi Manual

[`^ kembali ke atas ^`](#)

#### Kebutuhan Sistem:

- Server Ubuntu 20.04+
- Nginx Web server
- PHP 7.4+ (dengan ekstensi yang dibutuhkan)
- MySQL 5.7+ atau MariaDB 10.1+
- RAM minimal 128MB+

#### Proses Instalasi:

1.  Login ke dalam server menggunakan SSH.

    ```bash
    # Ganti 'user' dan 'ip_server' dengan kredensialmu
    ssh user@ip_server
    ```

2.  Update server dan install semua komponen yang dibutuhkan (Nginx, MySQL, PHP-FPM, Git, Unzip).

    ```bash
    sudo apt update && sudo apt upgrade -y
    sudo apt install nginx mysql-server php-fpm php-mysql php-zip php-gd php-intl php-curl php-mbstring php-xml git unzip -y
    ```

3.  Konfigurasi Firewall.

    ```bash
    sudo ufw allow OpenSSH
    sudo ufw allow 'Nginx Full'
    sudo ufw enable
    ```

4.  Buat database dan user untuk WordPress.

    ```bash
    sudo mysql -u root -p -e "
        CREATE DATABASE woocommerce_db;
        CREATE USER 'woo_user'@'localhost' IDENTIFIED BY 'password_yang_aman';
        GRANT ALL PRIVILEGES ON `woocommerce_db`.* TO 'woo_user'@'localhost';
        FLUSH PRIVILEGES;"
    ```

5.  Unduh dan siapkan file WordPress di direktori web.

    ```bash
    # Unduh WordPress
    wget [https://wordpress.org/latest.tar.gz](https://wordpress.org/latest.tar.gz)

    # Ekstrak ke /var/www/woocommerce
    sudo tar -xzf latest.tar.gz -C /var/www/
    sudo mv /var/www/wordpress /var/www/woocommerce

    # Atur kepemilikan file ke web server
    sudo chown -R www-data:www-data /var/www/woocommerce
    ```

6.  Konfigurasi Nginx. Buat file `/etc/nginx/sites-available/woocommerce` dengan isi berikut:

    ```nginx
    server {
        listen 80;
        server_name ip_server_atau_domain;
        root /var/www/woocommerce;

        index index.php;

        location / {
            try_files $uri $uri/ /index.php?$args;
        }

        location ~ \.php$ {
            include snippets/fastcgi-php.conf;
            fastcgi_pass unix:/var/run/php/php8.1-fpm.sock; # Sesuaikan versi PHP jika beda
        }
    }
    ```

7.  Aktifkan situs dan restart Nginx.

    ```bash
    sudo ln -s /etc/nginx/sites-available/woocommerce /etc/nginx/sites-enabled/
    sudo nginx -t
    sudo systemctl restart nginx
    ```

8.  Hubungkan WordPress ke database dengan menyalin `wp-config-sample.php` menjadi `wp-config.php` dan mengisi detail database.

9.  Kunjungi alamat IP server di browser untuk menyelesaikan instalasi WordPress.

10. Setelah WordPress terinstal, instal dan aktifkan plugin WooCommerce dari dashboard admin.

## Otomatisasi

[`^ kembali ke atas ^`](#)

Untuk mempermudah proses instalasi, sebuah skrip otomatis telah disediakan. Cukup unduh dan jalankan skrip ini di servermu.

```bash
# Berikan izin eksekusi
chmod +x install-woocommerce.sh

# Jalankan skrip
./install-woocommerce.sh
```
