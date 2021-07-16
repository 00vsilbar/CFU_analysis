%Vanessa Silbar
%7/7/21, Image processing for bacteria colonies

clear all
close all force hidden

curr_path = pwd;
disp('Select Experiment')

img_dir_path = uigetdir(curr_path);

%set to 0 if you don't care about separating colonies
manually_separate = 1;

img_paths = dir(fullfile(img_dir_path, '*.png'));

disp(['Processing data for: ' img_dir_path])

[~,name] = fileparts(img_dir_path); %gets name of experiment/plate

exp_name = strings(1,length(img_paths));
img_name = strings(1,length(img_paths));
img_num = zeros(1,length(img_paths));
major_radius = zeros(1,length(img_paths));
minor_radius = zeros(1,length(img_paths));
calculated_radius = zeros(1,length(img_paths));
avg_radius = zeros(1,length(img_paths));
img_num_colony = zeros(1,length(img_paths));
total_num_colony = zeros(1,length(img_paths));
area_data = zeros(1,length(img_paths));

count = 1;
se = strel('disk',30);

for i = 1:length(img_paths)
    
    this_img_path = fullfile(img_dir_path,img_paths(i).name);
    
    this_img = imread(this_img_path);
    
    data = rgb2gray(this_img);
    
    thresh = mean2(data) + 2*std2(data);
    
    mask = bwareaopen(data > thresh,3000,4);
    %     masked_data = mask.*double(data);
    masked_data = mask;
    %             if isequal(dlg_choice,'Yes')
    
    if manually_separate
        imshow(masked_data); 
        title(img_paths(i).name,'Interpreter','none')
        hold on
        
        dlg_choice = questdlg({'Do any colonies in this image need to be separated?',...
            'If so draw line between colonies'},'Colonies','Yes','No','No');
        
        clear ROI
        
        while isequal(dlg_choice,'Yes')
            
            clear ROI
            
            ROI= drawline;
            bw_ROI = ROI.createMask(masked_data);
            
            thicc_bw_ROI = imgaussfilt(bw_ROI*5,3)>0;
            
            masked_data = masked_data.*(~thicc_bw_ROI);
            
            %               new_mask = (~imdilate(bw_ROI~=0,se));
            %               new_mask = (~new_mask);
            
            %               masked_data = masked_data + new_mask;
            
            dlg_choice = questdlg({'Do more colonies need to be separated?',...
                'If so draw line between colonies'},'Colonies','Yes','No','No');
        end
    end
    final_mask = imclearborder(masked_data);
    close all
    
    clear ROI
    
    Ifill = imfill(final_mask>0,'holes');
%     B = bwboundaries(Ifill);
    stat = regionprops(Ifill,'Centroid','MajorAxisLength','MinorAxisLength','Area');
%     imshow(final_mask); hold on
%     title([char(img_paths(i).name) ' perimeter image'],'Interpreter','none')
%     for k = 1 : length(B)
%         b = B{k};
%         c = stat(k).Centroid;
%         plot(b(:,2),b(:,1),'g','linewidth',2);
%         text(c(1),c(2),num2str(k),'backgroundcolor','g');
%     end
    
    for j = 1:length(stat)
        exp_name(count) = string(name);
        img_name(count) = string(img_paths(i).name);
        img_num(count) = i;
        total_num_colony(count) = count;
        img_num_colony(count) = j;
        major_radius(count) = stat(j).MajorAxisLength/2;
        minor_radius(count) = stat(j).MajorAxisLength/2;
        calculated_radius(count) = sqrt(stat(j).Area/pi);
        avg_radius(count) = (stat(j).MajorAxisLength/2 + stat(j).MajorAxisLength/2 + sqrt(stat(j).Area/pi))/3;
        area_data(count) = stat(j).Area;
        
        count = count + 1;
    end
    
end

csv_header = ["Sub Experiment Name","Image Path","Image Number",...
    "Total Colony Counter","Image Colony Counter"...
    "Major Radius","Minor Radius","Calculated Radius","Average Radius"...
    "Calculated Area sq pixels"];
   
exp_table = [exp_name;img_name;img_num;total_num_colony;img_num_colony;major_radius;minor_radius;calculated_radius;...
    avg_radius;area_data]';

for i = 1:size(exp_table,1)
    for j = 1:size(exp_table,2)
        final_table{i,j} = exp_table(i,j);
    end
end

T = cell2table(final_table,'VariableNames',csv_header);

output_csv_path = fullfile(img_dir_path,'data.csv');
disp(['Data output to ' output_csv_path])

writetable(T,output_csv_path);


