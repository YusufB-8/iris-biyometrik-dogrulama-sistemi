function liveVerify()
% liveVerify  Kameradan canli iris dogrulama
%   Windows kamera uygulamasini acar, ekran goruntusu alir, analiz eder.

    [srcDir, ~, ~] = fileparts(mfilename('fullpath'));
    modelPath = fullfile(srcDir, '..', 'models', 'irisModel.mat');

    if ~exist(modelPath, 'file')
        msgbox('Model bulunamadi! Once "MODEL EGIT" calistirin.','Hata','error');
        return;
    end

    % --- Kamerayı aç ---
    fprintf('Kamera aciliyor...\n');
    system('start microsoft.windows.camera:');
    pause(3);

    % --- Hazır mısın penceresi ---
    choice = questdlg( ...
        sprintf(['Kamera acildi.\n\n' ...
                 '1. Kameranizi TAM EKRAN yapin\n' ...
                 '2. Gozunuzu kameraya gosterin\n' ...
                 '3. "GORUNTUYU AL" butonuna basin\n']), ...
        'Canli Iris Dogrulama', ...
        'GORUNTUYU AL', 'IPTAL', 'GORUNTUYU AL');

    if ~strcmp(choice, 'GORUNTUYU AL')
        fprintf('İptal edildi.\n');
        return;
    end

    % --- Geri sayım ---
    fprintf('3...\n'); pause(1);
    fprintf('2...\n'); pause(1);
    fprintf('1...\n'); pause(1);
    fprintf('Goruntu aliniyor!\n');

    % --- Ekran görüntüsü al ---
    try
        import java.awt.Robot
        import java.awt.Rectangle
        import java.awt.Toolkit

        robot      = Robot();
        screenSize = Toolkit.getDefaultToolkit().getScreenSize();
        W = screenSize.width;
        H = screenSize.height;
        rect = Rectangle(0, 0, W, H);

        jImg  = robot.createScreenCapture(rect);
        iData = jImg.getRGB(0, 0, W, H, [], 0, W);
        raw   = reshape(typecast(iData, 'uint8'), 4, W, H);
        img   = cat(3, reshape(raw(3,:,:), W, H)', ...
                       reshape(raw(2,:,:), W, H)', ...
                       reshape(raw(1,:,:), W, H)');
    catch ME
        msgbox(sprintf('Goruntu alinamadi: %s', ME.message), 'Hata', 'error');
        return;
    end

    % --- Geçici dosyaya kaydet ---
    tmpPath = fullfile(tempdir, 'iris_live_capture.jpg');
    imwrite(img, tmpPath, 'Quality', 95);
    fprintf('Goruntu alindi, analiz ediliyor...\n');

    % --- Analiz et ---
    verifyIdentity(tmpPath);

    % --- Geçici dosyayı sil ---
    if exist(tmpPath, 'file'), delete(tmpPath); end
end
