
mainFolder = uigetdir();    % Selectyour Main folder
[~,message,~] = fileattrib([mainFolder,'\*']);

fprintf('\nThere are %i total files & folders in the overarching folder.\n',numel(message));

allExts = cellfun(@(s) s(end-2:end), {message.Name},'uni',0); % Get exts

CSVidx = ismember(allExts,'csv');    % Search ext for "CSV" at the end
CSV_filepaths = {message(CSVidx).Name};  % Use CSVidx to list all paths.

fprintf('There are %i files with *.CSV exts.\n',numel(CSV_filepaths));

csv_table = cell(1,length(CSV_filepaths));
% censored,dead,areas,intensities,names
for i = 1:numel(CSV_filepaths)
    csv_table{i}= readtable(CSV_filepaths{i},'VariableNamingRule','preserve'); % Your parsing will be different
end

for i = 1:length(csv_table)
    
    if isequal(i,1)
        
        full_table = csv_table{1};
        
    else
        full_table = [full_table;csv_table{i}];
    end
    
end

writetable(full_table,fullfile(mainFolder,'combined_data.csv'))