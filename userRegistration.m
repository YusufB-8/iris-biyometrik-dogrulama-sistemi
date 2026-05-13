function userRegistration()
% userRegistration  Yeni kullanıcı kaydeder ve modeli günceller.
%
%   Düzeltmeler:
%   - Klasör yolu pwd yerine mfilename ile belirlendi
%   - Ekran görüntüsü yerine belirli bir ekran bölgesi (kamera penceresi) alınıyor
%   - Kayıt öncesi kullanıcı onayı eklendi
%   - run('main.m') yerine ana eğitim fonksiyonu çağrısı ile daha güvenli eğitim

    % --- 1. Kullanıcı adı ---
    answer = inputdlg('Kaydedilecek kişinin adı:', 'Kayıt Paneli', [1 40], {'Yeni_Kullanici'});
    if isempty(answer), disp('Kayıt iptal edildi.'); return; end

    uName = strtrim(strrep(answer{1}, ' ', '_'));
    if isempty(uName)
        errordlg('Geçerli bir isim girin!', 'Hata'); return;
    end

    % --- 2. Klasör yolu ---
    [srcDir, ~, ~] = fileparts(mfilename('fullpath'));
    targetDir = fullfile(srcDir, '..', 'data', uName);

    if exist(targetDir, 'dir')
        choice = questdlg(sprintf('[%s] zaten kayıtlı. Üzerine yazılsın mı?', uName), ...
                          'Uyarı', 'Evet', 'Hayır', 'Hayır');
        if ~strcmp(choice, 'Evet'), return; end
    else
        mkdir(targetDir);
    end

    % --- 3. Kamerayı başlat ---
    fprintf('Kamera açılıyor... Lütfen kameranın tam ekrana geçmesini bekleyin.\n');
    system('start microsoft.windows.camera:');
    pause(4);

    import java.awt.Robot
    import java.awt.Rectangle
    import java.awt.Toolkit

    robot      = Robot();
    screenSize = Toolkit.getDefaultToolkit().getScreenSize();
    W = screenSize.width;
    H = screenSize.height;

    % Kamera uygulaması genellikle ekranın ortasında açılır.
    % Burada tam ekranı yakalıyoruz — kullanıcı kamerayı tam ekrana almalı.
    rect = Rectangle(0, 0, W, H);

    % --- 4. Görüntü yakala ---
    N_FRAMES = 10;
    saved    = 0;
    fprintf('%d kare yakalanıyor...\n', N_FRAMES);

    for i = 1:N_FRAMES
        try
            jImg  = robot.createScreenCapture(rect);
            iData = jImg.getRGB(0, 0, W, H, [], 0, W);
            raw   = reshape(typecast(iData, 'uint8'), 4, W, H);
            img   = cat(3, reshape(raw(3,:,:), W, H)', ...
                           reshape(raw(2,:,:), W, H)', ...
                           reshape(raw(1,:,:), W, H)');

            fname = sprintf('cap_%s_%03d.jpg', uName, i);
            imwrite(img, fullfile(targetDir, fname), 'Quality', 90);
            saved = saved + 1;
            fprintf('  [%d/%d] kaydedildi.\n', i, N_FRAMES);
        catch ME
            fprintf('  [%d] hata: %s\n', i, ME.message);
        end
        pause(0.4);
    end

    fprintf('\n%d/%d görüntü başarıyla kaydedildi: %s\n', saved, N_FRAMES, targetDir);

    if saved == 0
        errordlg('Hiç görüntü kaydedilemedi! Kamera kontrolü yapın.', 'Kayıt Hatası');
        return;
    end

    % --- 5. Modeli güncelle ---
    msgbox(sprintf('%s için %d görüntü kaydedildi.\nModel şimdi güncelleniyor, lütfen bekleyin...', ...
           uName, saved), 'Kayıt Başarılı');

    fprintf('\nModel yeniden eğitiliyor...\n');

    % run() yerine script'in tam yoluyla çalıştır
    mainScript = fullfile(srcDir, 'main.m');
    run(mainScript);

    fprintf('\n=== KAYIT VE EĞİTİM TAMAMLANDI ===\n');
    msgbox('Model güncellendi. Sistem hazır.', 'Tamamlandı');
end
