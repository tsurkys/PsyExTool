function petExperimentEmulator(StimPar)
% Function to emulate psychophysical exrperiment
% Variable StimPar is structure containing stimulus parameters
% Variable PET is the main structure of the toolbox.
% PET.Temp.State defines the state of the experiment:
    % 'start' - the begining of the experiment;
    % 'continue' - experiment is continued;
    % 'stop' - the end of the experiment.
global PET
P=PET.ExPar;
if strcmp(PET.Temp.State,'start')
    disp('Experiment has started');
    disp(['Independant variable ',P.IndepVar1Name,'=',num2str(StimPar.(P.IndepVar1Name))]);
    if isfield(P,'DepVar1Name')
        disp(['Dependant variable ',P.DepVar1Name,'=',num2str(StimPar.(P.DepVar1Name))]);
    end
    return
end
if ~isfield(PET.Temp,'Enter') || PET.Temp.Enter==1
    disp('ENTERED DATA:')
    disp(['Response: ' num2str(PET.Data.Response(PET.Temp.cinx-1))]);
    disp(['reaction time =' num2str(etime(datevec(PET.Data.ResponseTime(end)),...
        datevec(PET.Data.DisplayTime(end)))),' s']);
    if strcmp(PET.Temp.State,'stop')
        disp('The experiment was finished');
        return
    end
    % display the value of the second variable;
%     disp(['first variable ',P.IndepVar1Name,'=' num2str(Recorded{1}.(P.IndepVar1Name))]);

    disp('*****************');
%     PET.Data.DisplayTime=now;
    disp(['No=',num2str(PET.Temp.cinx)]);
    disp(['Independant variable ',P.IndepVar1Name,'=',num2str(StimPar.(P.IndepVar1Name))]); 
    if isfield(P,'DepVar1Name')
        disp(['Dependant variable ',P.DepVar1Name,'=',num2str(StimPar.(P.DepVar1Name))]);
    end
else
    if isfield(P,'DepVar1Name')
        disp(['Dependant variable ',P.DepVar1Name,'=',num2str(StimPar.(P.DepVar1Name))]);
    end
end
  

    