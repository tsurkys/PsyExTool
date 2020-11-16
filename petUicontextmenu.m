function petUicontextmenu(hob,a)
%PETUICONEXTMENU Summary of this function goes here
%   Detailed explanation goes here
global PET
PET.Temp.State='correct';
if strcmp(get(hob,'Type'),'uicontrol')
    handles=guidata(PET.Temp.MainFigure);
    indx=get(hob,'Value');
    PET.Temp.PsyMethodfh([a indx 2]);
    return
else
    indx=get(hob,'UserData');
end
switch a
    case 1
        set(hob,'color',[0 1 0]);
        state='correct';
        PET.Temp.State='correct';       
        petMain(indx, state);
    case 2
        set(hob,'color',[0 0.8 0.9]);
        correctsaved(hob)
    case 3
        delete(hob);
end
function correctsaved(hob)
global PET
indx=get(hob,'UserData');
a=indx(2);
PET0=PET.Temp.PET0;
gh=PET.Temp.MainFigure;
PET=PET0(a);
PET.Temp.PET0=PET0;
PET.Temp.MainFigure=gh;
petMain(indx(1),'correctsaved')
