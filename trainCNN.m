function [cnnModel, cnnAcc] = trainCNN(images, labels, names)

    fprintf('\n========== CNN EĞİTİMİ ==========\n');

    numClasses = length(unique(labels));
    IMG_SIZE   = [64 64 1];   

    fprintf('Görüntüler hazırlanıyor...\n');

    N = length(images);
    imgArray  = zeros(IMG_SIZE(1), IMG_SIZE(2), 1, N, 'uint8');
    labelVec  = categorical(labels(:));

   for i = 1:N
    img = images{i};
    if size(img,3) == 3, img = rgb2gray(img); end
    img = imresize(img, [IMG_SIZE(1) IMG_SIZE(2)]);
    imgArray(:,:,1,i) = img;
   end
  
    idx       = randperm(N);
    nTrain    = round(0.8 * N);
    trainIdx  = idx(1:nTrain);
    valIdx    = idx(nTrain+1:end);

    XTrain    = imgArray(:, :, :, trainIdx);
    YTrain    = labelVec(trainIdx);
    XVal      = imgArray(:, :, :, valIdx);
    YVal      = labelVec(valIdx);


    augmenter = imageDataAugmenter( ...
        'RandRotation',      [-8, 8], ...
        'RandXTranslation',  [-4, 4], ...
        'RandYTranslation',  [-4, 4], ...
        'RandXReflection',   true);

    augimdsTrain = augmentedImageDatastore(IMG_SIZE, XTrain, YTrain, ...
        'DataAugmentation', augmenter);
    valdsTrain   = augmentedImageDatastore(IMG_SIZE, XVal, YVal);

 
    layers = [
        imageInputLayer(IMG_SIZE, 'Name', 'input', 'Normalization', 'zerocenter')

     
        convolution2dLayer(3, 32, 'Padding', 'same', 'Name', 'conv1')
        batchNormalizationLayer('Name', 'bn1')
        reluLayer('Name', 'relu1')
        maxPooling2dLayer(2, 'Stride', 2, 'Name', 'pool1')
       
        convolution2dLayer(3, 64, 'Padding', 'same', 'Name', 'conv2')
        batchNormalizationLayer('Name', 'bn2')
        reluLayer('Name', 'relu2')
        maxPooling2dLayer(2, 'Stride', 2, 'Name', 'pool2')

        convolution2dLayer(3, 128, 'Padding', 'same', 'Name', 'conv3')
        batchNormalizationLayer('Name', 'bn3')
        reluLayer('Name', 'relu3')
        maxPooling2dLayer(2, 'Stride', 2, 'Name', 'pool3')

        
        fullyConnectedLayer(256, 'Name', 'fc1')
        reluLayer('Name', 'relu4')
        dropoutLayer(0.5, 'Name', 'drop1')

        fullyConnectedLayer(numClasses, 'Name', 'fc2')
        softmaxLayer('Name', 'softmax')
        classificationLayer('Name', 'output')
    ];

    options = trainingOptions('adam', ...
        'MaxEpochs',          40, ...
        'MiniBatchSize',      32, ...
        'InitialLearnRate',   1e-3, ...
        'LearnRateSchedule',  'piecewise', ...
        'LearnRateDropFactor', 0.5, ...
        'LearnRateDropPeriod', 15, ...
        'ValidationData',     valdsTrain, ...
        'ValidationFrequency', 10, ...
        'Shuffle',            'every-epoch', ...
        'Verbose',            true, ...
        'Plots',              'training-progress');

    fprintf('CNN eğitiliyor (%d sınıf, %d eğitim, %d validasyon)...\n', ...
        numClasses, nTrain, N - nTrain);

    cnnModel = trainNetwork(augimdsTrain, layers, options);

    YPred    = classify(cnnModel, valdsTrain);
    cnnAcc   = mean(YPred == YVal) * 100;

    fprintf('\nCNN Validasyon Doğruluğu: %.2f %%\n', cnnAcc);

    [srcDir, ~, ~] = fileparts(mfilename('fullpath'));
    modelDir = fullfile(srcDir, '..', 'models');
    if ~exist(modelDir, 'dir'), mkdir(modelDir); end
    save(fullfile(modelDir, 'cnnModel.mat'), 'cnnModel', 'names');
    fprintf('CNN modeli kaydedildi.\n');

end
