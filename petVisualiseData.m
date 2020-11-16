function petVisualiseData(PET,e)
global VDS
if nargin==0 || nargin==2 && ~strcmp(e.EventName,'loading')
    [PET,byla]=petLoad;
    if isempty(byla)
        return;
    end
    e=[];
    %figure('NumberTitle','off','Name',byla);
end
if isempty(VDS)
    V=load('petVisDataStruct.mat');
    VDS=V.VDS;
end
if ~iscell(PET)
    PET={PET};
end
for a=1:length(PET)
    P=PET{a};
    if length(P)>1 && VDS.GraphPar.Split_files
        for b=1:length(P)
            exgraf(P(b),e);
        end
    else
        exgraf(P,e);
    end
end
function h=exgraf(PET,e)
global VDS
DVP=VDS.GraphPar;
if DVP.New_figure==1 || ~ishandle(VDS.fh)
    h=figure('Renderer','painters');
    VDS.fh=h.Number;
%         huim = uimenu('label',' *** PET ***');
%         uimenu(huim,'label','Export to MS Excell','callback','petExportData');
else    
     h=VDS.fh;
end %('NumberTitle','off','Name',byla);
set(0,'CurrentFigure',h);
if DVP.Hold==0
    delete(allchild(gca));
end
if isempty(PET)
    return
end
pet=PET(end);
hold on;
name=replace(pet.Name,'_',' ');
title(name);
Data=petGetData(PET);
if strcmp(pet.ExPar.PsychoMethod,'constant_stimulus') || strcmp(pet.ExPar.PsychoMethod,'PAL_AMPM')
    PlotPsyFun(Data,h,name);
else
    PlotAdjustment(Data,name);
end
if VDS.GraphPar.Smooth
    line(Data.StimLevels,Data.Smooth,'displayname',['Smooth ',name],'Color','k');
end 
if VDS.GraphPar.Mean
    plot(Data.StimLevels,Data.Mean,'.--','MarkerSize',18,'displayname',['Mean ',name]...
        ,'Color','k')
end
if VDS.GraphPar.Raw
    if ~isempty(e) && isfield(e,'EventName') && strcmp(e.EventName,'loading')...
            && ~VDS.GraphPar.Convert && strcmp(pet.ExPar.PsychoMethod,'Adjustment')
        cntxt_menu=uicontextmenu('tag','cntxt_menu');
        uimenu(cntxt_menu,'Label','Present now','Callback','petUicontextmenu(gco,2)');
        for a=1:length(PET)
            for b=1:length(PET(a).Data.RawData)
                plot(PET(a).Data.RawData(b,1),PET(a).Data.RawData(b,2),'.','MarkerSize',9,...
                    'displayname',['Raw ',name]...
                    ,'Color','k','UserData',[b PET(a).Temp.a],'uicontextmenu',cntxt_menu);                
            end            
        end
        
    else
        plot(Data.Raw(:,1),Data.Raw(:,2),'.','MarkerSize',9,'displayname',['Raw ',name]...
            ,'Color','k');
    end
end 
if DVP.Hold==0
    hold off;
else
    hold on;
end
if VDS.GraphPar.Convert
     imk=petGetVisData(pet,'label');
     X1L=imk{2};
     YL=imk{1};
else
     X1L=pet.ExPar.IndepVar1Name;
     YL=pet.ExPar.DepVar1Name;
end
xlabel (X1L,'FontSize',12,'fontname','Arial Unicode MS');
ylabel (YL,'FontSize',12,'fontname','Arial Unicode MS');
grid on;
function PlotPsyFun(Data,figh, name)
figure(figh);
a=1;
StimLevels=Data(a).StimLevels;
line(StimLevels,Data(a).Mean,'LineStyle','none','Marker','.');
try
line(Data(a).StimLevelsFine,Data(a).Fit,'DisplayName',name,'Color','k');
line([Data(a).treshold-Data(a).seTreshold Data(a).treshold+Data(a).seTreshold],...
    [0.5 0.5],'DisplayName','seThreshold');
text(StimLevels(3),0.82,['Threshold=',num2str(Data(a).treshold)]);
text(StimLevels(3),0.72,['Slope=',num2str(Data(a).slope)]);
catch
end
function PlotAdjustment(Data,name)
global VDS
if Data.OutOfNum(1)>2
    if VDS.GraphPar.CI==true
        errorbar(Data.StimLevels,Data.Mean,Data.CI,'.--','displayname',['CI ',name]...
            ,'Color','k','MarkerSize',18);
    end
    if VDS.GraphPar.SE==true
        errorbar(Data.StimLevels,Data.Mean,Data.SE./2,'.--','displayname',['SE ',name]...
            ,'Color','k','MarkerSize',18);
    end
    if VDS.GraphPar.STD==true
        errorbar(Data.StimLevels,Data.Mean,Data.STD./2,'.--','displayname',['STD ',name]...
            ,'Color','k','MarkerSize',18);
    end     
end

 