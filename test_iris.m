% test_iris.m  — Tek görüntü ile hızlı test scripti
%
%   Düzeltmeler:
%   - 'names' değişkeni artık model dosyasından yükleniyor
%     (önceden workspace'den alınıyordu ve her zaman mevcut değildi)
%   - Güven eşiği ile karar gösteriliyor
%   - Dosya yolu düzenlenebilir şekilde en üstte

% ---- Ayarlar ----
TEST_IMAGE = 'S5001R03.jpg';   % Test edilecek görüntü dosyası
THRESHOLD  = 80;               % Kabul eşiği (%)
% -----------------

if ~exist(TEST_IMAGE, 'file')
    error('Görüntü bulunamadı: %s', TEST_IMAGE);
end

% Model ve isim listesini yükle
[srcDir, ~, ~] = fileparts(mfilename('fullpath'));
modelPath = fullfile(srcDir, '..', 'models', 'irisModel.mat');

if ~exist(modelPath, 'file')
    error('Model bulunamadı. Önce main.m çalıştırın.');
end

load(modelPath, 'names');

% Görüntüyü oku ve tanı
testImg              = imread(TEST_IMAGE);
[labelID, confidence] = matchIris(testImg);

confPct = confidence * 100;

fprintf('\n=================================\n');
fprintf('   IRIS SECURITY SYSTEM v2.0\n');
fprintf('=================================\n');
fprintf('Dosya         : %s\n', TEST_IMAGE);
fprintf('Tahmin        : %s\n', names{double(labelID)});
fprintf('Guven         : %.2f %%\n', confPct);

if confPct >= THRESHOLD
    fprintf('Karar         : ACCESS GRANTED\n');
else
    fprintf('Karar         : ACCESS DENIED (esik: %d%%)\n', THRESHOLD);
end

fprintf('=================================\n');
