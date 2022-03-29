% SOFIA -> ARIA_run_tests 0 REVIEW ../../input/fundus/REVIEW/ ../../input/AV_maps/ all 0.79 ./ 1 5 ../../output
% ARIA_run_tests 0 REVIEW ../../fundus_UKBB/REVIEW/ ../../AV_maps/ [artery|vein|all] 0.79 ./ 1 3 11000 20000 100 250 ../../output
% ARIA_run_tests 0 REVIEW /data/soin/retina/OphtalmoLaus/fundus/REVIEW/ /data/soin/retina/OphtalmoLaus/AV_maps/ all 0.0 /home/ch_mattiatomasoni/retina/preprocessing/helpers/MeasureVessels/src/petebankhead-ARIA-328853d/ARIA_tests/ 1 10 11000 20000 100 250 /data/soin/_scratch/retina/preprocessing/output/MeasureVessels_all/
function ARIA_run_tests(f_name, test_name, path_to_raw, path_to_AV_classified, AV_option, AV_thr, script_dir, chunk_start, chunk_size, path_to_output)
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


%% STORE DATE OF TEST FILE
test_date = ' ';

%% INPUT CHECKING

% Check whether or not we have a file to write, or if the output is to the
% command window
fid = 0;

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


%% REVIEW DATABASE TEST

if any(strcmp({'review', 'all'}, test_name))
    % Run the REVIEW tests for each image database
    if fid ~= 1
        %disp('Running REVIEW vessel measurement test...'); % mattia
        disp('Running vessel measurements...');
    end

    % Run the processing for all image sets
    sets = {'DRIVE'}; %sets = {'CLRIS'};
    
    for ii = numel(sets):-1:1
		processor = zeros(0); % mattia: setting preprocessor to null (the function will take care of initializing it)
        chunk_start = str2double(chunk_start); % mattia: converting input params to correct type
		chunk_size = str2double(chunk_size); % mattia: converting params
		REVIEW(ii) = REVIEW_evaluate_diameter_measurements(sets{ii}, processor, chunk_start, chunk_size, AV_option, AV_thr, path_to_raw, path_to_AV_classified, path_to_output);
    end
end

end
