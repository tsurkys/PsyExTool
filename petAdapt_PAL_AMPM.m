function M=petAdapt_PAL_AMPM(response)
global PM
global PET
gh=PET.Temp.MainFigure;
if strcmp(PET.Temp.State,'start')
    PM = PAL_AMPM_setupPM;
    pmflds=fieldnames(PM);
    for a=1:length(pmflds)
        if isfield(PET.ExPar,pmflds(a))
            if isnumeric(PET.ExPar.(pmflds{a}))%||any(isletter(PET.ExPar.(pmflds{a})))
                PM.(pmflds{a})=PET.ExPar.(pmflds{a});
            else
                PM.(pmflds{a})=eval(PET.ExPar.(pmflds{a}));
            end
        end
    end
    PM = PAL_AMPM_setupPM('priorAlphaRange',PM.priorAlphaRange,...
                          'priorBetaRange',PM.priorBetaRange,...
                          'priorGammaRange',PM.priorGammaRange,...
                          'priorLambdaRange',PM.priorLambdaRange,...
                          'numtrials',PM.numTrials,...
                          'PF' , PM.PF,...
                          'stimRange',PM.stimRange);
%                       PM.xCurrent=PM.stimRange(floor(rand*length(PM.stimRange)));
%                       PM.x(end)=PM.xCurrent;
%     feval(gh.drawMF,'start',PM.numTrials,gh);
PET.Temp.n=PM.numTrials;
PET.Temp.stimh=1:PM.numTrials;
elseif strcmp(PET.Temp.State,'response')
    M.Response=(response+1)/2;
    PM = PAL_AMPM_updatePM(PM, M.Response);
    % Making stimulus simetry around threshold
    PM.xCurrent=PM.threshold(end)+sign(rand-0.5)*(PM.threshold(end)-PM.xCurrent);
    PM.xCurrent=PM.stimRange(find(abs(PM.stimRange-PM.xCurrent)==min(abs(PM.stimRange-PM.xCurrent))));
    PM.x(end)=PM.xCurrent;   
    if isvalid(findobj(gh.Gaxis,'DisplayName','fapproximation'))
%         delete(findobj(gh.Gaxis,'DisplayName','approximation'));
        delete(findobj(gh.Gaxis,'DisplayName','fapproximation'));
    end
    y=PM.PF([PM.threshold(end),10^PM.slope(end),PM.priorGammaRange,PM.priorLambdaRange],PM.stimRange);
    line(PM.stimRange,y,'parent',gh.Gaxis,'DisplayName','fapproximation','Color','k');
%     line([PM.threshold(end)-PM.seThreshold(end) PM.threshold(end)+PM.seThreshold(end)],...
%         [(1-PM.priorGammaRange)/2 (1-PM.priorGammaRange)/2],'DisplayName','approximation',...
%         'parent',gh.Gaxis);

elseif strcmp(PET.Temp.State,'correct')
    if response(1)==3
        PET.Data.RawData(response(2),:)=[];
        pmflds=fieldnames(PM);
        for a=1:length(pmflds)
            if length(PM.(pmflds{a})(:))==length(PM.x)
                PM.(pmflds{a})(response(2))=[];
            end
        end
        delete(findobj(gh.Gaxis,'Type','line'));
    end
    for a=1:length(PM.x)-1
        line([PM.x(a) PM.x(a)],[0.5 PM.response(a)],'Color',[0.5 0.5 1],...
            'parent',gh.Gaxis,'UserData',a,'uicontextmenu',gh.cntxt_menu);   
        line(PM.x(a),0.5,'Marker','s','MarkerEdgeColor',[0.6 0.5 0.2],...
            'parent',gh.Gaxis,'UserData',PET.Temp.cinx,'uicontextmenu',gh.cntxt_menu);       
    end
    line(PM.x(a+1),0.5,'Marker','s','MarkerEdgeColor',[1 0.4 0],...
            'parent',gh.Gaxis,'UserData',PET.Temp.cinx,'uicontextmenu',gh.cntxt_menu);
%      y=PAL_Logistic([PM.threshold(end),10^PM.slope(end),PM.gamma,PM.lambda],PM.stimRange);
%     y(2,:)=PAL_Logistic([(PM.threshold(end)+PM.seThreshold(end)),10^(PM.slope(end)),PM.gamma,PM.lambda],PM.stimRange);
%     y(3,:)=PAL_Logistic([(PM.threshold(end)-PM.seThreshold(end)),10^(PM.slope(end)),PM.gamma,PM.lambda],PM.stimRange);
%     line(PM.stimRange,y,'parent',gh.Gaxis,'DisplayName','approximation');
    if PM.stop==1
        PET.Temp.State='stop';
    else
        PET.Temp.State='response';      
    end
    return
else
    return
end
if PM.stop==1
    PET.Temp=rmfield(PET.Temp,'PM');
    PET.Temp.State='stop'; 
else
    M.IndepVarVal=PM.xCurrent;   
%     feval(gh.drawMF,'next',{PM.xCurrent, length(PM.x)},gh);   
end 
% PET.Temp.cinx=length(PM.x);
% guidata(PET.Temp.MainFigure,gh);
PET.Temp.PM=PM;
% assignin('base','PM',PM);
% assignin('base','gh',gh);

