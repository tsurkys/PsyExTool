function [PET,filename,pathstr]=petLoad(failas)
% loads PET data files
% failas - file name;
% Return values:
% PET - main structure
% filename - file name
%created by tsurkys
if nargin==0
    [filename,pathstr]=uigetfile('*.mat','Choose experiment data files','MultiSelect','on');
    if ~iscell(filename)
        filename={filename};
    end
    if all(filename{1}==0)
        filename=[];
        pathstr=[];
        PET=[];
        return;
    end
    for a=1:size(filename,2)
        failas=[pathstr,'/',filename{a}];
        s=load(failas);
        [pathstr,name,ext] = fileparts(failas);
        PET(a)={importas(s,name)};
    end
    if a==1
        PET=PET{1};
        filename=filename{1};
    end
else
    [pathstr,name,ext] = fileparts(failas);
    filename=[name,ext];
    s=load(failas);
    PET=importas(s,name);
end
function PET=importas(s,name)
if isfield(s,'PET')
    if isfield(s.PET(end).Data,'RawData')
        if isfield(s.PET(end).SysPar,'PET_version') && strcmp(s.PET(end).SysPar.PET_version,'0.8.0')
            PET=s.PET;
            return
        else
            if isfield(s.PET,'Multiple')&&~isempty(s.PET.Multiple)
                for a=1:length(s.PET.Multiple)
                    PET(a)=PET6toPET8(s.PET.Multiple(a),name,a);
                end
            else
                PET=PET6toPET8(s.PET,name,1);
            end            
        end
    else
        if isfield(s.PET,'Multiple')&&~isempty(s.PET.Multiple)
            for a=1:length(s.PET.Multiple)
                PET(a)=PET5toPET8(s.PET.Multiple{a},name,a);
            end
        else
            PET=PET5toPET8(s.PET,name,1);
        end
    end
else
    PET5=PREVIOUStoPET5(s);
    PET=PET5toPET8(PET5,name,1);
end
    % Everything below is to support older formats..
    %==================================================
function PET=PET5toPET8(PET5,FileName,a)
P=PET5.ExPar;
PET.ExPar.StimFun=P.StimFun;
PET.ExPar.PsychoMethod=P.PsychoMethod;
if strcmp(PET.ExPar.PsychoMethod,'adjustment')
    PET.ExPar.PsychoMethod='Adjustment';
    PET.ExPar.DepVar1Name=P.Yvar;
    PET.ExPar.IndepVar1Name=P.X1var;
    PET.ExPar.Repeats=length(eval(P.X2val));
    PET.ExPar.DepVar1Range=['-100:',num2str(P.Ystep),':100'];
    PET.ExPar.IndepVar1Range=P.X1val;
    PET.ExPar.InitValInterval=[P.Ymid-P.Yrange P.Ymid+P.Yrange];
    PET.Comments=PET5.Comments;
    PET.Temp=[];
    PET.Name=[FileName,num2str(a)];
end
PET.Saved=PET5.Data.clock;
PET.Data.RawData(:,1)=PET5.Data.X1(:);
PET.Data.RawData(:,2)=PET5.Data.Y(:);
PET.Data.Subject=PET5.Data.Subject.Id;
PET.StimPar=PET5.StimPar;
PET.SysPar=PET5.SysPar;
PET.SysPar.PET_version='0.8.0';
PET.Temp.State='stop';
PET.Temp.cinx=PET5.Data.cinx;
function PET=PET6toPET8(PET6,FileName,a)
PET=PET6;
PET.Data.Subject=PET6.Data.Subject.Id;
PET.ExPar.Input='keyboard';
PET.ExPar.Repeats=length(eval(PET.ExPar.X2val));
if isfield(PET.ExPar,'input')
    PET.ExPar=rmfield(PET.ExPar,'input');
end
PET.ExPar.DepVar1Name='p';
PET.ExPar.IndepVar1Name=PET6.ExPar.X1var;
PET.ExPar=rmfield(PET.ExPar,'X1var');
PET.ExPar.IndepVar1Val=PET6.ExPar.X1val;
PET.Data.(PET.ExPar.IndepVar1Name)=PET.Data.X1;
PET.ExPar=rmfield(PET.ExPar,'X1val');
PET.ExPar=rmfield(PET.ExPar,'X2var');
PET.ExPar=rmfield(PET.ExPar,'X2val');
PET.ExPar=rmfield(PET.ExPar,'State');
PET.SysPar.PET_version='0.8.0';
PET.Saved=PET6.Clock;
PET.Comments='';
PET=rmfield(PET,'Clock');
PET.Name=[FileName,num2str(a)];
PET.Temp.State='stop';
function PET=PREVIOUStoPET5(PET)
% X0=[];X1=[];Y=[];Ys=[];n=[];t=[];EX=[];INF=[];
% s.INF=[];s.EX=[];
if isfield(s,'Y')
    if isfield(s,'Ys')
         [INF,EX]=exinf(INF, s.EX, s.X0, s.X1, s.Y, s.Ys, s.n, s.t);
    else
        [INF,EX]=exinf(INF, s.EX, s.X0, s.X1, s.Y, Ys,n, t);
    end
elseif ~isfield(s,'INF');
    return;
else
    [INF,EX]=exinf(s.INF,s.EX);
end;
PET=petINF2PET(INF);
[X1, X2, Y, Yini, ord, rt, cinx]=petGetData(PET);


 