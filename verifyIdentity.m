function verifyIdentity(imagePath)
% verifyIdentity  Explainable AI destekli iris kimlik dogrulama sistemi

    [srcDir, ~, ~] = fileparts(mfilename('fullpath'));
    modelPath = fullfile(srcDir, '..', 'models', 'irisModel.mat');

    if ~exist(modelPath,'file')
        error('Model bulunamadi. Once main.m calistirin.');
    end
    load(modelPath, 'model', 'names', 'X');

    if ~exist(imagePath,'file')
        error('Goruntu bulunamadi: %s', imagePath);
    end

    img = imread(imagePath);

    % Dashboard ac, animasyonlu tarama baslat
    fig = createDashboard();
    drawnow;

    % --- ADIM 1: Liveness Check ---
    logMsg(fig, 'Kamera goruntüsü alindi...');
    pause(0.4); updateStep(fig, 1);

    logMsg(fig, 'Sahte goz kontrolu yapiliyor...');
    pause(0.5);
    isLive = checkLiveness(img);
    livenessScore = calcLivenessScore(img);

    if ~isLive
        logMsg(fig, 'UYARI: Sahte goz tespit edildi!');
        showDecision(fig, img, [], 'ERISIM REDDEDILDI', 'SAHTE GÖZ TESPİT EDİLDİ', ...
            0, 60, false, 'BILINMIYOR', livenessScore, 'YUKSEK', 0);
        return;
    end
    logMsg(fig, 'Canlilik dogrulandi.');
    updateStep(fig, 2);

    % --- ADIM 2: Ön işleme ---
    logMsg(fig, 'Iris bölgesi isleniyor...');
    pause(0.4);
    processedIris = preprocessIris(img);
    updateStep(fig, 3);

    % --- ADIM 3: Özellik çıkarımı ---
    logMsg(fig, 'Biyometrik özellikler cikariliyor...');
    pause(0.5);
    features = extractFeatures(processedIris);
    modelFeatDim = size(X,2);
    if length(features) > modelFeatDim
        features = features(1:modelFeatDim);
    elseif length(features) < modelFeatDim
        features = [features, zeros(1, modelFeatDim-length(features))];
    end
    updateStep(fig, 4);

    % --- ADIM 4: Eşleştirme ---
    logMsg(fig, 'Veritabani ile karsilastiriliyor...');
    pause(0.5);
    [labelIdx, score] = predict(model, features);
    score = score - min(score);
    if max(score) > 0, score = score / max(score) * 100; end
    conf = max(score);
    predictedName = names{double(labelIdx)};

    rawScore = sort(score,'descend');
    margin   = rawScore(1) - rawScore(2);
    isUnknown = contains(lower(predictedName),'unknown') || margin < 40;
    updateStep(fig, 5);

    % --- ADIM 5: Karar ---
    logMsg(fig, 'Karar motoru calistiriliyor...');
    pause(0.4);

    THRESHOLD = 60;
    if conf >= THRESHOLD && ~isUnknown
        granted     = true;
        statusTitle = 'ERİŞİM VERİLDİ';
        statusSub   = ['HOŞ GELDİN, ' upper(predictedName)];
        riskLevel   = 'DÜŞÜK';
        logMsg(fig, sprintf('Kimlik dogrulandi: %s', predictedName));
    else
        granted     = false;
        statusTitle = 'ERİŞİM REDDEDİLDİ';
        statusSub   = 'KİMLİK DOĞRULANAMADI';
        riskLevel   = 'YÜKSEK';
        logMsg(fig, 'Kimlik dogrulanamadi. Erisim engellendi.');
    end
    updateStep(fig, 6);

    pause(0.3);
    showDecision(fig, img, processedIris, statusTitle, statusSub, ...
        conf, THRESHOLD, granted, predictedName, livenessScore, riskLevel, margin);
end

% ================================================================
function score = calcLivenessScore(img)
    if size(img,3)==3, img = rgb2gray(img); end
    lap = abs(del2(double(img)));
    raw = mean(lap(:));
    % 0-100 arası normalize et
    score = max(0, min(100, (1 - abs(raw-3)/10) * 100));
end

% ================================================================
function fig = createDashboard()
    darkBg   = [0.05 0.05 0.08];
    fig = figure('Name','Iris Security System — Authentication Core', ...
                 'NumberTitle','off','Color',darkBg, ...
                 'Position',[60 50 1200 700], ...
                 'MenuBar','none','ToolBar','none', ...
                 'Tag','IrisDashboard');
    fig.UserData.logs = {};
    fig.UserData.stepAxes = [];
end

% ================================================================
function showDecision(fig, img, processedIris, statusTitle, statusSub, ...
    conf, threshold, granted, predictedName, livenessScore, riskLevel, margin)

    if ~isvalid(fig), return; end
    clf(fig);
    drawnow;

    % Renkler
    if granted
        accentCol = [0.00 0.88 0.50];
        bgDecision = [0.02 0.12 0.07];
    else
        accentCol = [1.00 0.25 0.25];
        bgDecision = [0.12 0.02 0.02];
    end

    darkBg   = [0.05 0.05 0.08];
    cardBg   = [0.09 0.09 0.13];
    textCol  = [0.92 0.92 0.95];
    dimText  = [0.50 0.50 0.55];
    gridCol  = [0.14 0.14 0.19];

    logs = fig.UserData.logs;

    % ── HEADER ──────────────────────────────────────────────────
    axH = axes(fig,'Position',[0 0.91 1 0.09],'Color',[0.06 0.06 0.10], ...
        'XLim',[0 1],'YLim',[0 1],'XTick',[],'YTick',[]);
    hold(axH,'on');
    fill(axH,[0 0.005 0.005 0],[0 0 1 1],accentCol,'EdgeColor','none');
    text(axH,0.015,0.65,'Uyarlanabilir Açıklanabilir İris Tanıma Sistemi', ...
        'Color',textCol,'FontSize',13,'FontWeight','bold');
    text(axH,0.015,0.22,'Yapay Zekâ Destekli Biyometrik Güvenlik Platformu', ...
        'Color',dimText,'FontSize',8.5);
    % Sağ durum
    fill(axH,[0.78 1 1 0.78],[0.1 0.1 0.9 0.9],[0.08 0.08 0.12],'EdgeColor','none');
    plot(axH,0.795,0.65,'o','MarkerFaceColor',accentCol,'MarkerEdgeColor','none','MarkerSize',7);
    text(axH,0.808,0.65,'Sistem Durumu: AKTİF', ...
        'Color',accentCol,'FontSize',9,'FontWeight','bold');
    text(axH,0.808,0.25,'Gerçek Zamanlı Mod', 'Color',dimText,'FontSize',8);
    text(axH,0.99,0.65,datestr(now,'HH:MM:SS'), ...
        'Color',accentCol,'FontSize',9,'FontWeight','bold','HorizontalAlignment','right');
    line(axH,[0 1],[0.03 0.03],'Color',accentCol,'LineWidth',1.5);

    % ── SOL PANEL: Görüntüler ────────────────────────────────────
    ax1 = axes(fig,'Position',[0.01 0.52 0.22 0.36]);
    if ~isempty(img), imshow(img,'Parent',ax1); end
    set(ax1,'XTick',[],'YTick',[]);
    title(ax1,'Ham Görüntü','Color',dimText,'FontSize',8,'FontWeight','normal');

    ax2 = axes(fig,'Position',[0.01 0.10 0.22 0.36]);
    if ~isempty(processedIris)
        imshow(processedIris,'Parent',ax2);
    else
        set(ax2,'Color',cardBg,'XTick',[],'YTick',[]);
        text(0.5,0.5,'—','Parent',ax2,'HorizontalAlignment','center','Color',dimText,'FontSize',20);
    end
    set(ax2,'XTick',[],'YTick',[]);
    title(ax2,'İşlenmiş İris (128×128)','Color',dimText,'FontSize',8,'FontWeight','normal');

    % ── ORTA PANEL: Karar Merkezi ────────────────────────────────
    % Güven çubuğu
    axBar = axes(fig,'Position',[0.26 0.72 0.44 0.14], ...
        'Color',cardBg,'XLim',[0 100],'YLim',[0 1], ...
        'XTick',0:20:100,'YTick',[],'XColor',dimText,'YColor',dimText, ...
        'FontSize',8,'XGrid','on','GridColor',gridCol);
    hold(axBar,'on');
    fill(axBar,[0 threshold threshold 0],[0.05 0.05 0.95 0.95], ...
        [0.18 0.05 0.05],'EdgeColor','none');
    fill(axBar,[threshold 100 100 threshold],[0.05 0.05 0.95 0.95], ...
        [0.04 0.14 0.07],'EdgeColor','none');
    fill(axBar,[0 conf conf 0],[0.08 0.08 0.92 0.92], ...
        accentCol,'EdgeColor','none','FaceAlpha',0.85);
    line(axBar,[threshold threshold],[0 1],'Color',[1 0.95 0.3],'LineWidth',2,'LineStyle','--');
    text(threshold+0.5,0.90,sprintf('Eşik %d%%',threshold), ...
        'Parent',axBar,'Color',[1 0.95 0.3],'FontSize',7,'VerticalAlignment','top');
    if conf > 10
        text(conf/2,0.5,sprintf('%.0f%%',conf),'Parent',axBar,'Color',darkBg, ...
            'FontSize',14,'FontWeight','bold','HorizontalAlignment','center','VerticalAlignment','middle');
    end
    title(axBar,'Eşleşme Güven Skoru','Color',dimText,'FontSize',8);

    % Açıklanabilir AI kartları
    cardData = {
        'KULLANICI',        predictedName,            textCol;
        'GÜVEN SKORU',      sprintf('%.1f%%',conf),   accentCol;
        'CANLILIK',         sprintf('%.0f%%',livenessScore), [0.3 0.9 0.5];
        'RİSK SEVİYESİ',    riskLevel,                ternary(granted,[0.3 0.9 0.5],[1 0.3 0.3]);
    };

    nC=4; cW=0.102; cH=0.14; sX=0.26; gX=0.116; cY=0.54;
    for k=1:nC
        cx=sX+(k-1)*gX;
        axC=axes(fig,'Position',[cx cY cW cH],'Color',cardBg, ...
            'XLim',[0 1],'YLim',[0 1],'XTick',[],'YTick',[],'Box','on', ...
            'XColor',gridCol,'YColor',gridCol);
        text(0.5,0.68,cardData{k,2},'Parent',axC,'Color',cardData{k,3}, ...
            'FontSize',10,'FontWeight','bold','HorizontalAlignment','center');
        text(0.5,0.20,cardData{k,1},'Parent',axC,'Color',dimText,'FontSize',7, ...
            'HorizontalAlignment','center');
    end

    % ── EXPLAINABLE AI PANELİ ────────────────────────────────────
    axExp = axes(fig,'Position',[0.26 0.10 0.44 0.40], ...
        'Color',cardBg,'XLim',[0 1],'YLim',[0 1], ...
        'XTick',[],'YTick',[],'Box','on', ...
        'XColor',gridCol,'YColor',gridCol);
    hold(axExp,'on');

    title(axExp,'Decision Engine — Karar Açıklaması','Color',dimText,'FontSize',8);

    % Karar kriterleri
    criteria = {
        conf >= threshold,  sprintf('Eşleşme skoru eşiği aştı (%.1f%% > %d%%)', conf, threshold);
        ~contains(lower(predictedName),'unknown'), 'Tanınan kimlik bilinmeyen değil';
        margin >= 40,       sprintf('Karar marjı yeterli (%.1f%%)', margin);
        livenessScore > 50, sprintf('Canlılık testi geçildi (%.0f%%)', livenessScore);
    };

    yPos = 0.82;
    for k=1:size(criteria,1)
        if criteria{k,1}
            marker = '✔'; col = [0.3 0.9 0.5];
        else
            marker = '✖'; col = [1.0 0.3 0.3];
        end
        text(axExp,0.04, yPos, marker, 'Color',col,'FontSize',12,'FontWeight','bold');
        text(axExp,0.11, yPos, criteria{k,2}, 'Color',textCol,'FontSize',9);
        yPos = yPos - 0.20;
    end

    % Alt çizgi
    line(axExp,[0.04 0.96],[0.18 0.18],'Color',gridCol,'LineWidth',0.8);
    text(axExp,0.5,0.09, ...
        'Explainable AI — Her karar gerekçeli ve şeffaf', ...
        'Color',dimText,'FontSize',7.5,'HorizontalAlignment','center','FontAngle','italic');

    % ── SAĞ PANEL: Karar Ekranı ──────────────────────────────────
    axD = axes(fig,'Position',[0.72 0.37 0.27 0.50], ...
        'Color',bgDecision,'XLim',[0 1],'YLim',[0 1], ...
        'XTick',[],'YTick',[],'Box','on', ...
        'XColor',accentCol,'YColor',accentCol);
    hold(axD,'on');

    if granted, ikonStr='OK'; else, ikonStr='NO'; end
    text(0.5,0.78,ikonStr,'Parent',axD,'Color',accentCol,'FontSize',32, ...
        'FontWeight','bold','HorizontalAlignment','center');
    text(0.5,0.55,statusTitle,'Parent',axD,'Color',accentCol,'FontSize',11, ...
        'FontWeight','bold','HorizontalAlignment','center');
    line(axD,[0.08 0.92],[0.46 0.46],'Color',accentCol,'LineWidth',0.8);
    text(0.5,0.34,statusSub,'Parent',axD,'Color',textCol,'FontSize',8, ...
        'HorizontalAlignment','center');
    text(0.5,0.14,datestr(now,'HH:MM:SS'),'Parent',axD,'Color',dimText, ...
        'FontSize',9,'HorizontalAlignment','center');

    % ── SYSTEM LOG ───────────────────────────────────────────────
    axLog = axes(fig,'Position',[0.72 0.10 0.27 0.24], ...
        'Color',[0.06 0.06 0.09],'XLim',[0 1],'YLim',[0 1], ...
        'XTick',[],'YTick',[],'Box','on', ...
        'XColor',gridCol,'YColor',gridCol);
    hold(axLog,'on');
    title(axLog,'Sistem Logu','Color',dimText,'FontSize',7.5);

    nLog = min(length(logs), 5);
    for k=1:nLog
        yp = 0.85 - (k-1)*0.17;
        text(axLog,0.03,yp,logs{end-nLog+k},'Color',[0.6 0.8 0.6],'FontSize',7.5);
    end

    % ── FOOTER ───────────────────────────────────────────────────
    axF=axes(fig,'Position',[0 0 1 0.08],'Color',[0.06 0.06 0.10], ...
        'XLim',[0 1],'YLim',[0 1],'XTick',[],'YTick',[]);
    line(axF,[0 1],[0.92 0.92],'Color',gridCol,'LineWidth',0.5);
    text(axF,0.5,0.38, ...
        'CASIA Iris Dataset  •  SVM (LBP+HOG)  •  CNN Karşılaştırmalı  •  Explainable AI  •  Liveness Detection', ...
        'Color',dimText,'FontSize',7.5,'HorizontalAlignment','center');

    drawnow;
end

% ── Animasyonlu adım güncelleyici ──────────────────────────────
function updateStep(fig, step)
    if ~isvalid(fig), return; end
    steps = {'Görüntü Alındı','Canlılık','Ön İşleme','Özellik','Eşleştirme','Karar'};
    n = length(steps);

    % İlk çağrıda step axes oluştur
    if isempty(fig.UserData.stepAxes) || ~isvalid(fig.UserData.stepAxes(1))
        darkBg = [0.05 0.05 0.08];
        cardBg = [0.09 0.09 0.13];
        axS = axes(fig,'Position',[0.26 0.88 0.44 0.03], ...
            'Color',darkBg,'XLim',[0 n],'YLim',[0 1], ...
            'XTick',[],'YTick',[],'Box','off');
        fig.UserData.stepAxes = axS;
    end

    axS = fig.UserData.stepAxes;
    if ~isvalid(axS), return; end
    cla(axS);
    hold(axS,'on');

    for k=1:n
        if k < step
            col = [0.00 0.88 0.50];
        elseif k == step
            col = [1.00 0.82 0.20];
        else
            col = [0.25 0.25 0.30];
        end
        fill(axS,[k-0.9 k-0.1 k-0.1 k-0.9],[0.1 0.1 0.9 0.9],col,'EdgeColor','none');
        text(axS,k-0.5,0.5,steps{k},'Color',[0.05 0.05 0.08],'FontSize',6.5, ...
            'FontWeight','bold','HorizontalAlignment','center','VerticalAlignment','middle');
    end
    drawnow;
end

% ── Log mesajı ──────────────────────────────────────────────────
function logMsg(fig, msg)
    if ~isvalid(fig), return; end
    t = datestr(now,'HH:MM:SS');
    entry = sprintf('[%s]  %s', t, msg);
    fig.UserData.logs{end+1} = entry;
    fprintf('%s\n', entry);
end

% ── Yardımcı ────────────────────────────────────────────────────
function out = ternary(cond,a,b)
    if cond, out=a; else, out=b; end
end
