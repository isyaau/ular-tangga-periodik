import flash.display.MovieClip;
import fl.motion.Color;

// Variabel kuis
var nilai:int = 0;
var nomorSoal:int = 0;
var hasil:hasilMC;
var tempSoal:Array;
var tempJawaban:Array;
var gameAktif:Boolean = true;
var fps:int = 30;
var waktuSoal:int = waktuMaks * fps;
var petakAktif:int = 0;

// Fungsi untuk set petak aktif dari main game
function setPetakAktif(nomor:int):void {
    petakAktif = nomor;
    trace("Petak aktif diset ke: " + petakAktif);
}

function pilihSoalAcak(petak:int):Array {
    if (soalPetak[petak] != undefined) {
        var soalList:Array = soalPetak[petak]; // Ambil daftar soal untuk petak tersebut
        var randomIndex:int = Math.floor(Math.random() * soalList.length); // Pilih indeks acak
        return soalList[randomIndex]; // Kembalikan soal yang dipilih secara acak
    }
    return null; // Jika tidak ada soal untuk petak tersebut
}

function getSoalByPetak(nomorPetak:int):Array {
    trace("MENGAMBIL SOAL UNTUK PETAK: " + nomorPetak);
    
    // Pastikan nomorPetak berada dalam rentang yang valid
    if (nomorPetak >= 0 && nomorPetak < soalPetak.length) {
        // Pastikan soalPetak[nomorPetak] tidak null atau undefined
        if (soalPetak[nomorPetak] != null && soalPetak[nomorPetak] != undefined) {
            return soalPetak[nomorPetak];
        } else {
            trace("⚠️ Soal untuk petak " + nomorPetak + " kosong, menggunakan soal default.");
            return ["Soal untuk petak " + nomorPetak, "Jawaban A", "Jawaban B", "Jawaban C", "Jawaban D", 1];
        }
    } else {
        trace("⚠️ Nomor petak " + nomorPetak + " tidak valid.");
        return ["Soal untuk petak " + nomorPetak, "Jawaban A", "Jawaban B", "Jawaban C", "Jawaban D", 1];
    }
}




function tampilkanSoal(petak:int):void {
    petakAktif = petak;
    var soalData:Array = pilihSoalAcak(petak); // Ambil soal acak untuk petak yang aktif
    
    trace("=== MENAMPILKAN SOAL ===");
    trace("Petak: " + petak);
    trace("Soal: " + soalData[0]);
    trace("Jawaban: A:" + soalData[1] + " B:" + soalData[2] + " C:" + soalData[3] + " D:" + soalData[4]);
    
    // Cek apakah kuisMC ada
    if (!kuisMC) {
        trace("Error: kuisMC tidak ditemukan!");
        return;
    }
    
    // Set gambar soal (jika ada)
    if (kuisMC.gambarMC) {
        kuisMC.gambarMC.gotoAndStop(soalData[5] || 1); // Gambar soal, jika ada
        aturWarna(kuisMC.gambarMC, 0); // Atur warna gambar jika diperlukan
    }
    
    // Set teks soal
    if (kuisMC.soalTxt) {
        kuisMC.soalTxt.text = soalData[0]; // Menampilkan soal di UI
    }
    
    // Set pilihan jawaban
    var jawabanArray:Array = [soalData[1], soalData[2], soalData[3], soalData[4]];
    
    // Acak jawaban
    shuffle(jawabanArray);

    // Tampilkan jawaban yang sudah diacak
    if (kuisMC.jawab1 && kuisMC.jawab1.jawabanTxt) {
        kuisMC.jawab1.jawabanTxt.text = jawabanArray[0];
    }
    if (kuisMC.jawab2 && kuisMC.jawab2.jawabanTxt) {
        kuisMC.jawab2.jawabanTxt.text = jawabanArray[1];
    }
    if (kuisMC.jawab3 && kuisMC.jawab3.jawabanTxt) {
        kuisMC.jawab3.jawabanTxt.text = jawabanArray[2];
    }
    if (kuisMC.jawab4 && kuisMC.jawab4.jawabanTxt) {
        kuisMC.jawab4.jawabanTxt.text = jawabanArray[3];
    }
    
    // Simpan jawaban untuk pengecekan (menggunakan urutan yang baru diacak)
    tempJawaban = jawabanArray;
    tempSoal = soalData;
}


// Fungsi untuk mengacak elemen-elemen dalam array
function shuffle(array:Array):void {
    for (var i:int = array.length - 1; i > 0; i--) {
        var j:int = Math.floor(Math.random() * (i + 1));
        var temp:* = array[i];
        array[i] = array[j];
        array[j] = temp;
    }
}



function setupKuis():void {
    // Cek apakah kuisMC ada di stage
    if (!kuisMC) {
        trace("Warning: kuisMC tidak ditemukan di stage");
        return;
    }
    
    trace("Setup kuis berhasil");
    
    // Setup komponen jawaban
    kuisMC.jawab1.stop();
    kuisMC.jawab2.stop();
    kuisMC.jawab3.stop();
    kuisMC.jawab4.stop();
    
    // Event listener untuk jawaban
    kuisMC.jawab1.addEventListener(MouseEvent.CLICK, cekJawaban);
    kuisMC.jawab2.addEventListener(MouseEvent.CLICK, cekJawaban);
    kuisMC.jawab3.addEventListener(MouseEvent.CLICK, cekJawaban);
    kuisMC.jawab4.addEventListener(MouseEvent.CLICK, cekJawaban);
    
    // Mouse effects
    kuisMC.jawab1.addEventListener(MouseEvent.MOUSE_OVER, mouseOver);
    kuisMC.jawab2.addEventListener(MouseEvent.MOUSE_OVER, mouseOver);
    kuisMC.jawab3.addEventListener(MouseEvent.MOUSE_OVER, mouseOver);
    kuisMC.jawab4.addEventListener(MouseEvent.MOUSE_OVER, mouseOver);
    
    kuisMC.jawab1.addEventListener(MouseEvent.MOUSE_OUT, mouseOut);
    kuisMC.jawab2.addEventListener(MouseEvent.MOUSE_OUT, mouseOut);
    kuisMC.jawab3.addEventListener(MouseEvent.MOUSE_OUT, mouseOut);
    kuisMC.jawab4.addEventListener(MouseEvent.MOUSE_OUT, mouseOut);
    
    kuisMC.visible = false;
}

function mouseOver(e:MouseEvent):void {
    e.currentTarget.gotoAndStop(2);
}

function mouseOut(e:MouseEvent):void {
    e.currentTarget.gotoAndStop(1);
}

function cekJawaban(e:MouseEvent):void {
    if (!gameAktif) return;
    gameAktif = false; 

    // Ambil jawaban yang dipilih
    var nomorJawaban:int = int(e.currentTarget.name.substr(5)) - 1;
    var jawabanDipilih:String = tempJawaban[nomorJawaban];
    var jawabanBenar:String = tempSoal[1]; // selalu di index 1

    trace("=== CEK JAWABAN ===");
    trace("Petak: " + petakAktif);
    trace("Jawaban dipilih: " + jawabanDipilih);
    trace("Jawaban benar: " + jawabanBenar);

    // Beri poin +5 atau −5
    if (jawabanDipilih == jawabanBenar) {
        trace("✓ JAWABAN BENAR!");
        tampilkanHasil(1); // Frame "Benar"
        nilaiPemain[giliranPemain - 1] += 5;
    } else {
        trace("✗ JAWABAN SALAH!");
        tampilkanHasil(2); // Frame "Salah"
        nilaiPemain[giliranPemain - 1] -= 5;
    }

    // Perbarui tampilan dan cek menang
    updateNilai();
    checkEndByScore();
}


function tampilkanHasil(tp:int):void {
    hasil = new hasilMC();
    hasil.x = 600;
    hasil.y = 300;
    hasil.gotoAndStop(tp);
    hasil.scaleX = 0.2;
    hasil.scaleY = 0.2;
    hasil.waktu = 0;
    hasil.tp = tp;
    hasil.addEventListener(Event.ENTER_FRAME, efekPopup);
    addChild(hasil);
}

function efekPopup(e:Event):void {
    var ob:Object = e.currentTarget;
    
    // Animasi popup
    if (ob.scaleX < 1) {
        ob.scaleX += 0.1;
        ob.scaleY += 0.1;
    }
    
    // Timer untuk menutup popup
    if (ob.waktu > -1) {
        ob.waktu++;
        if (ob.waktu > 60) { // Tampil selama 2 detik
            ob.waktu = -1;
            ob.removeEventListener(Event.ENTER_FRAME, efekPopup);
            removeChild(DisplayObject(ob));
            
            // Tutup kuis dan lanjutkan game
            tutupKuis();
        }
    }
}

function tutupKuis():void {
    if (kuisMC) {
        kuisMC.visible = false;
    }
    
    gameAktif = true;
    
    // Lanjutkan ke pemain berikutnya
    giliranPemain++;
    if (giliranPemain > jumlahPemain) {
        giliranPemain = 1;
    }
    
    // Tambah giliran berikutnya jika game belum selesai
    if (!gameMenang) {
        tambahGiliran(giliranPemain);
    }
}

function aturWarna(ob:MovieClip, num:int):void {
    var color:Color = new Color();
    color.brightness = num;
    ob.transform.colorTransform = color;
}

function tampilkanKuis(petak:int):void {
    if (!kuisMC) {
        trace("Error: kuisMC tidak tersedia!");
        return;
    }

    // Tampilkan soal sesuai petak aktif
    tampilkanSoal(petak);  // Panggil tampilkanSoal dengan argumen petak

    // Posisikan dan tampilkan kuis
    kuisMC.x = 600;
    kuisMC.y = 300;
    kuisMC.visible = true;

    // Tambahkan ke stage jika belum ada
    if (!contains(kuisMC)) {
        addChild(kuisMC);
    }

    trace("Kuis ditampilkan untuk petak: " + petak);
}

/**
 * Cek apakah pemain saat ini sudah mencapai 100 poin.
 * Jika ya, tandai game sebagai selesai dan tampilkan pemenang.
 */
function checkEndByScore():void {
    if (nilaiPemain[giliranPemain - 1] >= 100) {
        gameMenang = true;
        tampilkanPemenang();
    }
}


function updateNilai():void {
    // Update tampilan nilai jika text field tersedia
    if (this["nilai1"]) {
        this["nilai1"].text = String(nilaiPemain[0]);
    }
    if (this["nilai2"]) {
        this["nilai2"].text = String(nilaiPemain[1]);
    }
    
    trace("Nilai diupdate - P1:" + nilaiPemain[0] + " P2:" + nilaiPemain[1]);
}

// Fungsi testing untuk debug
function testSoalPetak(nomorPetak:int):void {
    trace("=== TEST SOAL PETAK " + nomorPetak + " ===");
    setPetakAktif(nomorPetak);
    tampilkanKuis(petakAktif)
}