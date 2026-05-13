function mainPanel()
    [srcDir, ~, ~] = fileparts(mfilename('fullpath'));
    modelPath = fullfile(srcDir, '..', 'models', 'irisModel.mat');
 
    C.dark   = [0.05 0.05 0.08];
    C.card   = [0.09 0.09 0.13];
    C.border = [0.16 0.16 0.22];
    C.text   = [0.92 0.92 0.95];
    C.dim    = [0.45 0.45 0.52];
    C.green  = [0.00 0.88 0.50];
    C.blue   = [0.20 0.56 1.00];
    C.yellow = [1.00 0.82 0.20];
    C.purple = [0.65 0.35 1.00];
    C.orange = [1.00 0.55 0.15];
    C.cyan   = [0.00 0.82 0.92];
 
    nKisi = 0; modelOK = exist(modelPath,'file');
    if modelOK
        try; tmp=load(modelPath,'names'); nKisi=length(tmp.names); catch; end
    end
     scr = get(0,'MonitorPositions');
W = scr(1,3);
H = scr(1,4) - 40;  
 
    fig = uifigure('Name','BioSecure AI — Explainable Iris Recognition', ...
        'Color',C.dark,'WindowState','maximized', ...
        'Resize','off','AutoResizeChildren','off');
 
    PAD=22; GAP=12; HH=68; FH=38;
    innerW = W - PAD*2;
 
  
    availH = H - HH - 2 - FH - GAP*3;
    logH   = round(availH * 0.20);
    row2H  = round(availH * 0.14);
    row1H  = availH - logH - row2H - GAP*2;
    row3Y  = FH;
    row3H  = logH;
    row2Y  = row3Y + row3H + GAP;
    row1Y  = row2Y + row2H + GAP;
    heroW  = round(innerW * 0.62);
    sideW  = innerW - heroW - GAP;
 
    
    hBg = uipanel(fig,'Position',[0 H-HH W HH], ...
        'BackgroundColor',[0.07 0.07 0.11],'BorderType','none');
    uipanel(fig,'Position',[0 H-HH-2 W 2], ...
        'BackgroundColor',C.cyan,'BorderType','none');
    uilabel(hBg,'Position',[PAD 38 460 24],'Text','BioSecure AI', ...
        'FontColor',C.text,'FontSize',17,'FontWeight','bold', ...
        'BackgroundColor',[0.07 0.07 0.11]);
    uilabel(hBg,'Position',[PAD 14 500 18], ...
        'Text','Explainable Adaptive Iris Recognition Platform', ...
        'FontColor',C.dim,'FontSize',8.5,'BackgroundColor',[0.07 0.07 0.11]);
 
    hItems = {'● AKTİF',C.green,'Sistem Hazır'; ...
              sprintf('👤 %d Kullanıcı',nKisi),C.blue,'Kayıtlı'; ...
              '🧠 Model: Hazır',C.purple,'SVM + CNN'; ...
              ['🕒 ' datestr(now,'HH:MM')],C.cyan,'Gerçek Zamanlı'};
    hcW=115; hcGap=8;
    startX = W - PAD - size(hItems,1)*(hcW+hcGap);
    for k=1:size(hItems,1)
        cx = startX + (k-1)*(hcW+hcGap);
        p = uipanel(hBg,'Position',[cx 5 hcW 58], ...
            'BackgroundColor',[0.11 0.11 0.16],'BorderType','none');
        uilabel(p,'Position',[0 32 hcW 20],'Text',hItems{k,1}, ...
            'FontColor',hItems{k,2},'FontSize',8.5,'FontWeight','bold', ...
            'HorizontalAlignment','center','BackgroundColor',[0.11 0.11 0.16]);
        uilabel(p,'Position',[0 10 hcW 18],'Text',hItems{k,3}, ...
            'FontColor',C.dim,'FontSize',7.5,'HorizontalAlignment','center', ...
            'BackgroundColor',[0.11 0.11 0.16]);
    end

    heroP = uipanel(fig,'Position',[PAD row1Y heroW row1H], ...
        'BackgroundColor',C.card,'BorderType','line','HighlightColor',C.cyan);
    uipanel(heroP,'Position',[0 0 5 row1H],'BackgroundColor',C.cyan,'BorderType','none');
    uilabel(heroP,'Position',[18 row1H-38 300 26],'Text','CANLI İRİS TARAMA', ...
        'FontColor',C.cyan,'FontSize',14,'FontWeight','bold','BackgroundColor',C.card);
    uilabel(heroP,'Position',[18 row1H-56 500 16], ...
        'Text','Kameranıza gözünüzü gösterin ve kimliğinizi doğrulayın', ...
        'FontColor',C.dim,'FontSize',8.5,'BackgroundColor',C.card);
 
    camH = row1H - 130;
    camW = heroW - 50;
    camP = uipanel(heroP,'Position',[18 70 camW camH], ...
        'BackgroundColor',[0.06 0.10 0.12],'BorderType','line', ...
        'HighlightColor',[0.00 0.50 0.60]);
    uilabel(camP,'Position',[0 camH/2-20 camW 40], ...
        'Text','[ Kamera Görüntüsü ]','FontColor',[0.20 0.40 0.45],'FontSize',13, ...
        'HorizontalAlignment','center','BackgroundColor',[0.06 0.10 0.12]);
 
    statusLbl = uilabel(heroP,'Position',[18 46 300 18], ...
        'Text','● Durum: Bekleniyor','FontColor',C.yellow,'FontSize',9, ...
        'BackgroundColor',C.card);
    confLbl = uilabel(heroP,'Position',[18 28 300 16], ...
        'Text','Sonuç: —   Confidence: —','FontColor',C.dim,'FontSize',8.5, ...
        'BackgroundColor',C.card);
    uibutton(heroP,'Position',[18 4 200 40],'Text','▶  Taramayı Başlat', ...
        'FontSize',10,'FontWeight','bold','FontColor',C.dark,'BackgroundColor',C.cyan, ...
        'ButtonPushedFcn',@(~,~) runLive(statusLbl,confLbl));
    uibutton(heroP,'Position',[226 4 170 40],'Text','  Dosyadan Yükle', ...
        'FontSize',9.5,'FontWeight','bold','FontColor',C.green, ...
        'BackgroundColor',[0.07 0.12 0.09], ...
        'ButtonPushedFcn',@(~,~) doVerify(modelPath,statusLbl,confLbl));
 
    sideP = uipanel(fig,'Position',[PAD+heroW+GAP row1Y sideW row1H], ...
        'BackgroundColor',C.card,'BorderType','line','HighlightColor',C.blue);
    uipanel(sideP,'Position',[0 0 5 row1H],'BackgroundColor',C.blue,'BorderType','none');
    uilabel(sideP,'Position',[16 row1H-40 sideW-24 26],'Text','YENİ KULLANICI', ...
        'FontColor',C.blue,'FontSize',13,'FontWeight','bold','BackgroundColor',C.card);
    uilabel(sideP,'Position',[16 row1H-60 sideW-24 18], ...
        'Text','Yeni iris verisi ekle ve modeli güncelle', ...
        'FontColor',C.dim,'FontSize',8.5,'BackgroundColor',C.card,'WordWrap','on');
    regInfo = {sprintf('Kayıtlı: %d kullanıcı',nKisi);'Format: JPG/PNG';'Kamera: Windows Cam'};
    for k=1:length(regInfo)
        uilabel(sideP,'Position',[16 row1H-88-(k-1)*22 sideW-24 18], ...
            'Text',['  ' regInfo{k}],'FontColor',C.dim,'FontSize',8.5,'BackgroundColor',C.card);
    end
    uibutton(sideP,'Position',[16 10 sideW-32 40],'Text','+ Kayıt Oluştur', ...
        'FontSize',10,'FontWeight','bold','FontColor',C.dark,'BackgroundColor',C.blue, ...
        'ButtonPushedFcn',@(~,~) userRegistration());
 
    cardTitles = {'METRİKLER','ROC ANALİZİ','SVM vs CNN','SİSTEM BİLGİSİ'};

cardSubs = {'Accuracy & Confusion', ...
            'AUC eğrileri', ...
            'Model kıyası', ...
            'Dataset detayı'};

cardCols = {C.yellow, C.purple, C.orange, C.blue};

cardCBs = {
    @(~,~)doMetrics(modelPath)
    @(~,~)doROC(modelPath)
    @(~,~)doCompare(modelPath,srcDir)
    @(~,~)doInfo(modelPath,srcDir)
};
    nC = length(cardTitles);
    cW = round((innerW - GAP*(nC-1)) / nC);
    for k=1:nC
        cx = PAD + (k-1)*(cW+GAP);
        cp = uipanel(fig,'Position',[cx row2Y cW row2H], ...
            'BackgroundColor',C.card,'BorderType','line','HighlightColor',C.border);
        uipanel(cp,'Position',[0 0 5 row2H],'BackgroundColor',cardCols{k},'BorderType','none');
        uilabel(cp,'Position',[14 row2H-34 cW-20 20],'Text',cardTitles{k}, ...
            'FontColor',cardCols{k},'FontSize',10,'FontWeight','bold','BackgroundColor',C.card);
        uilabel(cp,'Position',[14 row2H-52 cW-20 16],'Text',cardSubs{k}, ...
            'FontColor',C.dim,'FontSize',8,'BackgroundColor',C.card,'WordWrap','on');
        btn=uibutton(cp,'Position',[0 0 cW row2H],'Text','', ...
            'BackgroundColor',C.card,'ButtonPushedFcn',cardCBs{k});
        uistack(btn,'bottom');
    end
 
    logW   = round(innerW * 0.70);
    trainW = innerW - logW - GAP;
 
    logP = uipanel(fig,'Position',[PAD row3Y logW row3H], ...
        'BackgroundColor',[0.04 0.06 0.04],'BorderType','line', ...
        'HighlightColor',[0.10 0.20 0.10]);
    uilabel(logP,'Position',[14 row3H-22 200 16],'Text','SYSTEM LOG', ...
        'FontColor',C.dim,'FontSize',8,'FontWeight','bold', ...
        'BackgroundColor',[0.04 0.06 0.04]);
    logLines = {
        sprintf('[%s]  Sistem başlatıldı — BioSecure AI v2.0',datestr(now,'HH:MM:SS'));
        sprintf('[%s]  Model yüklendi — %d kullanıcı kayıtlı',datestr(now,'HH:MM:SS'),nKisi);
        sprintf('[%s]  SVM + CNN modelleri aktif',datestr(now,'HH:MM:SS'));
        sprintf('[%s]  Liveness detection: AÇIK',datestr(now,'HH:MM:SS'));
        sprintf('[%s]  Gerçek zamanlı mod başlatıldı',datestr(now,'HH:MM:SS'));
    };
    lineH = min(20, round((row3H-36) / length(logLines)));
    for k=1:length(logLines)
        yp = row3H - 36 - (k-1)*lineH;
        if yp < 4, break; end
        uilabel(logP,'Position',[14 yp logW-28 16],'Text',logLines{k}, ...
            'FontColor',[0.40 0.80 0.40],'FontSize',8, ...
            'BackgroundColor',[0.04 0.06 0.04],'FontName','Courier New');
    end
 
    trainP = uipanel(fig,'Position',[PAD+logW+GAP row3Y trainW row3H], ...
        'BackgroundColor',C.card,'BorderType','line','HighlightColor',C.orange);
    uipanel(trainP,'Position',[0 0 5 row3H],'BackgroundColor',C.orange,'BorderType','none');
    uilabel(trainP,'Position',[14 row3H-32 trainW-20 20],'Text','MODEL EĞİT', ...
        'FontColor',C.orange,'FontSize',12,'FontWeight','bold','BackgroundColor',C.card);
    uilabel(trainP,'Position',[14 row3H-50 trainW-20 16],'Text','SVM + CNN yeniden eğit', ...
        'FontColor',C.dim,'FontSize',8.5,'BackgroundColor',C.card);
    uilabel(trainP,'Position',[14 row3H-66 trainW-20 14], ...
        'Text',sprintf('Son: %s',datestr(now,'dd.mm.yyyy')), ...
        'FontColor',C.dim,'FontSize',8,'BackgroundColor',C.card);
    uibutton(trainP,'Position',[14 8 trainW-28 36],'Text','Eğitimi Başlat', ...
        'FontSize',10,'FontWeight','bold','FontColor',C.dark,'BackgroundColor',C.orange, ...
        'ButtonPushedFcn',@(~,~) doTrain(srcDir));
 
    % ── FOOTER ──
    uipanel(fig,'Position',[0 0 W FH],'BackgroundColor',[0.06 0.06 0.10],'BorderType','none');
    uipanel(fig,'Position',[0 FH W 1],'BackgroundColor',C.border,'BorderType','none');
    uilabel(fig,'Position',[0 9 W 20], ...
        'Text','CASIA Iris Dataset  •  SVM (LBP+HOG)  •  CNN  •  Explainable AI  •  Liveness Detection', ...
        'FontColor',C.dim,'FontSize',8,'HorizontalAlignment','center', ...
        'BackgroundColor',[0.06 0.06 0.10]);
end
 
function out = ternary(cond,a,b)
    if cond, out=a; else, out=b; end
end
 
function runLive(statusLbl,confLbl)
    if isvalid(statusLbl), statusLbl.Text='● Durum: Analiz ediliyor...'; statusLbl.FontColor=[1 0.82 0.2]; end
    drawnow;
    try
        liveVerify();
        if isvalid(statusLbl), statusLbl.Text='● Durum: Tamamlandı'; statusLbl.FontColor=[0 0.88 0.5]; end
        if isvalid(confLbl), confLbl.Text='Sonuç: Analiz tamam'; end
    catch
        if isvalid(statusLbl), statusLbl.Text='● Durum: Hata'; statusLbl.FontColor=[1 0.25 0.25]; end
    end
end
 
function doVerify(modelPath,statusLbl,confLbl)
    if ~exist(modelPath,'file'), msgbox('Model bulunamadi!','Hata','error'); return; end
    [f,p]=uigetfile({'*.jpg;*.jpeg;*.png;*.bmp','Goruntu'},'Gozu Sec');
    if isequal(f,0), return; end
    if isvalid(statusLbl), statusLbl.Text='● Durum: Analiz ediliyor...'; statusLbl.FontColor=[1 0.82 0.2]; end
    drawnow;
    try
        verifyIdentity(fullfile(p,f));
        if isvalid(statusLbl), statusLbl.Text='● Durum: Tamamlandı'; statusLbl.FontColor=[0 0.88 0.5]; end
    catch
        if isvalid(statusLbl), statusLbl.Text='● Durum: Hata'; statusLbl.FontColor=[1 0.25 0.25]; end
    end
end
 
function doMetrics(modelPath)
    if ~exist(modelPath,'file'), msgbox('Model bulunamadi!','Hata','error'); return; end
    d=load(modelPath,'model','X','Y'); biometricMetrics(d.model,d.X,d.Y);
end
 
function doROC(modelPath)
    if ~exist(modelPath,'file'), msgbox('Model bulunamadi!','Hata','error'); return; end
    d=load(modelPath,'model','X','Y'); plotROC(d.model,d.X,d.Y);
end
 
function doTrain(srcDir)
    ch=questdlg('Model yeniden egitilecek. Devam?','Egitim','Evet','Hayir','Evet');
    if ~strcmp(ch,'Evet'), return; end
    run(fullfile(srcDir,'main.m')); msgbox('Egitim tamamlandi!','Tamamlandi');
end
 
function doCompare(modelPath,srcDir)
    if ~exist(modelPath,'file'), msgbox('Model bulunamadi!','Hata','error'); return; end
    cnnPath=fullfile(srcDir,'..','models','cnnModel.mat');
    if ~exist(cnnPath,'file'), msgbox('CNN modeli yok!','Hata','error'); return; end
    s=load(modelPath,'model','X','Y','names'); c=load(cnnPath,'cnnModel');
    compareModels(s.model,c.cnnModel,s.X,s.Y,[],[],s.names);
end
 
function doInfo(modelPath,srcDir)
    if ~exist(modelPath,'file'), msgbox('Model henuz egitilmedi.','Bilgi'); return; end
    d=load(modelPath,'names','X','Y');
    msg=sprintf(['DATASET\n  Kayitli kisi  : %d\n  Egitim ornegi : %d\n  Ozellik boyutu: %d\n\n'...
        'YONTEM\n  Siniflandirici: SVM (ECOC, RBF)\n  Ozellikler    : LBP + HOG\n'...
        '  Augmentation  : x4\n  Liveness      : Laplacian\n'], ...
        length(d.names),size(d.X,1),size(d.X,2));
    msgbox(msg,'Sistem Bilgisi');
end
 