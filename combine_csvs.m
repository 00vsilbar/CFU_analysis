clear all

mainFolder = uigetdir();    % Selectyour Main folder
[~,message,~] = fileattrib(fullfile(mainFolder,'*'));

fprintf('\nThere are %i total files & folders in the overarching folder.\n',numel(message));

allExts = cellfun(@(s) s(end-2:end), {message.Name},'uni',0); % Get exts

CSVidx = ismember(allExts,'csv');    % Search ext for "CSV" at the end
CSV_filepaths = {message(CSVidx).Name};  % Use CSVidx to list all paths.

[~,CSV_names,~] = fileparts(CSV_filepaths);

combined_data_idx = find(contains(CSV_names,'combined_data'));

if ~isempty(combined_data_idx)
    
    CSV_filepaths(combined_data_idx) = [];
    
end

CSV_filepaths = CSV_filepaths(~cellfun('isempty',CSV_filepaths));

fprintf('There are %i files with data.csv exts.\n',numel(CSV_filepaths));

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

additional_strings = strings();
for i = 1:height(full_table)
    
    this_path = string(full_table.("Image Path")(i));
    if i == 1
        additional_strings = strsplit(this_path,{'\','/'});
    else
        try
            additional_strings = [additional_strings; ...
                strsplit(this_path,{'\','/'})];
        catch
            disp(['error on full_table line ' num2str(i)])
        end
    end
    
end

writetable(out_table,fullfile(mainFolder,'combined_data.csv'))
