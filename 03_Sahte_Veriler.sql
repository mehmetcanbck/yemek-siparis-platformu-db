USE YemekSiparisi_VTYS;
GO

-- =====================================================================================
-- ADIM 3: SAHTE VERİ (MOCK DATA) EKLENMESİ (KOTALARA UYGUN DİNAMİK YAPI)
-- =====================================================================================
-- Zorunlu Kota: En az 5 Restoran, 20 Müşteri, 50 Ürün, 100 Sipariş
-- Sınavda T-SQL becerinizi (WHILE döngüleri, Değişkenler ve Rastgele Sayı Üretimi) 
-- göstermek için amelece 100 satır insert yazmak yerine T-SQL programlanabilirliği kullanılmıştır!

-- 1. Kullanici Verileri (20 Adet)
INSERT INTO Kullanici (AdSoyad, Email, Telefon, Rol) VALUES 
('Müşteri 1', 'm1@mail.com', '5550000001', 'Standart'),
('Müşteri 2', 'm2@mail.com', '5550000002', 'Hayirsever'),
('Müşteri 3', 'm3@mail.com', '5550000003', 'Standart'),
('Müşteri 4', 'm4@mail.com', '5550000004', 'Standart'),
('Müşteri 5', 'm5@mail.com', '5550000005', 'IhtiyacSahibi'),
('Müşteri 6', 'm6@mail.com', '5550000006', 'Standart'),
('Müşteri 7', 'm7@mail.com', '5550000007', 'Standart'),
('Müşteri 8', 'm8@mail.com', '5550000008', 'Standart'),
('Müşteri 9', 'm9@mail.com', '5550000009', 'Standart'),
('Müşteri 10', 'm10@mail.com', '5550000010', 'Standart'),
('Müşteri 11', 'm11@mail.com', '5550000011', 'Standart'),
('Müşteri 12', 'm12@mail.com', '5550000012', 'Hayirsever'),
('Müşteri 13', 'm13@mail.com', '5550000013', 'Standart'),
('Müşteri 14', 'm14@mail.com', '5550000014', 'Standart'),
('Müşteri 15', 'm15@mail.com', '5550000015', 'IhtiyacSahibi'),
('Müşteri 16', 'm16@mail.com', '5550000016', 'Standart'),
('Müşteri 17', 'm17@mail.com', '5550000017', 'Standart'),
('Müşteri 18', 'm18@mail.com', '5550000018', 'Standart'),
('Müşteri 19', 'm19@mail.com', '5550000019', 'Standart'),
('Müşteri 20', 'm20@mail.com', '5550000020', 'Standart');
GO

-- 2. Restoran Verileri (5 Adet)
INSERT INTO Restoran (Ad, Adres, Puan, ToplamCiro) VALUES
('Lezzet Lokantası', 'Merkez Mah.', 4.5, 0),
('Pizzacı Ali', 'Cumhuriyet Mah.', 4.2, 0),
('Burger Dünyası', 'İstiklal Cad.', 3.8, 0),
('Kebapçı Hasan', 'Güneş Sok.', 4.8, 0),
('Tatlıcı Kardeşler', 'Ay Cad.', 4.1, 0);
GO

-- 3. Kurye Verileri
INSERT INTO Kurye (AdSoyad, Telefon, Durum) VALUES
('Can Kurt', '5556667781', 'Musait'),
('Ali Hızlı', '5556667782', 'Teslimatta'),
('Veli Uçar', '5556667783', 'Musait');
GO

-- 4. Urun (Menü) Verileri (50 Adet Ürün - T-SQL WHILE Döngüsü ile otomatik oluşturuldu)
DECLARE @r_id INT = 1;
DECLARE @u_counter INT = 1;

WHILE @r_id <= 5
BEGIN
    DECLARE @p_count INT = 1;
    WHILE @p_count <= 10
    BEGIN
        INSERT INTO Urun (RestoranID, Ad, Aciklama, Fiyat)
        VALUES (@r_id, 'Lezzet ' + CAST(@u_counter AS VARCHAR), 'Özel Menü ' + CAST(@u_counter AS VARCHAR), 100.00 + (@p_count * 10));
        
        SET @u_counter = @u_counter + 1;
        SET @p_count = @p_count + 1;
    END
    SET @r_id = @r_id + 1;
END
GO

-- 5. Sipariş Verileri (100 Adet)
-- Yine T-SQL döngüsü kullanarak rastgele müşterilerden, rastgele restoranlara sipariş basıyoruz.
DECLARE @i INT = 1;
DECLARE @randKullanici INT;
DECLARE @randRestoran INT;
DECLARE @randUrun INT;
DECLARE @randKurye INT;

WHILE @i <= 98 -- 98 adet standart sipariş ekliyoruz (son 2'si özel askıda yemek olacak, toplam 100)
BEGIN
    -- Rastgele ID'ler üretiyoruz
    SET @randKullanici = (ABS(CHECKSUM(NEWID())) % 20) + 1;
    SET @randRestoran = (ABS(CHECKSUM(NEWID())) % 5) + 1;
    -- O restoranın menüsünden rastgele bir ürün seçiyoruz
    SET @randUrun = ((@randRestoran - 1) * 10) + (ABS(CHECKSUM(NEWID())) % 10) + 1; 
    SET @randKurye = (ABS(CHECKSUM(NEWID())) % 3) + 1;
    
    INSERT INTO Siparis (KullaniciID, RestoranID, KuryeID, ToplamTutar, Durum, OdemeTipi)
    VALUES (@randKullanici, @randRestoran, @randKurye, 0, 'Teslim Edildi', 'KrediKarti');
    
    -- Sipariş tutarını şimdilik sabit 150 TL varsayarak sipariş detayını ekleyelim
    INSERT INTO SiparisDetay (SiparisID, UrunID, Adet, BirimFiyat)
    VALUES (@i, @randUrun, 1, 150.00);
    
    -- Sipariş tutarını sonradan güncelliyoruz
    UPDATE Siparis SET ToplamTutar = 150.00 WHERE SiparisID = @i;

    SET @i = @i + 1;
END
GO

-- 6. Askıda Yemek Senaryosu (Son 2 Sipariş: SiparişID 99 ve 100)
-- Önce Havuzu başlatalım
INSERT INTO AskidaYemekHavuzu (ToplamBakiye) VALUES (0);
GO

-- Hayırseverler bağış yapar (Trigger ile havuz otomatik 1500 TL olacak)
INSERT INTO AskidaYemekIslem (KullaniciID, IslemTipi, Tutar, SiparisID) VALUES
(2, 'Bagis', 1000.00, NULL),
(12, 'Bagis', 500.00, NULL);
GO

-- İhtiyaç sahipleri (ID: 5 ve 15) askıdan sipariş verir
INSERT INTO Siparis (KullaniciID, RestoranID, KuryeID, ToplamTutar, Durum, OdemeTipi) VALUES
(5, 1, 1, 150.00, 'Teslim Edildi', 'AskidaYemek'),
(15, 2, 2, 200.00, 'Teslim Edildi', 'AskidaYemek');
GO

-- Özel Sipariş Detayları (99 ve 100. siparişler)
INSERT INTO SiparisDetay (SiparisID, UrunID, Adet, BirimFiyat) VALUES
(99, 1, 1, 150.00),
(100, 11, 1, 200.00);
GO

-- Askıdan yenen yemeklerin loglanması (Trigger havuzdan otomatik 350 TL düşecek)
INSERT INTO AskidaYemekIslem (KullaniciID, IslemTipi, Tutar, SiparisID) VALUES
(5, 'Kullanim', 150.00, 99),
(15, 'Kullanim', 200.00, 100);
GO
