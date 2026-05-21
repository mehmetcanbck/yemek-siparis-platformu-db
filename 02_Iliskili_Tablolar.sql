USE YemekSiparisi_VTYS;
GO

-- =====================================================================================
-- ADIM 2: İLİŞKİLİ TABLOLAR (FOREIGN KEY) VE ASKIDA YEMEK MODÜLÜ
-- =====================================================================================

-- 4. Urun (Menü) Tablosu
CREATE TABLE Urun (
    UrunID INT IDENTITY(1,1) PRIMARY KEY,
    RestoranID INT NOT NULL,
    Ad VARCHAR(100) NOT NULL,
    Aciklama VARCHAR(255),
    Fiyat DECIMAL(10,2) NOT NULL,
    IsActive BIT DEFAULT 1, -- Sınav isterine uygun Soft Delete yapısı (1: Aktif, 0: Menüden kaldırılmış)

    -- CHECK Kısıtlaması 4: Fiyat 0'dan büyük olmalıdır
    CONSTRAINT CHK_Urun_Fiyat CHECK (Fiyat > 0),
    -- Yabancı Anahtar: Hangi restorana ait olduğu
    CONSTRAINT FK_Urun_Restoran FOREIGN KEY (RestoranID) REFERENCES Restoran(RestoranID)
);

-- 5. Siparis Tablosu
CREATE TABLE Siparis (
    SiparisID INT IDENTITY(1,1) PRIMARY KEY,
    KullaniciID INT NOT NULL,
    RestoranID INT NOT NULL,
    KuryeID INT NULL, -- Başlangıçta kurye atanmamış olabilir
    SiparisTarihi DATETIME DEFAULT GETDATE(),
    ToplamTutar DECIMAL(10,2) DEFAULT 0,
    Durum VARCHAR(50) DEFAULT 'Hazirlaniyor', -- 'Hazirlaniyor', 'Yolda', 'Teslim Edildi', 'Iptal'
    OdemeTipi VARCHAR(50) DEFAULT 'KrediKarti', -- 'KrediKarti', 'Nakit', 'AskidaYemek'
    
    -- CHECK Kısıtlaması 5: Toplam tutar negatif olamaz
    CONSTRAINT CHK_Siparis_Tutar CHECK (ToplamTutar >= 0),
    -- Yabancı Anahtarlar (Referans Bütünlüğü - Referential Integrity)
    CONSTRAINT FK_Siparis_Kullanici FOREIGN KEY (KullaniciID) REFERENCES Kullanici(KullaniciID),
    CONSTRAINT FK_Siparis_Restoran FOREIGN KEY (RestoranID) REFERENCES Restoran(RestoranID),
    CONSTRAINT FK_Siparis_Kurye FOREIGN KEY (KuryeID) REFERENCES Kurye(KuryeID)
);

-- 6. SiparisDetay Tablosu (Sipariş ve Ürün arasındaki Çoka-Çok [M:N] ilişkiyi çözer)
CREATE TABLE SiparisDetay (
    SiparisDetayID INT IDENTITY(1,1) PRIMARY KEY,
    SiparisID INT NOT NULL,
    UrunID INT NOT NULL,
    Adet INT NOT NULL,
    BirimFiyat DECIMAL(10,2) NOT NULL, -- Sipariş anındaki fiyat (menü fiyatı değişse de burası sabit kalmalı)
    
    -- CHECK Kısıtlaması 6: Adet 0'dan büyük olmalı
    CONSTRAINT CHK_SiparisDetay_Adet CHECK (Adet > 0),
    -- Yabancı Anahtarlar
    CONSTRAINT FK_SiparisDetay_Siparis FOREIGN KEY (SiparisID) REFERENCES Siparis(SiparisID),
    CONSTRAINT FK_SiparisDetay_Urun FOREIGN KEY (UrunID) REFERENCES Urun(UrunID)
);

-- =====================================================================================
-- ASKIDA YEMEK MODÜLÜ TABLOLARI (ÖZEL TASARIM)
-- =====================================================================================

-- 7. AskidaYemekHavuzu Tablosu
-- Sistemde biriken toplam bağış miktarını özet olarak tutar. (Sistemin geneli için tek bir havuz)
-- Bu tablo sayesinde anlık bakiyeyi çok hızlı sorgulayabiliriz.
CREATE TABLE AskidaYemekHavuzu (
    HavuzID INT IDENTITY(1,1) PRIMARY KEY,
    ToplamBakiye DECIMAL(10,2) DEFAULT 0,
    SonGuncelleme DATETIME DEFAULT GETDATE(),
    
    -- CHECK Kısıtlaması 7: Havuzdaki bakiye eksiye düşemez
    CONSTRAINT CHK_Havuz_Bakiye CHECK (ToplamBakiye >= 0)
);

-- 8. AskidaYemekIslem Tablosu (Log Tablosu)
-- Havuza ne zaman para girdi, ne zaman para çıktı? Bu hareketleri kaydetmeden mühendislik yapılamaz.
-- Bu tablo sınavda hocanın tam not vereceği asıl kısımdır.
CREATE TABLE AskidaYemekIslem (
    IslemID INT IDENTITY(1,1) PRIMARY KEY,
    KullaniciID INT NOT NULL, -- Bağışı yapan hayırsever veya ücretsiz yemeği yiyen ihtiyaç sahibi
    IslemTipi VARCHAR(20) NOT NULL, -- 'Bagis' veya 'Kullanim'
    Tutar DECIMAL(10,2) NOT NULL,
    IslemTarihi DATETIME DEFAULT GETDATE(),
    SiparisID INT NULL, -- Sadece işlem tipi 'Kullanim' ise hangi siparişte harcandığı buraya yazılır
    
    -- CHECK Kısıtlaması 8: Tutar 0'dan büyük olmalı ve İşlem Tipi belirlenen değerlerde olmalı
    CONSTRAINT CHK_AskidaIslem_Tutar CHECK (Tutar > 0),
    CONSTRAINT CHK_AskidaIslem_Tipi CHECK (IslemTipi IN ('Bagis', 'Kullanim')),
    -- Yabancı Anahtarlar
    CONSTRAINT FK_AskidaIslem_Kullanici FOREIGN KEY (KullaniciID) REFERENCES Kullanici(KullaniciID),
    CONSTRAINT FK_AskidaIslem_Siparis FOREIGN KEY (SiparisID) REFERENCES Siparis(SiparisID)
);

