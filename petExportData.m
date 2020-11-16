% Exports data to MS excell or ascii format
% Input variables:
% PET is the main variable of the toolbox
function petExportData(PET,byla,npath,FilterIndex)
global VDS
if isempty(VDS)
    V=load('petVisDataStruct.mat');
    VDS=V.VDS;
end
if nargin==0
    [PET,byla]=petLoad;
    if byla==0; return; end
end
cfile=strtok(byla,'.');
if ~nargin==4
    [cfile,npath,FilterIndex] = uiputfile({'MS excell','*.xls'; 'ASCII', '*.txt'},'Export experiment data',cfile);
    if cfile==0
        return;
    end
end
if FilterIndex==1
    if VDS.GraphPar.Split_files==true
        for a=1:length(PET)
            [~, Tbl]=petGetData(PET(a));
            writetable(Tbl,[npath,cfile,'.xls'],'Sheet',a);
        end
    else
        [~, Tbl]=petGetData(PET);
        writetable(Tbl,[npath,cfile,'.xls']);
    end
else
    if VDS.GraphPar.Split_files==true
        disp('The file was not splited')
    end
    [~, Tbl]=petGetData(PET);
    writetable(Tbl,[npath,cfile]);
end
% for a=1:size(sheet,3)
%     if FilterIndex==1
%         sheet=num2cell(sheet);
%         xlswrite([npath,cfile], sheetcell(:,:,a));
% %         xlswrite([npath,cfile], sheet(:,:,a),[sheet{1,2,a},'=',num2str(sheet{2,2,a})]);
%     else
%         if a==1
%             dlmwrite([npath,cfile], sheet(1,1:6,a));
%         end
%         dlmwrite([npath,cfile], sheet(2:end,:,a),'-append');
%     end
% end