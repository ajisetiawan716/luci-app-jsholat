m = Map("jsholat", "Pengaturan Jadwal Sholat")
m.title = translate("Pengaturan Jadwal Shalat")
m.description = translate("Untuk mengatur jadwal sholat dan mengatur suara adzan.<br><br>"..
"1. Pengaturan Jadwal: Untuk mengatur jadwal sholat berdasarkan nama kota/wilayah beserta durasi setiap jadwal diperbarui.<br>" ..
"2. Lihat Jadwal: Untuk melihat jadwal sholat saat ini.<br>"..
"3. Pengaturan Suara: Untuk mengatur penyimpanan jadwal, mengatur suara adzan.<br>"..
[[<br/><br/><a href="https://github.com/ajisetiawan716" target="_blank">Powered by ajisetiawan716</a>]])

-- Section untuk pengaturan jadwal
s = m:section(TypedSection, "global", "Pengaturan Jadwal")
s.anonymous = true

-- Opsi untuk memilih sumber jadwal
source = s:option(ListValue, "source", "Sumber Jadwal Sholat")
source:value("jadwalsholat", "JadwalSholat.Org")  -- Jika memilih JadwalSholat.Org, jalankan /usr/bin/jadwal2
source:value("aladhan", "Aladhan")              -- Jika memilih Aladhan, jalankan /usr/bin/jadwal
source.default = "jadwalsholat"  -- Nilai default

-- Opsi untuk kota
local json = require("luci.json")  -- Pastikan modul JSON tersedia di sistem Anda
local cities = {}  -- Inisialisasi tabel kosong untuk kota
local city_label_map = {}  -- Untuk memetakan value ke label

-- Coba buka file JSON
local file, err = io.open("/usr/share/jsholat/cities.json", "r")
if not file then
    -- Jika file tidak ditemukan, tampilkan pesan error dan lanjutkan
    m.description = m.description .. "<br><br><strong style='color: red;'>Error: File cities.json tidak ditemukan!</strong>"
else
    -- Baca dan decode JSON
    local content = file:read("*a")
    file:close()
    local status, decoded = pcall(json.decode, content)
    if not status then
        -- Jika JSON tidak valid, tampilkan pesan error dan lanjutkan
        m.description = m.description .. "<br><br><strong style='color: red;'>Error: File cities.json tidak valid!</strong>"
    else
        cities = decoded  -- Gunakan data JSON yang valid
    end
end

-- Tambahkan opsi kota
city = s:option(ListValue, "city", "Kota")
if #cities == 0 then
    -- Jika tidak ada data kota, tambahkan pesan default
    city:value("none", "Tidak ada data kota yang tersedia")
else
    for _, city_data in ipairs(cities) do
        city:value(city_data.value, city_data.label)  -- Menambahkan setiap kota ke dropdown
        city_label_map[city_data.value] = city_data.label  -- Simpan mapping value ke label
    end
end
city.default = "brebes"  -- Nilai default (opsional)

function city.write(self, section, value)
    self.map:set(section, "city", value)
    local city_label = city_label_map[value]
    if city_label then
        self.map:set(section, "city_label", city_label)
    end
end

-- Opsi untuk negara
country = s:option(Value, "country", "Negara")
country.datatype = "string"
country.placeholder = "Contoh: Indonesia"

-- Opsi untuk metode perhitungan
method = s:option(ListValue, "method", "Metode Perhitungan")
method:value("20", "KEMENAG RI")
method:value("2", "ISNA")
method:value("3", "MWL")
method:value("4", "Makkah")
method:value("5", "Egypt")
method.default = "20"

-- Opsi untuk interval pembaruan
interval = s:option(ListValue, "interval", "Interval Pembaruan")
interval:value("0", "Tidak Otomatis")
interval:value("3600", "Setiap Jam")
interval:value("86400", "Setiap Hari")
interval.default = "0"

-- Tombol untuk menjalankan pembaruan manual
button = s:option(Button, "_button", "")
button.inputtitle = "Perbarui Jadwal Sekarang"
button.inputstyle = "apply"
button:depends("source", "jadwalsholat")  -- Hanya tampilkan jika sumber jadwal adalah JadwalSholat.Org
button:depends("source", "aladhan")      -- Hanya tampilkan jika sumber jadwal adalah Aladhan

-- Elemen untuk menampilkan output
output = s:option(DummyValue, "_output", "Output Pembaruan")
output.template = "jsholat/output"  -- Gunakan template khusus untuk output

-- Section untuk pengaturan file suara
s2 = m:section(TypedSection, "global", "Pengaturan File Suara")
s2.anonymous = true

file_jadwal = s2:option(Value, "file_jadwal", "File Jadwal")
file_jadwal.datatype = "file"
file_jadwal.placeholder = "/root/jsholat/jadwal.txt"

sound_adzan = s2:option(Value, "sound_adzan", "File Suara Adzan")
sound_adzan.datatype = "file"
sound_adzan.placeholder = "/root/jsholat/adzan.mp3"

sound_adzan_shubuh = s2:option(Value, "sound_adzan_shubuh", "File Suara Adzan Subuh")
sound_adzan_shubuh.datatype = "file"
sound_adzan_shubuh.placeholder = "/root/jsholat/adzan_subuh.mp3"

sound_adzan_imsy = s2:option(Value, "sound_adzan_imsy", "File Suara Imsak")
sound_adzan_imsy.datatype = "file"
sound_adzan_imsy.placeholder = "/root/jsholat/tahrim.mp3"

lihat_jadwal = s2:option(Button, "_jadwal", "Lihat Jadwal")
lihat_jadwal.inputtitle = "Lihat Jadwal Sholat"
lihat_jadwal.inputstyle = "view"
function lihat_jadwal.write(self, section)
    luci.http.redirect(luci.dispatcher.build_url("admin/services/jsholat/jadwal"))
end

-- Section untuk pengaturan service
s3 = m:section(TypedSection, "global", "Pengaturan Service")
s3.anonymous = true

-- Fungsi untuk memeriksa nilai interval jadwal
function check_interval()
    local handle = io.popen("uci get jsholat.setting.interval")
    local interval = tonumber(handle:read("*a"))
    handle:close()
    return interval
end

-- Definisikan pesan konfirmasi di awal
restart_jadwal_msg = s3:option(DummyValue, "_restart_jadwal_msg", "Pesan Restart Jadwal")
restart_jadwal_msg.value = "Belum ada perintah yang dijalankan."

-- Cek nilai interval sebelum membuat tombol
if check_interval() ~= 0 then
    -- Tombol untuk restart service jadwal
    restart_jadwal = s3:option(Button, "_restart_jadwal", "Restart Service Jadwal")
    restart_jadwal.inputtitle = "Restart Service Jadwal"
    restart_jadwal.inputstyle = "apply"

    function restart_jadwal.write(self, section)
        -- Jalankan perintah restart
        os.execute("/etc/init.d/jadwal restart")
        -- Set pesan konfirmasi
        restart_jadwal_msg.value = "Service Jadwal telah di-restart pada " .. os.date("%Y-%m-%d %H:%M:%S")
    end
else
    -- Jika interval adalah 0, tampilkan pesan bahwa tombol tidak tersedia
    restart_jadwal_msg.value = "Restart jadwal dinonaktifkan"
end

-- Tombol untuk restart service jsholat
restart_jsholat = s3:option(Button, "_restart_jsholat", "Restart Service Jsholat")
restart_jsholat.inputtitle = "Restart Service Jsholat"
restart_jsholat.inputstyle = "apply"
function restart_jsholat.write(self, section)
    os.execute("/etc/init.d/jsholat restart")
    restart_jsholat_msg.value = "Service Jsholat telah di-restart"
end

-- Pesan konfirmasi
restart_jsholat_msg = s3:option(DummyValue, "_restart_jsholat_msg", "Pesan Restart Jsholat")
restart_jsholat_msg.value = "Belum ada perintah.."

-- Status service jadwal
status_jadwal = s3:option(DummyValue, "_status_jadwal", "Status Service Jadwal")
status_jadwal.template = "jsholat/status_jadwal"  -- Gunakan template khusus untuk status
status_jadwal.description = "Status: "  -- Menambahkan keterangan teks "Status"

-- Status service jsholat
status_jsholat = s3:option(DummyValue, "_status_jsholat", "Status Service Jsholat")
status_jsholat.template = "jsholat/status_jsholat"  -- Gunakan template khusus untuk status
status_jsholat.description = "Status: "  -- Menambahkan keterangan teks "Status"

-- Opsi untuk mengaktifkan atau menonaktifkan service jsholat
service_jsholat = s3:option(ListValue, "service", "Status Service Jsholat")
service_jsholat:value("1", "ON")
service_jsholat:value("0", "OFF")
service_jsholat.default = "1"

-- Fungsi untuk mengaktifkan/menonaktifkan service saat nilai berubah
local sys = require "luci.sys"

function service_jsholat.write(self, section, value)
    -- Simpan nilai ke konfigurasi
    self.map:set(section, "service", value)

    -- Jalankan atau hentikan service berdasarkan nilai
    if value == "0" then
        sys.call("sudo /etc/init.d/jsholat stop>/dev/null 2>&1")
    else
        sys.call("sudo /etc/init.d/jsholat start >/dev/null 2>&1")
    end
end

return m