% D � sutrumpinimas Distractor;
% P � sutrumpinimas Point;
% StimConfig - stimulo konfiguracija nurodant elementu seka raidemis:
%     r - referentine dalis (nekintama);
%     t - testine dalis (kintama);
%     d - distraktorius;
%     g - gap, tarpas tarp stimulo daliu;
% Ref - referentines dalies ilgis;
% Test - test dalies ilgis;
% Diff - Skirtumas tarp Ref ir Test (tada Test parametras nereikalingas);
% GapHor - tarpo tarp elementu (r ir t) ilgis;
% DShiftVert - Distraktoriaus Vertikalus poslinkis;
% DShiftHor - Distraktoriaus Horizontalus poslinkis;
% DMirrorVert - Distraktoriaus atspindys per horizontalia asi;
% DMirrorHor - Distraktoriaus atspindys per vertikalia asi;
% Angle - Distraktoriaus pasvirimo kampas;
% LL - Line Length Linijos pavidalo distraktoriaus ilgis (netaikomas su Step parametru);
% DistrL - Distractor Length Distraktoriaus iligis (dazniausiai nelinija);
% Step - Zingsnis tarp distraktoriaus elementu (netaikoma kartu su LL);
% DistrN � distraktoriu skaicius;
% *********
% stimulFIG specifiniai parametrai:

% Marker, DMarker, PMarker � markerio tipas, o apvaus, I � staciakampis;
%   arba + | * | . | x | square | diamond | v | ^ | > | < | pentagram | hexagram
% DMarkerSize, PMarkerSize � markerio dydis (jei staciakampis, du skaiciai)
% DLineWidth, PLineWidth � vertikalaus bruksnio sotris;
% DLineHeight, PLineHeight � vertikalaus bruksnio  aukstis;
% FLum DLum PLum - figuros ryskis ([R G B] nuo 0 iki 1, default [1 1 1])
% BLum Background Luminance, fono spalva ([R G B] nuo 0 iki 1, default [0 0 0])
% WindowPosition - [x y plotis aukstis] default [800 220 800 600]
% FixPointPositionX - Fixation Point Position, [x]

function stimulFIG(EX) % Primary function
persistent ah pa fh;
global PET;
if strcmp(PET.Temp.State,'stop')
    delete(get(ah,'children'));return;
end
EX=checkex(EX);
if strcmp(PET.Temp.State,'start') || ~ishandle(33)
    fh=figure(33);
            set(fh,'units','pixels','position',EX.WindowPosition,'Renderer','painters',...
                'GraphicsSmoothing','on','color',EX.BLum,...
            'menubar','none','toolbar','none');
        if size(get(0,'MonitorPositions'),1)>1
            fh.WindowState='fullscreen';
        end
    if isempty(ah) || ~isvalid(ah)
        ah=axes('units','pixels','XLim',[-EX.WindowPosition(3)/2 EX.WindowPosition(3)/2],...
            'YLim',[-EX.WindowPosition(4)/2 EX.WindowPosition(4)/2],'XLimMode','manual',...
            'YLimMode','manual','Color', [0 0 0],'units','pixels','visible','off',...
            'Position',[1,1,EX.WindowPosition(3), EX.WindowPosition(4)]);
    end
end
[dx,dy,px,py]=stimul(EX);
%PAISYMAS naudojant line funkcija
if ~isempty(get(ah,'children'))
    delete(get(ah,'children'));
end
if isfield(EX,'FixPointPositionX')
    lh=line(ah,EX.FixPointPositionX,0,'Color',[1 1 1],...
        'Marker','.','MarkerSize',15);
    pause(1);
    delete(lh);
    pause(0.5);
end
if isfield(EX,'PictureName')
    if ~ischar(EX.PictureName)
        EX.PictureName=num2str(EX.PictureName);
    end
    P=imread([EX.PictureName,'.png']);
    if isempty(pa) || ~isvalid(pa)
        pa=axes(fh,'units','pixels');
    end
    set(pa,'Position',[EX.WindowPosition(3)/2+px(1)+1 0 EX.Ref EX.WindowPosition(4)]);
    imshow(P,'parent',pa);
end
if strcmp(EX.PMarker,'I')||strcmp(EX.PMarker,'line') 
    lh=line(ah,[px;px],[py-0.5*EX.PMarkerSize(end);py+0.5*EX.PMarkerSize(end)],...
        'LineStyle','-','LineWidth',EX.PMarkerSize(1)-(0.25*EX.PMarkerSize(1)),'Color',EX.PLum,'Marker','none');
% elseif strcmp(EX.PMarker,'rectangle')||strcmp(EX.PMarker,'ellipse')
%     for a=1:length(px)
%         an=annotation(EX.PMarker,'units','pixels','visible','on',...
%             'position', [px(a) py(a) EX.PMarkerSize(1) EX.PMarkerSize(end)],...
%             'Color','none','FaceColor',EX.PLum);
%     end
else
    lh=line(ah,px,py,'LineStyle','none','Color',EX.PLum,'Marker',EX.PMarker...
        ,'Markerfacecolor',EX.PLum,'Markeredgecolor','none','MarkerSize',EX.PMarkerSize(1)); 
end
if strcmp(EX.DMarker,'I')||strcmp(EX.DMarker,'line')
%     lh=line(ah,[dx;dx],[dy-round(0.5*EX.DMarkerSize(end));dy+round(0.5*EX.DMarkerSize(end))],...
%         'LineStyle','-','LineWidth',EX.DMarkerSize(1)-1,'Color',EX.DLum,'Marker','none');
        lh=line(ah,[dx;dx],[dy-0.5*EX.DMarkerSize(end);dy+0.5*EX.DMarkerSize(end)],...
        'LineStyle','-','LineWidth',EX.DMarkerSize(1)-0.25*EX.DMarkerSize(1),'Color',EX.DLum,'Marker','none');
else
    lh=line(ah,dx,dy,'LineStyle','none','Color',EX.DLum,'Marker',EX.DMarker...
        ,'Markerfacecolor',EX.DLum,'Markeredgecolor','none','MarkerSize',EX.DMarkerSize(1));
end  
if isfield(EX,'AddOn')
    switch EX.AddOn
        case 'patch'
%             xData=[px(1) px(1) px(2)];
%             yData=[50 -50 0];
            if ischar(EX.xData)
                EX.xData=eval(EX.xData);
            end
            patch(ah, EX.xData, EX.yData, 'k', 'EdgeColor',EX.DLum,'LineWidth',EX.LineWidth);
            if isfield(EX,'xData1')
                if ischar(EX.xData1)
                    EX.xData1=eval(EX.xData1);
                end   
                patch(ah, EX.xData1, EX.yData1, 'k', 'EdgeColor',EX.DLum,'LineWidth',EX.LineWidth);
            end
    end
end
                             
if isfield(EX,'FixPointPositionX')
    pause(0.5);
    if ~isempty(get(ah,'children'))
        delete(get(ah,'children'));
    end
end

function EX=checkex(EX) 
if ~isfield(EX,'WindowPosition')
    EX.WindowPosition=[800 220 800 600];
    if size(get(0,'MonitorPositions'),1)>1
        EX.WindowPosition=[800 220 1920 1080];
    else
        EX.WindowPosition=[800 220 800 600];
    end
end
if ~isfield(EX,'DLum')
    EX.DLum=[1 1 1];
end
if ~isfield(EX,'PLum')
    EX.PLum=[1 1 1];
end
if isfield(EX,'FLum')
    EX.PLum=EX.FLum;
    EX.DLum=EX.FLum;
end
if ~isfield(EX,'BLum')
    EX.BLum=[0 0 0];
end
if isfield(EX,'Marker')
    EX.DMarker=EX.Marker;
    EX.PMarker=EX.Marker;
end
if isfield(EX,'LineHeight')
    EX.DMarkerSize(2)=EX.LineHeight;
    EX.PMarkerSize(2)=EX.LineHeight;
end
if isfield(EX,'DLineWidth')
    EX.DMarkerSize=[EX.DLineWidth, EX.DLineHeight];
end
if isfield(EX,'PLineWidth')
    EX.PMarkerSize=[EX.PLineWidth, PLineHeight];
end   
%     if EX.PMarkerSize(1)<2
%         EX.PMarkerSize(1)=2;
%     end  
%     if EX.DMarkerSize(1)<2
%         EX.DMarkerSize(1)=2;
%     end    
