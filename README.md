# luci-app-jsholat
---

# **luci-app-jsholat**

`luci-app-jsholat` adalah aplikasi OpenWRT yang menyediakan fitur jadwal sholat dengan notifikasi suara adzan. Aplikasi ini menggunakan `madplay` untuk memainkan file MP3 adzan dan memiliki dua skrip untuk memperbarui jadwal sholat secara manual: `jadwal` dan `jadwal2`.

---

## **Fitur**

- Menampilkan jadwal sholat di antarmuka Luci.
- Memainkan suara adzan saat waktu sholat tiba.
- Memperbarui jadwal sholat secara manual menggunakan perintah `jadwal` atau `jadwal2`.
- Service otomatis untuk menjalankan aplikasi saat boot.

---

## **Panduan Instalasi**

### **1. Persyaratan**

- Perangkat dengan OpenWRT terinstal.
- Koneksi internet untuk mengunduh file dari GitHub.
- Paket pendukung: `madplay` dan `alsa-utils`.

### **2. Langkah-Langkah Instalasi**

#### **a. Download Paket**

1. Buka terminal di perangkat OpenWRT.
2. Download paket `.ipk` dari GitHub:
   
   ```bash
   wget https://github.com/ajisetiawan716/repo/releases/download/v1.0/luci-app-jsholat_1.0_all.ipk
   ```

#### **b. Install Paket**

1. Install paket menggunakan `opkg`:
   
   ```bash
   opkg install luci-app-jsholat_1.0_all.ipk
   ```
2. Pastikan semua dependensi terinstal:
   
   ```bash
   opkg update
   opkg install madplay alsa-utils
   ```

#### **c. Restart Service**

1. Restart service `uhttpd` dan `rpcd`:
   
   ```bash
   /etc/init.d/uhttpd restart
   /etc/init.d/rpcd restart
   ```

#### **d. Verifikasi Instalasi**

1. Buka antarmuka Luci di browser (biasanya di `http://192.168.1.1`).
2. Pastikan aplikasi `jsholat` muncul di menu Luci > Service dan periksa Jadwal Sholat.
3. Periksa status service:
   
   ```bash
   /etc/init.d/jsholat status
   /etc/init.d/jadwal status
   ```

---

## **Cara Menggunakan**

### **1. Memperbarui Jadwal Sholat Secara Manual**

Untuk memperbarui jadwal sholat secara manual, jalankan salah satu perintah berikut di terminal:

- Menggunakan perintah `jadwal`:
  
  ```bash
  jadwal
  ```

- Menggunakan perintah `jadwal2`:
  
  ```bash
  jadwal2
  ```

Kedua perintah ini akan memperbarui jadwal sholat berdasarkan lokasi dan waktu yang ditentukan.

### **2. Memeriksa Jadwal Sholat**

- Untuk melihat jadwal sholat yang sudah diperbarui, buka antarmuka Luci dan navigasikan ke menu `jsholat`.

### **3. Memainkan Suara Adzan**

- Suara adzan akan otomatis diputar saat waktu sholat tiba. Pastikan file MP3 adzan (`adzan.mp3`) ada di `/usr/share/sounds/`.

---

## **Struktur File Aplikasi**

Berikut adalah struktur file aplikasi yang diinstal:

```
/usr/bin/
├── jsholat          # Script utama untuk memainkan adzan
├── jadwal           # Script untuk memperbarui jadwal sholat (versi 1)
└── jadwal2          # Script untuk memperbarui jadwal sholat (versi 2)

/etc/init.d/
├── jsholat          # Service untuk menjalankan aplikasi jsholat
└── jadwal           # Service untuk memperbarui jadwal sholat

/usr/share/sounds/
└── adzan.mp3        # File suara adzan

/usr/lib/lua/luci/
├── controller/      # File controller untuk antarmuka Luci
├── model/cbi/       # File model CBI untuk konfigurasi
└── view/            # File view untuk tampilan Luci
```

---

## **Cara Update Aplikasi**

1. Download versi terbaru dari GitHub:
   
   ```bash
   wget https://github.com/ajisetiawan716/repo/releases/download/v2.0/luci-app-jsholat_2.0_all.ipk
   ```
2. Install ulang paket:
   
   ```bash
   opkg install --force-reinstall luci-app-jsholat_2.0_all.ipk
   ```

---

## **Cara Uninstall**

1. Hapus paket menggunakan `opkg`:
   
   ```bash
   opkg remove luci-app-jsholat
   ```
2. Hapus file yang tidak terhapus otomatis (jika ada):
   
   ```bash
   rm -rf /usr/bin/jsholat /usr/bin/jadwal /usr/bin/jadwal2 /etc/init.d/jsholat /etc/init.d/jadwal /usr/share/sounds/adzan.mp3
   ```

---

## **Catatan**

- Pastikan perangkat memiliki koneksi internet saat menjalankan perintah `jadwal` atau `jadwal2` untuk memperbarui jadwal sholat.
- Jika suara adzan tidak terdengar, periksa konfigurasi ALSA dan pastikan `madplay` terinstal dengan benar.

---

## **Lisensi**

Aplikasi ini dilisensikan di bawah [Lisensi MIT](LICENSE).



---