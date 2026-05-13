clear; clc; close all;

% =========================================================
%   IRIS SECURITY SYSTEM v2.0 — Ana Eğitim Scripti
%
%   Pipeline:
%     1. Veri yükleme (CASIA dataset)
%     2. Iris segmentasyonu (Hough Transform)
%     3. Data augmentation (8x çoğaltma)
%     4. LBP + HOG özellik çıkarımı
%     5. SVM (ECOC) eğitimi
%     6. CNN eğitimi (Deep Learning karşılaştırması)
%     7. Model karşılaştırması + metrikler
% =========================================================

% --- Yol ayarı ---
[srcDir, ~, ~] = fileparts(mfilename('fullpath'));
dataPath  = fullfile(srcDir, '..', 'data');
modelDir  = fullfile(srcDir, '..', 'models');
modelPath = fullfile(modelDir, 'irisModel.mat');

fprintf('Veri yolu  : %s\n', dataPath);
fprintf('Model yolu : %s\n', modelPath);

% --- 1. Veri yükleme ---
try
    [images, labels, names] = loadDataset(dataPath);
    fprintf('Toplam %d kişi, %d görüntü yüklendi.\n', length(names), length(images));
catch ME
    rethrow(ME);
end

if length(unique(labels)) < 2
    error('En az 2 farklı kişiye ait veri gerekli!');
end

% --- 2 & 3. Segmentasyon + Augmentation + Özellik çıkarımı (SVM için) ---
fprintf('\n--- SVM: ÖZELLİK BANKASI OLUŞTURULUYOR (Augmentation x8) ---\n');
[X, Y] = buildDatabase(images, labels);   % segmentIris + augmentIris içinde çağrılıyor
Y = categorical(Y);

% --- 4. SVM Eğitimi ---
fprintf('\n--- SVM MODELİ EĞİTİLİYOR ---\n');
t        = templateSVM('Standardize', true, 'KernelFunction', 'rbf');
svmModel = fitcecoc(X, Y, 'Learners', t);

% Kaydet (verifyIdentity ve matchIris bu dosyayı kullanır)
if ~exist(modelDir, 'dir'), mkdir(modelDir); end
model = svmModel;   % geriye dönük uyumluluk için
save(modelPath, 'model', 'X', 'Y', 'names', 'images', 'labels');
fprintf('\n--- SVM KAYDEDİLDİ: %s ---\n', modelPath);

% --- 5. SVM Metrikleri ---
biometricMetrics(svmModel, X, Y);

% --- 6. CNN Eğitimi ---
fprintf('\n--- CNN EĞİTİMİ BAŞLIYOR ---\n');
TRAIN_CNN = true;   % CNN istemiyorsan false yap — hızlıca atlar

if TRAIN_CNN
    try
        [cnnModel, cnnAcc] = trainCNN(images, labels, names);
        fprintf('\nCNN Accuracy: %.2f %%\n', cnnAcc);

        % --- 7. Karşılaştırma ---
        compareModels(svmModel, cnnModel, X, Y, images, labels, names);

    catch ME
        fprintf('\n!! CNN eğitimi başarısız: %s\n', ME.message);
        fprintf('Deep Learning Toolbox kurulu mu? SVM ile devam ediliyor.\n');
    end
else
    fprintf('CNN eğitimi atlandı (TRAIN_CNN = false).\n');
end

fprintf('\n====== TÜM EĞİTİM TAMAMLANDI ======\n');
