function img = preprocessIris(img)
% preprocessIris  Iris goruntusu modele hazirlar.
%   1. Gri tonlama
%   2. CLAHE kontrast artirma
%   3. Medyan filtresi
%   4. 128x128 boyut
%
%   segmentIris cok yavas oldugu icin kapali.
%   Acmak icin: img = segmentIris(img); satirini uncomment yap.

    if size(img, 3) == 3
        img = rgb2gray(img);
    end

    img = adapthisteq(img, 'ClipLimit', 0.02, 'NumTiles', [8 8]);
    img = medfilt2(img, [3 3]);
    img = imresize(img, [128 128]);

    % img = segmentIris(img);  % <- segmentasyon (yavas, kapali)

end
