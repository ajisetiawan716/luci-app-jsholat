#!/bin/sh

# Fungsi untuk membersihkan cache Luci
clean_luci_cache() {
    echo "Membersihkan cache Luci..."
    rm -f /tmp/luci-indexcache
    rm -f /tmp/luci-modulecache/*
    echo "Cache Luci telah dibersihkan."
}

# Fungsi untuk menginstall aplikasi
install_application() {
    echo "Menginstall aplikasi..."
    
    # Download file-file aplikasi dari GitHub
    wget -q -O /etc/config/jsholat https://raw.githubusercontent.com/ajisetiawan716/luci-app-jsholat/refs/heads/main/data/etc/config/jsholat
    wget -q -O /etc/init.d/jsholat https://raw.githubusercontent.com/ajisetiawan716/luci-app-jsholat/refs/heads/main/data/etc/init.d/jsholat
    wget -q -O /etc/init.d/jadwal https://raw.githubusercontent.com/ajisetiawan716/luci-app-jsholat/refs/heads/main/data/etc/init.d/jadwal
    wget -q -O /usr/bin/jsholat https://raw.githubusercontent.com/ajisetiawan716/luci-app-jsholat/refs/heads/main/data//usr/bin/jsholat
    wget -q -O /usr/bin/jadwal https://raw.githubusercontent.com/ajisetiawan716/luci-app-jsholat/refs/heads/main/data/usr/bin/jadwal
    wget -q -O /usr/bin/jadwal2 https://raw.githubusercontent.com/ajisetiawan716/luci-app-jsholat/refs/heads/main/data/usr/bin/jadwal2
    wget -q -O /usr/lib/lua/luci/controller/jsholat.lua https://raw.githubusercontent.com/ajisetiawan716/luci-app-jsholat/refs/heads/main/data/usr/lib/lua/luci/controller/jsholat.lua
    wget -q -O /usr/lib/lua/luci/model/cbi/jsholat.lua https://raw.githubusercontent.com/ajisetiawan716/luci-app-jsholat/refs/heads/main/data/usr/lib/lua/luci/model/cbi/jsholat.lua
    wget -q -O /usr/lib/lua/luci/view/jsholat/jsholat.htm https://raw.githubusercontent.com/ajisetiawan716/luci-app-jsholat/refs/heads/main/data/usr/lib/lua/luci/view/jsholat/jsholat.htm
    wget -q -O /usr/lib/lua/luci/view/jsholat/jadwal.htm https://raw.githubusercontent.com/ajisetiawan716/luci-app-jsholat/refs/heads/main/data/usr/lib/lua/luci/view/jsholat/jadwal.htm
    wget -q -O /usr/lib/lua/luci/view/jsholat/output.htm https://raw.githubusercontent.com/ajisetiawan716/luci-app-jsholat/refs/heads/main/data/usr/lib/lua/luci/view/jsholat/output.htm
    wget -q -O /usr/lib/lua/luci/view/jsholat/status_jadwal.htm https://raw.githubusercontent.com/ajisetiawan716/luci-app-jsholat/refs/heads/main/data/usr/lib/lua/luci/view/jsholat/status_jadwal.htm
    wget -q -O /usr/lib/lua/luci/view/jsholat/status_jsholat.htm https://raw.githubusercontent.com/ajisetiawan716/luci-app-jsholat/refs/heads/main/data/usr/lib/lua/luci/view/jsholat/status_jsholat.htm
    wget -q -O /usr/lib/lua/luci/view/jsholat/update_button.htm https://raw.githubusercontent.com/ajisetiawan716/luci-app-jsholat/refs/heads/main/data/usr/lib/lua/luci/view/jsholat/update_button.htm
    wget -q -O /usr/share/jsholat/cities.json https://raw.githubusercontent.com/ajisetiawan716/luci-app-jsholat/refs/heads/main/data/usr/share/jsholat/cities.json
    wget -q -O /usr/share/jsholat/last_updated.txt https://raw.githubusercontent.com/ajisetiawan716/luci-app-jsholat/refs/heads/main/data/usr/share/jsholat/last_updated.txt
    wget -q -O /root/jsholat/jadwal.txt https://raw.githubusercontent.com/ajisetiawan716/luci-app-jsholat/refs/heads/main/data/root/jsholat/jadwal.txt

    # Set permissions untuk file yang ada di folder "data"
    chmod -R 755 /usr/lib/lua/luci/controller/*
    chmod -R 755 /usr/lib/lua/luci/model/cbi/*
    chmod -R 755 /usr/lib/lua/luci/view/*
    chmod -R 755 /usr/share/jsholat/*
    chmod -R 755 /usr/bin/*
    chmod -R 755 /usr/init.d/*

    # Download file MP3 adzan dari GitHub
    echo "Sedang mengunduh file pendukung..."
    wget -q -O /root/jsholat/adzan.mp3 https://raw.githubusercontent.com/ajisetiawan716/luci-app-jsholat/refs/heads/main/sounds/adzan.mp3
    wget -q -O /root/jsholat/adzan_subuh.mp3 https://raw.githubusercontent.com/ajisetiawan716/luci-app-jsholat/refs/heads/main/sounds/adzan_subuh.mp3
    wget -q -O /root/jsholat/tahrim.mp3 https://raw.githubusercontent.com/ajisetiawan716/luci-app-jsholat/refs/heads/main/sounds/tahrim.mp3
    echo "File pendukung terunduh..."

    # Set permissions untuk file MP3
    chmod 644 /root/jsholat/adzan.mp3
    chmod 644 /root/jsholat/adzan_subuh.mp3
    chmod 644 /root/jsholat/tahrim.mp3

    # Install paket pendukung (madplay dan alsa-utils)
    install_packages() {
        # Fungsi untuk mengecek apakah paket sudah terinstal
        is_package_installed() {
            opkg list-installed | grep -q "^$1 -"
        }

        # Install paket pendukung jika belum terinstal
        if ! is_package_installed "madplay"; then
            echo "Installing madplay..."
            opkg update
            opkg install madplay
        else
            echo "madplay is already installed."
        fi

        if ! is_package_installed "alsa-utils"; then
            echo "Installing alsa-utils..."
            opkg update
            opkg install alsa-utils
        else
            echo "alsa-utils is already installed."
        fi

        if ! is_package_installed "luci-lib-json"; then
            echo "Installing luci-lib-json..."
            opkg update
            opkg install luci-lib-json
        else
            echo "luci-lib-json is already installed."
        fi
    }

    install_packages

    # Set permissions untuk script /usr/bin/jsholat
    chmod 755 /usr/bin/jsholat
    chmod 755 /usr/bin/jadwal
    chmod 755 /usr/bin/jadwal2

    # Enable dan start service jsholat
    if [ -f /etc/init.d/jsholat ]; then
        /etc/init.d/jsholat enable
        /etc/init.d/jsholat start
    fi

    # Enable dan start service jadwal
    if [ -f /etc/init.d/jadwal ]; then
        /etc/init.d/jadwal enable
        /etc/init.d/jadwal start
    fi

    # Restart layanan uhttpd dan rpcd
    /etc/init.d/uhttpd restart
    /etc/init.d/rpcd restart

    echo "Aplikasi berhasil diinstall."
}

# Fungsi untuk menghapus aplikasi
uninstall_application() {
    echo "Menghapus aplikasi..."
    
    # Hapus file-file aplikasi
    rm -f /etc/config/jsholat
    rm -f /etc/init.d/jsholat
    rm -f /etc/init.d/jadwal
    rm -f /usr/bin/jsholat
    rm -f /usr/bin/jadwal
    rm -f /usr/bin/jadwal2
    rm -f /usr/lib/lua/luci/controller/jsholat.lua
    rm -f /usr/lib/lua/luci/model/cbi/jsholat.lua
    rm -f /usr/lib/lua/luci/view/jsholat/jsholat.htm
    rm -f /usr/lib/lua/luci/view/jsholat/jadwal.htm
    rm -f /usr/lib/lua/luci/view/jsholat/output.htm
    rm -f /usr/lib/lua/luci/view/jsholat/status_jadwal.htm
    rm -f /usr/lib/lua/luci/view/jsholat/status_jsholat.htm
    rm -f /usr/lib/lua/luci/view/jsholat/update_button.htm
    rm -f /usr/share/jsholat/cities.json
    rm -f /usr/share/jsholat/last_updated.txt
    rm -f /root/jsholat/jadwal.txt
    rm -f /root/jsholat/adzan.mp3
    rm -f /root/jsholat/adzan_subuh.mp3
    rm -f /root/jsholat/tahrim.mp3

    # Hapus service jika ada
    if [ -f /etc/init.d/jsholat ]; then
        /etc/init.d/jsholat stop
        /etc/init.d/jsholat disable
        rm -f /etc/init.d/jsholat
    fi

    if [ -f /etc/init.d/jadwal ]; then
        /etc/init.d/jadwal stop
        /etc/init.d/jadwal disable
        rm -f /etc/init.d/jadwal
    fi

    echo "Aplikasi berhasil dihapus."
}

# Menu interaktif
while true; do
echo " ====================================="
echo "           JSHOLAT INSTALLER           "
echo "        Created by @ajisetiawan716        "
echo " ====================================="
echo " ====================================="
echo " ==    Choice options:             =="
echo " ==    1. Install Jsholat          =="
echo " ==    2. Delete Jsholat           =="
echo " ==    3. Exiting Script..         =="
echo " ====================================="
    read -p "Select choice (1/2/3): " choice

    case $choice in
        1)
            clean_luci_cache
            install_application
            ;;
        2)
            uninstall_application
            ;;
        3)
            echo "Keluar dari script."
            exit 0
            ;;
        *)
            echo "Pilihan tidak valid. Silakan coba lagi."
            ;;
    esac
done