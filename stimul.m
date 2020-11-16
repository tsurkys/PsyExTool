% [sx, sy, px,py]=stimul(EX),kur:
% EX - Eksperimento stimulo parametru struktura
% sx,sy - distraktoriaus elementu koordinates
% px,py - signalo elementu koordinates
% StimConfig - stimulo konfiguracija nurodant element? sek? raidemis:
%     r - referentine dalis (nekintama);
%     t - testine dalis (kintama);
%     d - distraktorius;
%     g - gap, tarpas tarp stimulo dali?;
% Ref - referentines dalies ilgis;
% Test - test dalies ilgis;
% GapHor - tarpo tarp elementu ilgis;
% DShiftVert - Distraktoriaus Vertikalus poslinkis;
% DShiftHor - Distraktoriaus Horizontalus poslinkis;
% DMirrorVert - Distraktoriaus atspindys per horizontalia asi;
% DMirrorHor - Distraktoriaus atspindys per vertikalia asi;
% Angle - Distraktoriau pasvirimo kampas;
% DistrN – distraktoriu skaicius;
% LL - Line Length Distraktoriaus linijos ilgis;
% DistrL - Distractor Length Distraktoriaus iligis (nebutinai linija);
% Step - Zingsnis tarp distraktoriaus elementu;
% Diff - Skirtumas tarp Ref ir Test.
function [sx, sy, px,py]=stimul(EX) % Primary function
EX=EXcorrect(EX);
%Calculation of coordinates
dx=[1:EX.DistrN]*EX.Step;
dy=sin(EX.Angle*pi()/360)*dx+EX.DShiftVert;
dx=cos(EX.Angle*pi()/360)*dx+EX.DShiftHor;
if isfield(EX,'DMirrorHor')
    dx=[dx -EX.DMirrorHor*dx];
    dy=[dy dy];
end
px=-EX.Ref-EX.GapHor/2;%+40;
r=[EX.Ref];
t=[EX.Test];
sx=[];sy=[];
remain=EX.StimConfig;
while true
   [str, remain] = strtok(remain);
   if isempty(str),  break;  end
    if strcmp(str,'d')
        sx=[sx px(end)+dx];
        sy=[sy dy];
    elseif strcmp(str,'-d')
        sx=[sx px(end)-dx];
        sy=[sy dy];
    elseif strcmp(str,'r') 
        px=[px px(end)+r];
    elseif strcmp(str,'t')
        px=[px px(end)+t];
    elseif strcmp(str,'g')
        px=[px px(end)+EX.GapHor];        
    end
end
if isfield(EX,'DMirrorVert')
    sy=[sy -sy*EX.DMirrorVert];
    sx=[sx sx*EX.DMirrorVert];
end
py=zeros(size(px));
if isfield(EX,'StimVert')
    s=-sx;
    sx=sy;
    sy=s-30;
    p=-px;
    px=py;
    py=p-30;
end
% EX strukturos elementu uzpildymas default reiksmemis
function EX=EXcorrect(ex)
EX=ex;
if ~isfield(EX,'DShiftVert')
    EX.DShiftVert=0;
end
if ~isfield(EX,'DShiftHor')
    EX.DShiftHor=0;
end
if ~isfield(EX,'Angle')
    EX.Angle=0;
end
if ~isfield(EX,'DistrL')
    EX.DistrL=EX.Ref;
end
if isfield(EX,'LL')
    EX.Step=1;
    EX.DistrN=EX.LL;
end
if ~isfield(EX,'Step')
    EX.Step=EX.DistrL/(EX.DistrN+1);
end
if isfield(EX,'Diff')
    EX.Test=EX.Ref+EX.Diff;
end
if ~isfield(EX,'GapHor')
    EX.GapHor=0;
end