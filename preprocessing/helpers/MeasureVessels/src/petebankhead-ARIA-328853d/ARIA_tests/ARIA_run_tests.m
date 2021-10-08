% How to run on brynhild
% for i in $(seq 1 2414 173808); do (nohup nice matlab -nodisplay -nosplash -nodesktop -r "ARIA_run_tests 0 REVIEW /HDD/data/UKBB/fundus/raw /HDD/data/UKBB/fundus/lwnet/  all 0.79 ./ ${i} 2414 -1 999999 -1 999999 ~/2021_10_06_rawMeasurements_withoutQC" > batch${i}.txt &); done

% Let's take that apart:
% Each iteration of the for loop calls this (nohup (doesn't kill when logged out) and nice (low priority so that others can compute as well) modes are used):
% nohup nice matlab -nodisplay -nosplash -nodesktop -r "ARIA_run_tests 0 REVIEW /HDD/data/UKBB/fundus/raw /HDD/data/UKBB/fundus/lwnet/  all 0.79 ./ ${i} 2414 -1 999999 -1 999999 ~/2021_10_06_rawMeasurements_withoutQC

% Brynhild has 72 cores, and there are 173814 raw fundus images
% To have all CPUs busy and 1 process per CPU, that makes 2414 images per process

% 72 * 2414 = 173808 -> we process the last 6 images via:
% nohup nice matlab -nodisplay -nosplash -nodesktop -r "ARIA_run_tests 0 REVIEW /HDD/data/UKBB/fundus/raw /HDD/data/UKBB/fundus/lwnet/  all 0.79 ./ 173809 173814 -1 999999 -1 999999 ~/2021_10_06_rawMeasurements_withoutQC

% And that's all, we now did all the raw measurements without any QC! Check if everything got computed well via the following command:
% In the output folder, type:
% ls | cut -f1 -d_ | uniq -c | grep -v "9 " | grep -v "18 " | grep -v "27 " | grep -v "36 " | grep -v "45 " | grep -v "54 " | grep -v "63 " | grep -v "72 "

% This checks that for all measured images there is a multiple of 9 files, up to 72 files
% If some are not multiples of 9, it means something went wrong during the measurement process.

% Also check if all images were scored, via
% ls | awk -F "_all_" '{print $1}' | wc -l

% This should equal the number of raw images. If that's the case, we are really done!

% ARIA_run_tests 0 REVIEW /home/mbeyele5/ARIA_test /data/FAC/FBM/DBC/sbergman/retina/UKBiob/fundus/AV_maps all 0.79 ./ 1 1 -1 999999 -1 999999 /home/mbeyele5
function ARIA_run_tests(f_name, test_name, path_to_raw, path_to_AV_classified, AV_option, AV_thr, script_dir, chunk_start, chunk_size, minQCthr1, maxQCthr1, minQCthr2, maxQCthr2, path_to_output)
% Run all the tests using ARIA to create the results reported in the paper
% 'Fast retinal vessel detection and measurement using wavelets and edge
% location refinement'.
% 
% Input:
%   F_NAME - (optional) a string giving a file name to which the output
%   should be written.  The file will be tab-delimited, so will look best
%   in a spreadsheet.  If F_NAME is omitted, the output is written to the
%   MATLAB command window.
%   TEST_NAME - (optional) a string giving the name of the test to run
%   ('SEGMENT' for the segmentation test, 'DRIVE' for the DRIVE processing
%   time test or 'REVIEW' for the REVIEW measurement test), or 'ALL' if all
%   available tests should be applied (Default = 'ALL').
%
% 
% Copyright � 2011 Peter Bankhead.
% See the file : Copyright.m for further details.

% process inputs: 

function path = fix_trailing_slash(path)
    last_letter = path(end);
    if not(strcmp(last_letter,"/"))
        path = char(path + "/");
    end
end
path_to_raw = fix_trailing_slash(path_to_raw);
path_to_AV_classified = fix_trailing_slash(path_to_AV_classified);
script_dir = fix_trailing_slash(script_dir);
path_to_output = fix_trailing_slash(path_to_output);

%EO: export script_dir
setenv('SCRIPT_DIR', script_dir)

%mattia adding path to raw images cannot be done here when code is compiled
%addpath(genpath(path_to_raw));

%mattia: not needed, passing var directly to function
%dir_database=path_to_raw;
%matfile = fullfile(script_dir, 'database_directory_REVIEW.mat');
%save(matfile,'dir_database')

%% STORE DATE OF TEST FILE
test_date = ' ';

%% INPUT CHECKING

% Check whether or not we have a file to write, or if the output is to the
% command window
fid = 0;
% mattia: do not use file, it can create a race condition between SLURM jobs
%{
if nargin < 1 || ~ischar(f_name)
    fid = 1;
    do_file = false;
else
    fid = fopen(f_name, 'w');
    do_file = true;
end

do_file;
f_name;
%}

% Determine which tests to apply
if nargin < 2 || ~ischar(test_name)
    test_name = 'all';
else
    test_name = lower(test_name);
    if ~any(strcmp({'all', 'review', 'drive', 'segment'}, test_name))
        error('Invalid TEST_NAME given!');
    end
end

% Make sure we have the ARIA files somewhere on the search path, at least
% for this MATLAB session - or give a warning if the functions can't be
% found
if exist('ARIA_setup', 'file')
    ARIA_setup(true);
else
    error(['Cannot find the function ARIA_SETUP.M.  ', ...
           'To fix this, you should find the file with this name in the ARIA base folder, and run it once.  ', ...
           'Alternatively, manually add the ARIA base folder to the MATLAB search path (File -> Set Path...).']);
end


%% ENSURE FILE PATHS

% Make sure we have paths to the required directories containing the image
% databases
if ~strcmp(test_name, 'review')
    dir_drive = get_vessel_database_directory('DRIVE');
    if isempty(dir_drive)
        disp('DRIVE database path not set - aborting tests');
        return
    end
end
if any(strcmp({'review', 'all'}, test_name))
    % mattia
    %dir_review = get_vessel_database_directory('REVIEW');
    dir_review = path_to_raw;
    if isempty(dir_review)
        disp('REVIEW database path not set - aborting tests');
        return
    end
end


%% 'WARM UP' MATLAB - JUST IN CASE

% Run the KPIS test first.  This isn't strictly necessary, although it
% should be fast because the images are so small.
% The purpose of this is to call the full analysis algorithm.  Because the
% first call to any code in MATLAB tends to be slower (thanks to file
% systems / memory management / M file parsing etc.), including the
% results from first runs would lead to potentially misleading benchmarking
% results in which the analysis of the first tested image would appear
% slower than the others for reasons quite independent of the image itself.
%
% (In fact, for *really* accurate times more repetitions of the code being
% profiled may be required to properly overcome these issues, but for slower
% functions this may make the tests last much too long.  Still, ensuring
% the analysis algorithm is called at least once in advance is a reasonable
% start.)
%
% See http://www.mathworks.com/matlabcentral/fileexchange/18510 for more
% detailed information about benchmarking pitfalls, or
% http://blogs.mathworks.com/steve/2008/02/29/timing-code-in-matlab/ for
% some of the main points.
%REVIEW_evaluate_diameter_measurements('KPIS');



%% SYSTEM INFORMATION

% mattia: do not use file, it can create a race condition between SLURM jobs
%{
% Output some information about the test system for reference
fprintf(fid, '\n--------------------------------------------------\n\n');
fprintf(fid, '**--TEST SYSTEM--**\n\n');
fprintf(fid, 'Computer:\t%s\n', computer);
fprintf(fid, 'Version:\t%s\n', version);
fprintf(fid, 'Original test written:\t%s', test_date);
fprintf(fid, '\n--------------------------------------------------\n\n');
%}

%mattia: commenting DRIVE test logic: not needed
%{
%% DRIVE SEGMENTATION TEST

if any(strcmp({'segment', 'all'}, test_name))
    % Apply the IUWT segmentation to the test images of the DRIVE database, and
    % determine the average processing time along with accuracy measurements
    % (determined by comparison with manually segmented images).
    if fid ~= 1
        disp('Running DRIVE segmentation test...');
    end
    
    % Run the segmentation test
    segmentation_algorithm = DRIVE_get_segmentation_algorithm;
    [table, processing_time] = DRIVE_measure_segmentation_accuracy(segmentation_algorithm, true);
    
    % Output the accuracy
    fprintf(fid, '**--DRIVE SEGMENTATION TEST--**\n\n');
    if fid == 1
        write_table_to_command_window(table, [0, 1, 3], [0, 1, 4]);
    else
        write_table_to_file(fid, table);
    end
    
    % Output the segmentation timing
    fprintf(fid, '\nProcessing time for IUWT segmentation of DRIVE image:\n');
    fprintf(fid, '\tMean:\t%.3f seconds\n', mean(processing_time));
    fprintf(fid, '\tStd. dev.:\t%.3f seconds\n', std(processing_time));
    fprintf(fid, '\n--------------------------------------------------\n\n');
end


%% DRIVE PROCESSOR TEST

if any(strcmp({'drive', 'all'}, test_name))
    % Apply the analysis algorithm to the test images of the DRIVE database,
    % and determine the average processing time.
    if fid ~= 1
        disp('Running DRIVE full processing test...');
    end
    
    % Apply the full processing test
    processor = ARIA_generate_test_processor('DRIVE');
    processing_time = DRIVE_measure_processing_time(processor);
    
    % Output the timing
    fprintf(fid, '**--DRIVE FULL PROCESSING TEST--**\n\n');
    fprintf(fid, 'Processing time for DRIVE database images:\n');
    fprintf(fid, '\tMean:\t%.3f seconds\n', mean(processing_time));
    fprintf(fid, '\tStd. dev.:\t%.3f seconds\n', std(processing_time));
    fprintf(fid, '\n--------------------------------------------------\n\n');
end

%mattia: commenting DRIVE test logic: not needed
%}


%% REVIEW DATABASE TEST

if any(strcmp({'review', 'all'}, test_name))
    % Run the REVIEW tests for each image database
    if fid ~= 1
        %disp('Running REVIEW vessel measurement test...'); % mattia
        disp('Running vessel measurements...');
    end

    % Run the processing for all image sets
    sets = {'CLRIS'};
    % mattia: we are simulating a REVIEW CLRIS test
    % sets = {'KPIS', 'CLRIS', 'VDIS', 'HRIS_downsample', 'HRIS'};
    
    for ii = numel(sets):-1:1
		processor = zeros(0); % mattia: setting preprocessor to null (the function will take care of initializing it)
        chunk_start = str2double(chunk_start); % mattia: converting input params to correct type
		chunk_size = str2double(chunk_size); % mattia: converting params
		REVIEW(ii) = REVIEW_evaluate_diameter_measurements(sets{ii}, processor, chunk_start, chunk_size, AV_option, AV_thr, minQCthr1, maxQCthr1, minQCthr2, maxQCthr2, path_to_raw, path_to_AV_classified, path_to_output);
    end

    % mattia: do not use file, it can create a race condition between SLURM jobs
    %{
    % Generate a table containing the results, and display it
    table = REVIEW_create_results_table(REVIEW);
    fprintf(fid, '**--REVIEW MEASUREMENT TEST--**\n\n');
    if fid == 1
        write_table_to_command_window(table, [0, 2, size(table,1)], [0, 1:3:size(table,2)]);
    else
        write_table_to_file(fid, table);
    end
    
    % Output the processing times
    fprintf(fid, '\n\nProcessing time for REVIEW database images:\n');
    for ii = 1:numel(REVIEW)
        fprintf(fid, '\t%s\t%f seconds\n', REVIEW(ii).image_set, REVIEW(ii).mean_processing_time);
    end
    fprintf(fid, '\n--------------------------------------------------\n\n');
    %}
end

% mattia: do not use file, it can create a race condition between SLURM jobs
%{
%% CLEANUP

% If not outputing everything to the command window, send a notification
% that we are finished
if fid ~= 1
    disp('Finished!');
end

% Close any open file
if do_file
    fclose(fid);
end
%}
end
