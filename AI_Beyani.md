# Yapay Zeka (AI) Kullanım Beyanı ve Dürüstlük Raporu

## Proje Bilgileri
- **Ders:** VTYS-1 Veritabanı Yönetim Sistemleri
- **Proje Konusu:** Çevrimiçi Yemek Sipariş Platformu ve Askıda Yemek Modülü

## AI Kullanım Detayları
Bu projenin geliştirilme sürecinde Yapay Zeka (LLM) araçlarından danışmanlık alınmıştır. Aşağıda bu kullanımın sınırları ve kapsamı dürüstlük ilkesi çerçevesinde beyan edilmiştir:

1. **Kavramsal Tasarım ve Normalizasyon:**
   Proje gereksinimlerinde istenen "Askıda Yemek Modülü"nün nasıl kurgulanacağı konusunda (Havuz ve Log tablosu ayrımı) AI ile beyin fırtınası yapılmış ve 3. Normal Form (3NF) kuralları doğrultusunda tabloların en uygun şekilde nasıl bölüneceği tartışılmıştır.

2. **SQL Sentaksı ve Hata Ayıklama:**
   Karmaşık JOIN, GROUP BY ve IN/EXISTS sorgularının yazımında SQL Server (T-SQL) sentaksına uygunluk açısından AI'dan faydalanılmış, yazılan sorguların performansı (Index kullanımı) hakkında tavsiyeler alınmıştır.

3. **Otomasyon (Trigger) Mantığı:**
   Veritabanı seviyesinde otomasyon sağlamak amacıyla yazılan Tetikleyicilerin (Trigger) (Örn: Sipariş teslim edilince cironun artması ve havuz bakiyesinin otomatik güncellenmesi) mantıksal akış şeması AI destekli olarak kurgulanmıştır.

**Özgünlük Beyanı:**
Yukarıda belirtilen AI yardımlarına rağmen, sistemin temel iş kuralları (Business Rules), tabloların birbirine nasıl bağlanacağına dair mühendislik kararları ve projenin "Askıda Yemek" gibi özel senaryolarının kurgusu tamamen projenin yönergesine uygun olarak şekillendirilmiş, oluşturulan veri modeli tarafımca bütünüyle anlaşılmış ve savunulabilir düzeyde özümsenmiştir.
