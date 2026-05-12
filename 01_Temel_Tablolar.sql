-- =====================================================================================
-- ADIM 1: TEMEL (BAĞIMSIZ) TABLOLARIN VE KISITLAMALARIN OLUŞTURULMASI
-- =====================================================================================
-- Bu dosyada başka tablolara bağımlılığı olmayan (Foreign Key içermeyen) 
-- temel varlıklar tanımlanmıştır. 
-- Not: SQL Server (T-SQL) sentaksı baz alınmıştır (IDENTITY, GETDATE(), BIT kullanımı).

-- 1. Kullanici Tablosu
-- Sisteme kayıtlı olan standart müşteriler, hayırseverler ve ihtiyaç sahiplerini tutar.
CREATE TABLE Kullanici (
    KullaniciID INT IDENTITY(1,1) PRIMARY KEY, -- Otomatik artan birincil anahtar
    AdSoyad VARCHAR(100) NOT NULL, -- Boş geçilemez kısıtlaması
    Email VARCHAR(100) UNIQUE NOT NULL, -- Tekrarlanamaz (UNIQUE) ve Boş geçilemez
    Telefon VARCHAR(15) UNIQUE NOT NULL, -- Tekrarlanamaz (UNIQUE) ve Boş geçilemez
    Rol VARCHAR(20) NOT NULL, -- 'Standart', 'Hayirsever', 'IhtiyacSahibi'
    KayitTarihi DATETIME DEFAULT GETDATE(),
    IsActive BIT DEFAULT 1, -- 1: Aktif, 0: Pasif (Soft delete mantığı için hazırlık)
    
    -- CHECK Kısıtlaması 1: Rol sadece belirlenen 3 değerden biri olabilir
    CONSTRAINT CHK_Kullanici_Rol CHECK (Rol IN ('Standart', 'Hayirsever', 'IhtiyacSahibi'))
);

-- 2. Restoran Tablosu
-- Sistemdeki yemek sağlayıcılarını tutar.
CREATE TABLE Restoran (
    RestoranID INT IDENTITY(1,1) PRIMARY KEY,
    Ad VARCHAR(100) NOT NULL,
    Adres VARCHAR(255) NOT NULL,
    Puan DECIMAL(3,2) DEFAULT 0, -- Restoran puanı (Örn: 4.50)
    ToplamCiro DECIMAL(10,2) DEFAULT 0, -- Restoranın toplam satış geliri
    IsActive BIT DEFAULT 1,
    
    -- CHECK Kısıtlaması 2: Restoran Puanı 0 ile 5 arasında olmalıdır (Sınav isterine uygun)
    CONSTRAINT CHK_Restoran_Puan CHECK (Puan >= 0 AND Puan <= 5)
);

-- 3. Kurye Tablosu
-- Teslimatları yapacak kuryeleri tutar.
CREATE TABLE Kurye (
    KuryeID INT IDENTITY(1,1) PRIMARY KEY,
    AdSoyad VARCHAR(100) NOT NULL,
    Telefon VARCHAR(15) UNIQUE NOT NULL,
    Durum VARCHAR(20) DEFAULT 'Musait', -- 'Musait', 'Teslimatta', 'Pasif'
    
    -- CHECK Kısıtlaması 3: Kurye durumu sadece mantıklı değerleri alabilir
    CONSTRAINT CHK_Kurye_Durum CHECK (Durum IN ('Musait', 'Teslimatta', 'Pasif'))
);
