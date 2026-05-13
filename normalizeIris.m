function normIris = normalizeIris(img)
% normalizeIris  İris görüntüsünü Daugman-tarzı şeride yeniden boyutlandırır.
%
%   normIris = normalizeIris(img)
%
%   Çıktı: 64 x 256 gri görüntü
%
%   !! ÖNEMLİ NOT !!
%   Bu fonksiyon ana pipeline'dan ÇIKARILMIŞTIR.
%   buildDatabase.m, matchIris.m ve verifyIdentity.m artık bu fonksiyonu
%   çağırmıyor. Çünkü:
%     - preprocessIris → 128x128 çıktı üretiyor
%     - normalizeIris  → 64x256 yapıyor
%     - extractFeatures → 128x128 bekliyor (HOG hücre boyutlarına göre)
%   Bu zincir HOG özellik boyutunu değiştiriyor ve eğitim/test
%   pipeline'larını tutarsız kılıyordu.
%
%   Gerçek bir Daugman normalizasyonu (polar koordinat açılımı)
%   uygulamak istiyorsanız preprocessIris'i bu fonksiyonla
%   entegre edin ve extractFeatures'ı 64x256 için yeniden kalibre edin.

    normIris = imresize(img, [64, 256]);

end
