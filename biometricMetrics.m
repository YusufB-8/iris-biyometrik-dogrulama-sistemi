function biometricMetrics(model, X, Y)
    fprintf('\n========== BİYOMETRİK METRİKLER ==========\n');
    fprintf('Egitim verisi: %d ornek, %d sinif\n', size(X,1), length(unique(double(Y))));
    fprintf('Train accuracy hesaplanıyor...\n');
    
    % Sadece ilk 200 örnek üzerinde hızlı kontrol
    idx = randperm(size(X,1), min(200, size(X,1)));
    predSample = predict(model, X(idx,:));
    accApprox  = mean(predSample == Y(idx)) * 100;
    
    fprintf('Tahmini Train Accuracy : %.2f %%\n', accApprox);
    cvAcc = 0;
    fprintf('CV Accuracy            : atlandı\n');
    fprintf('===========================================\n\n');
    
    figure('Name','Biometric Metrics','NumberTitle','off');
    confusionchart(Y(idx), predSample, ...
        'Title', sprintf('Confusion Matrix (~%.1f%%)', accApprox), ...
        'RowSummary', 'row-normalized');
end