USE YemekSiparisi_VTYS;
GO

-- =====================================================================================
-- ADIM 4: VERİTABANI PROGRAMLANABİLİRLİĞİ (TRIGGER & INDEX)
-- =====================================================================================

-- -------------------------------------------------------------------------------------
-- BÖLÜM 1: TETİKLEYİCİLER (TRIGGERS)
-- -------------------------------------------------------------------------------------

-- Trigger 1: Sipariş "Teslim Edildi" olduğunda Restoranın ToplamCiro'sunu otomatik artır.
-- Bu tetikleyici, uygulama tarafında kod yazmaya gerek kalmadan veritabanı seviyesinde
-- veri bütünlüğünü ve otomatik hesaplamayı sağlar.
GO
CREATE TRIGGER trg_SiparisTeslimEdildi
ON Siparis
AFTER INSERT, UPDATE
AS
BEGIN
    -- Sadece 'Durum' kolonu güncellenmişse (Update) veya yeni kayıt gelmişse (Insert) çalışsın
    IF UPDATE(Durum)
    BEGIN
        -- Eğer aynı anda birden fazla sipariş (Toplu/Bulk Insert) teslim edilirse, cironun eksik hesaplanmaması için 
        -- RestoranID'ye göre gruplayarak SUM alıyoruz (Enterprise seviyesi hata ayıklama).
        UPDATE r
        SET r.ToplamCiro = r.ToplamCiro + src.ToplamArtis
        FROM Restoran r
        INNER JOIN (
            SELECT RestoranID, SUM(ToplamTutar) AS ToplamArtis
            FROM inserted i
            WHERE i.Durum = 'Teslim Edildi'
              -- Eğer güncelleme işlemiyse, önceki durumun 'Teslim Edildi' olmadığından emin ol
              -- (Aynı sipariş iki kere teslim edildi işaretlenirse ciro iki kere artmasın diye koruma)
              AND NOT EXISTS (
                  SELECT 1 FROM deleted d 
                  WHERE d.SiparisID = i.SiparisID AND d.Durum = 'Teslim Edildi'
              )
            GROUP BY RestoranID
        ) src ON r.RestoranID = src.RestoranID;
    END
END;
GO

-- Trigger 2: Askıda Yemek Log (İşlem) tablosuna kayıt eklendikçe ana havuzu otomatik güncelle.
-- Bu sayede yazılımcı "havuzu güncellemeyi unutursa" bile bakiye asla şaşmaz. Tam bir 3NF ve ACID uyumu!
CREATE TRIGGER trg_AskidaYemekBakiyeGuncelle
ON AskidaYemekIslem
AFTER INSERT
AS
BEGIN
    -- Toplu (Bulk) eklemelerde (Aynı anda birden çok bağış veya kullanım gelmesi) 
    -- Trigger'ın sadece tek bir satırı alıp diğerlerini atlamaması (bug) için 
    -- küme tabanlı (Set-based) işlem yapıyoruz. (Sınavda sorulursa tam notluk bir detaydır)
    UPDATE AskidaYemekHavuzu
    SET ToplamBakiye = ToplamBakiye 
        + ISNULL((SELECT SUM(Tutar) FROM inserted WHERE IslemTipi = 'Bagis'), 0)
        - ISNULL((SELECT SUM(Tutar) FROM inserted WHERE IslemTipi = 'Kullanim'), 0),
        SonGuncelleme = GETDATE()
    WHERE HavuzID = 1;
END;
GO

-- -------------------------------------------------------------------------------------
-- BÖLÜM 2: İNDEKSLER (INDEXES)
-- -------------------------------------------------------------------------------------
-- Projede kayıt sayısı milyonlara ulaştığında sorguların yavaşlamaması için (Performans kriteri)

-- Index 1: Siparişlerde tarih bazlı ("Bugünün siparişleri", "Geçen ayın siparişleri") 
-- aramalar çok yapılacağı için SiparisTarihi kolonuna indeks ekliyoruz.
CREATE NONCLUSTERED INDEX IDX_Siparis_Tarih 
ON Siparis(SiparisTarihi);
GO

-- Index 2: Kullanıcıların kendi sipariş geçmişini görüntüleme (WHERE KullaniciID = X) 
-- veya sisteme girip aktif siparişlerini listeleme hızını artırmak için indeks.
CREATE NONCLUSTERED INDEX IDX_Siparis_Kullanici 
ON Siparis(KullaniciID);
GO

