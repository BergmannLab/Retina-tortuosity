% SOFIA 
% Read the different data of all the images allowing have all together 
% in read_all_taus

rootdir='/Users/sortinve/develop/retina/preprocessing/helpers/MeasureVessels/src/output';
read_taus_all = zeros(13,1);
read_taus_artery = zeros(13,1);
read_taus_vein = zeros(13,1);
%"median_diameter \t D9_diameter \t median_tortuosity \t short_tortuosity \t D9_tortuosity \t D95_tortuosity \t tau1 \t tau2 \t tau3 \t tau4 \t tau5 \t tau6 \t tau7 \t tau0 \n";


d_all=dir(fullfile(rootdir,'*all_stats.tsv')); 

for i=1:length(d_all)
  fidi=tdfread(fullfile(rootdir,d_all(i).name));       
  fidi2 = cell2mat(struct2cell(fidi));
  read_taus_all = [read_taus_all,fidi2];  
end

d_artery=dir(fullfile(rootdir,'*artery_stats.tsv')); 

for i=1:length(d_artery)
  fidi=tdfread(fullfile(rootdir,d_artery(i).name));       
  fidi2 = cell2mat(struct2cell(fidi));
  read_taus_artery = [read_taus_artery,fidi2];  
end
 
d_vein=dir(fullfile(rootdir,'*vein_stats.tsv')); 

for i=1:length(d_vein)
  fidi=tdfread(fullfile(rootdir,d_vein(i).name));       
  fidi2 = cell2mat(struct2cell(fidi));
  read_taus_vein = [read_taus_vein,fidi2];  
end
