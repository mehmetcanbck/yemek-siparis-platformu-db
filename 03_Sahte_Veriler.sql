-- =====================================================================================
-- ADIM 3: SAHTE VERİ (MOCK DATA) EKLENMESİ
-- =====================================================================================
-- Bu dosyada veritabanının test edilebilmesi için tüm tablolara örnek veriler girilmiştir.
-- INSERT INTO ifadeleri, ilişkisel (Foreign Key) kısıtlamalarına dikkat edilerek 
-- bağımsızdan bağımlıya doğru sırayla eklenmiştir.

-- 1. Kullanici Verileri
INSERT INTO Kullanici (AdSoyad, Email, Telefon, Rol) VALUES 
('Ahmet Yılmaz', 'ahmet@email.com', '5551234567', 'Standart'),
('Ayşe Kaya', 'ayse@email.com', '5559876543', 'Hayirsever'),
('Mehmet Demir', 'mehmet@email.com', '5551112233', 'IhtiyacSahibi'),
('Zeynep Çelik', 'zeynep@email.com', '5554445566', 'Standart');

-- 2. Restoran Verileri
INSERT INTO Restoran (Ad, Adres, Puan, ToplamCiro) VALUES
('Lezzet Lokantası', 'Merkez Mah. Atatürk Cad. No:1', 4.5, 0),
('Pizzacı Ali', 'Cumhuriyet Mah. Çiçek Sok. No:5', 4.2, 0),
('Burger Dünyası', 'İstiklal Cad. No:45', 3.8, 0);

-- 3. Kurye Verileri
INSERT INTO Kurye (AdSoyad, Telefon, Durum) VALUES
('Can Kurt', '5556667788', 'Musait'),
('Ali Hızlı', '5559998877', 'Teslimatta');

-- 4. Urun (Menü) Verileri
-- Restoran 1: Lezzet Lokantası
INSERT INTO Urun (RestoranID, Ad, Aciklama, Fiyat) VALUES
(1, 'Mercimek Çorbası', 'Sıcacık ev yapımı', 45.00),
(1, 'Kuru Fasulye', 'Pilav üstü kuru', 120.00),
-- Restoran 2: Pizzacı Ali
(2, 'Karışık Pizza', 'Büyük boy, bol malzemeli', 250.00),
(2, 'Margarita', 'Orta boy ince hamur', 180.00),
-- Restoran 3: Burger Dünyası
(3, 'Cheeseburger Menü', 'Patates ve içecek dahil', 150.00);

-- 5. Siparis Verileri
-- Sipariş 1: Ahmet Yılmaz (Standart), Lezzet Lokantası (1) -> Teslim Edildi
INSERT INTO Siparis (KullaniciID, RestoranID, KuryeID, ToplamTutar, Durum, OdemeTipi) VALUES
(1, 1, 1, 165.00, 'Teslim Edildi', 'KrediKarti');

-- Sipariş 2: Zeynep Çelik (Standart), Pizzacı Ali (2) -> Yolda
INSERT INTO Siparis (KullaniciID, RestoranID, KuryeID, ToplamTutar, Durum, OdemeTipi) VALUES
(4, 2, 2, 250.00, 'Yolda', 'KrediKarti');

-- 6. SiparisDetay Verileri
-- Sipariş 1 Detay: 1 Çorba (45), 1 Kuru Fasulye (120) = 165.00 Toplam Tutar
INSERT INTO SiparisDetay (SiparisID, UrunID, Adet, BirimFiyat) VALUES
(1, 1, 1, 45.00),
(1, 2, 1, 120.00);

-- Sipariş 2 Detay: 1 Karışık Pizza (250)
INSERT INTO SiparisDetay (SiparisID, UrunID, Adet, BirimFiyat) VALUES
(2, 3, 1, 250.00);

-- 7. AskidaYemekHavuzu Başlangıç Verisi
-- Havuzda biriken parayı tek satırda tutacağız. Başlangıçta 0 TL var.
INSERT INTO AskidaYemekHavuzu (ToplamBakiye) VALUES (0);

-- =====================================================================================
-- ASKIDA YEMEK SENARYOSU TEST VERİLERİ VE LOGLAMASI
-- =====================================================================================

-- Senaryo 1: Hayırsever (Ayşe Kaya - KullaniciID:2) Havuza 500 TL Bağış Yapar.
INSERT INTO AskidaYemekIslem (KullaniciID, IslemTipi, Tutar, SiparisID) VALUES
(2, 'Bagis', 500.00, NULL);

-- Havuz güncellenir: ToplamBakiye 500 TL oldu.
UPDATE AskidaYemekHavuzu SET ToplamBakiye = ToplamBakiye + 500.00 WHERE HavuzID = 1;

-- Senaryo 2: İhtiyaç Sahibi (Mehmet Demir - KullaniciID:3) Askıdan Ücretsiz Yemek Yer.
-- Burger Dünyasından (Restoran 3) Cheeseburger Menü (150 TL) söyler. OdemeTipi 'AskidaYemek' olur.
INSERT INTO Siparis (KullaniciID, RestoranID, KuryeID, ToplamTutar, Durum, OdemeTipi) VALUES
(3, 3, 1, 150.00, 'Teslim Edildi', 'AskidaYemek');

-- Eklenen son siparişin detayı (Mock data senaryosunda bu 3 Nolu sipariştir)
INSERT INTO SiparisDetay (SiparisID, UrunID, Adet, BirimFiyat) VALUES
(3, 5, 1, 150.00);

-- Askıdan harcama loglanır:
INSERT INTO AskidaYemekIslem (KullaniciID, IslemTipi, Tutar, SiparisID) VALUES
(3, 'Kullanim', 150.00, 3);

-- Havuzdan bakiye düşülür: 500 TL - 150 TL = 350 TL kaldı.
UPDATE AskidaYemekHavuzu SET ToplamBakiye = ToplamBakiye - 150.00 WHERE HavuzID = 1;
