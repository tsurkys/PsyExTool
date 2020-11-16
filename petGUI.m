function f=petGUI
global PET VDS
f=figure('position',[120 280 810 590],'FileName','petCreateGUI','NumberTitle','off',...
    'name','petGUI 0.8.0','MenuBar','None','WindowScrollWheelFcn',@figScroll,...
    'KeyPressFcn',@KeyPressFcn,'WindowButtonDownFcn',@MouseClick,...
    'WindowButtonUpFcn',@MouseUnClick,'Renderer','painters','CloseRequestFcn',@closereq);
%  Kairë
uicontrol('string','Load','tag','open','position',[6 560 90 20],'callback',@open...
    ,'TooltipString','Load experiment data and settings from a file');
uicontrol('string','Start experiment','tag','start','position',[6 530 90 20],...
    'callback',@start,'KeyPressFcn',@KeyPressFcn,'TooltipString','Start the experiment');
uipanel('Title','','FontSize',12,'Position',[.007 .79 .113 .090],'units','pixels');
uicontrol (f, 'style', 'edit','Max',1,'position',[6 440 90 20],'callback',@exactedit,...
    'tag','edit_Id','horizontalalignment','center','string','Subject Id',...
    'TooltipString','Enter Id of the subject');
uicontrol('string','Save as','position',[6 410 90 20],'callback',@SaveAs...
    ,'TooltipString','Save or exprot the loaded file(s) or newly obtained data');
uicontrol('string','Add & save','position',[6 380 90 20],'callback',@AddSave,...
    'enable','off','tag','AddSave','TooltipString','Attache experimental data to the loaded file');
uicontrol('string','Graph other','position',[6 350 90 20],'callback',@plotas...
    ,'TooltipString','Plot experimental data (it does not load experiment parameters)');
GraphPar=uitable(f,'tag','GraphPar','RowName',[],'ColumnName',{},...
    'ColumnEditable',[false true],'RowStriping','off','CellEditCallback',@paredit,...
    'position',[6 130 90 210],'ColumnWidth',{60 25},...
    'TooltipString','Check box that will affect data ploting and data export');
uicontrol('string','Plot','tag','Plot','position',[6 70 90 20],'callback',@plotas...
    ,'TooltipString','Plot experiment data');
uicontrol('string','Present stimulus','tag','Present','position',[6 40 90 20],...
    'callback',@present,'TooltipString','Present stimulus');
uicontrol('string','Reload','tag','Refresh','position',[6 10 90 20],'callback',@LoadPET2G...
    ,'TooltipString','Reload parameters');
%   Deðinë
xp=606;wd=200; Yp=560;
uicontrol(f,'style','text','string','Experiment method','position',[xp Yp wd 20]);
uicontrol(f,'style','popupmenu','string',{'','constant_stimulus','PAL_AMPM','Adjustment'},...
    'position',[xp Yp-20 wd 20],'callback',@popexpar,'tag','PsychoMethod');
uicontrol(f,'style','text','string','Experiment settings','position',[xp Yp-44 wd 20]);
uitable(f,'tag','ExPar','RowName',[],'ColumnName',{'Property','Value'},...
    'ColumnWidth',{90 90},'ColumnEditable',[true true],...
    'RowStriping','off','CellEditCallback',@paredit,'position',[xp Yp-205 wd 165]);
%%% %%% %%%
uicontrol(f,'style','text','string','Stimulus function','position',[xp Yp-230 wd 20]);
stimfunc={'','petExperimentEmulator','stimulFIG','StimSound','petRemote'};
uicontrol(f,'style','popupmenu','string',stimfunc,...
    'position',[xp Yp-248 wd 20],'callback',@popexpar,'tag','StimFun');
uicontrol(f,'style','text','string','Stimulus parameters','position',[xp Yp-273 wd 20]);
StimParT=uitable(f,'tag','StimPar','RowName',[],'ColumnName',{'Property','Value'},...
    'ColumnEditable',[true true],'RowStriping','off','CellEditCallback',@paredit,...
    'position',[xp Yp-460 wd 190],'ColumnWidth',{90 90});
uicontrol(f,'style','text','string','Raw data','position',[xp Yp-490 wd 20]);
RawDataT=uitable(f,'tag','RawDataT','ColumnName',{'N','IndepVar',' DepVar '},...
    'RowName',[],'ColumnEditable',[false false true],'RowStriping','off',...
    'CellEditCallback',@setrawdata,'position',[xp Yp-550 wd 60],'ColumnWidth',{25 72 72});
% Asys
axes('units','pixels','OuterPosition',[190 540 380 30],'tag','waitbara',...
    'XTick',[],'YTick',[],'XColor','w','YColor','w');
axes('units','pixels','OuterPosition',[80 130 570 420],'tag','Gaxis',...
    'color',[1 1 1]);
uicontrol(f,'style','text','string','File info','position',[183 120 wd 20]);
uitable(f,'tag','FileInfo','ColumnName',{'v','Name','N','Saved','Comments'},...
    'position',[183 10 395 110],'ColumnWidth',{24 100 24 90 122},...
    'ColumnEditable',[true false false false true],'CellEditCallback',@paredit);
childr=get(gcf,'children');
set(childr,'FontSize',8);
f.UserData.cntxt_menu=uicontextmenu('tag','cntxt_menu');
% f.UserData.mousexec=timer(f,'ExecutionMode','fixedRate','TasksToExecute',100);
uimenu(f.UserData.cntxt_menu,'Label','Present next','Callback','petUicontextmenu(gco,1)');
% uimenu(f.UserData.cntxt_menu,'Label','Delete data point','Callback','petUicontextmenu(gco,3)');
gh=guihandles;
gh.drawMF=@drawMF;
if ~isempty(PET)
    PET(end).Temp.MainFigure=gh;
    LoadPET2G([],[]);
end
V=load('petVisDataStruct.mat');
VDS=V.VDS;
VDS.fh=f.Number;
rowname=fieldnames(VDS.GraphPar);
C=struct2cell(VDS.GraphPar);
GraphPar.Data=[rowname C];
% set(f,'CurrentAxes',Gaxis);
function closereq(h,e)
  global VDS
  gh=guihandles(h);
  dlg=quitex(gh);
    if strcmp(dlg,'Quit')
        delete(gcf);
    end
  if ~isempty(VDS)  
    save([fileparts(which(mfilename)),'/private/petVisDataStruct.mat'],'VDS');
  end
function MouseClick(h,cb)
global PET
persistent m
if isempty(PET) || strcmp(PET.Temp.State,'stop')||~strcmp(PET.ExPar.Input,'mouse')
    return
end
mc=get(h,'SelectionType');
set(h,'pointer','crosshair');  
while strcmp(get(h,'pointer'),'crosshair') 
    if strcmp(mc,'extend')
        petMain(0);
        m=4;
        return;
    elseif strcmp(mc,'normal') || strcmp(mc,'open')&& m==1
        petMain(-1);
        m=1;
        pause(0.05);
    elseif strcmp(mc,'alt') || strcmp(mc,'open')&& m==2
        petMain(+1);
        m=2;
        pause(0.05);
    end
end 
function MouseUnClick(h,callbackdata)
global PET
if isempty(PET) ||~strcmp(PET.ExPar.Input,'mouse')
    return
end
set(h,'pointer','arrow');
function figScroll(h,callbackdata)
global PET
if isempty(PET) || strcmp(PET.Temp.State,'stop')||~strcmp(PET.ExPar.Input,'mouse')
    return
end
  petMain(-callbackdata.VerticalScrollCount);
function KeyPressFcn (h,callbackdata)
global PET
if isempty(PET) || isfield(PET.ExPar,'Input') && ~strcmp(PET.ExPar.Input,'keyboard')...
        || strcmp(PET.Temp.State,'stop')
    return
end
ck=double(get(gcf,'currentcharacter'));
switch ck
    case {30, 29} %arrow up / mouse right
        out=1;
    case {31, 28} %arrow down / mouse left
        out(1)=-1;
    case {13} %enter / mouse middle  
        out=0;
end
petMain(out);
function paredit(h,callbackdata)
global PET VDS
tag=get(h,'tag');
switch tag
    case {'ExPar', 'StimPar'}
        PsychoMethod=PET.ExPar.PsychoMethod;
        StimFun=PET.ExPar.StimFun;
        PET.(tag)=[];
        PET.ExPar.PsychoMethod=PsychoMethod;
        PET.ExPar.StimFun=StimFun;
        for a=1:length(h.Data)
            if isempty(h.Data{a,2}) || isempty(h.Data{a,1})
                continue
            end
            if ~isnumeric(h.Data{a,2}) && ~any(isletter(h.Data{a,2}))...
                && ~contains(h.Data{a,2},':')
                PET.(tag).(char(h.Data(a,1)))=str2num(h.Data{a,2});
            else
                PET.(tag).(char(h.Data(a,1)))=h.Data{a,2};
            end
        end
        PET.Temp.StimPar=PET.StimPar;
    case 'GraphPar'
        field=h.Data(callbackdata.Indices(1),1);
        VDS.GraphPar.(char(field))=callbackdata.NewData;
        if VDS.GraphPar.Refresh % VDS.GraphPar.Hold
            plotas(h,[]);
        end
    case 'FileInfo'
        if callbackdata.Indices(2)==1 && VDS.GraphPar.Refresh
            plotas(h,[]);
        elseif callbackdata.Indices(2)==5
            PET.Temp.PET0(callbackdata.Indices(1)).Comments=callbackdata.NewData;
        end
end
function popexpar(h,e)
  global PET
  str=get(h,'string');
  tag=get(h,'tag');
  val = get(h,'Value');
  PET.ExPar.(tag)=str{val};
function exactedit(h,e)
global PET
str=get(h,'string');
tag=get(h,'tag');
PET.(tag)=str;
function open(h,e)
  global PET
  global VDS
    if isempty(VDS)
        V=load('petVisDataStruct.mat');
        VDS=V.VDS;
    end
  gh=guihandles(get(h,'parent'));
  dlg=quitex(gh);
    if strcmp(dlg,'Back')
        return
    end
  if isfield(e,'nextfile')
      [PET0,filename,pathstr]=petLoad(e.nextfile);
  else
      [PET0,filenames,pathstr]=petJoin;
      if isempty(PET0)
          return
      end
      filename=filenames{end};
      if length(filenames)>1
          filename=['joint'];
      end
  end
  for a=1:length(PET0)
      PET0(a).Temp.a=a;
  end
  PET=PET0(end);
  PET.Temp.PET0=PET0;
  PET.Temp.cfile=[pathstr,'/',filename];
  delete(allchild(gh.waitbara));
  delete(allchild(gh.Gaxis));
  gh.drawMF=@drawMF;
  PET.Temp.MainFigure=gh;
  LoadPET2G([],[]);
  VDS.fh=get(get(gh.Gaxis,'parent'),'number');
  plotas(h,e)
% FileInfo(PET0,gh)
  evalin('base', 'global PET');
  evalin('base', 'PET0=PET.Temp.PET0;');
function LoadPET2G(h,e)
global PET
gh=PET.Temp.MainFigure;
[~,filename]=fileparts(PET.Temp.cfile);
  gh.Gaxis.Title.String=replace(filename,'_',' ');  
%   seting up parameteres
  rowname=fieldnames(PET.ExPar);
  C=struct2cell(PET.ExPar);
  st=get(gh.PsychoMethod,'string');
  set(gh.PsychoMethod,'value',find(contains(st,PET.ExPar.PsychoMethod)));
  st=get(gh.StimFun,'string');
  set(gh.StimFun,'value',find(contains(st,PET.ExPar.StimFun)));
  rowname([1 2])=[];
  C([1 2])=[];
  i=find(cellfun(@ischar,C)==0);
  C(i)=cellfun(@mat2str,C(i),'UniformOutput', false);
  rowname(end+1)={''};
  C(end+1)={''};
  set(gh.ExPar,'Data',[rowname C]);
  rowname=fieldnames(PET.StimPar);
  C=struct2cell(PET.StimPar);
  i=find(cellfun(@ischar,C)==0);
  C(i)=cellfun(@mat2str,C(i),'UniformOutput', false);
  rowname(end+1)={''};
  C(end+1)={''};
  set(gh.StimPar,'Data',[rowname C]);
  NamesC={' N ',PET.ExPar.IndepVar1Name,'Response'};
  if isfield(PET.Data,'Response')
      set(gh.RawDataT,'ColumnName',NamesC,...
        'Data',flipud([(1:length(PET.Data.Response))',...
        PET.Data.(PET.ExPar.IndepVar1Name) PET.Data.Response]));
  end
  FileInfo(PET.Temp.PET0,gh);
function FileInfo(P0,gh)
    global VDS
    if isempty(VDS)
        V=load('petVisDataStruct.mat');
        VDS=V.VDS;
    end
    for a=1:length(P0)
        c{a,1}=true;
        c{a,2}=P0(a).Name;
        if isfield(P0(a).ExPar,'Repeats')
            c{a,3}=P0(a).ExPar.Repeats;
        else
            c{a,3}=length(P0(a).Data.Response);
        end
        c{a,4}=mat2str(P0(a).Saved);
        c{a,5}=P0(a).Comments;
    end
   set(gh.FileInfo,'Data',c)
function selection=quitex(gh)
    global PET
if ~isempty(PET) && isfield(PET(end),'Temp')&&PET(end).Temp.cinx>16 &&...
        ~strcmp(gh.start.String,'Start experiment')
    selection = questdlg('Do you want to quit?',...
      'Quit Request',...
      'Quit','Back','Back');
else
    selection='Quit';
end
function start(h,e)
global PET
if isempty(PET)
    warndlg('Experiment parameters are not seted');
    return
end
gh=guihandles(get(h,'parent'));
gh.drawMF=@drawMF;
dlg=quitex(gh);
if strcmp(dlg,'Back')
    return
end
gh.Gaxis.Title.FontWeight = 'normal';
gh.start.String='Restart experiment';
PET.Temp.MainFigure=gh;
petMain(0,'start');
gh.Addsave.Enable='on';
% gh.start.Backgroundcolor=[0.877 0.875 0.89];
function AddSave(h,e)
global PET
if length(PET)>1 || strcmp(PET.Temp.State,'stopcs') || ~isempty(PET.Saved)
    return
end
gh=guihandles(get(h,'parent'));
PET.Data.Subject=gh.edit_Id.String;
PET.Saved=clock;
PET.Temp.PET0=AddSaveStep(PET,h,e);
plotas(h,e);
    function PET0=AddSaveStep(PET,h,e)
    gh=guihandles(get(h,'parent'));
    PET0=PET.Temp.PET0;
    pet=PET;
    pet.Temp.PET0=[];
    try
        pet.Name=[PET0(1).Name,'(',num2str(length(PET0)+1),')'];
        [PET]=petJoin({PET0,pet});
        if ~(length(PET)==length(PET0)) && ~strcmp(PET(end).Temp.cfile,'joint')
            save(PET(end).Temp.cfile, 'PET');
        else
            SaveAs(h,e)
            return
        end
    catch
        [cfile,npath] = uiputfile('','*SAFE MODE* Save experiment data *SAFE MODE*'); 
        if ~cfile==0
            save ([npath,cfile], 'pet');
        else
            save ('petTemp.mat', 'pet');
        end
    end
    PET0=PET;
    gh.start.String='Start experiment';
    FileInfo(PET0,gh);
function SaveAs(h,e)
global PET
global VDS
if isempty('PET')
    return
end
gh=guihandles(get(h,'parent'));
str=petDenominat(PET(end));
[cfile,npath,filterindex] = uiputfile({'*.mat','MAT-files (*.mat)';...
    '*.xlsx','Export to MS Excell sheet'},...
    'Save experiment data',[gh.edit_Id.String,'_',str]);
if cfile==0
    return;
end  
if strcmp(gh.start.String,'Start experiment')
    PET0=PET.Temp.PET0;
    b=0;
    for a=1:length(PET0)    
        if gh.FileInfo.Data{a,1}
            b=b+1;
            pet(b)=PET0(a);
        end
    end
    if b==0    
        return
    else
        PET=pet;
        PET0=pet;
    end      
else
    PET.Data.Subject=gh.edit_Id.String;
    PET.Name=strtok(cfile,'.');
    PET.Temp.cfile=[npath,cfile];
    if isempty(PET.Saved) % saved field works as unique tag for the exp
        PET.Saved=clock;
    end
    PET.Temp.PET0=[];
    PET0=PET;
end
if filterindex==1
    if VDS.GraphPar.Split_files==true
        pet=PET;
        for a=1:length(pet)
            PET=pet(a);
            save ([npath,strtok(cfile,'.'),'_session_',num2str(a),'.mat'], 'PET');
        end
    else    
        save ([npath,cfile], 'PET'); 
    end
else
    petExportData(PET,cfile,npath,1);
end
gh.start.String='Start experiment';
PET=[];
PET=PET0(end);
PET.Name=strtok(cfile,'.');
PET0(end).Name=strtok(cfile,'.');
PET.Temp.PET0=PET0;
PET.Temp.MainFigure=gh;
plotas(h,e);
FileInfo(PET.Temp.PET0,gh);
function drawMF(state)
global PET
persistent l
gh=PET.Temp.MainFigure;
f=get(gh.Gaxis,'parent');
T=PET.Temp;
cntxt_menu=f.UserData.cntxt_menu;
if strcmp(state,'start')
    delete(allchild(gh.waitbara));
    delete(allchild(gh.Gaxis));
    PET.Temp.stimh=1:PET.Temp.n;
    line(gh.waitbara,1:T.n,zeros(1,T.n),'Color','r','marker','.','LineStyle','none');
    set(gh.waitbara,'xlim',[1 PET.Temp.n],'YTick',[],'FontSize',8,'XTickMode','auto');
    gh.waitbara.XAxis.Color='k';
    hold(gh.waitbara,'on');
    set(gh.Gaxis,'YLimMode','auto');
    gh.Gaxis.XLabel.String = PET.ExPar.IndepVar1Name;
    if isfield(PET.ExPar,'DepVar1Name')
        gh.Gaxis.YLabel.String = PET.ExPar.DepVar1Name;
    end
    if isfield(PET.Data,'InitVal')
        for a=1:length(PET.Data.InitVal)
            line(PET.Data.InitVal(a,1),PET.Data.InitVal(a,2),'Marker','.','MarkerEdgeColor',[0.7 0.5 0.5],...
                'parent',gh.Gaxis,'UserData',a,'uicontextmenu',cntxt_menu); 
        end
    end
    return
elseif strcmp(state,'stop')
    gh.AddSave.Enable='on';
    return
end
x=PET.Data.(PET.ExPar.IndepVar1Name)(T.cinx);
if strcmp(PET.ExPar.PsychoMethod,'Adjustment')
    y=PET.Temp.StimPar.(PET.ExPar.DepVar1Name);
else
    y=0.5;
end
RawDataT=flipud([(1:length(PET.Data.Response))',...
    PET.Data.(PET.ExPar.IndepVar1Name) PET.Data.Response]);
set(gh.RawDataT,'Data',RawDataT);
if strcmp(state,'record')
    l.recorded=line(x,PET.Data.Response(T.cinx),'Marker','s','MarkerSize',9,...
        'UserData',T.stimh(T.cinx),'color',[0.5 0.5 1],'parent',...
        gh.Gaxis,'uicontextmenu',cntxt_menu);
    l.current.Color=[0.9 0.9 0.9];
    line([T.cinx T.cinx],[0 1],'Color','b','marker','none','parent',gh.waitbara);
elseif strcmp(state,'curentstim') 
    l.current=line([x x],[y y],'Marker','o','Color',[1 0.4 0],...
        'parent',gh.Gaxis,'UserData',T.stimh(T.cinx),'uicontextmenu',cntxt_menu); 
    line(T.cinx,1,'Color','y','marker','o','LineStyle','none','parent',gh.waitbara);
elseif strcmp(state,'any')
    l.current.YData=[PET.Data.InitVal(T.cinx,2) y];
end
function plotas(h,e)
global PET
global VDS
if isobject(e) && strcmp(e.Source.String,'Graph other')
    petVisualiseData;
    return
end
if ~ishandle(VDS.fh)
    fh=get(h,'parent');
    VDS.fh=fh.Number;
end
ev.EventName='loading';
gh=guihandles(get(h,'parent'));
    b=0;
for a=1:length(PET.Temp.PET0)% kazkas cia visai negerai, kodel eina per Temp?
    if gh.FileInfo.Data{a,1}
        b=b+1;
        pet(b)=PET.Temp.PET0(a);
        pet(b).Temp.a=a;
    end
end
if b>0
    petVisualiseData(pet,ev);
else
    petVisualiseData([],ev);
end
function present(h,e)
global PET
State=PET.Temp.State;
PET.Temp.State='start';
StimFunHandle=str2func(PET.ExPar.StimFun);
StimFunHandle(PET.StimPar);
PET.Temp.State=State;
    function setrawdata(h,e)
        return