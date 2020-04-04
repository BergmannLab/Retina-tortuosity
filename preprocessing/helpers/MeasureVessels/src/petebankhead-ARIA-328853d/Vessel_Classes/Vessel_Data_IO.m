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
       function [stats_file, measurements_file, quality_measure] = save_vessel_data_to_text(fname, vessel_data, path_to_output)
           
            % names of output files
            stats_file = fullfile(path_to_output, strcat(fname,"_stats.tsv"));
            measurements_file = fullfile(path_to_output, strcat(fname,"_measurements.tsv"));
            
            % data structure to contain stats
            stats_names="length__TOT \t max_diameter \t min_diameter \t median_diameter \t median_tortuosity \t std_tortuosity \n";
            stats_names = strrep(stats_names,' ','');
            stats_array = zeros(1,6);
            num_vessels = numel(vessel_data.vessel_list());
            lengths = zeros(num_vessels,1);
            max_diameters = zeros(num_vessels,1);
            min_diameters = zeros(num_vessels,1);
            median_diameters = zeros(num_vessels,1);
            tortuosities = zeros(num_vessels,1);

            % for each vessel
            for segmement_index = 1:num_vessels
                segment = vessel_data.vessel_list(segmement_index);
                all_segment_diameters = segment.diameters();
                valid = segment.keep_inds();
                diameters = all_segment_diameters(valid);
                
                % save diameters measurements to file
                dlmwrite(measurements_file,diameters','delimiter','\t','-append');
                
                % store value to calculate stats
                lengths(segmement_index,1) = segment.length_cumulative;
                max_diameters(segmement_index,1) = max(diameters);
                min_diameters(segmement_index,1) = min(diameters);
                median_diameters(segmement_index,1) = median(diameters);
                tortuosities(segmement_index,1) = segment.length_cumulative / segment.length_straight_line;
            end

            % return value that will be used for quality filtering
            quality_measure = sum(lengths); % tot length of vasculature system
            
            % calculate stats
            stats_array(1) = quality_measure;
            stats_array(2) = max(max_diameters);
            stats_array(3) = min(min_diameters);
            stats_array(4) = median(median_diameters);
            stats_array(5) = median(tortuosities);
            stats_array(6) = std(tortuosities);
            
            % save stats to tile
            fid = fopen(stats_file,'wt');
            fprintf(fid, stats_names);
            fclose(fid);
            dlmwrite(stats_file,stats_array,'delimiter','\t','precision', 14,'-append');
       end
       
       %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
       % MATTIA: apply quality filter
       % remove generated files for images with "quality_data" (i.e. tot 
       % length of vasculature system) < then "threshold"
       function filter_quality(stats_file, measurements_file, ARIA_object_file, quality_thr, quality_measure, path_to_output)
           if (quality_measure < str2double(quality_thr))
                disp(strcat("  SKIPPING IMAGE: tot amount of vasculature (", num2str(quality_measure), ") < quality threshold "))
                delete(stats_file);
                delete(measurements_file);
                delete(ARIA_object_file);
           end
       end
       
       
       % Loads VESSEL_DATA from .MAT file
       % Alternatively, loads image from file, applies the PROCESSOR to it 
       % and adds the appropriate VESSEL_SETTINGS.
       % PROCESSOR can either be an actual vessel processor (a STRUCT
       % containing a PROCESSOR_FUNCTION field), or a string giving a
       % processor name to be loaded with VESSEL_DATA_IO.
       % PROCESS_TIME gives the time spent processing an image, if
       % relevant.  Otherwise it is NaN.
        function [vessel_data, process_time] = load_from_file(filename, processor, settings, quality_thr, path_to_output)
                        
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
                        [stats_file, measurements_file, quality_measure] = Vessel_Data_IO.save_vessel_data_to_text(fname, vessel_data, path_to_output); % mattia
                        ARIA_object_file = Vessel_Data_IO.save_vessel_object_to_file(fname, vessel_data, path_to_output); % mattia
                        % mattia: apply quality filter to appropriate
                        % files, if needed
                        Vessel_Data_IO.filter_quality(stats_file, measurements_file, ARIA_object_file, quality_thr, quality_measure, path_to_output)
                    end

                    
                catch ME
                    rethrow(ME);
                end
            end

        end
       
   end

end
