# VTYS-1 Dönem Projesi: Çevrimiçi Yemek Sipariş Platformu Veritabanı Tasarımı Teslim Raporu

**Ad Soyad:** Mehmet Can
**Ogrenci No:** [Öğrenci Numaranızı Yazınız]

## 1. Proje Özeti ve Kapsamı
**Genel Tanım:** Bu sistem; müşterilerin restoranlardan yemek siparişi verebildiği, kuryelerin teslimat süreçlerini yönettiği klasik bir çevrimiçi yemek sipariş platformudur. Sistem, standart işlevlere ek olarak sosyal yardımlaşmayı dijitalleştiren özel bir "Askıda Yemek" modülüne sahiptir.
**3NF Uyumluluğu:** Veritabanı tasarımı 3. Normal Form (3NF) kurallarına sıkı sıkıya bağlıdır. Veri tekrarını önlemek adına varlıklar (Müşteri, Restoran, Ürün vb.) kendi bağımsız tablolarına ayrılmıştır. Örneğin, siparişteki her yemeğin adı ve restoran bilgisi sipariş tablosuna tekrar tekrar yazılmak yerine, `SiparisDetay` (M:N ilişkiyi çözen tablo) üzerinden ID referanslarıyla (Foreign Key) yönetilmektedir. Her sütun yalnızca kendi Primary Key'ine tam bağımlıdır.

## 2. "Askıda Yemek" Modülü İş Kuralları
**Bağış Mantığı:** Sisteme kayıtlı ve rolü 'Hayirsever' olan kullanıcılar havuza bakiye bağışlayabilir. Yapılan her bağış `AskidaYemekIslem` adlı log tablosuna eklenir.
**Gizlilik Kuralları:** Yönergede istenen "kimliğini gizleyerek veya açıkça bağış yapabilme" şartını teknik olarak tam karşılamak için `AskidaYemekIslem` tablosuna **`GizliMi (BIT)`** kolonu eklenmiştir. Bu değer 1 (True) ise bağışçı anonim sayılır ve kimliği gizlenir, 0 ise açıkça listelenir.
**Yararlanma Şartları:** Sistemde rolü 'IhtiyacSahibi' olarak doğrulanmış kullanıcılar, sipariş verirken `OdemeTipi = 'AskidaYemek'` seçeneğini kullanabilir. Bu sayede kişilerin ifşa olmadan ücretsiz yemek yiyebilmesi sağlanmıştır.
**Bakiye Yönetimi:** Havuzdaki para miktarı yazılım katmanına bırakılmamıştır. Veritabanı seviyesinde yazılan `trg_AskidaYemekBakiyeGuncelle` adlı tetikleyici (trigger) sayesinde, log tablosuna bir bağış eklendiğinde ana havuzdaki (`AskidaYemekHavuzu`) para otomatik olarak artar; bir kullanım yapıldığında ise otomatik olarak eksilir. Böylece bakiye hesaplamasında hata payı sıfıra indirilmiştir.

## 3. Varlık-İlişki (ER) Diyagramı
*(Not: Teslim edeceğiniz Word veya PDF dosyasına SQL Server'dan aldığınız ER diyagramının görselini ekleyiniz. İlişkiler şu şekildedir:)*
**İlişki Açıklamaları:**
- **Restoran - Urun (1:N):** Bir restoranın birden çok ürünü olabilir, bir ürün sadece bir restorana aittir.
- **Kullanici - Siparis (1:N):** Bir müşteri birden çok sipariş verebilir.
- **Urun - Siparis (M:N):** Bir ürün birden çok siparişte olabilir, bir siparişte birden çok ürün olabilir. Bu ilişki `SiparisDetay` isimli ara tablo (Junction Table) ile 1:N ve 1:N şeklinde ikiye bölünerek çözülmüştür.

## 4. Veri Tanımlama ve Kısıtlamalar (DDL)
**Tablo Yapıları:**
- `Kullanici`: Sistemdeki tüm kullanıcıların (Standart, Hayırsever, İhtiyaç Sahibi) bilgilerini tutar.
- `Restoran`: Sisteme kayıtlı işletmeleri tutar.
- `Kurye`: Teslimat görevlilerini tutar.
- `Urun`: Restoranların menülerindeki yemekleri tutar.
- `Siparis` ve `SiparisDetay`: Sipariş başlıklarını ve içeriğindeki yemekleri tutar.
- `AskidaYemekHavuzu`: Sistemdeki mevcut toplam askı bakiyesini tek satırda tutar.
- `AskidaYemekIslem`: Askıya yapılan para giriş ve çıkışlarının tarihsel dökümünü tutar (`GizliMi` kolonu ile anonimlik sağlar).
**Constraint Kullanımı:**
- **CHECK:** Mantıksız verileri engellemek için kullanıldı. Örn: Restoran puanı `0-5` arasında sınırlandı, Sipariş tutarı ve Ürün fiyatlarının negatif (`> 0`) olması engellendi. Rollerin sadece 3 belirli tipte olabileceği kısıtlandı.
- **UNIQUE:** Kullanıcıların e-posta ve telefon numaralarının tekrarlanmasını (aynı kişinin iki hesap açmasını) engellemek için kullanıldı.
- **NOT NULL:** Kritik alanların (örn: AdSoyad, Fiyat) boş geçilmesini önlemek için eklendi.
**Soft Delete:** Restoranların yemekleri sildiğinde veritabanından kalıcı olarak yok olmasını (ve eski sipariş fiyat/isim geçmişlerinin bozulmasını) engellemek için `Urun` tablosuna `IsActive (BIT)` kolonu eklenmiştir. Ürün silinmez, pasife çekilir (IsActive = 0).

## 5. Veritabanı Programlanabilirlik Nesneleri
**Görünümler (Views):**
- `vw_AktifRestoranMenuleri`: Müşteri uygulamayı açtığında sadece aktif restoranların, silinmemiş aktif yemeklerini listelemek için yazıldı.
- `vw_AskidaYemekHavuzDurumu`: Havuzdaki güncel parayı ve yapılan toplam bağış/harcama miktarını tek satırda gösteren yönetici raporudur.
**Tetikleyiciler (Triggers):**
- `trg_SiparisTeslimEdildi`: Bir sipariş teslim edildiğinde, siparişin toplam tutarını ilgili restoranın Toplam Ciro'suna otomatik ekler. 
- `trg_AskidaYemekBakiyeGuncelle`: İşlem tablosuna para girişi veya çıkışı eklendiğinde ana havuzu günceller.
- **Not:** Her iki trigger da aynı anda birden fazla sipariş (Toplu/Bulk Insert) gelmesi durumunda verilerin eksik hesaplanmaması için Enterprise seviyesi olan **Küme Tabanlı (Set-Based)** mantıkla kodlanmıştır.
**İndeksleme (Index):** Milyonlarca sipariş olduğunda performansı korumak için `SiparisTarihi` ve `KullaniciID` kolonlarına indeks tanımlandı. Çünkü raporlama ve müşterinin kendi siparişlerini listelemesi esnasında WHERE şartında en çok bu iki kolon kullanılacaktır.

## 6. Analitik Sorgu Senaryoları
**JOIN Sorgusu:** Kullanici, Restoran, Kurye ve Siparis tabloları (Toplam 4 tablo) birleştirilerek "Detaylı Sipariş Fişi" oluşturulmuştur. Bu sorgu sayesinde bir siparişin kim tarafından, hangi restorandan, hangi kurye ile teslim edildiği ve tutarı tek satırda görülebilir.
**Gruplama ve Agregasyon:** GROUP BY ve HAVING kullanarak "Başarılı Siparişlerden 100 TL üzeri ciro elde eden restoranların toplam kazançları" hesaplanmıştır. Restoran performans analizine cevap vermektedir.
**Alt Sorgu (Subquery):** IN / EXISTS ifadeleri kullanılarak; sisteme üye olan kullanıcılar içerisinde, `AskidaYemek` ödeme yöntemini kullanarak en az 1 kez yemek yiyen 'IhtiyacSahibi' profilli müşterilerin iletişim listesi (alt sorgu filtrelemesi ile) çıkarılmıştır.

## 7. Yapay Zeka (AI) Beyanı
**Asistan Kullanımı:** Bu projenin geliştirilmesi sırasında yapay zeka asistanından faydalanılmıştır. Veritabanının 3NF kurallarına uygun tasarlanması için tablo kurgularında (özellikle Havuz ve Log tablolarının ayrılması hususunda) fikir alışverişi yapılmıştır. SQL kodlarının (Trigger'lardaki Bulk Insert bug'larının set-based yaklaşımla çözümü) optimize edilmesinde ve istenen zorunlu "5 Restoran, 20 Müşteri, 50 Ürün, 100 Sipariş" kotasının T-SQL `WHILE` döngüleri kullanılarak dinamik şekilde sisteme eklenmesinde asistandan sentaks (kod yazımı) yardımı alınmıştır.
**Özgünlük Onayı:** AI tarafından üretilen çözümler doğrudan kopyalanmamış; projenin özel kural ve yönergelerine (GizliMi kolonu zorunluluğu, CHECK kısıtlamaları, Soft Delete vb.) uyumlu olacak şekilde sistem tarafımca kurgulanmış, üretilen veri modeli test edilip tam olarak anlaşıldıktan sonra projeye entegre edilmiştir.

## 8. GitHub ve Versiyonlama
**Repo Linki:** `https://github.com/mehmetcanbck/yemek-siparis-platformu-db.git`
**Commit Geçmişi:** Proje tek bir devasa dosya halinde gönderilmemiş; tablolar, ilişkiler, test verileri, triggerlar ve sorgular adım adım geliştirilerek anlamlı commit mesajlarıyla (`feat: Temel tablolar oluşturuldu`, `fix: Trigger kume tabanli mantiga gecildi` vb.) düzenli olarak versiyonlanmıştır. Reponun commit geçmişi, kodların yavaş yavaş ve kontrollü yazıldığını ispatlamaktadır.
