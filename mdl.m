% mdl.m  — Acil model yeniden eğitim scripti
%
%   Bu script workspace'de X ve Y zaten varsa modeli hızlıca
%   yeniden eğitip kaydeder. main.m çalıştırılamadığında kullanın.
%
%   Düzeltmeler:
%   - FitPosterior eklendi (plotROC ve güven skoru için zorunlu)
%   - Standardize eklendi
%   - Model yolu güvenilir hale getirildi

if ~exist('X', 'var') || ~exist('Y', 'var')
    error('X ve Y değişkenleri workspace''de bulunamadı. Önce loadDataset + buildDatabase çalıştırın.');
end

fprintf('Model eğitiliyor...\n');
t     = templateSVM('Standardize', true, 'KernelFunction', 'rbf');
model = fitcecoc(X, Y, 'Learners', t, 'FitPosterior', true);

[srcDir, ~, ~] = fileparts(mfilename('fullpath'));
modelDir  = fullfile(srcDir, '..', 'models');
modelPath = fullfile(modelDir, 'irisModel.mat');

if ~exist(modelDir, 'dir'), mkdir(modelDir); end
save(modelPath, 'model', 'X', 'Y');
fprintf('Model kaydedildi: %s\n', modelPath);
