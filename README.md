# Setup WordPress + WooCommerce dengan Nginx

<div align="center">

![WordPress](https://img.shields.io/badge/WordPress-6.4+-blue.svg)
![WooCommerce](https://img.shields.io/badge/WooCommerce-8.0+-purple.svg)
![Nginx](https://img.shields.io/badge/Nginx-1.18+-green.svg)
![PHP](https://img.shields.io/badge/PHP-8.1+-777BB4.svg)
![MySQL](https://img.shields.io/badge/MySQL-8.0+-4479A1.svg)

</div>

## 👨‍🎓 Project Member

| Nama Anggota                    | NIM         | Github Userid     |
| ------------------------------- | ----------- | ----------------- |
| Ghaliyh Rayhan Adz Dzikra       | G6401231001 | ghaliyhadzkr      |
| Praditya Putra Irawan           | G6401231057 | radityaapp        |
| Marstella Nataline Purba Siboro | G6401231101 | marstellanataline |
| Andra Firmansyah Asmoro         | G6401231115 | derrandra         |
| Khalisha Rana Putri             | G6401231141 | khalisharana      |

## 📑 Daftar Isi

- [Sekilas Tentang WooCommerce](#-sekilas-tentang-woocommerce)
- [Fitur](#-fitur)
- [Kebutuhan Sistem](#-kebutuhan-sistem)
- [Instalasi Manual](#-instalasi-manual)
- [Instalasi Otomatis](#-instalasi-otomatis)
- [Troubleshooting](#-troubleshooting)
- [Optimasi Performa](#-optimasi-performa)
- [Cara Penggunaan WooCommerce](#-cara-penggunaan-woocommerce)
- [Kelebihan & Kekurangan](#-kelebihan--kekurangan)
- [Pembahasan: WooCommerce vs. Others](#-pembahasan-woocommerce-vs-others)
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

### Database Optimization

Jalankan secara berkala:

```bash
wp db optimize --all-tables
```

Atau install plugin **WP-Optimize**.

## 🧑‍💻 Cara Penggunaan WooCommerce

Cara penggunaan **WooCommerce** jauh lebih mudah daripada yang terlihat. Plugin ini bekerja langsung dalam **WordPress**, jadi kalau sudah familiar/terbiasa dengan tampilan dashboard WordPress, penggunaan WooCommerce bukanlah suatu tantangan yang besar.

Berikut langkah-langkah penggunaan WooCommerce secara umum:

### 1. Login WordPress untuk Akses Admin WooCommerce

Sebelum dapat mengatur apapun pada WooCommerce, login ke halaman **Admin WordPress** diperlukan. Setelah berhasil login akan dibawa ke dashboard utama WordPress.
![Admin WP](./Screenshot/Login%20WordPress%20untuk%20admin%20akses%20WooCommerce.png)

### 2. Dashboard Awal

Setelah WooCommerce berhasil diinstal dan login pada WordPress, tampilan **Dashboard Awal** akan terlihat. Di halaman ini, ringkasan seluruh aktivitas yang toko dapat lakukan akan terlihat.

![Dashboard Awal](./Screenshot/Dashboard%20Awal.png)

WooCommerce juga akan menampilkan notifikasi penting di sini, seperti pesanan baru, stok menipis, atau update sistem yang perlu dilakukan.

### 3. Maintenance Mode

Sebelum _open_ ke publik, ada baiknya **Maintenance Mode** diaktifkan. Selama mode ini aktif, pengunjung hanya akan melihat halaman penjelasan bahwa toko sedang melakukan sesuatu di belakang layar.

![Maintenance Mode](./Screenshot/Maintenance%20mode.png)

### 4. Add Product

Setelah tampilan toko siap, produk dapat ditambahkan ke katalog pada toko melalui Produk -> **Tambahkan Produk**. Lengkapi detail produk seperti nama produk, deskripsinya, stok, harga, dan lain sebagainya.

![Add Product](./Screenshot/Add%20product.png)

### 5. Cek Pesanan Pembeli

Begitu toko aktif dan transaksi diterima, menu **Pesanan** akan menjadi salah satu menu yang akan sering dibuka. Aktivitas penjualan akan terkam secara otomatis di sini.

![Cek Pesanan Pembeli](./Screenshot/Cek%20pesanan%20pembeli.png)

### 6. Cek Data Pelanggan

Halaman **Pelanggan** dapat digunakan untuk menampilkan daftar pelanggan yang pernah belanja pada toko. Laman ini menunjukkan _customer_ mana yang lebih loyal.

![Cek Data Pelanggan](./Screenshot/Cek%20data%20pelanggan.png)

### 7. Stastik Toko

Menu **Laporan** di WooCommerce berisi data performa toko secara visual dan mendetail. Di laman ini dapat dilihat grafik penjualan, _best seller product_, pesanan yang dibatalkan, dan lain sebagainya.

![Statistic](/Screenshot/Statistik%20toko.png)

### 8. Extensions di WooCommerce

Berbagai fitur tambahan dapat disesuaikan dengan kebutuhan toko. Beberapa _extension_ yang populer diantaranya:

1.  Plugin pembayaran lokal seperti **Midtrans**, **Xendit**, atau **Doku**
2.  Plugin pengiriman otomatis seperti **RajaOngkir** dan **JNE**
3.  Plugin SEO, dan lain-lain

![Ext](./Screenshot/Extension%20in%20WooCommerce.png)

### 9. Sesuaikan Theme Tampilan

WooCommerce menyediakan beberapa _template_ tampilan yang mungkin dapat menarik beberapa pelanggan.

![Theme Choser](./Screenshot/Sesuaikan%20theme%20tampilan.png)

### 10. Up Toko

Toko dapat dibuka ke publik. Matikan _Maintenance Mode_ dan toko sudah siap beroperasi penuh dan menerima pelanggan dari berbagai penjuru.

![Publish Toko](./Screenshot/Up%20toko.png)

## 🌟 Kelebihan & Kekurangan

### ✅ Kelebihan

WooCommerce adalah platform e-commerce open-source yang dibangun di atas WordPress. Berikut adalah kelebihan-kelebihannya:

1. _Terintegrasi dengan WordPress_ - WooCommerce adalah plugin yang berjalan di atas platform WordPress, sehingga dapat memanfaatkan semua fitur WordPress untuk konten, blog, dan SEO yang lebih baik. Ini memudahkan untuk mengelola toko online dan website informasi dalam satu dashboard.

2. _Panel administrasi yang intuitif dan mudah digunakan_ - WooCommerce memiliki antarmuka yang user-friendly dengan sistem dashboard yang jelas, sehingga pengguna pemula sekalipun dapat dengan mudah mengelola produk, pesanan, dan pengaturan toko tanpa memerlukan keahlian teknis yang mendalam.

3. _Sangat fleksibel dan dapat dikustomisasi_ - WooCommerce adalah open-source dan modular, memungkinkan developer untuk membuat customization dan ekstensi sesuai kebutuhan bisnis spesifik. Ribuan plugin dan tema tersedia untuk memperluas fungsionalitas.

4. _Mendukung berbagai metode pembayaran_ - WooCommerce kompatibel dengan berbagai gateway pembayaran populer seperti PayPal, Stripe, Square, Bank Transfer, dan berbagai payment gateway lokal, memberikan fleksibilitas kepada pelanggan dalam memilih cara pembayaran.

5. _Responsif dan mobile-friendly_ - Desain WooCommerce secara default responsive dan dapat diakses dengan baik melalui berbagai perangkat (desktop, tablet, smartphone), memastikan pengalaman berbelanja yang optimal untuk semua pengguna.

6. _Komunitas yang besar dan aktif_ - WooCommerce memiliki komunitas pengguna dan developer yang sangat besar. Forum diskusi, documentation, dan community support tersedia di WordPress.org, sehingga masalah yang dihadapi dapat cepat terselesaikan dengan bantuan komunitas.

7. _SEO-friendly dan optimasi search engine_ - Karena dibangun di atas WordPress yang terkenal SEO-friendly, WooCommerce memberikan keuntungan dalam optimasi mesin pencari, sehingga produk Anda lebih mudah ditemukan di Google dan search engine lainnya.

8. _Gratis dan open-source_ - WooCommerce adalah platform e-commerce gratis, berbeda dengan platform berbayar lainnya. Biaya yang dikeluarkan hanya untuk hosting, domain, dan plugin/tema tambahan yang diinginkan.

9. _Fitur lengkap untuk manajemen inventory dan pesanan_ - WooCommerce dilengkapi dengan fitur-fitur canggih seperti manajemen stok otomatis, tracking pesanan real-time, laporan penjualan yang detail, dan integrasi dengan berbagai shipping provider.

10. _Dukungan multi-currency dan multi-language_ - WooCommerce mendukung berbagai mata uang dan bahasa termasuk Bahasa Indonesia, memudahkan Anda untuk menjual produk ke pasar internasional dengan pengaturan yang fleksibel.

11. _Ekosistem plugin yang sangat kaya_ - WooCommerce memiliki ribuan plugin resmi dan pihak ketiga yang dapat memperluas fungsionalitas, mulai dari marketing automation, email marketing, affiliate program, hingga integration dengan platform pihak ketiga lainnya.

12. _Mudah diintegrasikan dengan tools marketing_ - WooCommerce dapat dengan mudah diintegrasikan dengan Google Analytics, Facebook Pixel, email marketing platform, dan berbagai tool marketing lainnya untuk membantu menganalisis dan mengoptimalkan performa penjualan.

### ⚠️ Kekurangan

Berikut adalah kekurangan-kekurangan dari woocommerece :

1. _Kompleksitas setup awal_ - Proses setup menjadi tantangan dan memakan waktu yang cukup banyak bagi orang yang tidak familiar dengan wordpress
2. _Full Technical Responsibility_ - WooComerce memerlukan tanggung jawab penuh terhadap teknikal website seperti mengelola web hosting, nama domain, keamanan, back up, serta update secara reguler
3. _Memerlukan sumber daya berat_ - WooCommerce dibangun diatas wordpress memerlukan sumber daya server yang substansial. Ini
4. _Konflik Plugin_ - WooCommerce bergantung pada sistem modular. Pembaruan pada satu plugin atau inti WordPress terkadang dapat menyebabkan masalah kompatibilitas
5. _Support team yang terpisah_ - Apabila terdapat suatu permasalahan yang dialami oleh web, tim harus melakukan komunikasi ke berbagai support team yang berbeda (Hosting, wordpress, dll)

## 🛒 Pembahasan: WooCommerce vs. Others

### PrestaShop 🛍

- ✅ Kelebihan: memiliki fitur bawaan yang lebih lengkap (laporan statistik yang detail, dll), manajemen multitoko yaitu mengelola beberapa toko dari satu panel admin jauh lebih mudah, performa lebih baik
- ⚠️ Kekurangan: jumlah add-ons tidak sebanyak WooCommerce, interface PrestaShop membutuhkan adaprasi, PrestaShop tidak seintuitif WordPress

### OpenCart 🛍

- ✅ Kelebihan: instalasi dasar yang ringan sehingga tidak membebani server, interface yang straightforward dan mudah dinavigasi, dukungan untuk multitoko
- ⚠️ Kekurangan: menemukan fungsionalitas spesifik lebih sulit, kurang ramah SEO, memiliki tantangan skalabilitas untuk puluhan ribu produk dan lalu lintas tinggi

### Magento Open Source 🛍

- ✅ Kelebihan: Magento dibangun untuk menangani ribuan produk dan lalu lintas tinggi tanpa mengorbankan performa sehingga skalabilitas dan performa superior, memiliki fitur kompleks seperti manajemen inventaris multigudang dan penetapan harga kompleks, memiliki fleksibilitas sehingga memungkinkan developer untuk mengkustomisasi hampir setiap aspek
- ⚠️ Kekurangan: kompleks dan susah dipelajari, biaya pengembangan dan hosting tinggi, manajemen sehari-hari lebih rumit

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
