function [Data,T]=petGetData(PET)
global VDS
T=[];
if isempty(VDS)
    V=load('petVisDataStruct.mat');
    VDS=V.VDS;
end
ds=PET(1).Data.RawData;
for a=2:length(PET)
    ds=[ds; PET(a).Data.RawData];
end
pet=PET(end);
ds(isnan(ds(:,2)),:)=[];
if VDS.GraphPar.Convert
    ds=konverteris(pet,ds);
end
ds=sortrows(ds);
% find second independant variable values (if it exist)
% if size(ds,2)>2
%     x2val=ds(1,2);
%     v=1;
%     xi=find(ds(:,2)==x2val(v));
%     c(v)={ds(xi,:)};
%     for b=2:size(ds,1)
%         if ~any(find((x2val)==ds(b,2)));
%             v=v+1;
%             x2val(v)=ds(b,2);
%             xi=find(ds(:,2)==x2val(v));
%             c(v)={ds(xi,:)};
%         end
%     end
% else
%     c={ds};
% end
% Ieskom Var1 reiksmiu ir atsaku
ci={};
x1val=ds(1);
v=1;
xi=ds(:,1)==x1val(v);
ci(1)={ds(xi,:)};
for b=2:size(ds,1)
    if ~any(find((x1val)==ds(b,1)))
        v=v+1;
        x1val(v)=ds(b,1);
        xi=ds(:,1)==x1val(v);
        ci(v)={ds(xi,:)};
    end
end
for v=1:length(ci)
    xyi=ci{v};
    yi=xyi(:,2);
    Data.StimLevels(v,1)=xyi(1);
    Data.OutOfNum(v,1)=length(xyi(:,2));
    Data.Mean(v,1)=mean(yi);
    if ~strcmp(pet.ExPar.PsychoMethod,'Adjustment')
        Data.NumPos(v,1)=sum(xyi(:,2));
    elseif strcmp(pet.ExPar.PsychoMethod,'Adjustment')
        Data.Y(v,:)=yi;
    end
end
if strcmp(pet.ExPar.PsychoMethod,'Adjustment')&& size(Data.Y,2)>2
    Data.STD=std(Data.Y')';
    Data.SE=Data.STD./Data.OutOfNum(1)^0.5;
    if exist('ttest')==2 && VDS.GraphPar.CI 
        [h,sig,CI] = ttest(Data.Y',0,0.05);       
        Data.CI=(abs(CI(1,:)-CI(2,:))')/2;
    end
end
if VDS.GraphPar.Smooth
    Data.Smooth=smoothdata(Data.Mean);
end
if exist('table','file')==2 && nargout==2
    T = table(Data.StimLevels,'VariableNames',{'StimLevels'});
    if VDS.GraphPar.Mean==true
        T=[T table(Data.Mean,'VariableNames',{'Mean'})];  
    end
    if Data.OutOfNum(1)>2 && strcmp(pet.ExPar.PsychoMethod,'Adjustment')
        if VDS.GraphPar.CI==true
            T=[T table(Data.CI,'VariableNames',{'CI_095'})];
        end
        if VDS.GraphPar.SE==true
            T=[T table(Data.SE,'VariableNames',{'SE'})];
        end
        if VDS.GraphPar.STD==true
            T=[T table(Data.STD,'VariableNames',{'STD'})];
        end        
    end
    if VDS.GraphPar.Smooth==true
        T=[T table(Data.Smooth,'VariableNames',{'Smooth'})];
    end
    if VDS.GraphPar.Raw==true && strcmp(pet.ExPar.PsychoMethod,'Adjustment')
        T=[T table(Data.Y,'VariableNames',{'Raw'})];
    elseif VDS.GraphPar.Raw==true
        T=[T table(Data.OutOfNum) table(Data.NumPos),'VariableNames',{'OutOfNum','NumPos'}];
    end    
else
    names=fieldnames(Data);
    T=struct2cell(Data);
    T(end + 1)={names};
end
if ~strcmp(pet.ExPar.PsychoMethod,'Adjustment') && exist('PAL_PFML_Fit')==2
    paramsValues = [0 0.18 0.02 0.02];
    paramsFree = [1 1 0 0];
    PF=@PAL_Logistic;
%     PF=@PAL_Gumbel;
  searchGrid.alpha = [-1:.01:1];    %structure defining grid to
  searchGrid.beta = 10.^[0:.01:1.5]; %search for initial values
  searchGrid.gamma = [0:.01:.04];
  searchGrid.lambda = [0:.01:.04];
    [paramsValues] = PAL_PFML_Fit(Data.StimLevels', Data.NumPos',...
        Data.OutOfNum', searchGrid, paramsFree,PF);
%     
%     [paramsValues] = PAL_PFML_Fit(Data.StimLevels', Data.NumPos',...
%         Data.OutOfNum', paramsValues, paramsFree,PF);
    Data.StimLevelsFine = [min(Data.StimLevels):(max(Data.StimLevels)- ...
        min(Data.StimLevels))./100:max(Data.StimLevels)]';
    Data.Fit = PF(paramsValues,Data.StimLevelsFine);
    SD=PAL_PFML_BootstrapParametric(Data.StimLevels',...
    Data.OutOfNum',paramsValues,paramsFree, 100, PF);
    Data.treshold=paramsValues(1);
    Data.seTreshold=SD(1);
    Data.slope=paramsValues(2);
%    [Dev Data.pDev]=PAL_PFML_GoodnessOfFit(Data.StimLevels,...
%         Data.NumPos, Data.OutOfNum,paramsValues,...
%         paramsFree,400, PF);
elseif strcmp(pet.ExPar.PsychoMethod,'Adjustment')
end

Data.Raw=ds;
function convertData=konverteris(PET,RawData)
%Converts experminent values to different units 
% according petVisDataStruct.mat file
 imk=petGetVisData(PET,'formula');
 EX=PET.StimPar;
 StimPar=PET.StimPar;
 SysPar=PET.SysPar;
 if isfield(PET.SysPar,'PixelSize')
     PixelSize=PET.SysPar.PixelSize;
 else
     PixelSize=1;
 end
 eval([PET.ExPar.IndepVar1Name,'=RawData(:,1);']);
 eval([PET.ExPar.DepVar1Name,'=RawData(:,2);']);
 StimPar.(PET.ExPar.IndepVar1Name)=RawData(:,1);
 StimPar.(PET.ExPar.DepVar1Name)=RawData(:,2);
 convertData(:,1)=eval(char(imk{2}));
 convertData(:,2)=eval(char(imk{1}));