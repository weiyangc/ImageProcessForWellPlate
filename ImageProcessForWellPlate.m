function ImageProcessForWellPlate( onetest_path, output_midresult, output_finalresult, live_mobility_thresh, average_worm_size )
% This function process one test's(video) images and compute all features' values; 
% onetest_path:        the images' path of one test video; 
% output_midresult:    middle results' output path;
% output_finalresult:  final results' output path;
%                    path must be end by '/'; 
% live_mobility_thresh: overlap ratio < this threshold is moving worm;
% average_worm_size:    single worm's average size; 


impurity_size_thresh = average_worm_size/2.5;   
length_width_ratio_up = 300;         
length_width_ratio = 6.0;      

disp_use = ['ImageProcessForWellPlate: ' 'onetest_path(' onetest_path '), ' 'output_midresult(' output_midresult '), ' 'output_finalresult(' output_finalresult ')'];
disp( disp_use );

middle_result_name = [output_midresult 'detailed_info.txt'];   
fid_middle_result = fopen(middle_result_name,'w');

% Processing images in this path
images_list = dir([onetest_path '*.jpg']);           
ima1size_name = [onetest_path images_list(1).name];
ima1size = imread( ima1size_name );
[M N Z] = size( ima1size ); 
images_num  = length(images_list); 
    
L = zeros(M,N,images_num);
all_processed_gray = zeros(M,N,images_num); 
all_original_gray_image = zeros(M,N,images_num); 
numc = zeros(images_num);
for i_file3 = 1:images_num
    ima1_name = [onetest_path images_list(i_file3).name];
	ima1 = imread( ima1_name );
    
	[oneimage_bw oneimage_processed_gray] = WellPlate_bw( ima1, impurity_size_thresh );
	
	if size(ima1,3) == 3
		ima1 = rgb2gray(ima1); 
	end
	all_original_gray_image(:,:,i_file3) = ima1; 
	
	out_filename = [output_midresult images_list(i_file3).name(1:length(images_list(i_file3).name)-4) '_bw.png'];
    imwrite(oneimage_bw, out_filename);	
	out_filename2 = [output_midresult images_list(i_file3).name(1:length(images_list(i_file3).name)-4) '_gray.png'];
    imwrite(oneimage_processed_gray, out_filename2);	
	
    [L(:,:,i_file3) numc(i_file3)] = bwlabel( oneimage_bw, 8 );  
	all_processed_gray(:,:,i_file3) = oneimage_processed_gray; 
end


frame_number_all = [];                   
frame_number_live_all = [];              
frame_number_single = [];                
frame_number_single_live = [];           

frame_worms_disperse_situation = [];     

frame_worms_centroid_mean_dis_all = [];  
frame_worms_centroid_std_dis_all = [];   

frame_area_single_all = [];              
frame_area_single_live = [];             

frame_length_single_all = [];            
frame_length_single_live = [];           

frame_width_single_all = [];            
frame_width_single_live = [];           

frame_Perimeter_single_all = [];        
frame_Perimeter_single_live = [];        

frame_meangray_single_all = [];          
frame_meangray_single_live = [];         

frame_stdgray_single_all = [];           
frame_stdgray_single_live = [];          

frame_majoraxis_single_all = [];         
frame_majoraxis_single_live = [];       

frame_minoraxis_single_all = [];        
frame_minoraxis_single_live = [];        

frame_minor_vs_major_single_all = [];    
frame_minor_vs_major_single_live = [];   

frame_Eccentricity_single_all = [];      
frame_Eccentricity_single_live = [];     

frame_Orientation_single_all = [];       
frame_Orientation_single_live = [];     

frame_mot_area_single_all = [];          
frame_mot_area_single_live = [];         
frame_mot_ratio_single_all = [];        
frame_mot_ratio_single_live = [];        


for i_file = 1:images_num-1    
	
	oneimage_labled = L(:,:,i_file);                
	oneimage_labled_next = L(:,:,i_file+1);          
	oneimage_gray = all_processed_gray(:,:,i_file);  
	
	STATS = regionprops(oneimage_labled, 'Area', 'Centroid', 'Eccentricity', 'MajorAxisLength', 'MinorAxisLength', 'Orientation' ,'PixelList','PixelIdxList'); 
	
	worm_number_all = 0;                   
	worm_number_live_all = 0;              
	worm_number_single = 0;                
	worm_number_single_live = 0;          
	
	worms_centroid = [];                  
	
	
	final_bw = zeros(M,N);
	
	frame1 = all_original_gray_image(:,:,i_file);
	frame2 = all_original_gray_image(:,:,i_file+1);
	ima_minus = double(frame2) - double(frame1);
	ima_minus = ima_minus > 5;
	ima_minus = bwareaopen(ima_minus, 10);
	out_filename_bw_moved = [output_midresult images_list(i_file).name(1:length(images_list(i_file).name)-4)  '_moved_bw.png'];
	imwrite(ima_minus, out_filename_bw_moved);
	
	
	objects_num = length(STATS); 
	for i_object = 1:objects_num		
		oneworm_area = STATS(i_object).Area;
		
		oneworm = zeros(size(oneimage_labled));
        oneworm(oneimage_labled==i_object) = 1;    
		
		oneworm_perimeter = sum(sum(edge(uint8(oneworm))));  
		one_width_temp = fzero(@(x) widlenfun(x,oneworm_area,oneworm_perimeter), 6);
        one_length_temp = oneworm_area/one_width_temp;
		
		if one_length_temp/one_width_temp >= length_width_ratio   
			
			final_bw( STATS(i_object).PixelIdxList ) = 1;
			
			worms_centroid = [worms_centroid; STATS(i_object).Centroid];  
			object = oneimage_labled == i_object; 
			overlap = sum(sum(uint8(object & oneimage_labled_next)));  
			
			if oneworm_area > 1.5*average_worm_size  
				num_in_cluster = round(oneworm_area/average_worm_size);
				worm_number_all = worm_number_all + num_in_cluster;    
				
				frame1_object_overlap = ima_minus & object; 
				inside_object_moved_size = sum(sum(uint8( frame1_object_overlap )));
				live_num_1 = round( inside_object_moved_size/(average_worm_size/4) );  
				live_num_2 = round( inside_object_moved_size/(average_worm_size/3) );  
				live_num_3 = round( inside_object_moved_size/(average_worm_size/2) );  
				live_num_4 = round( inside_object_moved_size/average_worm_size );  
				
				live_num_5 = 0;
				[labeled_insid_object num_insid_object] = bwlabel( frame1_object_overlap, 8 );  
				STAT_insid_object = regionprops(labeled_insid_object, 'Area', 'Centroid' );
				if num_insid_object > 0  
					regions_centroid = zeros(2, num_insid_object); 
					for i_region =1:num_insid_object
						regions_centroid(:, i_region)=[STAT_insid_object(i_region).Centroid(1) STAT_insid_object(i_region).Centroid(2)]';						
					end
					
					regions_dist = dist(regions_centroid);  
					regions_index_label = zeros(1, num_insid_object);  
					regions_dist_bw = regions_dist < 80; 
					for i_index =1:num_insid_object       
						if regions_index_label(i_index) == 0
							regions_in_dist = find(regions_dist_bw(i_index,:));  
							regions_area = 0;
							for i_child_region = 1:length(regions_in_dist)     
								STAT_index = regions_in_dist(i_child_region);
								regions_area = regions_area + STAT_insid_object(STAT_index).Area;								
							end
							if regions_area > (1 - live_mobility_thresh)*average_worm_size  
								regions_number = regions_area/(1.2*average_worm_size);     
								live_num_5 = live_num_5 + ceil(regions_number);								
							end
							
							regions_index_label(i_index) = 1; 
							regions_index_label(regions_in_dist) = 1; 
						end
					end
						
				else
					live_num_5 = 0;
				end
				
				if live_num_5 <= num_in_cluster
					worm_number_live_all = worm_number_live_all + live_num_5;
				elseif live_num_1 <= num_in_cluster
					worm_number_live_all = worm_number_live_all + live_num_1;
				elseif live_num_2 <= num_in_cluster
					worm_number_live_all = worm_number_live_all + live_num_2;
				elseif live_num_3 <= num_in_cluster
					worm_number_live_all = worm_number_live_all + live_num_3;
				else
					worm_number_live_all = worm_number_live_all + live_num_4;
				end
				
			else 
				worm_number_all = worm_number_all + 1;
				worm_number_single = worm_number_single + 1; 
				
				temponewormgray = oneimage_gray( oneimage_labled==i_object );
				one_meangray = mean( double(temponewormgray) );
				one_stdgray = std( double(temponewormgray) );
				one_minor_vs_major = STATS(i_object).MinorAxisLength/STATS(i_object).MajorAxisLength; 
				moved_area = oneworm_area - overlap;
				moved_rate = 1 - overlap/oneworm_area;
				
				frame1_object_overlap = ima_minus & object; 
				inside_object_moved_size = sum(sum(uint8( frame1_object_overlap )));
				
				frame_area_single_all = [frame_area_single_all oneworm_area];                                      
				frame_length_single_all = [frame_length_single_all one_length_temp];                               
				frame_width_single_all = [frame_width_single_all one_width_temp];                                  
				frame_Perimeter_single_all = [frame_Perimeter_single_all oneworm_perimeter];                       
				frame_meangray_single_all = [frame_meangray_single_all one_meangray];                              
				frame_stdgray_single_all = [frame_stdgray_single_all one_stdgray];                                 
				frame_majoraxis_single_all = [frame_majoraxis_single_all STATS(i_object).MajorAxisLength];         
				frame_minoraxis_single_all = [frame_minoraxis_single_all STATS(i_object).MinorAxisLength];         
				frame_minor_vs_major_single_all = [frame_minor_vs_major_single_all one_minor_vs_major];            
				frame_Eccentricity_single_all = [frame_Eccentricity_single_all STATS(i_object).Eccentricity];      
				frame_Orientation_single_all = [frame_Orientation_single_all STATS(i_object).Orientation];         
				if overlap > 0  
					frame_mot_area_single_all = [frame_mot_area_single_all moved_area];                            
					frame_mot_ratio_single_all = [frame_mot_ratio_single_all moved_rate];                         					
				end
				
				if overlap > 0 && inside_object_moved_size > (1 - live_mobility_thresh)*average_worm_size  
					worm_number_live_all = worm_number_live_all + 1;   	
					worm_number_single_live = worm_number_single_live + 1;   
					
					frame_area_single_live = [frame_area_single_live oneworm_area];             
					frame_length_single_live = [frame_length_single_live one_length_temp];           
					frame_width_single_live = [frame_width_single_live one_width_temp];            
					frame_Perimeter_single_live = [frame_Perimeter_single_live oneworm_perimeter];        
					frame_meangray_single_live = [frame_meangray_single_live one_meangray];         
					frame_stdgray_single_live = [frame_stdgray_single_live one_stdgray];          
					frame_majoraxis_single_live = [frame_majoraxis_single_live STATS(i_object).MajorAxisLength];        
					frame_minoraxis_single_live = [frame_minoraxis_single_live STATS(i_object).MinorAxisLength];        
					frame_minor_vs_major_single_live = [frame_minor_vs_major_single_live one_minor_vs_major];   
					frame_Eccentricity_single_live = [frame_Eccentricity_single_live STATS(i_object).Eccentricity];    
					frame_Orientation_single_live = [frame_Orientation_single_live STATS(i_object).Orientation];      
					
					frame_mot_area_single_live = [frame_mot_area_single_live moved_area];         
					frame_mot_ratio_single_live = [frame_mot_ratio_single_live moved_rate];        
				end				
			end			
		end		
	end 
	
	out_filename_3 = [output_midresult images_list(i_file).name(1:length(images_list(i_file).name)-4) '_bw_finalworm.png'];
	imwrite(final_bw, out_filename_3);	
	
	frame_number_all = [frame_number_all worm_number_all];                   
	frame_number_live_all = [frame_number_live_all worm_number_live_all];             
	frame_number_single = [frame_number_single worm_number_single];               
	frame_number_single_live = [frame_number_single_live worm_number_single_live];          
	
	if ~isempty( worms_centroid )  
		[mean_dist std_dist]= ComputeDistanceOfCentroids( worms_centroid );
	else
		mean_dist = [];
		std_dist = [];
	end
	one_disperse_situation = worm_number_single/worm_number_all;
	
	frame_worms_centroid_mean_dis_all = [frame_worms_centroid_mean_dis_all mean_dist];  
	frame_worms_centroid_std_dis_all = [frame_worms_centroid_std_dis_all std_dist];  
	frame_worms_disperse_situation = [frame_worms_disperse_situation one_disperse_situation];     
	
	% write to 'txt' file
	ima_name = [onetest_path images_list(i_file).name];
	fprintf(fid_middle_result,'Frame: %d, %s\n',i_file, ima_name);
	fprintf(fid_middle_result,'worm_number_all: %d, worm_number_live_all: %d, worm_number_single: %d, worm_number_single_live: %d\n', ...
	                           worm_number_all, worm_number_live_all, worm_number_single, worm_number_single_live);
	fprintf(fid_middle_result,'All objects centroids info: ');
	for i_object_write = 1:objects_num   
		fprintf(fid_middle_result,'X(%f), Y(%f); ',STATS(i_object_write).Centroid(1), STATS(i_object_write).Centroid(2));
	end 
	fprintf(fid_middle_result,'\n');
	size_worms_centroid = size( worms_centroid );
	fprintf(fid_middle_result,'All worm objects centroids info: ');
	for i_object_write = 1:size_worms_centroid(1)   
		fprintf(fid_middle_result,'X(%f), Y(%f); ', worms_centroid(1), worms_centroid(2));
	end 
	fprintf(fid_middle_result,'\n');
		
end


middle_detailed_result_name = [output_midresult 'detailed_features.txt'];   
fid_middle_detailed_result = fopen(middle_detailed_result_name,'w');
fprintf(fid_middle_detailed_result,'frame_number_all: \t');
fprintf(fid_middle_detailed_result,'%d\t',frame_number_all);  
fprintf(fid_middle_detailed_result,'\n');

fprintf(fid_middle_detailed_result,'frame_number_live_all: \t');
fprintf(fid_middle_detailed_result,'%d\t',frame_number_live_all);  
fprintf(fid_middle_detailed_result,'\n');

fprintf(fid_middle_detailed_result,'frame_number_single: \t');
fprintf(fid_middle_detailed_result,'%d\t',frame_number_single);  
fprintf(fid_middle_detailed_result,'\n');

fprintf(fid_middle_detailed_result,'frame_number_single_live: \t');
fprintf(fid_middle_detailed_result,'%d\t',frame_number_single_live );  
fprintf(fid_middle_detailed_result,'\n');

fprintf(fid_middle_detailed_result,'frame_worms_disperse_situation: \t');
fprintf(fid_middle_detailed_result,'%f\t',frame_worms_disperse_situation );  
fprintf(fid_middle_detailed_result,'\n');

fprintf(fid_middle_detailed_result,'frame_worms_centroid_mean_dis_all: \t');
fprintf(fid_middle_detailed_result,'%f\t',frame_worms_centroid_mean_dis_all );  
fprintf(fid_middle_detailed_result,'\n');

fprintf(fid_middle_detailed_result,'frame_worms_centroid_std_dis_all: \t');
fprintf(fid_middle_detailed_result,'%f\t',frame_worms_centroid_std_dis_all );  
fprintf(fid_middle_detailed_result,'\n');

fprintf(fid_middle_detailed_result,'frame_area_single_all: \t');
fprintf(fid_middle_detailed_result,'%f\t',frame_area_single_all );  
fprintf(fid_middle_detailed_result,'\n');

fprintf(fid_middle_detailed_result,'frame_area_single_live: \t');
fprintf(fid_middle_detailed_result,'%f\t',frame_area_single_live );  
fprintf(fid_middle_detailed_result,'\n');

fprintf(fid_middle_detailed_result,'frame_length_single_all: \t');
fprintf(fid_middle_detailed_result,'%f\t',frame_length_single_all );  
fprintf(fid_middle_detailed_result,'\n');

fprintf(fid_middle_detailed_result,'frame_length_single_live: \t');
fprintf(fid_middle_detailed_result,'%f\t',frame_length_single_live );  
fprintf(fid_middle_detailed_result,'\n');

fprintf(fid_middle_detailed_result,'frame_width_single_all: \t');
fprintf(fid_middle_detailed_result,'%f\t',frame_width_single_all );  
fprintf(fid_middle_detailed_result,'\n');

fprintf(fid_middle_detailed_result,'frame_width_single_live: \t');
fprintf(fid_middle_detailed_result,'%f\t',frame_width_single_live );  
fprintf(fid_middle_detailed_result,'\n');

fprintf(fid_middle_detailed_result,'frame_Perimeter_single_all: \t');
fprintf(fid_middle_detailed_result,'%f\t',frame_Perimeter_single_all );  
fprintf(fid_middle_detailed_result,'\n');

fprintf(fid_middle_detailed_result,'frame_Perimeter_single_live: \t');
fprintf(fid_middle_detailed_result,'%f\t',frame_Perimeter_single_live );  
fprintf(fid_middle_detailed_result,'\n');

fprintf(fid_middle_detailed_result,'frame_meangray_single_all: \t');
fprintf(fid_middle_detailed_result,'%f\t',frame_meangray_single_all  );  
fprintf(fid_middle_detailed_result,'\n');

fprintf(fid_middle_detailed_result,'frame_meangray_single_live : \t');
fprintf(fid_middle_detailed_result,'%f\t',frame_meangray_single_live );  
fprintf(fid_middle_detailed_result,'\n');

fprintf(fid_middle_detailed_result,'frame_stdgray_single_all: \t');
fprintf(fid_middle_detailed_result,'%f\t',frame_stdgray_single_all );  
fprintf(fid_middle_detailed_result,'\n');

fprintf(fid_middle_detailed_result,'frame_stdgray_single_live: \t');
fprintf(fid_middle_detailed_result,'%f\t',frame_stdgray_single_live );  
fprintf(fid_middle_detailed_result,'\n');

fprintf(fid_middle_detailed_result,'frame_majoraxis_single_all: \t');
fprintf(fid_middle_detailed_result,'%f\t',frame_majoraxis_single_all );  
fprintf(fid_middle_detailed_result,'\n');

fprintf(fid_middle_detailed_result,'frame_majoraxis_single_live: \t');
fprintf(fid_middle_detailed_result,'%f\t',frame_majoraxis_single_live );  
fprintf(fid_middle_detailed_result,'\n');

fprintf(fid_middle_detailed_result,'frame_minoraxis_single_all: \t');
fprintf(fid_middle_detailed_result,'%f\t',frame_minoraxis_single_all );  
fprintf(fid_middle_detailed_result,'\n');

fprintf(fid_middle_detailed_result,'frame_minoraxis_single_live: \t');
fprintf(fid_middle_detailed_result,'%f\t',frame_minoraxis_single_live );  
fprintf(fid_middle_detailed_result,'\n');

fprintf(fid_middle_detailed_result,'frame_minor_vs_major_single_all: \t');
fprintf(fid_middle_detailed_result,'%f\t',frame_minor_vs_major_single_all );  
fprintf(fid_middle_detailed_result,'\n');

fprintf(fid_middle_detailed_result,'frame_minor_vs_major_single_live: \t');
fprintf(fid_middle_detailed_result,'%f\t',frame_minor_vs_major_single_live );  
fprintf(fid_middle_detailed_result,'\n');

fprintf(fid_middle_detailed_result,'frame_Eccentricity_single_all: \t');
fprintf(fid_middle_detailed_result,'%f\t',frame_Eccentricity_single_all );  
fprintf(fid_middle_detailed_result,'\n');

fprintf(fid_middle_detailed_result,'frame_Eccentricity_single_live: \t');
fprintf(fid_middle_detailed_result,'%f\t',frame_Eccentricity_single_live );  
fprintf(fid_middle_detailed_result,'\n');

fprintf(fid_middle_detailed_result,'frame_Orientation_single_all: \t');
fprintf(fid_middle_detailed_result,'%f\t',frame_Orientation_single_all );  
fprintf(fid_middle_detailed_result,'\n');

fprintf(fid_middle_detailed_result,'frame_Orientation_single_live: \t');
fprintf(fid_middle_detailed_result,'%f\t',frame_Orientation_single_live );  
fprintf(fid_middle_detailed_result,'\n');

fprintf(fid_middle_detailed_result,'frame_mot_area_single_all: \t');
fprintf(fid_middle_detailed_result,'%f\t',frame_mot_area_single_all );  
fprintf(fid_middle_detailed_result,'\n');

fprintf(fid_middle_detailed_result,'frame_mot_area_single_live: \t');
fprintf(fid_middle_detailed_result,'%f\t',frame_mot_area_single_live );  
fprintf(fid_middle_detailed_result,'\n');

fprintf(fid_middle_detailed_result,'frame_mot_ratio_single_all: \t');
fprintf(fid_middle_detailed_result,'%f\t',frame_mot_ratio_single_all );  
fprintf(fid_middle_detailed_result,'\n');

fprintf(fid_middle_detailed_result,'frame_mot_ratio_single_live: \t');
fprintf(fid_middle_detailed_result,'%f\t',frame_mot_ratio_single_live );  
fprintf(fid_middle_detailed_result,'\n');


mean_frame_number_all = round( mean( frame_number_all ) );
mean_frame_number_live_all = round( mean( frame_number_live_all ) );
mean_frame_number_single = round( mean( frame_number_single ) );
mean_frame_number_single_live = round( mean( frame_number_single_live ) );
mean_frame_worms_disperse_situation = mean( frame_worms_disperse_situation );
mean_frame_worms_centroid_mean_dis_all = mean( frame_worms_centroid_mean_dis_all );
mean_frame_worms_centroid_std_dis_all = mean( frame_worms_centroid_std_dis_all );
mean_frame_area_single_all = mean( frame_area_single_all );
mean_frame_area_single_live = mean( frame_area_single_live );
mean_frame_length_single_all = mean( frame_length_single_all );
mean_frame_length_single_live = mean( frame_length_single_live );
mean_frame_width_single_all = mean( frame_width_single_all );
mean_frame_width_single_live = mean( frame_width_single_live );
mean_frame_Perimeter_single_all = mean( frame_Perimeter_single_all );
mean_frame_Perimeter_single_live = mean( frame_Perimeter_single_live );
mean_frame_meangray_single_all = mean( frame_meangray_single_all );
mean_frame_meangray_single_live = mean( frame_meangray_single_live );
mean_frame_stdgray_single_all = mean( frame_stdgray_single_all );
mean_frame_stdgray_single_live = mean( frame_stdgray_single_live );
mean_frame_majoraxis_single_all = mean( frame_majoraxis_single_all );
mean_frame_majoraxis_single_live = mean( frame_majoraxis_single_live );
mean_frame_minoraxis_single_all = mean( frame_minoraxis_single_all );
mean_frame_minoraxis_single_live = mean( frame_minoraxis_single_live );
mean_frame_minor_vs_major_single_all = mean( frame_minor_vs_major_single_all );
mean_frame_minor_vs_major_single_live = mean( frame_minor_vs_major_single_live );
mean_frame_Eccentricity_single_all = mean( frame_Eccentricity_single_all );
mean_frame_Eccentricity_single_live = mean( frame_Eccentricity_single_live );
mean_frame_Orientation_single_all = mean( frame_Orientation_single_all );
mean_frame_Orientation_single_live = mean( frame_Orientation_single_live );
mean_frame_mot_area_single_all = mean( frame_mot_area_single_all );
mean_frame_mot_area_single_live = mean( frame_mot_area_single_live );
mean_frame_mot_ratio_single_all = mean( frame_mot_ratio_single_all );
mean_frame_mot_ratio_single_live = mean( frame_mot_ratio_single_live );

final_result_name = [output_finalresult 'results.tsv'];   
if ~exist(final_result_name,'file')     
	fid_final_result = fopen(final_result_name,'w');
	file_head = ['input path \t mean_worm_number_all \t mean_worm_number_live_all \t mean_worm_number_single \t mean_worm_number_single_live \t' ...
	            'mean_worm_disperse_situation \t mean_worm_centroid_mean_dis_all \t mean_worm_centroid_std_dis_all \t mean_worm_area_single_all \t mean_worm_area_single_live \t' ...
				'mean_worm_length_single_all \t mean_worm_length_single_live \t mean_worm_width_single_all \t mean_worm_width_single_live \t mean_worm_perimeter_single_all \t' ...
				'mean_worm_perimeter_single_live \t mean_worm_meangray_single_all \t mean_worm_meangray_single_live \t mean_worm_stdgray_single_all \t mean_worm_stdgray_single_live \t' ...
				'mean_worm_majoraxis_single_all \t mean_worm_majoraxis_single_live \t mean_worm_minoraxis_single_all \t mean_worm_minoraxis_single_live \t mean_worm_minor_vs_major_single_all \t' ...
				'mean_worm_minor_vs_major_single_live \t mean_worm_eccentricity_single_all \t mean_worm_eccentricity_single_live \t mean_worm_orientation_single_all \t mean_worm_orientation_single_live \t' ...
				'mean_worm_mot_area_single_all \t mean_worm_mot_area_single_live \t mean_worm_mot_ratio_single_all \t mean_worm_mot_ratio_single_live \n'];
	fprintf(fid_final_result, file_head);			
else
	fid_final_result = fopen(final_result_name,'a');
end


S = regexp(onetest_path, '/');
if length(S) > 4                 
	usedpath = onetest_path(S(length(S)-4)+1 : end);
else
	usedpath = onetest_path;
end

fprintf(fid_final_result,'%s\t%d\t%d\t%d\t%d\t%f\t%f\t%f\t%f\t%f\t%f\t%f\t%f\t%f\t%f\t%f\t%f\t%f\t%f\t%f\t%f\t%f\t%f\t%f\t%f\t%f\t%f\t%f\t%f\t%f\t%f\t%f\t%f\t%f\n', ...
                          usedpath, mean_frame_number_all, mean_frame_number_live_all ,mean_frame_number_single ,mean_frame_number_single_live ,mean_frame_worms_disperse_situation , ...
						  mean_frame_worms_centroid_mean_dis_all ,mean_frame_worms_centroid_std_dis_all ,mean_frame_area_single_all ,mean_frame_area_single_live ,mean_frame_length_single_all , ...
						  mean_frame_length_single_live ,mean_frame_width_single_all ,mean_frame_width_single_live ,mean_frame_Perimeter_single_all ,mean_frame_Perimeter_single_live , ...
						  mean_frame_meangray_single_all ,mean_frame_meangray_single_live ,mean_frame_stdgray_single_all ,mean_frame_stdgray_single_live ,mean_frame_majoraxis_single_all , ...
						  mean_frame_majoraxis_single_live ,mean_frame_minoraxis_single_all ,mean_frame_minoraxis_single_live ,mean_frame_minor_vs_major_single_all ,mean_frame_minor_vs_major_single_live , ...
						  mean_frame_Eccentricity_single_all ,mean_frame_Eccentricity_single_live ,mean_frame_Orientation_single_all ,mean_frame_Orientation_single_live , ...
						  mean_frame_mot_area_single_all ,mean_frame_mot_area_single_live ,mean_frame_mot_ratio_single_all ,mean_frame_mot_ratio_single_live );


fclose(fid_middle_result);
fclose(fid_middle_detailed_result);
fclose(fid_final_result);


all_mean_features_values = [mean_frame_number_all, mean_frame_number_live_all ,mean_frame_number_single ,mean_frame_number_single_live ,mean_frame_worms_disperse_situation , ...
						  mean_frame_worms_centroid_mean_dis_all ,mean_frame_worms_centroid_std_dis_all ,mean_frame_area_single_all ,mean_frame_area_single_live ,mean_frame_length_single_all , ...
						  mean_frame_length_single_live ,mean_frame_width_single_all ,mean_frame_width_single_live ,mean_frame_Perimeter_single_all ,mean_frame_Perimeter_single_live , ...
						  mean_frame_meangray_single_all ,mean_frame_meangray_single_live ,mean_frame_stdgray_single_all ,mean_frame_stdgray_single_live ,mean_frame_majoraxis_single_all , ...
						  mean_frame_majoraxis_single_live ,mean_frame_minoraxis_single_all ,mean_frame_minoraxis_single_live ,mean_frame_minor_vs_major_single_all ,mean_frame_minor_vs_major_single_live , ...
						  mean_frame_Eccentricity_single_all ,mean_frame_Eccentricity_single_live ,mean_frame_Orientation_single_all ,mean_frame_Orientation_single_live , ...
						  mean_frame_mot_area_single_all ,mean_frame_mot_area_single_live ,mean_frame_mot_ratio_single_all ,mean_frame_mot_ratio_single_live]; 

end
% end of this function;





function [oneimage_bw oneimage_processed_gray] = WellPlate_bw( oneimage_orig_gray, impurity_size_thresh )
% This function segments the images, and return the BW result; 
% oneimage_orig_gray:   one original gray image; 

orig_ima_filterwidth = 2;    
step_num = 32;   
sigma_mask = 9; 

ima = oneimage_orig_gray; 

if size(ima,3) == 3
    ima1 = rgb2gray(ima); 
else 
	ima1 = ima; 
end
	

ima1 = filter_function(ima1, orig_ima_filterwidth); 

min_gray = min(min(ima1));
max_gray = max(max(ima1));
step_gray = (max_gray - min_gray +1)/step_num;   

grades = min_gray:step_gray:max_gray;
ima_mask = zeros(size(ima1));


if step_num > length(grades)
	step_num = length(grades); 
end

for i_g = 1:step_num    
	ima_t = zeros(size(ima1));
	ima_t( ima1>=grades(i_g) )=1;  
	[rows cols] = find(ima_t>0);
	if length(rows) > 5   
        xv = [];
        yv = [];
        [k2 v2]= convhull(rows, cols);  
        for i_k=1:length(k2)
            xv = [xv rows(k2(i_k))];
            yv = [yv cols(k2(i_k))];
        end

        [X Y] = find(ima_t==0);  
        
        in = inpolygon(X,Y,xv,yv);
        for i_n =1:length(in)
            if in(i_n) == 1   
                ima_t(X(i_n), Y(i_n)) = 1;
            end	
        end
        
        idlist_mask = find(ima_t==1); 
        ima_mask( idlist_mask ) = grades(i_g);
	end
end

y = filter_function(ima_mask, sigma_mask);

ima_mask = y;

ima2=double(ima1);
ima1_results = ima2 - ima_mask;

min_imaresult = min(min(ima1_results));    
if min(min(ima1_results))<0
	ima1_results = ima1_results - min(min(ima1_results));   
end

max_gray = max(max(ima1_results));
min_gray = min(min(ima1_results));
gray_scope = max_gray - min_gray;  
[row col] = size(ima1_results);
for i =1:row
	for j =1:col
		ima1_results(i,j) = ( (ima1_results(i,j)-min_gray)/gray_scope )*255;  
	end
end

ima1_results = uint8(ima1_results);

ima1bw = im2bw(ima1_results, graythresh(ima1_results)); 

ima1bw_2 = ~ima1bw;
ima1bw_2 = bwareaopen(ima1bw_2, impurity_size_thresh); 

oneimage_bw = ima1bw_2;
oneimage_processed_gray = ima1_results;

end



function smth = filter_function(image, sigma)
% This function smooths the image

smask = fspecial('gaussian', ceil(3*sigma), sigma);
smth = filter2(smask, image, 'same');
end



function fwidlen = widlenfun(x,a,p)
fwidlen = x*x-(p/2)*x+a;
end






function [mean_dist std_dist]= ComputeDistanceOfCentroids( centroid_matrix )
% compute average distance between every two centroids; 
% centroid_matrix: coordinates of all centroids;

coordinates_matrix = centroid_matrix;
k = size(coordinates_matrix,1);
coordinates_matrix_x = repmat(coordinates_matrix(:,1),1,k);
coordinates_matrix_y = repmat(coordinates_matrix(:,2),1,k);
coordinates_matrix_t_x = repmat(coordinates_matrix(:,1)',k,1);
coordinates_matrix_t_y = repmat(coordinates_matrix(:,2)',k,1);
distance = sqrt((coordinates_matrix_x - coordinates_matrix_t_x).^2 + (coordinates_matrix_y - coordinates_matrix_t_y).^2);

mean_dist = mean(distance(distance>0));
std_dist  = std(distance(distance>0));
end














