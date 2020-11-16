function M=petAdapt_Adjustment(response)
persistent A 
global PET
if strcmp(PET.Temp.State,'start')
    A=SetupA;
    disp('Adjustment method experiment has started');
    PET.Temp.Enter=0;
    PET.Temp.n=A.n;
    PET.Data.InitVal=[A.X1' A.InitVal'];
    NewM;
elseif strcmp(PET.Temp.State,'response') || strcmp(PET.Temp.State,'responsecs')
    if response==0
        M.Response=A.Y(PET.Temp.cinx);
        PET.Temp.Enter=1;
        if strcmp(PET.Temp.State,'responsecs')
            PET.Temp.State='stopcs';
        elseif PET.Temp.cinx>=length(A.ord)
            PET.Temp.State='stop';
            return
        else
            NewM;
        end
    else
        if A.InitRangeInx(PET.Temp.cinx)+response==0 || A.InitRangeInx(PET.Temp.cinx)+(response*2-1)...
                >length(A.DepVar1Range)
            disp('Index exceeds dependent variable defined range size');
        else
            A.InitRangeInx(PET.Temp.cinx)=A.InitRangeInx(PET.Temp.cinx)+response;
        end
        A.Y(PET.Temp.cinx)=A.DepVar1Range(A.InitRangeInx(PET.Temp.cinx));
        M.Response=A.Y(PET.Temp.cinx);
        PET.Temp.StimPar.(PET.ExPar.DepVar1Name)=A.Y(PET.Temp.cinx);
        PET.Temp.Enter=0;
    end
elseif strcmp(PET.Temp.State,'correct')
    inx=response;
    T=PET.Temp;
    A.X1(T.cinx+1:length(A.X1)+1)=A.X1(T.cinx:length(A.X1));
    A.InitRangeInx(T.cinx+1:length(A.Y)+1)=A.InitRangeInx(T.cinx:length(A.Y));
    PET.Data.InitVal(T.cinx+1:length(A.Y)+1,:)=PET.Data.InitVal(T.cinx:length(A.Y),:);
    A.Y(T.cinx+1:length(A.Y)+1)=A.Y(T.cinx:length(A.Y));
    T.stimh(T.cinx+1:length(T.stimh)+1)=T.stimh(T.cinx:length(T.stimh));
    a=find(T.stimh==inx);
    A.X1(T.cinx+1)=A.X1(a); A.X1(a)=[];
    A.InitRangeInx(T.cinx+1)=A.InitRangeInx(a); A.InitRangeInx(a)=[];
    PET.Data.InitVal(T.cinx+1,:)=PET.Data.InitVal(a,:); PET.Data.InitVal(a,:)=[];
    A.Y(T.cinx+1)=A.Y(a); A.Y(a)=[];
    T.stimh(T.cinx+1)=T.stimh(a); T.stimh(a)=[];
    PET.Temp=T;
    PET.Temp.State='continue';
elseif strcmp(PET.Temp.State,'correctsaved')
    A=SetupA;
    A.InitVal=PET.Data.Response; 
    PET.Temp.stimh=1:A.n;
    for a=1:length(A.InitRangeInx)
        A.InitRangeInx(a)=find(A.DepVar1Range==A.InitVal(a));
    end
    A.Y=PET.Data.Response;
    A.X1=PET.Data.(PET.ExPar.IndepVar1Name);
    PET.Temp.StimPar.(PET.ExPar.DepVar1Name)=PET.Data.Response(PET.Temp.cinx);
end 
    function NewM %nested function
        M.IndepVarVal(1)=A.X1(PET.Temp.cinx+PET.Temp.Enter);
%         M.IndepVarVal(2)=A.X2(PET.Temp.cinx+PET.Temp.Enter);
        PET.Temp.StimPar.(PET.ExPar.DepVar1Name)=A.Y(PET.Temp.cinx+PET.Temp.Enter);
    end
end
function A=SetupA
global PET
if ~isnumeric(PET.ExPar.IndepVar1Range)
    A.IndepVar1Range=eval(PET.ExPar.IndepVar1Range);
else
    A.IndepVar1Range=PET.ExPar.IndepVar1Range;
end
A.IndepVar2Range=[NaN];%eval(PET.ExPar.IndepVar2Range);
if ~isnumeric(PET.ExPar.DepVar1Range)
    A.DepVar1Range=eval(PET.ExPar.DepVar1Range);
else
    A.DepVar1Range=PET.ExPar.DepVar1Range;
end
A.IndepVar1Range=repmat(A.IndepVar1Range,1,PET.ExPar.Repeats);
[A.X1, A.X2]=meshgrid(A.IndepVar1Range, A.IndepVar2Range);
A.n=length(A.X1(:));
if isfield(PET.ExPar,'InitValInterval')
    A.initRange=find(A.DepVar1Range>=PET.ExPar.InitValInterval(1) &...
    A.DepVar1Range<=PET.ExPar.InitValInterval(2));
    A.InitRangeInx=A.initRange(ceil(rand(size(A.X1))*length(A.initRange)));
    A.InitVal=A.DepVar1Range(A.InitRangeInx);
else
    A.InitVal(1:A.n)=PET.StimPar.(PET.ExPar.DepVar1Name);
end
A.ord=randperm(A.n);
A.X1=A.X1(A.ord);
A.X2=A.X2(A.ord);
A.Y=A.InitVal;
end

    