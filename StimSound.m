% audio stimulus generation function
% SDur - Signal Duration;
% SVol - Signal Volume;
% SFr - Signal Frequency;
% DDur - Distractor Duration;
% DVol - Distractor Volume;
% signal? pozicijos skai?iuojamos nuo vidurio
function StimSound(EX) % Primary function
global PET
if strcmp(PET.Temp.State,'stop');return;end
sfr=44100;% sample frequency
Dsound=zeros(6.3*sfr,1);
Ssound=zeros(6.3*sfr,1);
if isfield(EX,'DFr')%|| isfield(EX,'DType') && strcmp(EX.DType,'sin')
    Dur=round(EX.DDur*EX.DFr*2)*0.5/EX.DFr;
    DVec=1:(Dur*sfr);
    % generuoja distraktoriaus signala LSigdur ilgio ir DVol garsumo
    DVec=sin(DVec.*(2*pi*EX.DFr/sfr)).*EX.DVol;
else
    %generate noise vector
    DVec=rand(EX.DDur.*sfr,1);
    %generuoja triuksma DDur ilgio ir DVol garsumo
    DVec=(1-EX.DVol)./2+DVec.*EX.DVol;
    DVec(1:150)=DVec(1:150).*[1:150]'/150;
    DVec(end-149:end)=DVec(end-149:end).*[150:-1:1]'/150;
end
% generuoja signalo vektoriu
Dur=round(EX.SDur*EX.SFr*2)*0.5/EX.SFr; %padaro kad nebutu fazes suolio
SVec=1:Dur*sfr;
% generuoja signala LSigdur ilgio ir SVol garsumo
SVec=sin(SVec.*(2*pi*EX.SFr/sfr)).*EX.SVol;
SVec(1:150)=SVec(1:150).*[1:150]/150;
SVec(end-149:end)=SVec(end-149:end).*[150:-1:1]/150;
% k=find(SVec>-0.1 & SVec<0.1,1,'last');
[dx, dy, sx,sy]=stimul(EX);
sx=sx*sfr;
sl=length(SVec);
for x=1:length(sx)
    Spos=floor((sx(x)-0.5*sl:sx(x)+0.5*sl-1)+sfr*2.6);
    Ssound(Spos)=SVec;
end
dx=dx*sfr;
sl=length(DVec);
for x=1:length(dx)
    Spos=floor((dx(x)-0.5*sl:dx(x)+0.5*sl-1)+sfr*2.6);
    Dsound(Spos)=DVec;
end
SDsound=(Ssound+Dsound)/2;
% SDsound=[Ssound Dsound];
sound(SDsound,sfr);
