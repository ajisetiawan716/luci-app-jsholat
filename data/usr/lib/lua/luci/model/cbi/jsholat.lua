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
local file, err = io.open("/root/jsholat/cities.json", "r")
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
function button.write(self, section)
    -- Kosongkan fungsi write karena proses sekarang dilakukan via AJAX
end

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
lihat_jadwal.inputtitle = "Lihat Jadwal"
lihat_jadwal.inputstyle = "view"
function lihat_jadwal.write(self, section)
    luci.http.redirect(luci.dispatcher.build_url("admin/services/jsholat/jadwal"))
end

return m