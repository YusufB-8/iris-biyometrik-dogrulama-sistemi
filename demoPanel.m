function demoPanel()
% demoPanel  Ana demo arayüzü — dosya seçer ve kimlik doğrular.
%
%   Düzeltmeler:
%   - Model var mı kontrolü eklendi
%   - Çoklu dosya seçimi desteklendi (batch test)
%   - Hata mesajları iyileştirildi

    clc;
    fprintf('=================================\n');
    fprintf('   IRIS SECURITY SYSTEM v2.0\n');
    fprintf('      Demo Paneli\n');
    fprintf('=================================\n');

    % --- Model kontrolü ---
    [srcDir, ~, ~] = fileparts(mfilename('fullpath'));
    modelPath = fullfile(srcDir, '..', 'models', 'irisModel.mat');

    if ~exist(modelPath, 'file')
        choice = questdlg('Model bulunamadı. main.m çalıştırılsın mı?', ...
                          'Model Yok', 'Evet', 'Hayır', 'Evet');
        if strcmp(choice, 'Evet')
            run(fullfile(srcDir, 'main.m'));
        else
            return;
        end
    end

    % --- Dosya seçimi (çoklu) ---
    [files, path] = uigetfile( ...
        {'*.jpg;*.jpeg;*.png;*.bmp', 'Görüntü Dosyaları (*.jpg, *.png, *.bmp)'}, ...
        'Test Edilecek Gözleri Seç', ...
        'MultiSelect', 'on');

    if isequal(files, 0)
        disp('Seçim yapılmadı. Çıkılıyor...');
        return;
    end

    % Tekli seçim de cell'e çevir
    if ischar(files)
        files = {files};
    end

    % --- Her dosyayı işle ---
    for k = 1:length(files)
        fullPath = fullfile(path, files{k});
        fprintf('\n[%d/%d] Analiz ediliyor: %s\n', k, length(files), files{k});
        try
            verifyIdentity(fullPath);
        catch ME
            fprintf('!! HATA (%s): %s\n', files{k}, ME.message);
        end
    end

    fprintf('\n--- Tüm analizler tamamlandı ---\n');
end
