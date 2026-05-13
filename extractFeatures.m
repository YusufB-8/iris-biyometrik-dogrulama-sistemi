function feat = extractFeatures(img)
% extractFeatures  128x128 gri goruntuden LBP + HOG ozellik vektoru cikarir.
%   Hizli mod: CellSize [16 16] (onceki [8 8] 4x daha fazla HOG hesaplar)

    if ~isequal(size(img), [128 128])
        img = imresize(img, [128 128]);
    end

    % LBP — ~59 ozellik
    lbp = extractLBPFeatures(img, 'Radius', 2, 'NumNeighbors', 8, 'Upright', false);

    % HOG — buyuk hucre = daha az ozellik, daha hizli
    hog = extractHOGFeatures(img, 'CellSize', [16 16]);

    feat = [lbp, hog];
end
