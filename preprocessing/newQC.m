cd /home/mbeyele5/data_sbergman/retina/UKBiob/fundus/REVIEW/CLRIS/
files = dir();
files = files(3:end); %first 2 elements are '.' and '..'

myLen = length(files);

myf=string.empty; %strings gotta be declared differently
avg=NaN(1,myLen);
diffY=NaN(1,myLen);
diffX=NaN(1,myLen);
diffXY=NaN(1,myLen);

for k = 1:myLen
    if rem(k, 100) == 0
        disp(k)
    end
 
    myf(k) = string(files(k).name);
    img = imread(files(k).name);
    
    avg(k) = mean(img(:));
    
    sizeImg = size(img);

    diffY(k) = sum(abs(diff(img,1,1)),'all')/((sizeImg(1)-1)*sizeImg(2));
    diffX(k) = sum(abs(diff(img,1,2)),'all')/(sizeImg(1)*(sizeImg(2)-1));
    diffXY(k) = sum(abs(img(1:end-1,1:end-1,:)-img(2:end,2:end,:)),'all')/((sizeImg(1)-1)*(sizeImg(2)-1));

end
%disp(myf');
%csvwrite("/scratch/beegfs/FAC/FBM/DBC/sbergman/retina/preprocessing/output/newQC/images.csv", myf')
outfile = "/scratch/beegfs/FAC/FBM/DBC/sbergman/retina/preprocessing/output/newQC/stats.csv";
T = table(avg',diffX',diffY',diffXY');
writetable(T,outfile);
%dlmwrite(outfile,myf','delimiter',',')
%dlmwrite(outfile,avg','delimiter',',','-append');
%dlmwrite(outfile,diffX','delimiter',',','-append');
%dlmwrite(outfile,diffY','delimiter',',','-append');
%dlmwrite(outfile,diffXY','delimiter',',','-append');

disp("done")
