// Penambahan untuk kuis
import flash.display.MovieClip;
import fl.motion.Color;

stop();
var giliranPemain:int = 1;
var waktuTunggu:int = 0;
var dataPemain:Array;

var dadu1:Object;
var dadu2:Object;
var angkaDadu:int = 0;

var giliran:giliranMC;
var pemenang:pemenangMC;

var ularTangga:Array = [];
var jumlahPetak:int = 118;
var namaPemain:Array = [" pemain 1", " pemain2", " pemain3", " pemain4"];
var jumlahPemain:int = 2;
var gameMenang:Boolean = false;
var frameGameOver:int = 2;

function lemparDadu(px:int, py:int):Object{
    var dadu:daduMC = new daduMC;
    dadu.x = px;
    dadu.y = py;
    dadu.waktu = 0;
    dadu.speed = 5;
    dadu.berhenti = false;
    dadu.nilai = 1;
    dadu.arah = 1;
    dadu.cf = Math.floor(Math.random() * 6) + 1;  // Hasil angka dadu antara 1 hingga 6
    dadu.addEventListener(Event.ENTER_FRAME, animasiDadu);
    addChild(dadu);
    return dadu;
}

function animasiDadu(e:Event):void{
    var ob:Object = e.currentTarget;
    ob.waktu++;
    ob.rotation += Math.random() * 180;
    ob.gotoAndStop(Math.ceil(Math.random() * 6)); // Untuk animasi perubahan frame dadu

    if (ob.waktu >= 60){
        ob.num = ob.currentFrame;
        ob.berhenti = true;
        ob.removeEventListener(Event.ENTER_FRAME, animasiDadu); // Hentikan animasi setelah 60 frame
    }
}

function jalankanGame():void{
    giliranPemain = 1;
    dataPemain = new Array();
    //letakkan bidak di petak 0 
    var p1:Object = getChildByName("petak1");
    for (var i:int = 0; i < jumlahPemain; i++){
        var bidak:bidakMC = new bidakMC;
        bidak.x = p1.x-100;
        bidak.y = p1.y;
        bidak.posisi = 0;
        bidak.langkah = 0;
        bidak.gotoAndStop(i+1);
        addChild(bidak);
        dataPemain.push(bidak);
    }
    tambahGiliran(1);
}

function tambahGiliran(noPemain:int):void{
    giliran = new giliranMC;
    giliran.x = 750;
    giliran.y = 300;
    giliran.vy = 30;
    giliran.status = 0;
    giliran.bidak.gotoAndStop(noPemain);
    giliran.pemainTxt.text = namaPemain[noPemain-1];
    giliran.lemparBtn.addEventListener(MouseEvent.CLICK, tutupGiliran);
    giliran.addEventListener(Event.ENTER_FRAME, animasiGiliran);
    addChild(giliran);
}

function tutupGiliran(e:MouseEvent):void{
    giliran.status = 2;
}

function animasiGiliran(e:Event):void{
    if (giliran.status == 0){
        //animasi muncul
        if (giliran.vy > 1) giliran.vy--;
        giliran.y += giliran.vy;
        if (giliran.y > 240) giliran.status = 1;
    }
    if (giliran.status == 2){
        //animasi setelah lempar dadu di klik
        giliran.vy++;
        giliran.y += giliran.vy;
        if (giliran.y > 500){
            //hapus giliran setelah keluar dari layar
            giliran.removeEventListener(Event.ENTER_FRAME, animasiGiliran);
            removeChild(giliran);
            //munculkan dadu
            dadu1 = lemparDadu(150 + Math.random() * 200, 120 + Math.random() * 150);
            addEventListener(Event.ENTER_FRAME, tungguDadu);
            waktuTunggu = 0;
        }
    }
}

function tungguDadu(e:Event):void{
    if (dadu1.berhenti){
        waktuTunggu++;
        if (waktuTunggu > 60){
            removeEventListener(Event.ENTER_FRAME, tungguDadu)
            //hapus dadu
            angkaDadu = dadu1.num;
            removeChild(DisplayObject(dadu1));
            gerakBidak(giliranPemain, angkaDadu);            
        }
    }
}

function gerakBidak(nomorPemain:int, langkah:int):void{
    var bidak:Object = dataPemain[nomorPemain-1];
    bidak.langkah = langkah;
    bidak.arah = 1;
    bidak.petakSelanjutnya = bidak.posisi + bidak.arah;
    bidak.addEventListener(Event.ENTER_FRAME, animasiBidak);
}

function animasiBidak(e:Event):void{
    var bidak:Object = e.currentTarget;
    if (bidak.langkah > 0){
        if (bidak.petakSelanjutnya <= jumlahPetak){
            var petakTujuan:Object = getChildByName("petak"+bidak.petakSelanjutnya);
            //menghitung gerakan ke petak selanjutnya
            var dx:int = petakTujuan.x - bidak.x;
            var dy:int = petakTujuan.y - bidak.y;
            var sudut:int = Math.atan2(dy, dx) * 180 / Math.PI;
            var jarak:int = Math.sqrt(dx * dx + dy * dy);
            bidak.x += 5 * Math.cos(sudut * Math.PI / 180);
            bidak.y += 5 * Math.sin(sudut * Math.PI / 180);
            //jika sudah sampai di bidak selanjutnya
            if (jarak < 10){
                bidak.x = petakTujuan.x;
                bidak.y = petakTujuan.y;
                bidak.posisi = bidak.petakSelanjutnya;
                bidak.petakSelanjutnya += bidak.arah;
                if (bidak.petakSelanjutnya > jumlahPetak){
                    bidak.petakSelanjutnya = 27;
                    bidak.arah = -1;
                }
                bidak.langkah--;
            }
        }   
    } else {
        //selesai melangkah, 
        bidak.removeEventListener(Event.ENTER_FRAME, animasiBidak);
        //cek apakah menang
        if (bidak.posisi == jumlahPetak){
            //menang
            tampilkanPemenang();
        } else {
            //cek ularTangga
            var naikTurun:Boolean = false;
            for (var i:int = 0; i < ularTangga.length; i++){
                if (bidak.posisi == ularTangga[i][0]){
                    bidak.petakSelanjutnya = ularTangga[i][1];
                    bidak.langkah = 1;
                    naikTurun = true;
                }
            }
            if (naikTurun){
                bidak.addEventListener(Event.ENTER_FRAME, animasiBidak);
            } else {
                giliranPemain++;
                if (giliranPemain > jumlahPemain) giliranPemain = 1;
                tambahGiliran(giliranPemain);
            }            
        }                
    }   
}

function tampilkanPemenang():void{
    pemenang = new pemenangMC;
    pemenang.x = 400;
    pemenang.y = -200;
    pemenang.vy = 30;
    pemenang.status = 0;
    pemenang.bidak.gotoAndStop(giliranPemain);
    pemenang.pemainTxt.text = namaPemain[giliranPemain-1];
    pemenang.homeBtn.addEventListener(MouseEvent.CLICK, tutupPemenang);
    pemenang.addEventListener(Event.ENTER_FRAME, animasiPemenang);
    addChild(pemenang);
    gameMenang = true;
}

function tutupPemenang(e:MouseEvent):void{
    pemenang.status = 2;
}

function animasiPemenang(e:Event):void{
    if (pemenang.status == 0){
        //animasi muncul
        if (pemenang.vy > 1) pemenang.vy--;
        pemenang.y += pemenang.vy;
        if (pemenang.y > 240) pemenang.status = 1;
    }
    if (pemenang.status == 2){
        //animasi menutup
        pemenang.vy++;
        pemenang.y += pemenang.vy;
        if (pemenang.y > 500){
            //hapus pemenang setelah keluar dari layar
            pemenang.removeEventListener(Event.ENTER_FRAME, animasiPemenang);
            removeChild(pemenang);
            //hapus bidak sebelum kembali ke halaman cover
            for (var i:int = 0; i < dataPemain.length; i++){
                removeChild(dataPemain[i]);
            }
            //kembali ke hal cover
            gotoAndStop(frameGameOver);
        }
    }
}



var nilai:int = 0;
var nomorSoal:int = 0;
var hasil:hasilMC;
var tempSoal:Array;
var tempJawaban:Array;
var gameAktif:Boolean = true;
var fps:int = 30; //frame per second 
var waktuSoal:int = waktuMaks*fps;
var halamanScore:int = 5;
var nilaiPemain:int = 0;

var jumlahSoal:int = 10;
var waktuMaksimum:int = 10;
var pertanyaan:Array = [["Hewan apakah pada gambar di samping ?", "Gajah", "Anjing Laut", "Zebra", "Berang-berang", 1],
				  ["Sebutkan nama hewan di samping ?", "Anjing Laut", "Zebra", "Berang-berang", "Anjing", 2],	
				  ["Hewan apakah pada gambar di samping ?", "Keledai", "Kuda", "Zebra", "Sapi", 3],
				  ["Hewan apakah pada gambar di samping ?", "Bebek", "Ayam", "Angsa", "Platipus", 4],
				  ["Tahukah kamu nama hewan di samping ?", "Anak Ayam", "Burung Elang", "Kuda", "Monyet", 5],
				  ["Hewan apakah pada gambar di samping ?", "Sapi", "Banteng", "Kerbau", "Bison", 6],
				  ["Sebutkan nama hewan di samping ?", "Anjing", "Kuda", "Tupai", "Monyet", 7],
				  ["Hewan apakah pada gambar di samping ?", "Monyet", "Kucing", "Anjing", "Orangutan", 8],
				  ["Hewan apakah pada gambar di samping ?", "Berang-berang", "Anjing Laut", "Tupai", "Monyet", 9],
				  ["Sebutkan nama hewan di samping ?", "Pinguin", "Burung", "Ayam", "Bebek", 10],
				  ["Tahukah kamu nama hewan di samping ?", "Zebra", "Keledai", "Kuda", "Okapi", 11],
				  ["Sebutkan nama hewan di samping ?", "Babi", "Kucing", "Badak", "Sapi", 12],
				  ["Hewan apakah pada gambar di samping ?", "Ayam", "Burung Hantu", "Itik", "Bebek", 13],
				  ["Hewan apakah pada gambar di samping ?", "Singa", "Harimau", "Kudanil", "Gajah", 14]];

function acakSoal():void{
    //mengacak soal
    tempSoal = soal.slice(0, soal.length);
    for (var i:int = 0; i < soal.length; i++){
        var acak:int = Math.floor(Math.random()*soal.length);
        var temp:Array = tempSoal[acak];
        tempSoal[acak] = tempSoal[i];
        tempSoal[i] = temp;
    }
}

function tampilkanSoal():void {
    // Menambahkan pengecekan untuk memastikan kuisMC tidak null
    if (kuisMC != null) {
        kuisMC.gambarMC.gotoAndStop(tempSoal[nomorSoal][5]);
        if (nomorSoal > soalMaks / 2) {
            aturWarna(kuisMC.gambarMC, -1);
        }
        // Tampilkan soal
        kuisMC.soalTxt.text = tempSoal[nomorSoal][0];
        
        // Acak jawaban
        tempJawaban = tempSoal[nomorSoal].slice(1, 5);
        for (var i:int = 0; i < tempJawaban.length; i++) {
            var acak:int = Math.floor(Math.random() * tempJawaban.length);
            var temp:String = tempJawaban[acak];
            tempJawaban[acak] = tempJawaban[i];
            tempJawaban[i] = temp;
        }

        // Tampilkan jawaban
        kuisMC.jawab1.jawabanTxt.text = tempJawaban[0];
        kuisMC.jawab2.jawabanTxt.text = tempJawaban[1];
        kuisMC.jawab3.jawabanTxt.text = tempJawaban[2];
        kuisMC.jawab4.jawabanTxt.text = tempJawaban[3];
    } else {
        trace("Error: kuisMC belum diinisialisasi!");
    }
}


function setupKuis():void{
    acakSoal();
    //mengatur jawaban
    kuisMC.jawab1.stop();
    kuisMC.jawab2.stop();
    kuisMC.jawab3.stop();
    kuisMC.jawab4.stop();
    kuisMC.jawab1.addEventListener(MouseEvent.CLICK, cekJawaban);
    kuisMC.jawab2.addEventListener(MouseEvent.CLICK, cekJawaban);
    kuisMC.jawab3.addEventListener(MouseEvent.CLICK, cekJawaban);
    kuisMC.jawab4.addEventListener(MouseEvent.CLICK, cekJawaban);
    //listener untuk efek tombol
    kuisMC.jawab1.addEventListener(MouseEvent.MOUSE_OVER, mouseOver);
    kuisMC.jawab2.addEventListener(MouseEvent.MOUSE_OVER, mouseOver);
    kuisMC.jawab3.addEventListener(MouseEvent.MOUSE_OVER, mouseOver);
    kuisMC.jawab4.addEventListener(MouseEvent.MOUSE_OVER, mouseOver);
    //mouse out
    kuisMC.jawab1.addEventListener(MouseEvent.MOUSE_OUT, mouseOut);
    kuisMC.jawab2.addEventListener(MouseEvent.MOUSE_OUT, mouseOut);
    kuisMC.jawab3.addEventListener(MouseEvent.MOUSE_OUT, mouseOut);
    kuisMC.jawab4.addEventListener(MouseEvent.MOUSE_OUT, mouseOut);    
    kuisMC.visible = false;
}

function mouseOver(e:MouseEvent):void{
    e.currentTarget.gotoAndStop(2);
}

function mouseOut(e:MouseEvent):void{
    e.currentTarget.gotoAndStop(1);
}

function cekJawaban(e:MouseEvent):void{
    if (gameAktif){
        aturWarna(kuisMC.gambarMC, 0);
        var nomorJawaban:int = int(e.currentTarget.name.substr(5))-1;
        if (tempJawaban[nomorJawaban] == tempSoal[nomorSoal][1]){
            //jawaban benar
            tampilkanHasil(1);
            nilaiPemain[giliranPemain-1]+=10;
            updateNilai();
        } else {
            //jawaban salah
            tampilkanHasil(2);
        }
    }
}

function tampilkanHasil(tp:int):void{
    hasil = new hasilMC;
    hasil.x = 600;
    hasil.y = 300;
    hasil.gotoAndStop(tp);
    hasil.scaleX = 0.2;
    hasil.scaleY = 0.2;
    hasil.waktu = 0;
    hasil.tp = tp;
    hasil.addEventListener(Event.ENTER_FRAME, efekPopup);
    addChild(hasil);
    //reset timer
    gameAktif = false;
    waktuSoal = waktuMaks*fps;
}

function efekPopup(e:Event):void{
    var ob:Object = e.currentTarget;
    if (ob.scaleX < 1){
        ob.scaleX+=0.1;
        ob.scaleY+=0.1;
    }
    if (ob.waktu > -1){
        ob.waktu++;
        if (ob.waktu > 60){        
            ob.waktu = -1;
            //tambah no soal
            nomorSoal++;
            if (nomorSoal > soal.length-1) nomorSoal = 1    
            ob.removeEventListener(Event.ENTER_FRAME, efekPopup);
            removeChild(DisplayObject(ob));
            gameAktif = true;
            kuisMC.visible = false;
            //lanjutkan game ular tangga
            if (giliranPemain > jumlahPemain) giliranPemain = 1;
            tambahGiliran(giliranPemain);
        }        
    }
}

function aturWarna(ob:MovieClip, num:int):void{
    var color:Color = new Color;
    color.brightness = num;
    ob.transform.colorTransform = color;
}

function tampilkanKuis():void{
    kuisMC.x = 600;
    kuisMC.y = 300;
    kuisMC.visible = true;
    tampilkanSoal();
    addChild(kuisMC);
}

function updateNilai():void{
    nilai1.text = String(nilaiPemain[0]);
    nilai2.text = String(nilaiPemain[1]);
}
