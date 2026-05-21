USE YemekSiparisi_VTYS;
GO

-- =====================================================================================
-- ADIM 5: İLERİ DÜZEY SORGULAR VE GÖRÜNÜMLER (VIEWS)
-- =====================================================================================

-- -------------------------------------------------------------------------------------
-- BÖLÜM 1: GÖRÜNÜMLER (VIEWS)
-- -------------------------------------------------------------------------------------

-- View 1: Aktif Restoran Menüleri
-- Sadece sistemde aktif olan (IsActive = 1) restoranların, yine aktif olan ürünlerini getirir.
-- Amaç: Müşteri uygulamayı açtığında arka planda bu View çalışır ve "Soft Delete" ile silinmiş yemekleri görmez.
GO
CREATE VIEW vw_AktifRestoranMenuleri AS
SELECT 
    r.Ad AS RestoranAdi,
    u.Ad AS YemekAdi,
    u.Fiyat,
    u.Aciklama
FROM Restoran r
INNER JOIN Urun u ON r.RestoranID = u.RestoranID
WHERE r.IsActive = 1 AND u.IsActive = 1;
GO

-- View 2: Askıda Yemek Havuz Durumu Raporu
-- Yöneticilerin anlık olarak havuzdaki parayı, toplam bağışı ve tüketimi görmesini sağlayan özet rapor.
CREATE VIEW vw_AskidaYemekHavuzDurumu AS
SELECT 
    (SELECT ToplamBakiye FROM AskidaYemekHavuzu WHERE HavuzID = 1) AS GuncelBakiye,
    COUNT(IslemID) AS ToplamIslemSayisi,
    SUM(CASE WHEN IslemTipi = 'Bagis' THEN Tutar ELSE 0 END) AS ToplamYapilanBagis,
    SUM(CASE WHEN IslemTipi = 'Kullanim' THEN Tutar ELSE 0 END) AS ToplamYenenYemekTutari
FROM AskidaYemekIslem;
GO

-- -------------------------------------------------------------------------------------
-- BÖLÜM 2: İLERİ DÜZEY ANALİTİK SORGULAR (DQL)
-- (Sınavda kesinlikle istenen JOIN, GROUP BY ve IN/EXISTS sorguları)
-- -------------------------------------------------------------------------------------

-- Sorgu 1: JOIN ile Detaylı Sipariş Fişi (Müşteri ne yemiş, ne kadar ödemiş, kurye kim?)
-- 4 Tabloyu (Siparis, Kullanici, Restoran, Kurye) birbirine bağlayan kompleks sorgu.
SELECT 
    s.SiparisID,
    k.AdSoyad AS MusteriAdi,
    r.Ad AS RestoranAdi,
    kr.AdSoyad AS KuryeAdi,
    s.SiparisTarihi,
    s.Durum,
    s.OdemeTipi,
    s.ToplamTutar
FROM Siparis s
INNER JOIN Kullanici k ON s.KullaniciID = k.KullaniciID
INNER JOIN Restoran r ON s.RestoranID = r.RestoranID
LEFT JOIN Kurye kr ON s.KuryeID = kr.KuryeID
ORDER BY s.SiparisTarihi DESC;

-- Sorgu 2: GROUP BY ve HAVING ile Restoran Performans Analizi (Ciro Analizi)
-- Sadece "Teslim Edildi" statüsünde siparişi olan ve toplam cirosu 100 TL'den büyük restoranları listeler.
SELECT 
    r.Ad AS RestoranAdi,
    COUNT(s.SiparisID) AS ToplamBasariliSiparisSayisi,
    SUM(s.ToplamTutar) AS ToplamKazanilanCiro
FROM Restoran r
LEFT JOIN Siparis s ON r.RestoranID = s.RestoranID AND s.Durum = 'Teslim Edildi'
GROUP BY r.Ad
HAVING SUM(s.ToplamTutar) > 100
ORDER BY ToplamKazanilanCiro DESC;

-- Sorgu 3: IN / EXISTS Kullanımı (Özel Müşteri Filtresi - Subquery)
-- Sisteme kayıtlı olup, 'AskidaYemek' ödeme tipiyle hayatında en az bir kez ücretsiz sipariş vermiş 
-- ihtiyaç sahibi müşterilerin iletişim listesi.
SELECT 
    KullaniciID, 
    AdSoyad, 
    Telefon,
    Email
FROM Kullanici
WHERE KullaniciID IN (
    SELECT DISTINCT KullaniciID 
    FROM Siparis 
    WHERE OdemeTipi = 'AskidaYemek'
);

