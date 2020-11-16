function imk=gpeGetVisData(PET,ko)
global VDS
% Extracts and saves variable labels and conversion formulas
% this function is used in:
% petGetData;
% petDenominator;
% load structure with required data
P=PET.ExPar;
exfn=PET.ExPar.StimFun ;
imk={};
switch (ko)
    case 'label'; koks='" label';
    case 'formula'; koks='" conversion formula';
end
if ~isfield(P,'DepVar1Name'); P.DepVar1Name='p';end
prompt={['Enter dependent variable "',P.DepVar1Name,koks],...
        ['Enter independent variable "',P.IndepVar1Name,koks],'"'};
strfnames=fields(VDS);
% verify is function name in structure VDS that is in P.Function recorded
torf=find(strcmp(P.StimFun,strfnames));
% if there is no such function name in the VDS structure, then create new
if isempty(torf); VDS.(exfn).description=[]; end
param={[P.DepVar1Name,'_',ko] [P.IndepVar1Name,'_',ko]};
p={[P.DepVar1Name] [P.IndepVar1Name]};
% find requested parameter fields if no, create
for a=1:2
    torf=find(strcmp(fields(VDS.(exfn)),param{a}));
    if isempty(torf)
        VDS.(exfn).(param{a})=[];
    end
end
b=1;
% find requested parameter values
iv=[];
for a=1:2
    torf=0;
    if  isempty(VDS.(exfn).(param{a})); torf=1; end
   if torf==1
        iv(b)=a; b=b+1; 
   end
end
% if no any parameter ask with inputdlg
if isempty(iv)==0
	answer = inputdlg(prompt(iv),'Fill in',1,p(iv));
    if ~isempty(answer)
        for nc=1:length(iv)
           VDS.(exfn).(param{iv(nc)})=answer{nc};
        end     
    else
        for nc=1:length(iv)
           VDS.(exfn).(param{iv(nc)})=p{iv(nc)};
        end   
    end
end
imk(1)={VDS.(exfn).(param{1})};
imk(2)={VDS.(exfn).(param{2})};
save(which('petVisDataStruct.mat'),'VDS');  
