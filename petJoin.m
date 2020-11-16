function [PET,failai,path]=petJoin(Pc)
% choose files to summarise
if nargin==0
    [failai,path]=uigetfile('*.mat','Choose experiment data files','MultiSelect','on');
    if ~iscell(failai)
        failai={failai};
    end
    if all(failai{1}==0)
        failai=[];
        path=[];
        PET=[];
        return;
    end
    byla0=failai{1};
    byla0=[path,byla0];
    for a=1:size(failai,2)
        Pc(a)={petLoad([path,failai{a}])};
    end
end
PET=Pc{1};
str0=petDenominat(PET);
for a=2:length(Pc)
    pet=Pc{a};
    str=petDenominat(pet);
    if strcmp(str,str0)% && strcmp(PET0.ExPar.PsychoMethod,pet.ExPar.PsychoMethod)
        PET=[PET pet];
    else
        disp([mat2str(a),'file was not included!']);
    end
end
t=length(PET);
k=[];
for a=1:t-1
    for b=a+1:t
        if all(PET(a).Saved==PET(b).Saved)
            k=[k a];
            disp([mat2str(a),' duplicated file was not included']);
        end
    end
end
PET(k)=[];
if nargout==0 && t>1
   [cfile,npath] = uiputfile(byla0,'Save experiment data');
    if cfile==0
        return;
    end
    save ([npath,cfile], 'PET');    
end