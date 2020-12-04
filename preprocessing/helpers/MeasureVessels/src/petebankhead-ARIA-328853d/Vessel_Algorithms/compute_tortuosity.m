function [tau, r, centers] = compute_tortuosity(points, method, plot_curve, smooth_curve)
    
    %disp('Computing tortuosity ...');
    
    % Input:
    %
    %   'points' is a [n x 2] array. The first column represents the x, and
    %   the second colum the y coordinate of an ordered set of n points.
    %   if less than 3 points are given, a test set of point along a sinus
    %   curve is used instead.
    %
    %   'method' is an integer defining the method type:
    %   (0) or no argument given: t = "tortuosity density" (as in
    %   https://sci-hub.tw/https://ieeexplore.ieee.org/document/1279902)
    %   (1) tau = (total arc-length over total chord-length) - 1
    %   (2) tau = the integral over the curvature along the entire curve
    %   (3) tau = the integral over the curvature squared along the entire curve
    %   (4)
    %   (5)
    %   (6)
    %   (7)
    %
    %   'plot_curve' is a Boolean: If true or absent the curve is plotted with the tangent
    %   circles and a color scheme denoting the tortuosity
    %
    % Outputs:
    %
    %   'tau' is a float containing the tortuosity computed for the curve defined by the input points with the specified methods
    %   'r' is a [(n-2) x 1] array for the curvature radius for all points except the first and the last
    %   'centers' is a [(n-2) x 2] array for the centers of the tangent circles for all points except the first and the last
    %
    % Author: Sven Bergmann.
    % Version: v1.4 (11 September 2020)
    
    if(nargin < 1)
        N = 201;
        t = linspace(0, 4*pi, N);
        points = [t; 1.0*sin(t)] + 0.001*rand(2,N);
        
        % rotation
        alpha = pi/4;
        R = [cos(alpha) sin(alpha); -sin(alpha) cos(alpha)];
        points = R * points;
    end
    
    if(nargin < 2)
        method = 0;
    end
    
    if(nargin < 3)
        plot_curve = true;
    end
    
    if(nargin < 4)
        smooth_curve = false;
    end
    
    if(smooth_curve)
        points(2,:) = smooth(points(1,:),points(2,:),0.3,'rloess');
    end
    
    points1 = points(:,1:end-2); % QUESTIONS: WHY ARE THESE EMPTY?
    points2 = points(:,2:end-1);
    points3 = points(:,3:end);
    
    Deltas = points(:,1:end-1) - points(:,2:end);
    
    mean_Deltas = (Deltas(:,1:end-1) + Deltas(:,2:end))/2; % mean difference of neighboring points
    Deltas2 = Deltas(:,1:end-1) - Deltas(:,2:end); % difference of differences
    
    curvature_sign = sign(mean_Deltas(1,:) .* Deltas2(2,:) - mean_Deltas(2,:) .* Deltas2(1,:));
    
    ABC = [points1(:)'; points2(:)'; points3(:)'];
    
    [r,centers] = find_circle_through_3_points(ABC);
    r = r .* curvature_sign;
    
    hysteresis_threshold = 2.0 * std(abs(1 ./ r));
    
    if(plot_curve)
        figure(1)
        
        subplot(2,1,1) % curve visualisation
        
        x_min = min(points(1,:));
        x_max = max(points(1,:));
        
        y_min = min(points(2,:));
        y_max = max(points(2,:));
        
        hold off
        plot(points(1,:), points(2,:), '.-k') % plot curve
        hold on
        
        % indicate absolute curvature using color
        scatter(points(1,2:end-1), points(2,2:end-1), 15, abs(1 ./ r))
        scatter(centers(1,:), centers(2,:), 15, abs(1 ./ r))
        
        % connect points of curve to centers of tangent circles
        plot([points(1,2:end-1);centers(1,:)], [points(2,2:end-1); centers(2,:)], 'k')
        
        margin = 0.1;
        margin_x = (x_max-x_min) * margin;
        margin_y = (y_max-y_min) * margin;
        
        xlim([x_min-margin_x x_max+margin_x])
        ylim([y_min-margin_y y_max+margin_y])
        
        subplot(2,1,2) % curvature analysis
        
        hold off
        plot(t(1,2:end-1), 1 ./ r); % plot signed curvature
        xlim([t(1) t(end)])
    end
    
    switch(method)
        case 0
            tic
            tau_forward = TD3(points,r,hysteresis_threshold);
            subplot(2,1,2) % curvature analysis
            if(plot_curve)
                hold on
                plot(t(1,2:end-1), hysteresis_threshold * curvature_sign,'r') % plot sign of curvature
            end % if(plot_curve)
            
            tau_backward = TD3(points(:,end:-1:1),r(end:-1:1),hysteresis_threshold);
            subplot(2,1,2) % curvature analysis
            if(plot_curve)
                hold on
                plot(t(1,2:end-1), hysteresis_threshold * curvature_sign(end:-1:1),'b') % plot sign of curvature
            end % if(plot_curve)
            
            tau_fb = (tau_forward + tau_backward) / 2
            toc
            
            tic
            [tau,forward_segment_starts, backward_segment_starts, segment_boundaries] =  TD3(points,r,hysteresis_threshold)
            toc
            
            tic
            [tau3, significant_sign_change_starts, significant_sign_change_ends, segment_boundaries3] = TD3(points,r,hysteresis_threshold)
            toc
            
            if(plot_curve)
                hold on
                plot(t(forward_segment_starts), 0,'>r') 
                plot(t(backward_segment_starts), 0,'<b') 
                plot(t(segment_boundaries), 0,'ok') 
                
                plot(t(significant_sign_change_starts),0,'vk')
                plot(t(significant_sign_change_ends),0,'^k')
                plot(t(segment_boundaries3), 0,'xk')    
            end % if(plot_curve)
           
        case 1
            L_arc = sum(sqrt(Deltas(1,:) .^2 + Deltas(2,:) .^2));
            L_chord = norm(points(:,end) - points(:,1));
            
            tau = L_arc / L_chord - 1;
            
        case 2
            tau = sum(sqrt(Deltas(1,:) .^2 + Deltas(2,:) .^2) ./ abs(r));
            
        case 3
            tau = sum(sqrt(Deltas(1,:) .^2 + Deltas(2,:) .^2) ./ (r .* r));
            
        case 4
            L_arc = sum(sqrt(Deltas(1,:) .^2 + Deltas(2,:) .^2));
            tau = sum(sqrt(Deltas(1,:) .^2 + Deltas(2,:) .^2) ./ abs(r)) / L_arc;
            
        case 5
            L_arc = sum(sqrt(Deltas(1,:) .^2 + Deltas(2,:) .^2));
            tau = sum(sqrt(Deltas(1,:) .^2 + Deltas(2,:) .^2) ./ (r .* r)) / L_arc;
            
        case 6
            L_chord = norm(points(:,end) - points(:,1));
            tau = sum(sqrt(Deltas(1,:) .^2 + Deltas(2,:) .^2) ./ abs(r)) / L_chord;
            
        case 7
            L_chord = norm(points(:,end) - points(:,1));
            tau = sum(sqrt(Deltas(1,:) .^2 + Deltas(2,:) .^2) ./ (r .* r)) / L_chord;
            
        otherwise
            tau = NaN;
            
    end % switch(method)
    
    
    function tau = TD(points,r,hysteresis_threshold)
        
        N_segments = 0;
        
        % recompute curbature sign using hysteresis
        curvature_sign = zeros(1,length(r));
        curvature_sign(1) = sign(r(1));
        segment_start = 1;
        L_arcs = [];
        L_chords = [];
        
        for index = 2:length(r)
            if(1/r(index)*curvature_sign(index-1) > -hysteresis_threshold)
                curvature_sign(index) = curvature_sign(index-1);
            else
                curvature_sign(index) = -curvature_sign(index-1);
                N_segments = N_segments + 1;
                
                L_arcs(N_segments) = sum(sqrt(Deltas(1,segment_start:index) .^2 + Deltas(2,segment_start:index) .^2));
                L_chords(N_segments) = norm(points(:,segment_start) - points(:,index));
                
                segment_start = index;
                taus(N_segments) = L_arcs(N_segments) / L_chords(N_segments) - 1;
            end
        end
        
        if(segment_start < length(r)) % process last segment
            L_arcs(end+1) = sum(sqrt(Deltas(1,segment_start:end) .^2 + Deltas(2,segment_start:end) .^2));
            L_chords(end+1) = norm(points(:,segment_start) - points(:,end));
            taus(end+1) = L_arcs(end) / L_chords(end) - 1;
            N_segments = N_segments + 1;
        end
        
        tau = (N_segments-1)/N_segments * sum(taus);
        
    end % function TD
    
    
    function [tau,forward_segment_starts, backward_segment_starts, segment_boundaries] = TD2(points,r,hysteresis_threshold) % improved version
        
        % recompute curbature sign using hysteresis
        forward_curvature_sign = zeros(1,length(r));
        forward_curvature_sign(1) = curvature_sign(1);
        
        backward_curvature_sign = zeros(1,length(r));
        backward_curvature_sign(end) = curvature_sign(end);
        
        segment_start = 1;
        L_arcs = [];
        L_chords = [];
        forward_segment_starts = [];
        backward_segment_starts = [];
        
        % forward scan
        for index = 2:length(r)
            if(1/r(index)*forward_curvature_sign(index-1) > -hysteresis_threshold)
                forward_curvature_sign(index) = forward_curvature_sign(index-1);
            else
                forward_curvature_sign(index) = -forward_curvature_sign(index-1);
                forward_segment_starts(end+1) = index;
            end
        end
        
        % backward scan
        for index = (length(r)-1):-1:1
            if(1/r(index)*backward_curvature_sign(index+1) > -hysteresis_threshold)
                backward_curvature_sign(index) = backward_curvature_sign(index+1);
            else
                backward_curvature_sign(index) = -backward_curvature_sign(index+1);
                backward_segment_starts(end+1) = index+1;
            end
        end
        
        % remove inconsistant starts:
        if(forward_curvature_sign(forward_segment_starts(1)) ~= backward_curvature_sign(backward_segment_starts(end)))
            disp(sprintf('Removing from forward scan: %d',forward_segment_starts(1)))
            forward_segment_starts = forward_segment_starts(2:end);
        end
        
        if(backward_curvature_sign(backward_segment_starts(1) ~= forward_curvature_sign(forward_segment_starts(end))))
            disp(sprintf('Removing from backward scan: %d',backward_segment_starts(1)))
            backward_segment_starts = backward_segment_starts(2:end);
        end
        
        
        % take midpoints as segment boundaries:
        if(length(forward_segment_starts) == length(backward_segment_starts))
            segment_boundaries = round( (forward_segment_starts + backward_segment_starts(end:-1:1)) / 2);
        else
            disp('forward segmentation is inconsistant with backward segmentation')
            tau = NaN;
            segment_boundaries = 1;
            return
        end
        
        segment_start = 1;
        for N_segments = 1:length(segment_boundaries)
            index = segment_boundaries(N_segments);
            L_arcs(N_segments) = sum(sqrt(Deltas(1,segment_start:index) .^2 + Deltas(2,segment_start:index) .^2));
            L_chords(N_segments) = norm(points(:,segment_start) - points(:,index));
            
            segment_start = index;
            taus(N_segments) = L_arcs(N_segments) / L_chords(N_segments) - 1;
        end
        
        
        if(segment_start < length(r)) % process last segment
            L_arcs(end+1) = sum(sqrt(Deltas(1,segment_start:end) .^2 + Deltas(2,segment_start:end) .^2));
            L_chords(end+1) = norm(points(:,segment_start) - points(:,end));
            taus(end+1) = L_arcs(end) / L_chords(end) - 1;
            N_segments = N_segments + 1;
        end
                
        tau = (N_segments-1)/N_segments * sum(taus);
    end % function TD2
    
    
    function [tau, significant_sign_change_starts, significant_sign_change_ends, segment_boundaries] = TD3(points,r,hysteresis_threshold) % further improved version
        curvature_sign = sign(1 ./ r) .* (abs(1 ./ r) > hysteresis_threshold);
        sign_changes = (curvature_sign(1:end-1) ~= curvature_sign(2:end));
        segment_ends = find(sign_changes);
        segment_starts = segment_ends+1;
        
        non_zero_ends = segment_ends(curvature_sign(segment_ends) ~= 0);
        non_zero_starts = segment_starts(curvature_sign(segment_starts) ~= 0);
        
        valid_non_zero_ends = non_zero_ends(1:end-1);
        valid_non_zero_starts = non_zero_starts(2:end);
 
        significant_sign_end_changes = (curvature_sign(non_zero_ends(1:end-1)) ~= curvature_sign(non_zero_ends(2:end)));
        significant_sign_change_ends = valid_non_zero_ends(significant_sign_end_changes) + 1;
        
        significant_sign_start_changes = (curvature_sign(non_zero_starts(1:end-1)) ~= curvature_sign(non_zero_starts(2:end)));
        significant_sign_change_starts = valid_non_zero_starts(significant_sign_start_changes);
        
        segment_boundaries = round((significant_sign_change_ends +  significant_sign_change_starts) / 2);
        
        segment_start = 1;
        N_segments = 1;
        for N_segments = 1:length(segment_boundaries)
            index = segment_boundaries(N_segments);
            L_arcs(N_segments) = sum(sqrt(Deltas(1,segment_start:index) .^2 + Deltas(2,segment_start:index) .^2));
            L_chords(N_segments) = norm(points(:,segment_start) - points(:,index));
            
            segment_start = index;
            taus(N_segments) = L_arcs(N_segments) / L_chords(N_segments) - 1;
        end
        
        
        if(segment_start < length(r)) % process last segment
            L_arcs(end+1) = sum(sqrt(Deltas(1,segment_start:end) .^2 + Deltas(2,segment_start:end) .^2));
            L_chords(end+1) = norm(points(:,segment_start) - points(:,end));
            taus(end+1) = L_arcs(end) / L_chords(end) - 1;
            N_segments = N_segments + 1;
        end
                
        tau = (N_segments-1)/N_segments * sum(taus);
    end
    
    
    function [R,xcyc] = find_circle_through_3_points(ABC)
        % FIT_CIRCLE_THROUGH_3_POINTS
        % Mathematical background is provided in http://www.regentsprep.org/regents/math/geometry/gcg6/RCir.htm
        %
        % Input:
        %
        %   ABC is a [3 x 2n] array. Each two columns represent a set of three points which lie on
        %       a circle. Example: [-1 2;2 5;1 1] represents the set of points (-1,2), (2,5) and (1,1) in Cartesian
        %       (x,y) coordinates.
        %
        % Outputs:
        %
        %   R     is a [1 x n] array of circle radii corresponding to each set of three points.
        %   xcyc  is an [2 x n] array of of the centers of the circles, where each column is [xc_i;yc_i] where i
        %         corresponds to the {A,B,C} set of points in the block [3 x 2i-1:2i] of ABC
        %
        % Author: Danylo Malyuta.
        % Version: v1.0 (June 2016)
        % ----------------------------------------------------------------------------------------------------------
        % Each set of points {A,B,C} lies on a circle. Question: what is the circles radius and center?
        % A: point with coordinates (x1,y1)
        % B: point with coordinates (x2,y2)
        % C: point with coordinates (x3,y3)
        % ============= Find the slopes of the chord A<-->B (mr) and of the chord B<-->C (mt)
        %   mt = (y3-y2)/(x3-x2)
        %   mr = (y2-y1)/(x2-x1)
        % /// Begin by generalizing xi and yi to arrays of individual xi and yi for each {A,B,C} set of points provided in ABC array
        x1 = ABC(1,1:2:end);
        x2 = ABC(2,1:2:end);
        x3 = ABC(3,1:2:end);
        y1 = ABC(1,2:2:end);
        y2 = ABC(2,2:2:end);
        y3 = ABC(3,2:2:end);
        % /// Now carry out operations as usual, using array operations
        mr = (y2-y1)./(x2-x1);
        mt = (y3-y2)./(x3-x2);
        % A couple of failure modes exist:
        %   (1) First chord is vertical       ==> mr==Inf
        %   (2) Second chord is vertical      ==> mt==Inf
        %   (3) Points are collinear          ==> mt==mr (NB: NaN==NaN here)
        %   (4) Two or more points coincident ==> mr==NaN || mt==NaN
        % Resolve these failure modes case-by-case.
        idf1 = isinf(mr); % Where failure mode (1) occurs
        idf2 = isinf(mt); % Where failure mode (2) occurs
        idf34 = isequaln(mr,mt) | isnan(mr) | isnan(mt); % Where failure modes (3) and (4) occur
        % ============= Compute xc, the circle center x-coordinate
        xcyc = (mr.*mt.*(y3-y1)+mr.*(x2+x3)-mt.*(x1+x2))./(2*(mr-mt));
        xcyc(idf1) = (mt(idf1).*(y3(idf1)-y1(idf1))+(x2(idf1)+x3(idf1)))/2; % Failure mode (1) ==> use limit case of mr==Inf
        xcyc(idf2) = ((x1(idf2)+x2(idf2))-mr(idf2).*(y3(idf2)-y1(idf2)))/2; % Failure mode (2) ==> use limit case of mt==Inf
        xcyc(idf34) = NaN; % Failure mode (3) or (4) ==> cannot determine center point, return NaN
        % ============= Compute yc, the circle center y-coordinate
        xcyc(2,:) = -1./mr.*(xcyc-(x1+x2)/2)+(y1+y2)/2;
        idmr0 = mr==0;
        xcyc(2,idmr0) = -1./mt(idmr0).*(xcyc(idmr0)-(x2(idmr0)+x3(idmr0))/2)+(y2(idmr0)+y3(idmr0))/2;
        xcyc(2,idf34) = NaN; % Failure mode (3) or (4) ==> cannot determine center point, return NaN
        % ============= Compute the circle radius
        R = sqrt((xcyc(1,:)-x1).^2+(xcyc(2,:)-y1).^2);
        R(idf34) = Inf; % Failure mode (3) or (4) ==> assume circle radius infinite for this case
        
    end % function find_circle_through_3_points
    
end % function compute_tortuosity
