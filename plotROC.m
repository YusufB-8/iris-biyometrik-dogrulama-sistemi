function plotROC(model, X, Y)

    
    maxSamples = 300;

    if size(X,1) > maxSamples
        idx = randperm(size(X,1), maxSamples);
        X = X(idx,:);
        Y = Y(idx,:);
    end

    disp('ROC hesaplanıyor...');

    [~, scores] = predict(model, X);

    classes = unique(Y);

    figure('Name','ROC Curve');

    hold on;

    for i = 1:length(classes)

        [Xroc,Yroc,~,AUC] = perfcurve(Y, scores(:,i), classes(i));

        plot(Xroc,Yroc,'LineWidth',2, ...
            'DisplayName',sprintf('Class %d (AUC=%.2f)',classes(i),AUC));

    end

    xlabel('False Positive Rate');
    ylabel('True Positive Rate');
    title('ROC Curves');
    legend('show');
    grid on;

end