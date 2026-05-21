# Çevrimiçi Yemek Sipariş Platformu - İş Kuralları ve Veritabanı Tasarımı

## Proje Hakkında
Bu proje, VTYS-1 dersi kapsamında geliştirilmiş, 3. Normal Form'a (3NF) uygun bir ilişkisel veritabanı tasarımıdır. Klasik yemek sipariş fonksiyonlarının yanı sıra, sosyal yardımlaşmayı amaçlayan özel bir "Askıda Yemek Modülü" içermektedir.

## Varlık İlişki Modeli (ER) ve İş Kuralları

1. **Kullanıcı Modülü**
   - Sisteme üye olan kişiler 3 farklı rolde olabilir: `Standart`, `Hayirsever`, `IhtiyacSahibi`.
   - Aynı telefon numarası veya e-posta ile ikinci bir kayıt açılamaz (UNIQUE kısıtlaması).
   - "Soft Delete" yapısı mevcuttur. Kullanıcı silinmez, `IsActive = 0` yapılarak pasife çekilir.

2. **Restoran ve Ürün (Menü) Modülü**
   - Bir restoranın sisteme eklenmesi için adres ve isim zorunludur.
   - Puanı 0 ile 5 arasında olmalıdır (CHECK kısıtlaması).
   - Bir restoranın birden çok ürünü olabilir (1:N ilişki).
   - Ürün fiyatları kesinlikle 0'dan büyük olmalıdır.
   - Restoran bir ürünü kaldırdığında veri silinmez, sadece `IsActive = 0` yapılır. (Eski sipariş geçmişlerinin fiyat/isim olarak bozulmaması için).

3. **Sipariş ve Kurye Modülü**
   - Bir siparişin birden fazla ürünü olabilir, bir ürün birden fazla siparişte yer alabilir (M:N ilişki). Bu ilişki `SiparisDetay` tablosu ile çözülmüştür.
   - Sipariş tutarı 0'ın altına düşemez.
   - Sipariş "Teslim Edildi" olduğunda, siparişin toplam tutarı otomatik olarak (Tetikleyici / Trigger ile) restoranın "ToplamCiro"suna eklenir.

4. **ÖZEL MODÜL: Askıda Yemek Havuzu**
   - "Askıda Yemek", havuz mantığıyla çalışır. `AskidaYemekHavuzu` tablosunda sistemdeki toplam birikmiş bağış miktarı tutulur. Havuz bakiyesi 0'ın altına düşemez.
   - Hayırsever para bağışladığında veya ihtiyaç sahibi havuzdan yemek yediğinde, bu işlem `AskidaYemekIslem` tablosunda (Log tablosu) kayıt altına alınır.
   - Sisteme yazılan bir veritabanı Trigger'ı sayesinde, işlem log tablosuna eklendiği anda havuz bakiyesi hatasız bir şekilde güncellenir.
