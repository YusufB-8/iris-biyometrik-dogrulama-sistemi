# Iris Biyometrik Doğrulama Sistemi

Bu proje, MATLAB ortamında geliştirilmiş yapay zekâ destekli bir iris tanıma ve biyometrik doğrulama sistemidir.

Sistem; iris görüntülerini işleyerek kişiye ait biyometrik özellikleri analiz eder ve doğrulama/sınıflandırma işlemleri gerçekleştirir.

---

# Proje İçeriği

Projede aşağıdaki işlemler gerçekleştirilmektedir:

- Iris görüntü ön işleme
- Iris segmentasyonu
- Özellik çıkarımı
- Veri artırma (augmentation)
- SVM ve CNN model eğitimi
- Kimlik doğrulama
- Canlılık kontrolü (liveness detection)
- ROC performans analizi
- Model karşılaştırma
- MATLAB GUI arayüzü

---

# Kullanılan Teknolojiler

- MATLAB
- Machine Learning
- Support Vector Machine (SVM)
- Convolutional Neural Network (CNN)
- Image Processing
- Biometrics
- Pattern Recognition

---

# Veri Seti

Kullanılan veri seti:

- :contentReference[oaicite:0]{index=0}

---

# Projede Kullanılan Modeller

Projede iris sınıflandırması için iki farklı model kullanılmıştır:

## SVM (Support Vector Machine)

- Daha düşük sistem maliyeti
- Hızlı sınıflandırma performansı
- Özellik tabanlı öğrenme yaklaşımı

## CNN (Convolutional Neural Network)

- Derin öğrenme tabanlı yaklaşım
- Görüntü verilerinde yüksek başarı
- Otomatik özellik öğrenebilme yeteneği

Her iki model performans açısından karşılaştırılmış ve ROC analizleri gerçekleştirilmiştir.

---

# Proje Dosyaları

```text
verifyIdentity.m      -> Kimlik doğrulama
userRegistration.m    -> Kullanıcı kayıt işlemi
trainCNN.m            -> CNN model eğitimi
test_iris.m           -> Test işlemleri
segmentIris.m         -> Iris segmentasyonu
preprocessIris.m      -> Görüntü ön işleme
plotROC.m             -> ROC eğrisi çizimi
normalizeIris.m       -> Iris normalizasyonu
matchIris.m           -> Iris eşleştirme
mainPanel.m           -> Ana GUI paneli
main.m                -> Ana sistem başlatma
liveVerify.m          -> Gerçek zamanlı doğrulama
extractFeatures.m     -> Özellik çıkarımı
demoPanel.m           -> Demo arayüzü
compareModels.m       -> Model karşılaştırma
checkLiveness.m       -> Canlılık kontrolü
buildDatabase.m       -> Veri tabanı oluşturma
biometricMetrics.m    -> Biyometrik metrik hesaplama
augmentIris.m         -> Veri artırma işlemleri
```

---

# Özellikler

- Modern MATLAB GUI tasarımı
- SVM ve CNN tabanlı sınıflandırma
- ROC performans analizi
- Gerçek zamanlı doğrulama sistemi
- Canlılık tespiti desteği
- Model performans karşılaştırması
- Biyometrik metrik hesaplama

---

# Projeyi Çalıştırma

MATLAB üzerinde aşağıdaki komut çalıştırılır:

```matlab
mainPanel
```

veya

```matlab
main
```

---

# Gelecekte Yapılabilecek Geliştirmeler

- Deep Learning optimizasyonu
- Gerçek zamanlı kamera entegrasyonu
- Daha büyük veri setleri ile eğitim
- Mobil entegrasyon
- Çok kullanıcılı sistem desteği

---

# Geliştirici

Yusuf Barut  
Adli Bilişim Mühendisliği
