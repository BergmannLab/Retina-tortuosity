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
       function [imageStats_file, segmentStats_file, posX_file, posY_file, diameters_file, QCmeasure1, QCmeasure2] = save_vessel_data_to_text(fname, vessel_data, AV_option, AV_thr, path_to_output)
           
            % names of output files
            imageStats_file = fullfile(path_to_output, strcat(fname,"_",AV_option,"_imageStats.tsv"));
           
            segmentStats_file = fullfile(path_to_output, strcat(fname,"_",AV_option,"_segmentStats.tsv"));           
            segmentStats_names = "medianDiameter\tmedianPosX\tmedianPosY\tarcLength\tchordLength\tDF\ttau1\ttau2\ttau3\ttau4\ttau5\ttau6\ttau7\tAVScore\n";
            fid = fopen(segmentStats_file,'wt');
            fprintf(fid, segmentStats_names);
            fclose(fid);

            posX_file = fullfile(path_to_output, strcat(fname,"_",AV_option,"_rawXCoordinates.tsv"));
            posY_file = fullfile(path_to_output, strcat(fname,"_",AV_option,"_rawYCoordinates.tsv"));
            diameters_file = fullfile(path_to_output, strcat(fname,"_",AV_option,"_rawDiameters.tsv"));
            
            %SOFIA : Have all the taus value for the last image analized
            %taus_file = fullfile(path_to_output, strcat("all_taus_same_image.tsv"));
            
            % data structure to contain stats
            stats_names="DF\tDF1st\tDF2nd\tDF3rd\tDF4th\tDF5th\ttau1\ttau2\ttau3\ttau4\ttau5\ttau6\ttau7\tnVessels\n";
            size_stats_names = size(strsplit(stats_names,"\\t"));
            num_stat_features = size_stats_names(2);
            stats_array = zeros(1,num_stat_features);
            num_vessels = numel(vessel_data.vessel_list());
            lengths = zeros(num_vessels,1);
            median_diameters = zeros(num_vessels,1);
            tortuosities = zeros(num_vessels,1);
            short_tortuosities = zeros(num_vessels,1);
            tau1s = zeros(num_vessels,1);
            tau2s = zeros(num_vessels,1);
            tau3s = zeros(num_vessels,1);
            tau4s = zeros(num_vessels,1);
            tau5s = zeros(num_vessels,1);
            tau6s = zeros(num_vessels,1);
            tau7s = zeros(num_vessels,1);
            %tau0s = zeros(num_vessels,1);
            
            median_diameters(median_diameters==0)=-999;
            tortuosities(tortuosities==0)=-999;
            short_tortuosities(short_tortuosities==0)=-999;
            tau1s(tau1s==0)=-999;
            tau2s(tau2s==0)=-999;
            tau3s(tau3s==0)=-999;
            tau4s(tau4s==0)=-999;
            tau5s(tau5s==0)=-999;
            tau6s(tau6s==0)=-999;
            tau7s(tau7s==0)=-999;

            
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

                % save raw segment measurements to file
                dlmwrite(posX_file,segment.centre(:,1)','delimiter','\t','-append');
                dlmwrite(posY_file,segment.centre(:,2)','delimiter','\t','-append');
                dlmwrite(diameters_file,diameters','delimiter','\t','-append');
                
                % store value to calculate stats
                median_diameters(segmement_index,1) = median(diameters);
                DistanceFactor = segment.length_cumulative / segment.length_straight_line;
                tortuosities(segmement_index,1) = DistanceFactor;
                if(segment.length_cumulative >=10 && segment.length_cumulative<=100)
                	short_tortuosities(segmement_index,1) = DistanceFactor;
                end
                
                [tau1, ~, ~] = compute_tortuosity(segment.centre, 1, false, false);
                tau1s(segmement_index,1) = tau1;
                [tau2, ~, ~] = compute_tortuosity(segment.centre, 2, false, false);
                tau2s(segmement_index,1) = tau2;
                [tau3, ~, ~] = compute_tortuosity(segment.centre, 3, false, false);
                tau3s(segmement_index,1) = tau3;
                [tau4, ~, ~] = compute_tortuosity(segment.centre, 4, false, false);
                tau4s(segmement_index,1) = tau4;
                [tau5, ~, ~] = compute_tortuosity(segment.centre, 5, false, false);
                tau5s(segmement_index,1) = tau5;
                [tau6, ~, ~] = compute_tortuosity(segment.centre, 6, false, false);
                tau6s(segmement_index,1) = tau6;
                [tau7, ~, ~] = compute_tortuosity(segment.centre, 7, false, false);
                tau7s(segmement_index,1) = tau7;
                %tau0 = 0; Sofia tau0 is not used
                %[tau0, ~, ~] = compute_tortuosity(segment.centre, 0, false, false);
                %tau0s(segmement_index,1) = tau0;

                % saving segment stats
                dlmwrite(segmentStats_file,[median(diameters), median(segment.centre(:,1)), median(segment.centre(:,2)), ...
                    segment.length_cumulative, segment.length_straight_line, DistanceFactor, ...
                    tau1, tau2, tau3, tau4, tau5, tau6, tau7, av_score],'delimiter','\t','-append');
            end

            lenght_quintiles = quantile(lengths,4);
            DF_1st = tortuosities(lengths < lenght_quintiles(1));
            DF_2nd = tortuosities(lengths < lenght_quintiles(2) & lengths >= lenght_quintiles(1));
            DF_3rd = tortuosities(lengths < lenght_quintiles(3) & lengths >= lenght_quintiles(2));
            DF_4th = tortuosities(lengths < lenght_quintiles(4) & lengths >= lenght_quintiles(3));
            DF_5th = tortuosities(lengths >= lenght_quintiles(4));

            % set return value that will be used for quality filtering
            QCmeasure1 = sum(lengths); % tot length of vasculature system
            QCmeasure2 = num_vessels; % number of vessels
            
            % remove hard zeros (they correspond to vessels that have been
            % filtered out as part of the artery/vein processing)
            
            %median_diameters(median_diameters==-999)=[];
            tortuosities(tortuosities==-999)=[];
            %short_tortuosities(short_tortuosities==-999)=[];
            
            tau1s(tau1s==-999)=[];
            tau2s(tau2s==-999)=[];
            tau3s(tau3s==-999)=[];
            tau4s(tau4s==-999)=[];
            tau5s(tau5s==-999)=[];
            tau6s(tau6s==-999)=[];
            tau7s(tau7s==-999)=[];

            DF_1st(DF_1st==-999)=[];
            DF_2nd(DF_2nd==-999)=[];
            DF_3rd(DF_3rd==-999)=[];
            DF_4th(DF_4th==-999)=[];
            DF_5th(DF_5th==-999)=[];

            % DF, DF quintiles, all the taus, and #vessels
            % Controls are stats_array(#):
            % (6 ) Vanilla DF
            % (7/8)) if everything works as planned, there should be about equal number of elements in all quantile ranges, so these number should be ~=1 
            stats_array(1) = median(tortuosities);
            stats_array(2) = median(DF_1st);
            stats_array(3) = median(DF_2nd);
            stats_array(4) = median(DF_3rd);
            stats_array(5) = median(DF_4th);
            stats_array(6) = median(DF_5th);
            stats_array(7) = median(tau1s);
            stats_array(8) = median(tau2s);
            stats_array(9) = median(tau3s);
            stats_array(10) = median(tau4s);
            stats_array(11) = median(tau5s);
            stats_array(12) = median(tau6s);
            stats_array(13) = median(tau7s);
            stats_array(14) = num_vessels;


            % save stats to tile
            fid = fopen(imageStats_file,'wt');
            fprintf(fid, stats_names);
            fclose(fid);
            dlmwrite(imageStats_file,stats_array,'delimiter','\t','precision', 14,'-append');
            
            %SOFIA: Have all the taus value for the last image analized
            %alltaus = [tau1s tau2s tau3s tau4s tau5s tau6s tau7s];
            %dlmwrite(taus_file,alltaus);

       end
       
       %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
       % MATTIA: apply quality filter
       % remove generated files for images with "quality_data" (i.e. tot 
       % length of vasculature system) < then "threshold"
       function filter_quality(imageStats_file, segmentStats_file, posX_file, posY_file, diameters_file, minQCthr1, maxQCthr1, minQCthr2, maxQCthr2, QCmeasure1, QCmeasure2)
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
                delete(imageStats_file);
                delete(segmentStats_file);
                delete(posX_file);
                delete(posY_file);
                delete(diameters_file);
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
                        [imageStats_file, segmentStats_file, posX_file, posY_file, diameters_file, QCmeasure1, QCmeasure2] = Vessel_Data_IO.save_vessel_data_to_text(fname, vessel_data, AV_option, AV_thr, path_to_output); % mattia
                        
                        % optionally save .mat file.
                        %%%if you enable this, uncomment line "delete(ARIA_object_file)" in Vessel_Data_IO.filter_quality
                        %%%ARIA_object_file = Vessel_Data_IO.save_vessel_object_to_file(fname, vessel_data, path_to_output); % mattia
                        
                        % mattia: apply quality filter: files correspoding to low quality images will be deleted
                        Vessel_Data_IO.filter_quality(imageStats_file, segmentStats_file, posX_file, posY_file, diameters_file, minQCthr1, maxQCthr1, minQCthr2, maxQCthr2, QCmeasure1, QCmeasure2)
                    end

                    
                catch ME
                    rethrow(ME);
                end
            end

        end
       
   end

end
