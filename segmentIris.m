function irisRegion = segmentIris(img)
% segmentIris  Hough Transform ile göz bebeği ve iris sınırını tespit eder.
%              Sadece iris dokusunu döndürür (normalized 128x128).
%
%   irisRegion = segmentIris(img)
%
%   Adımlar:
%     1. Gri tonlama + gürültü giderme
%     2. Göz bebeği (pupil) tespiti — koyu dairesel bölge
%     3. Iris dış sınırı tespiti — açık dairesel bölge
%     4. Annular (halka) maske ile sadece iris dokusunu kes
%     5. 128x128 normalize et

    % --- Giriş kontrolü ---
    if size(img, 3) == 3
        img = rgb2gray(img);
    end
    img = im2uint8(img);

    % --- Ön işleme ---
    imgSmooth = imgaussfilt(img, 1.5);

    [H, W] = size(imgSmooth);

    % --- 1. Pupil tespiti (Hough çemberleri — koyu bölge) ---
    % Pupil genellikle görüntünün %10-35'i kadar çaplı
    rPupilMin = round(min(H, W) * 0.08);
    rPupilMax = round(min(H, W) * 0.25);

    % Kenar tespiti (Canny)
    edges = edge(imgSmooth, 'Canny', [0.05 0.15]);

    [centersPupil, radiiPupil] = imfindcircles(edges, [rPupilMin rPupilMax], ...
        'ObjectPolarity', 'dark', ...
        'Sensitivity', 0.92, ...
        'EdgeThreshold', 0.05);

    % Pupil bulunamazsa merkezi varsay
    if isempty(centersPupil)
        cxP = W / 2;
        cyP = H / 2;
        rP  = round(min(H, W) * 0.15);
    else
        cxP = centersPupil(1, 1);
        cyP = centersPupil(1, 2);
        rP  = radiiPupil(1);
    end

    % --- 2. Iris dış sınır tespiti ---
    rIrisMin = round(rP * 1.5);
    rIrisMax = round(min(H, W) * 0.55);

    [centersIris, radiiIris] = imfindcircles(edges, [rIrisMin rIrisMax], ...
        'ObjectPolarity', 'bright', ...
        'Sensitivity', 0.88, ...
        'EdgeThreshold', 0.05);

    if isempty(centersIris)
        % Iris bulunamazsa pupil'in ~3 katı yarıçap kullan
        cxI = cxP;
        cyI = cyP;
        rI  = rP * 2.8;
    else
        cxI = centersIris(1, 1);
        cyI = centersIris(1, 2);
        rI  = radiiIris(1);
    end

    % --- 3. Annular (halka) maske ---
    [XX, YY] = meshgrid(1:W, 1:H);
    distFromPupil = sqrt((XX - cxP).^2 + (YY - cyP).^2);
    distFromIris  = sqrt((XX - cxI).^2 + (YY - cyI).^2);

    mask = (distFromPupil > rP) & (distFromIris < rI);

    % Maskeyi uygula (iris dışını sıfırla)
    imgMasked = img;
    imgMasked(~mask) = 0;

    % --- 4. Sınır kutusunu kes ---
    % Iris merkezi etrafında kare bölge
    margin = round(rI * 1.1);
    x1 = max(1, round(cxI - margin));
    x2 = min(W, round(cxI + margin));
    y1 = max(1, round(cyI - margin));
    y2 = min(H, round(cyI + margin));

    cropped = imgMasked(y1:y2, x1:x2);

    % --- 5. Normalize et → 128x128 ---
    if isempty(cropped) || any(size(cropped) == 0)
        % Segmentasyon başarısız — orijinal görüntüyü döndür
        irisRegion = imresize(img, [128 128]);
        warning('segmentIris: Segmentasyon başarısız, ham görüntü kullanılıyor.');
    else
        irisRegion = imresize(cropped, [128 128]);
        % Kontrast artır
        irisRegion = adapthisteq(irisRegion, 'ClipLimit', 0.02);
    end

end
