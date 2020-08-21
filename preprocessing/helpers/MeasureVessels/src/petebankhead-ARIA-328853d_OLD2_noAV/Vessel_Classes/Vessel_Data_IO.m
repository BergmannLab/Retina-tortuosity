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
       function [stats_file, measurements_file, QCmeasure1, QCmeasure2] = save_vessel_data_to_text(fname, vessel_data, path_to_output)
           
            % names of output files
            stats_file = fullfile(path_to_output, strcat(fname,"_stats.tsv"));
            measurements_file = fullfile(path_to_output, strcat(fname,"_measurements.tsv"));
            
            % data structure to contain stats
            stats_names="median_diameter \t D9_diameter \t median_tortuosity \t short_tortuosity \t D9_tortuosity \t D95_tortuosity\n";
            stats_names = strrep(stats_names,' ','');
            stats_array = zeros(1,6);
            num_vessels = numel(vessel_data.vessel_list());
            lengths = zeros(num_vessels,1);
            max_diameters = zeros(num_vessels,1);
            min_diameters = zeros(num_vessels,1);
            median_diameters = zeros(num_vessels,1);
            tortuosities = zeros(num_vessels,1);
            short_tortuosities = zeros(num_vessels,1);

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
                DistanceFactor = segment.length_cumulative / segment.length_straight_line;
                tortuosities(segmement_index,1) = DistanceFactor;
                if(segment.length_cumulative >=10 && segment.length_cumulative<=100)
                    short_tortuosities(segmement_index,1) = DistanceFactor;
                end
            end

            % return value that will be used for quality filtering
            QCmeasure1 = sum(lengths); % tot length of vasculature system
            QCmeasure2 = num_vessels; % number of vessels

            % calculate stats: median_diameter
            stats_array(1) = median(median_diameters);
            % calculate stats: 9th decile of diameter
            sorted_diameters = sort(median_diameters);
            D9_dia_index = floor(0.90*num_vessels);
            D9_diameter = sorted_diameters(D9_dia_index);
            stats_array(2) = D9_diameter;
            % calculate stats: median tortuosity
            stats_array(3) = median(tortuosities);
            % calculate stats: median tortuosity (only considering short vessels)
            stats_array(4) = median(nonzeros(short_tortuosities));
            % calculate stats: 9th decile of tortuosity
            sorted_tortuosities = sort(tortuosities);
            D9_tort_index = floor(0.90*num_vessels);
            D9_tortuosity = sorted_tortuosities(D9_tort_index);
            stats_array(5) = D9_tortuosity;
            % calculate stats: 95 percentile of tortuosity
            D95_tort_index = floor(0.95*num_vessels);
            D95_tortuosity = sorted_tortuosities(D95_tort_index);
            stats_array(6) = D95_tortuosity;
            
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
       function filter_quality(stats_file, measurements_file, ARIA_object_file, minQCthr1, maxQCthr1, minQCthr2, maxQCthr2, QCmeasure1, QCmeasure2, path_to_output)
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
                delete(ARIA_object_file);
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
        function [vessel_data, process_time] = load_from_file(filename, processor, settings, minQCthr1, maxQCthr1, minQCthr2, maxQCthr2, path_to_output)

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
                        [stats_file, measurements_file, QCmeasure1, QCmeasure2] = Vessel_Data_IO.save_vessel_data_to_text(fname, vessel_data, path_to_output); % mattia
                        ARIA_object_file = Vessel_Data_IO.save_vessel_object_to_file(fname, vessel_data, path_to_output); % mattia
                        % mattia: apply quality filter to appropriate
                        % files, if needed
                        Vessel_Data_IO.filter_quality(stats_file, measurements_file, ARIA_object_file, minQCthr1, maxQCthr1, minQCthr2, maxQCthr2, QCmeasure1, QCmeasure2, path_to_output)
                    end

                    
                catch ME
                    rethrow(ME);
                end
            end

        end
       
   end

end