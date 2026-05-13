function [X, Y] = buildDatabase(images, labels)
    N       = length(images);
    N_AUG   = 4;
    N_TOTAL = N * N_AUG;

    tempImg  = preprocessIris(images{1});
    tempFeat = extractFeatures(tempImg);
    featDim  = length(tempFeat);

    fprintf('Ozellik boyutu  : %d\n', featDim);
    fprintf('Orijinal goruntu: %d\n', N);
    fprintf('Augmentation    : x%d\n', N_AUG);
    fprintf('Toplam ornek    : ~%d\n', N_TOTAL);

    X   = zeros(N_TOTAL, featDim, 'single');
    Y   = zeros(N_TOTAL, 1);
    idx = 1;

    for i = 1:N
        img  = preprocessIris(images{i});
        imgs = augmentIris(img);

        for k = 1:length(imgs)
            feat      = extractFeatures(imgs{k});
            X(idx, :) = feat;
            Y(idx)    = labels(i);
            idx       = idx + 1;
        end

        if mod(i, 50) == 0 || i == N
            fprintf('  [%d/%d] islendi (%.0f%%)\n', i, N, 100*i/N);
        end
    end

    X = X(1:idx-1, :);
    Y = Y(1:idx-1);
    fprintf('Veritabani hazir: %d ornek, %d ozellik\n', size(X,1), size(X,2));
end
