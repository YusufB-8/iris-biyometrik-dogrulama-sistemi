function isLive = checkLiveness(img)
% checkLiveness  Laplacian frekans analizi ile canlı/sahte göz tespiti.
%
%   isLive = checkLiveness(img)
%
%   img : dosya yolu (char/string) VEYA görüntü matrisi
%
%   Düzeltmeler:
%   - String girişi desteklendi (verifyIdentity imagePath geçiriyordu, imread yoktu)
%   - Gri tonlamaya çevirme eklendi (RGB girişte del2 hata veriyordu)
%   - Eşik değeri ve mantığı düzeltildi:
%       Gerçek iris kamerayla çekilmiş → orta frekanslı, temiz doku
%       Ekran/kağıt baskısı → aşırı yüksek veya çok düşük Laplacian
%   - Hem alt hem üst eşik kontrol ediliyor

    % --- Girişi normalize et ---
    if ischar(img) || isstring(img)
        img = imread(char(img));
    end

    if size(img, 3) == 3
        img = rgb2gray(img);
    end

    img_gray = double(img);

    % --- Laplacian analizi ---
    lap   = abs(del2(img_gray));
    score = mean(lap(:));

    % --- Karar ---
    % Çok düşük skor  → tamamen bulanık, sahte (basılı fotoğraf, blur saldırısı)
    % Orta skor       → canlı iris dokusu
    % Çok yüksek skor → pikselleşmiş ekran / taranmış kağıt
    %
    % Eşik değerleri: gerçek veriyle kalibre edilmeli.
    % Başlangıç değerleri (IRISdatabase testlerine göre):
    LOW_THRESH  = 0.5;   % altı → çok bulanık, sahte
    HIGH_THRESH = 12.0;  % üstü → çok keskin, dijital ekran/baskı

    isLive = (score >= LOW_THRESH) && (score <= HIGH_THRESH);

    fprintf('[Liveness] Laplacian skoru: %.4f  →  %s\n', score, ...
        ternary(isLive, 'CANLI', 'SAHTE'));
end

% --------------------------------------------------------
function out = ternary(cond, a, b)
    if cond, out = a; else, out = b; end
end
