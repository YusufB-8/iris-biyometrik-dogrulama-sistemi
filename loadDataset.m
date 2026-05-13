function [images, labels, names] = loadDataset(dataPath)
% loadDataset  Klasör başına bir kişi olacak şekilde veri yükler.
%
%   [images, labels, names] = loadDataset(dataPath)
%
%   Klasör yapısı:
%     data/
%       Kisi_A/
%         img1.jpg  img2.jpg  ...
%       Kisi_B/
%         img1.jpg  ...
%
%   Düzeltmeler:
%   - Gizli klasörler (. ve ..) yanı sıra sistem klasörleri de filtreleniyor
%   - Bozuk görüntüler try/catch ile atlanıyor, sistem çökmüyor
%   - Yükleme özeti geliştirildi

    if ~exist(dataPath, 'dir')
        error('Veri klasörü bulunamadı: %s', dataPath);
    end

    d  = dir(dataPath);
    df = [d.isdir] & ~strncmp({d.name}, '.', 1);
    subFolders = d(df);

    if isempty(subFolders)
        error('"%s" içinde hiç kişi klasörü bulunamadı!', dataPath);
    end

    images = {};
    labels = [];
    names  = {subFolders.name};

    fprintf('--- VERİ YÜKLENİYOR ---\n');

    for i = 1:length(subFolders)
        fPath = fullfile(dataPath, subFolders(i).name);

        fList = [ dir(fullfile(fPath, '*.jpg'));
                  dir(fullfile(fPath, '*.jpeg'));
                  dir(fullfile(fPath, '*.png'));
                  dir(fullfile(fPath, '*.bmp')) ];

        if isempty(fList)
            fprintf('!! UYARI: [%s] klasöründe resim yok, atlanıyor.\n', subFolders(i).name);
            continue;
        end

        loaded = 0;
        for j = 1:length(fList)
            try
                img = imread(fullfile(fPath, fList(j).name));
                images{end+1} = img;  %#ok<AGROW>
                labels(end+1) = i;    %#ok<AGROW>
                loaded = loaded + 1;
            catch
                fprintf('   !! Bozuk dosya atlandı: %s\n', fList(j).name);
            end
        end

        fprintf('-> [%s] : %d resim yüklendi.\n', subFolders(i).name, loaded);
    end

    if isempty(images)
        error('Hiç görüntü yüklenemedi! Klasör yapısını kontrol edin.');
    end

    fprintf('Toplam: %d görüntü, %d kişi.\n\n', length(images), length(unique(labels)));
end
