function M=petAdapt_constant_stimulus(response)
persistent CP
global PET
PET.Temp.Enter=1;
if strcmp(PET.Temp.State,'start')
    CP=SetupCP;
    PET.Temp.Enter=0;
    M.IndepVarVal(1)=CP.X1(CP.ord(PET.Temp.cinx));
%     M.IndepVarVal(2)=CP.X2(CP.ord(PET.Temp.cinx));
    PET.Data.InitVal=[CP.X1(CP.ord)' CP.Y'];
    PET.Temp.n=CP.n;
    return
elseif strcmp(PET.Temp.State,'response')
    if isempty(CP)
        CP=PET.Temp.CP;
    end
    if response==0; return; end
    response=(response+1)/2;
    CP.Y(CP.ord(PET.Temp.cinx))=response;
elseif strcmp(PET.Temp.State,'correct')
    CP=petcorrect(response);
    if CP.stop==0
        return
    end
else
    return
end
M.Response=response;
if PET.Temp.cinx>=length(CP.ord)
    PET.Temp.State='stop';
    CP.stop=1;
    disp('End of the experiment');
else
    setview(CP,10);
    M.IndepVarVal(1)=CP.X1(CP.ord(PET.Temp.cinx+1));
%     M.IndepVarVal(2)=CP.X2(CP.ord(PET.Temp.cinx));
    PET.Temp.State='continue';
end 
PET.Temp.CP=CP;
function CP=SetupCP
global PET
ExPar=PET.ExPar;
CP.X1val=eval(ExPar.IndepVar1Range);
CP.X2val=NaN;%eval(ExPar.IndepVar2Range);
CP.X1val=repmat(CP.X1val,1,ExPar.Repeats);
[CP.X1, CP.X2]=meshgrid(CP.X1val, CP.X2val);
CP.Y=CP.X1;
CP.Y(:)=0.5;
CP.n=length(CP.X1(:));
CP.ord=randperm(CP.n);
CP.stop=0;
setview(CP,0);
function CP=petcorrect(in)
global PET
CP=PET.Temp.CP;
handles=guidata(PET.Temp.MainFigure);
keis=in(1);
if in(3)==1
    indx=in(2);
    input=find(CP.ord==indx);
elseif in(3)==2
    indx=CP.ord(in(2));
    input=in(2);
end
switch keis
    case 1 % Move to next
    CP.ord=[CP.ord(1:PET.Temp.cinx) indx CP.ord(PET.Temp.cinx+1:end)];
    if input<PET.Temp.cinx
        PET.Temp.cinx=PET.Temp.cinx-1;
        CP.ord(input)=[];
        PET.Data.RawData(input,:)=[];
        PET.Data.Response(input)=nan;
    else
        CP.ord(input+1)=[];           
    end   
    case 2 % Insert
        CP.ord=[CP.ord(1:PET.Temp.cinx) indx CP.ord(PET.Temp.cinx+1:end)];            
    case 3 % Delete
    CP.ord(input)=[];
    if input<PET.Temp.cinx
        PET.Temp.cinx=PET.Temp.cinx-1;
%         PET.Data.RawData(input,:)=[];
        PET.Data.Response(input)=nan;
    end  
    case -1 % The experiment was opened 
        CP.stop=1;
end
setview(CP,keis);
if CP.stop==1 && keis==3 
    M.State='stop';
else
    M.State='continue'; 
end
guidata(PET.Temp.MainFigure,handles);
function setview(CP,keis)
return
global PET
if isempty(PET.Temp.MainFigure)
    return
end
handles=guidata(PET.Temp.MainFigure);
set(handles.popupmenu_varv,'string',num2str([[1:length(CP.ord)]' CP.X1(CP.ord)' CP.X2(CP.ord)' CP.Y(CP.ord)']),...
    'value',PET.Temp.cinx+1); %#ok<NBRAK>
stem(PET.Temp.cinx+1,1,'b','marker','none','parent',handles.waitbar);
if keis<1 % to start or full recovery
    cla(handles.axes1);
    cla(handles.waitbar);
    uimenu(handles.cntxt_menu,'Label','Make it next','Callback','petUicontextmenu(gco,1)');
    % uimenu(handles.cntxt_menu,'Label','Insert data point','Callback','petUicontextmenu(gco,2)');
    set(handles.axes1,'YLim',[0 1])
    ylabel(handles.axes1,'p')
    for a=1:CP.n
        line(CP.X1(CP.ord(a)),0.5,CP.X2(CP.ord(a)),'Marker','.','MarkerEdgeColor',[0.5 0 0],...
            'parent',handles.axes1,'UserData',a,'uicontextmenu',handles.cntxt_menu);
    end
    stem(1:CP.n,ones(1,CP.n),'r','marker','none','parent',handles.waitbar);
    set(handles.waitbar,'xlim',[1 (CP.n)],'YTick',[],'FontSize',8);
    hold(handles.waitbar,'on');
end
if keis==-1 % Full recover from not finished loaded experiment
    for a=1:PET.Temp.cinx
    line(CP.X1(CP.ord(a)),0.5,CP.X1(CP.ord(a)),'Marker','o','MarkerEdgeColor',[0.5 0.4 0],...
        'parent',handles.axes1);
    line([CP.X1(CP.ord(a)),CP.X1(CP.ord(a))],...
        [0.5, CP.Y(CP.ord(a))],[CP.X2(CP.ord(a)),CP.X2(CP.ord(a))],...
        'UserData',CP.ord(a), 'color',[0.5 0.5 1],'parent',handles.axes1,'uicontextmenu',handles.cntxt_menu);    
    end
end
delete(findobj(handles.axes1,'DisplayName','smoothed'));
if PET.Temp.cinx>6*length(CP.X2val)
    X1=CP.X1(CP.ord(1:PET.Temp.cinx));
    X2=CP.X2(CP.ord(1:PET.Temp.cinx));
    Y=CP.Y(CP.ord(1:PET.Temp.cinx));
    for a=1:length(CP.X2val)
        i=find(X2==CP.X2val(a));
        xy=sortrows([X1(i)' Y(i)']);
        xy(:,3)=CP.X2val(a);
        y=conv(xy(:,2),([1 1 1])./3,'same');
        line(xy(3:end-2,1)',y(3:end-2),xy(3:end-2,3),'color',[0.2 a/(length(CP.X2val)*2) 0.2],'DisplayName','smoothed');
    end
end

