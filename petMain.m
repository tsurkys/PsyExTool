function pet=petMain(in,state)
persistent methodfh StimFunHandle sfs
global PET
global scn
pet=[];
CheckInputArguments;
if isempty(PET)
    return
end
IndepVar1Name=PET.ExPar.IndepVar1Name;
if strcmp(PET.Temp.State,'start')
    methodfh=str2func(['petAdapt_',PET.ExPar.PsychoMethod]);
    StimFunHandle=str2func(PET.ExPar.StimFun);
    PET=PET(end);
    if exist('SysPar.mat','file')==2
        S=load('SysPar');
        PET.SysPar=S.SysPar;
    end
    if isfield(PET.ExPar,'SoundFeedback') && strcmp(PET.ExPar.SoundFeedback,'on')
        sfs.start=[sin(1:0.5:400) sin(1:1200)];
        sfs.stop=[sin(1:400) sin(1:0.5:1000)];
        sfs.any=[sin(1:300)];
        sfs.curentstim=[];
        sfs.record=[sin(1:0.5:400)];
    end
    PET.SysPar.PET_version='0.8.0';
    PET.Data=[];
    PET.Saved=[];
    PET.Comments='';
    PET.Temp.StimPar=PET.StimPar;
    PET.Temp.cinx=1;
    PET.Temp.Enter=1;
    M=methodfh();
    setview('start');
    NextStim;
elseif strcmp(PET.Temp.State,'response') || strcmp(PET.Temp.State,'responsecs')
    if in==0 && ~strcmp(PET.ExPar.PsychoMethod,'Adjustment')
        StimFunHandle(PET.Temp.StimPar);
        return;
    elseif PET.Temp.cinx>length(PET.Data.DisplayTime) ||...
            PET.Temp.Enter==1 && (now-PET.Data.DisplayTime(end,1))*100000<0.5
        return
    end 
    PET.Data.ResponseTime(PET.Temp.cinx,1)=now;
    M=methodfh(in);
    PET.Data.Response(PET.Temp.cinx,1)=M.Response; 
    if PET.Temp.Enter==1
        setview('record');
        PET.Temp.cinx=PET.Temp.cinx+1;
        if strcmp(PET.Temp.State,'stopcs')
            PET.Data.RawData=[PET.Data.(IndepVar1Name) PET.Data.Response];
            gh=PET.Temp.MainFigure;
            PET.Temp.MainFigure=[];
            PET.Temp.PsyMethodfh=[];
            PET0=PET.Temp.PET0;
            PET.Temp.PET0=[];
            PET0(PET.Temp.a)=PET;
            PET=PET0(end);
            PET.Temp.PET0=PET0;
            PET.Temp.MainFigure=gh;
            PET.Temp.State='stopcs';
        elseif strcmp(PET.Temp.State,'stop')
            StimFunHandle(PET.Temp.StimPar);
            setview('stop');
            PET.Temp.MainFigure=[];
            PET.Temp.PsyMethodfh=[];
        else
            NextStim;
        end
    elseif PET.Temp.Enter==0
        setview('any');
        StimFunHandle(PET.Temp.StimPar);
    end
elseif strcmp(PET.Temp.State,'correct') && nargin>0
    in=abs(in);
    methodfh(in);
    if length(PET.Data.Response)>in
        PET.Data.Response(in)=[];
        PET.Data.RawData(in,:)=[];
        PET.Data.(IndepVar1Name)(in)=[];
        PET.Data.DisplayTime(in)=[];
        PET.Data.ResponseTime(in)=[];
        PET.Temp.cinx=PET.Temp.cinx-1;
    end
elseif strcmp(PET.Temp.State,'correctsaved')     
    methodfh=str2func(['petAdapt_',PET.ExPar.PsychoMethod]);
    StimFunHandle=str2func(PET.ExPar.StimFun);
    PET.Temp.cinx=in;
    M.IndepVarVal=PET.Data.(PET.ExPar.IndepVar1Name)(in);
    methodfh(1);
    NextStim;
end
PET.Data.RawData=[PET.Data.(IndepVar1Name) PET.Data.Response];
pet=PET;
if strcmp(PET.Temp.State,'stop')&&~isempty(scn)
    petScenario(1);
end
    function NextStim %nested function
        PET.Temp.StimPar.(IndepVar1Name)=M.IndepVarVal(1);
        PET.Data.(IndepVar1Name)(PET.Temp.cinx,1)=M.IndepVarVal(1);
%         PET.Temp.cinx=PET.Temp.cinx+1;
        StimFunHandle(PET.Temp.StimPar);
        PET.Data.DisplayTime(PET.Temp.cinx,1)=now;         
        PET.Data.Response(PET.Temp.cinx,1)=nan;
        setview('curentstim');
    end
    function CheckInputArguments %nested function
        if exist('in','var')
            if isstruct(in)
                PET=in;
            elseif isscalar(in)
                if strcmp(PET.Temp.State,'correctsaved')||strcmp(PET.Temp.State,'responsecs')
                    PET.Temp.State='responsecs';
                else
                    PET.Temp.State='response';
                end
            else
                disp('First input variable has to be scalar or PET structure');
                in=[];
            end
        end
        if exist('state','var')
            if ischar(state)
                PET.Temp.State=state;
            else
                disp('Second input variable has to be type of char');
            end
        end
        if isempty(PET) || ~exist('in','var')
            [pet,filename,pathstr]=petLoad;
            if isempty(pet)
                return
            end
            PET=pet;
            PET.Temp.cfile=[pathstr,'/',filename];
            PET.Temp.State='start';
        end
%         if strcmp(PET.Temp.State,'stop') || exist('in','var')==0
%             PET.Temp.State='start';
%         end
    end
    function setview(keis)
        if ~isempty(sfs)
            sound(sfs.(keis));
        end
        if isempty(PET.Temp.MainFigure)
            return
        end
        feval(PET.Temp.MainFigure.drawMF,keis);
    end
end