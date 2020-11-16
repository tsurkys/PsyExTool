% sudaro string priklausomai nuo stimulo ir experimento parametru
function str=petDenominat(PET,byla)
P=PET.ExPar;
str=[];
if (nargin == 3)
    if  ~strcmp(PET.Data.Subject,'')
        Id=PET.Data.Subject;
        str=[Id,'_'];
    else
        [Id,rem]=strtok(byla,'_');
        if ~isempty(rem)
            str=[Id,'_'];
        end
    end
end
if isfield(P,'IndepVar2Name')
    switch P.IndepVar2Name
        case 'non'
            P.IndepVar2Name='';
        otherwise
            P.IndepVar2Name=['&',P.IndepVar2Name];
    end
else
    P.IndepVar2Name='';
end
str=[str,P.StimFun];
str=[str,'(',P.IndepVar1Name,P.IndepVar2Name,')'];
% if isfield(P,'Repeats')
%     str=[str,num2str(P.Repeats)];   
% end
str=strrep(str,'.',',');
end % main function end
