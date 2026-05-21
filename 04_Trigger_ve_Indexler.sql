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
        UPDATE r
        SET r.ToplamCiro = r.ToplamCiro + i.ToplamTutar
        FROM Restoran r
        INNER JOIN inserted i ON r.RestoranID = i.RestoranID
        WHERE i.Durum = 'Teslim Edildi' 
          -- Eğer güncelleme işlemiyse, önceki durumun 'Teslim Edildi' olmadığından emin ol
          -- (Aynı sipariş iki kere teslim edildi işaretlenirse ciro iki kere artmasın diye koruma)
          AND NOT EXISTS (
              SELECT 1 FROM deleted d 
              WHERE d.SiparisID = i.SiparisID AND d.Durum = 'Teslim Edildi'
          );
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
    DECLARE @IslemTipi VARCHAR(20);
    DECLARE @Tutar DECIMAL(10,2);

    -- Yeni eklenen satırdaki değerleri alıyoruz
    SELECT @IslemTipi = IslemTipi, @Tutar = Tutar FROM inserted;

    -- Bağış yapıldıysa havuzu artır
    IF @IslemTipi = 'Bagis'
    BEGIN
        UPDATE AskidaYemekHavuzu
        SET ToplamBakiye = ToplamBakiye + @Tutar,
            SonGuncelleme = GETDATE()
        WHERE HavuzID = 1;
    END
    -- Kullanım yapıldıysa havuzdan düş
    ELSE IF @IslemTipi = 'Kullanim'
    BEGIN
        UPDATE AskidaYemekHavuzu
        SET ToplamBakiye = ToplamBakiye - @Tutar,
            SonGuncelleme = GETDATE()
        WHERE HavuzID = 1;
    END
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
