function petScenario(input)
persistent SCN scnp gh
global PET
global scn
if nargin==0 || iscell(input)
    if nargin==0
    	[file,path]=uigetfile;
        if file==0
            return
        end
        scnp=[path,file];
        inSCN=load(scnp);        
        SCN=inSCN.SCN;
    else
        SCN=input;
    end
    h=petGUI;
    gh=guihandles(h);
end
a=zerofinder(SCN);
if a<1
    return
end
scn=SCN(a,:);
if nargin==1 && isnumeric(input) % if session is finished, save...
    if strcmp([scn{1},scn{2}],[scn{3},scn{4}])
        feval(gh.AddSave.Callback,gh.AddSave,[]);
    else
        PET.Edit_Id=scn{6};
        PET.Name=scn{4};
        PET.Saved=clock;
        PET.Temp.PET0=[];
        save ([scn{3},scn{4}],'PET');
        gh.start.String='Start experiment';
        petVisualiseData(PET);
        PET.Temp.PET0=PET;
    end
    SCN{a,5}=1;
    if ~isempty(scnp)
        save(scnp,'SCN');      
    end
end
% Load next experiment
a=zerofinder(SCN);
if a<1
    return
end
scn=SCN(a,:);
e.nextfile=[scn{1},'/',scn{2}];
feval(gh.open.Callback,gh.open,e);
feval(gh.start.Callback,gh.start,[]);
function a=zerofinder(SCN)
a=0;
while a>-1
    a=a+1;
    if a>size(SCN,1)
        a=0;
        return
    end
    if SCN{a,5}==0
        return
    end
end
