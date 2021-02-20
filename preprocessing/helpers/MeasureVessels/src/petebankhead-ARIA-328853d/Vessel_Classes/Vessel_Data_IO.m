classdef Vessel_Data_IO
% VESSEL_DATA_IO Class containing static functions to load and process
% images, and to save VESSEL_DATA objects.
%   
%
% Copyright ? 2011 Peter Bankhead.
% See the file : Copyright.m for further details.

   methods (Static)
       
       %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
       % MATTIA: Save VESSEL OBJECT to a MATLAB (.m) file
       function ARIA_object_file = save_vessel_object_to_file(fname, vessel_data, path_to_output)
           ARIA_object_file = fullfile(path_to_output, strcat(fname,"_ARIA.mat"));
           save(ARIA_object_file, 'vessel_data');
       end
      
       %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
       % MATTIA: Save VESSEL STATS and MEASUREMTNS to a TEXT file
       function [stats_file, measurements_file, QCmeasure1, QCmeasure2] = save_vessel_data_to_text(fname, vessel_data, AV_option, AV_thr, path_to_output)
           
            % names of output files
            stats_file = fullfile(path_to_output, strcat(fname,"_",AV_option,"_stats.tsv"));
            measurements_file = fullfile(path_to_output, strcat(fname,"_",AV_option,"_measurements.tsv"));
            
            %SOFIA : Have all the taus value for the last image analized
            %taus_file = fullfile(path_to_output, strcat("all_taus_same_image.tsv"));
            
            % data structure to contain stats
            %stats_names="median_diameter\tD9_diameter\tmedian_tortuosity\tshort_tortuosity\tD9_tortuosity\tD95_tortuosity\ttau1\ttau2\ttau3\ttau4\ttau5\ttau6\ttau7\n";
            stats_names="median_diameter\tD9_diameter\tmedian_tortuosity\tshort_tortuosity\tD9_tortuosity\tD95_tortuosity\n";

            size_stats_names = size(strsplit(stats_names,"\\t"));
            num_stat_features = size_stats_names(2);
            stats_array = zeros(1,num_stat_features);
            num_vessels = numel(vessel_data.vessel_list());
            lengths = zeros(num_vessels,1);
            median_diameters = zeros(num_vessels,1);
            tortuosities = zeros(num_vessels,1);
            short_tortuosities = zeros(num_vessels,1);
            %tau1s = zeros(num_vessels,1);
            %tau2s = zeros(num_vessels,1);
            %tau3s = zeros(num_vessels,1);
            %tau4s = zeros(num_vessels,1);
            %tau5s = zeros(num_vessels,1);
            %tau6s = zeros(num_vessels,1);
            %tau7s = zeros(num_vessels,1);
            %tau0s = zeros(num_vessels,1);
            
            % for each vessel
            for segmement_index = 1:num_vessels
                segment = vessel_data.vessel_list(segmement_index);
                all_segment_diameters = segment.diameters();
                valid = segment.keep_inds();
                diameters = all_segment_diameters(valid);
                lengths(segmement_index,1) = segment.length_cumulative;

                % only process vessels with a artery/vein classification score > user-defined threshold
                av_score = segment.AV_score();
                
                % uncomment to perform random AV calling (as a test)
                %%%heads=(rand(1,1)>0.5);
                %%%if heads
                %%%    av_score = -av_score;
                %%%end

                if strcmp(AV_option,"artery") && av_score < str2double(AV_thr) % skip all arteries with score
                    continue;  
                elseif strcmp(AV_option,"vein") && av_score > -str2double(AV_thr) % skip all arteries with score
                    continue;  
                end

                % save diameters measurements to file
                dlmwrite(measurements_file,diameters','delimiter','\t','-append');
                
                % store value to calculate stats
                median_diameters(segmement_index,1) = median(diameters);
                DistanceFactor = segment.length_cumulative / segment.length_straight_line;
                tortuosities(segmement_index,1) = DistanceFactor;
                if(segment.length_cumulative >=10 && segment.length_cumulative<=100)
                	short_tortuosities(segmement_index,1) = DistanceFactor;
                end
                
                %[tau1, ~, ~] = compute_tortuosity(segment.centre, 1, false, false);
                %tau1s(segmement_index,1) = tau1;
                %[tau2, ~, ~] = compute_tortuosity(segment.centre, 2, false, false);
                %tau2s(segmement_index,1) = tau2;
                %[tau3, ~, ~] = compute_tortuosity(segment.centre, 3, false, false);
                %tau3s(segmement_index,1) = tau3;
                %[tau4, ~, ~] = compute_tortuosity(segment.centre, 4, false, false);
                %tau4s(segmement_index,1) = tau4;
                %[tau5, ~, ~] = compute_tortuosity(segment.centre, 5, false, false);
                %tau5s(segmement_index,1) = tau5;
                %[tau6, ~, ~] = compute_tortuosity(segment.centre, 6, false, false);
                %tau6s(segmement_index,1) = tau6;
                %[tau7, ~, ~] = compute_tortuosity(segment.centre, 7, false, false);
                %tau7s(segmement_index,1) = tau7;
                %tau0 = 0; Sofia tau0 is not used
                %[tau0, ~, ~] = compute_tortuosity(segment.centre, 0, false, false);
                %tau0s(segmement_index,1) = tau0;
            end

            % set return value that will be used for quality filtering
            QCmeasure1 = sum(lengths); % tot length of vasculature system
            QCmeasure2 = num_vessels; % number of vessels

            % remove hard zeros (they correspond to vessels that have been
            % filtered out as part of the artery/vein processing)
            median_diameters = nonzeros(median_diameters);
            tortuosities = nonzeros(tortuosities);
            short_tortuosities = nonzeros(short_tortuosities);

            %tau1s = nonzeros(tau1s);
            %tau2s = nonzeros(tau2s); 
            %tau3s = nonzeros(tau3s);
            %tau4s = nonzeros(tau4s);
            %tau5s = nonzeros(tau5s);
            %tau6s = nonzeros(tau6s);
            %tau7s = nonzeros(tau7s);
            
            % calculate stats: median_diameter
            stats_array(1) = median(median_diameters);
            % calculate stats: 9th decile of diameter
            sorted_diameters = sort(median_diameters);
            D9_dia_index = floor(0.90*numel(sorted_diameters));
            D9_diameter = sorted_diameters(D9_dia_index);
            stats_array(2) = D9_diameter;
            % calculate stats: median tortuosity
            stats_array(3) = median(tortuosities);
            % calculate stats: median tortuosity (only considering short vessels)
            stats_array(4) = median(nonzeros(short_tortuosities));
            % calculate stats: 9th decile of tortuosity
            sorted_tortuosities = sort(tortuosities);
            D9_tort_index = floor(0.90*numel(sorted_tortuosities));
            D9_tortuosity = sorted_tortuosities(D9_tort_index);
            stats_array(5) = D9_tortuosity;
            % calculate stats: 95 percentile of tortuosity
            D95_tort_index = floor(0.95*numel(sorted_tortuosities));
            D95_tortuosity = sorted_tortuosities(D95_tort_index);
            stats_array(6) = D95_tortuosity;
            
            % calculate stats: alternative tortuosity measures
            %stats_array(7) = median(tau1s); %SOFIA tau1 is the last value, the array is tau1s
            %stats_array(8) = median(tau2s);
            %stats_array(9) = median(tau3s);
            %stats_array(10) = median(tau4s);
            %stats_array(11) = median(tau5s);
            %stats_array(12) = median(tau6s);
            %stats_array(13) = median(tau7s);
            %stats_array(14) = median(tau0s);
            
            % save stats to tile
            fid = fopen(stats_file,'wt');
            fprintf(fid, stats_names);
            fclose(fid);
            dlmwrite(stats_file,stats_array,'delimiter','\t','precision', 14,'-append');
            
            %SOFIA: Have all the taus value for the last image analized
            %alltaus = [tau1s tau2s tau3s tau4s tau5s tau6s tau7s];
            %dlmwrite(taus_file,alltaus);

       end
       
       %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
       % MATTIA: apply quality filter
       % remove generated files for images with "quality_data" (i.e. tot 
       % length of vasculature system) < then "threshold"
       function filter_quality(stats_file, measurements_file, minQCthr1, maxQCthr1, minQCthr2, maxQCthr2, QCmeasure1, QCmeasure2)
           passes_QC = true;
           if (QCmeasure1 < str2double(minQCthr1))
                disp(strcat("  SKIPPING IMAGE: tot amount of vasculature < min threshold: ", num2str(QCmeasure1)));
                passes_QC = false;
           elseif (QCmeasure1 > str2double(maxQCthr1))
                disp(strcat("  SKIPPING IMAGE: tot amount of vasculature > max threshold ", num2str(QCmeasure1)));
                passes_QC = false;
           elseif (QCmeasure2 < str2double(minQCthr2))
                disp(strcat("  SKIPPING IMAGE: num vessels < min threshold ", num2str(QCmeasure2)));
                passes_QC = false;
           elseif (QCmeasure2 > str2double(maxQCthr2))
                disp(strcat("  SKIPPING IMAGE: num vessels > max threshold ", num2str(QCmeasure2)));
                passes_QC = false;
           end
           
           if passes_QC == false
                delete(stats_file);
                delete(measurements_file);
                %%%delete(ARIA_object_file);
           end
           %uncomment to output quality stats about those images that passed QC
           %fileID = fopen('Q.txt','a');
           %fprintf(fileID,stats_file);
           %fprintf(fileID,"\t");
           %fprintf(fileID,num2str(QCmeasure1));
           %fprintf(fileID,"\t");
           %fprintf(fileID,num2str(QCmeasure2));
           %fprintf(fileID,"\n");
       end
       
       
       % Loads VESSEL_DATA from .MAT file
       % Alternatively, loads image from file, applies the PROCESSOR to it 
       % and adds the appropriate VESSEL_SETTINGS.
       % PROCESSOR can either be an actual vessel processor (a STRUCT
       % containing a PROCESSOR_FUNCTION field), or a string giving a
       % processor name to be loaded with VESSEL_DATA_IO.
       % PROCESS_TIME gives the time spent processing an image, if
       % relevant.  Otherwise it is NaN.
        function [vessel_data, process_time] = load_from_file(filename, AV_filename, processor, settings, AV_option, AV_thr, minQCthr1, maxQCthr1, minQCthr2, maxQCthr2, path_to_output)

            % Full file name
            [fpath, fname, ext] = fileparts(filename);
            
            % Prepare for an unknown processing time
            process_time = NaN;

            % Try to open and process file
            if strcmpi(ext, '.mat')
                % MAT file - try to load first Vessel_Data object found
                s = load(filename);
                fields = fieldnames(s);
                vessel_data = [];
                for ii = 1:numel(fields)
                    if isa(s.(fields{ii}), 'Vessel_Data')
                        vessel_data = s.(fields{ii});
                        break;
                    end
                end
                if isempty(vessel_data)
                    error('No Vessel_Data object found in chosen file!');
                end
                % We want to use the passed settings *except* for
                % calibration, which should be read from the file
                if nargin >= 3
                    settings.calibration_value = vessel_data.settings.calibration_value;
                    settings.calibration_unit = vessel_data.settings.calibration_unit;
                    vessel_data.settings = settings;
                end
            else
                % Image file
                try
                    % Create VESSEL_DATA object
                    % Add settings if available, otherwise use default
                    if nargin >= 3
                        vessel_data = Vessel_Data(settings);
                    else
                        vessel_data = Vessel_Data;
                    end
                    
                    % Store file name
                    vessel_data.file_path = fpath;
                    vessel_data.file_name = fname;
                    
                    % Read image
                    vessel_data.im_orig = imread(filename);
                    % Read Artery/Vein map image
                    vessel_data.artery_vein_map = imread(AV_filename);
                    
                    % Choose image for processing - second (green) plane of
                    % a colour image, otherwise a floating point version of
                    % the original
                    if size(vessel_data.im_orig, 3) == 3
                        vessel_data.im = single(vessel_data.im_orig(:,:,2));
                    else
                        vessel_data.im = single(vessel_data.im_orig);
                    end

                    % Run the processor - if there isn't a function
                    % defined, use the general one
                    if ischar(processor)
                        [args, fun] = load_vessel_processor(processor);
                    elseif isstruct(processor)
                        args = processor;
                        fun = processor.processor_function;
                    else
                        error('PROCESSOR must be a file name for a vessel processor, or a valid STRUCT');
                    end
                    if isempty(fun) || ~exist(fun, 'file')
                        fun = 'aria_algorithm_general';
                    end
                    prompt = vessel_data.settings.prompt && ischar(processor);
                    tic;
                    [vessel_data, args, cancelled] = feval(fun, vessel_data, args, prompt);
                    process_time = toc;
                    
                    % Call Vessels: read Artery/Vein map
                    vessel_data.call_vessels()
                    
                    % Test whether empty or cancelled (by user)
                    if isempty(vessel_data) || cancelled
                        vessel_data = [];
                        return;
                    end
                    
                    % Store the arguments if user was prompted
                    if prompt
                        save_vessel_processor(processor, args, fun);
                    end

                    % Test whether vessels found
                    if isempty(vessel_data.vessel_list)
                        warning('Vessel_Data_IO:No_Vessels', ['No vessels found in ', fname]);
                         throw(MException('Vessel_Data_IO:Open', 'No vessels found in the chosen file.'));
                    else
                        % mattia: save data (measurements and stats) and store object to .m file 
                        [stats_file, measurements_file, QCmeasure1, QCmeasure2] = Vessel_Data_IO.save_vessel_data_to_text(fname, vessel_data, AV_option, AV_thr, path_to_output); % mattia
                        
                        % optionally save .mat file.
                        %%%if you enable this, uncomment line "delete(ARIA_object_file)" in Vessel_Data_IO.filter_quality
                        %%%ARIA_object_file = Vessel_Data_IO.save_vessel_object_to_file(fname, vessel_data, path_to_output); % mattia
                        
                        % mattia: apply quality filter: files correspoding to low quality images will be deleted
                        Vessel_Data_IO.filter_quality(stats_file, measurements_file, minQCthr1, maxQCthr1, minQCthr2, maxQCthr2, QCmeasure1, QCmeasure2)
                    end

                    
                catch ME
                    rethrow(ME);
                end
            end

        end
       
   end

end
