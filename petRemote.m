function petRemote(non)
global PET T
pet=PET;
pet.ExPar.StimFun=PET.ExPar.StimFunRemote;
pet.Temp=[];
pet.Temp.StimPar=PET.Temp.StimPar;
pet.Temp.RemoteState=1;
pet.ExPar.State=PET.Temp.State;
pet.Temp.State=PET.Temp.State;
try
save('S:\remote\petC.mat','pet');
catch
    disp('nepavyko irasyti');
    pause(0.1);
    save('S:\remote\petC.mat','pet');
end
% T=timerfind('TimerFcn','skaityk');
if strcmp(PET.Temp.State,'stop')
    stop(T);
end
if isempty(T)
    T=timer('TimerFcn','skaityk','Period',0.1,'StartDelay',0.5,...
        'ExecutionMode','fixedSpacing');%,'TasksToExecute',500);
    start(T)
elseif strcmp(T.Running,'off')
    start(T)
end
% if strcmp(get(T,'Running'),'off')
%     start(T)
% end




