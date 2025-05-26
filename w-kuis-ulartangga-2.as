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
	dadu.cf = Math.floor(Math.random()*50);
	dadu.addEventListener(Event.ENTER_FRAME, animasiDadu);
	addChild(dadu);
	return dadu;
}

function animasiDadu(e:Event):void{
	var ob:Object = e.currentTarget;
	ob.waktu++;
	ob.rotation+=Math.random()*180;
	ob.gotoAndStop(Math.ceil(Math.random()*6));
	if (ob.waktu >= 60){
		ob.num = ob.currentFrame;
		ob.berhenti = true;
		ob.removeEventListener(Event.ENTER_FRAME, animasiDadu);
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
			dadu1 = lemparDadu(150+Math.random()*200, 120+Math.random()*150);
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
			var sudut:int = Math.atan2(dy, dx)*180/Math.PI;
			var jarak:int = Math.sqrt(dx*dx + dy*dy);
			bidak.x += 5*Math.cos(sudut*Math.PI/180);
			bidak.y += 5*Math.sin(sudut*Math.PI/180);
			//jika sudah sampai di bidak selanjutnya
			if (jarak < 10){
				bidak.x = petakTujuan.x;
				bidak.y = petakTujuan.y;
				bidak.posisi = bidak.petakSelanjutnya;
				bidak.petakSelanjutnya+=bidak.arah;
				if (bidak.petakSelanjutnya > jumlahPetak){
					bidak.petakSelanjutnya = 27;
					bidak.arah = -1;
				}
				bidak.langkah--;
			}
		}	
	}else{
		//selesai melangkah, 
		bidak.removeEventListener(Event.ENTER_FRAME, animasiBidak);
		//cek apakah menang
		if (bidak.posisi == jumlahPetak){
			//menang
			tampilkanPemenang();
		}else{
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
			}else{
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