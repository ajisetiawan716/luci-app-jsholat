module("luci.controller.jsholat", package.seeall)

function index()
    -- Entry utama untuk halaman jadwal sholat
    entry({"admin", "services", "jsholat"}, cbi("jsholat"), _("Jadwal Sholat"), 60)

    -- Entry untuk halaman pengaturan jadwal
    entry({"admin", "services", "jsholat", "setting_jadwal"}, cbi("jsholat"), _("Pengaturan Jadwal"), 70)

    -- Entry untuk halaman lihat jadwal
    entry({"admin", "services", "jsholat", "jadwal"}, call("action_jadwal"), _("Lihat Jadwal"), 80)

    -- Entry untuk pembaruan jadwal via AJAX
    entry({"admin", "services", "jsholat", "update"}, call("action_update")).leaf = true
end

function action_jadwal()
    -- Membaca nilai file_jadwal dari konfigurasi UCI
    local uci = luci.model.uci.cursor()
    local file_path = uci:get("jsholat", "setting", "file_jadwal") or "/root/jsholat/jadwal.txt"

    -- Inisialisasi variabel untuk pesan error dan data jadwal
    local error_message = nil
    local jadwal = {}

    -- Coba buka file
    local file, err = io.open(file_path, "r")
    if not file then
        error_message = "File jadwal tidak ditemukan: " .. err
    else
        -- Baca isi file
        local content = file:read("*all")
        file:close()

        if content == "" then
            error_message = "File jadwal kosong"
        else
            -- Parsing isi file
            for line in content:gmatch("[^\r\n]+") do
                table.insert(jadwal, line)
            end

            if #jadwal == 0 then
                error_message = "Format file jadwal tidak sesuai"
            end
        end
    end

    -- Dapatkan nama kota dari konfigurasi UCI
    local cityName = uci:get("jsholat", "setting", "city_label") or "Kota Tidak Diketahui"

    -- Baca isi file last_updated.txt
    local lastUpdatedFile = io.open("/root/jsholat/last_updated.txt", "r")
    local lastUpdated = "Terakhir diperbarui: Informasi tidak tersedia"
    if lastUpdatedFile then
        lastUpdated = lastUpdatedFile:read("*a")
        lastUpdatedFile:close()
    end

    -- Dapatkan tanggal hari ini dalam format DD-MM-YYYY
    local today = os.date("%d-%m-%Y")

    -- Dapatkan bulan dan tahun dari tanggal hari ini
    local day, month, year = today:match("(%d+)-(%d+)-(%d+)")
    local monthNames = {
        "Januari", "Februari", "Maret", "April", "Mei", "Juni",
        "Juli", "Agustus", "September", "Oktober", "November", "Desember"
    }
    local monthName = monthNames[tonumber(month)]

    -- Fungsi untuk memvalidasi format waktu (HH:MM)
    local function isValidTime(time)
        return time and time:match("^%d%d:%d%d$")
    end

    -- Fungsi untuk mendapatkan waktu sholat berikutnya
    local function getNextPrayerTime()
        local now = os.time()
        local nextPrayerTime = nil
        local nextPrayerName = nil

        -- Loop melalui jadwal sholat untuk menemukan waktu sholat berikutnya
        for _, line in ipairs(jadwal) do
            local date, imsyak, subuh, dzuhur, ashar, maghrib, isya = line:match("(.+)%s+(.+)%s+(.+)%s+(.+)%s+(.+)%s+(.+)%s+(.+)")
            if date == today then
                local prayerTimes = {
                    {name = "Imsyak", time = imsyak},
                    {name = "Subuh", time = subuh},
                    {name = "Dzuhur", time = dzuhur},
                    {name = "Ashar", time = ashar},
                    {name = "Maghrib", time = maghrib},
                    {name = "Isya", time = isya}
                }

                for _, prayer in ipairs(prayerTimes) do
                    if isValidTime(prayer.time) then
                        local prayerTime = os.time({year=tonumber(year), month=tonumber(month), day=tonumber(day), hour=tonumber(prayer.time:sub(1, 2)), min=tonumber(prayer.time:sub(4, 5)), sec=0})
                        if prayerTime > now then
                            if not nextPrayerTime or prayerTime < nextPrayerTime then
                                nextPrayerTime = prayerTime
                                nextPrayerName = prayer.name
                            end
                        end
                    end
                end
            end
        end

        return nextPrayerTime, nextPrayerName
    end

    local nextPrayerTime, nextPrayerName = getNextPrayerTime()

    -- Render template dengan semua data yang diperlukan
    luci.template.render("jsholat/jadwal", {
        error_message = error_message,
        jadwal = jadwal,
        cityName = cityName,
        lastUpdated = lastUpdated,
        today = today,
        monthName = monthName,
        year = year,
        nextPrayerTime = nextPrayerTime,
        nextPrayerName = nextPrayerName
    })
end

function action_update()
    -- Ambil sumber jadwal dari konfigurasi UCI
    local uci = luci.model.uci.cursor()
    local source = uci:get("jsholat", "setting", "source") or "aladhan"
    local script = (source == "jadwalsholat") and "/usr/bin/jadwal2" or "/usr/bin/jadwal"

    -- Jalankan script dan tangkap outputnya
    local handle = io.popen(script .. " 2>&1")
    local output = ""
    for line in handle:lines() do
        output = output .. line .. "<br>"
    end
    handle:close()

    -- Kirim output sebagai respons
    luci.http.prepare_content("text/html")
    luci.http.write(output)
end