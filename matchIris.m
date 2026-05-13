function [identity, confidence] = matchIris(img)
% matchIris  Iris görüntüsünden kimlik ve güven skoru döndürür.
%
%   [identity, confidence] = matchIris(img)
%
%   Giriş  : img — uint8 görüntü matrisi (gri veya RGB)
%   Çıkış  : identity   — tahmin edilen sınıf etiketi (categorical)
%             confidence — posterior probability [0, 1]
%
%   Düzeltmeler:
%   - normalizeIris kaldırıldı (verifyIdentity ile pipeline tutarlı hale geldi)
%   - Model yolu mfilename ile belirlendi

    [srcDir, ~, ~] = fileparts(mfilename('fullpath'));
    modelPath = fullfile(srcDir, '..', 'models', 'irisModel.mat');

    if ~exist(modelPath, 'file')
        error('Model bulunamadı: %s\nÖnce main.m çalıştırın.', modelPath);
    end

    load(modelPath, 'model', 'X');

    % Pipeline: sadece preprocessIris (normalizeIris yok)
    img  = preprocessIris(img);      % → 128x128 gri
    feat = extractFeatures(img);

    % Boyut uyumu — kaydedilen X'ten gerçek boyutu al
    modelFeatDim = size(X, 2);
    if length(feat) > modelFeatDim
        feat = feat(1:modelFeatDim);
    elseif length(feat) < modelFeatDim
        feat = [feat, zeros(1, modelFeatDim - length(feat))];
    end

    [label, score] = predict(model, feat);

    identity   = label;
    confidence = max(score);         % [0, 1] — posterior probability
end
