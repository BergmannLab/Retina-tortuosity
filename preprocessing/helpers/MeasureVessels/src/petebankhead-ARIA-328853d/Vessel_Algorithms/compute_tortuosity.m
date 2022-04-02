function [tau, r, centers] = compute_tortuosity(points, method)
    
    %disp('Computing tortuosity ...');
    
    % Input:
    %
    %   'points' is a [n x 2] array. The first column represents the x, and
    %   the second colum the y coordinate of an ordered set of n points.
    %   if less than 3 points are given, a test set of point along a sinus
    %   curve is used instead.
    %
    %   'method' is an integer defining the method type:
    %   (1) tau1 = DistanceFactor = (total arc-length over total chord-length) - 1
    %   (2) tau2 = the integral over the curvature along the entire curve
    %   (3) tau3 = the integral over the curvature squared along the entire curve
    %   (4) tau4 = COMPLETE
    %   (5) tau5 = 
    %   (6) tau6 = 
    %   (7) tau7 = 
    %
    % Outputs:
    %
    %   'tau' is a float containing the tortuosity computed for the curve defined by the input points with the specified methods
    %   'r' is a [(n-2) x 1] array for the curvature radius for all points except the first and the last
    %   'centers' is a [(n-2) x 2] array for the centers of the tangent circles for all points except the first and the last
    %
    % Author: Sven Bergmann
    % Version: v1.0 (2020)
    
    points = transpose(points);
    
    if(nargin < 1)
        disp('ERROR: Fatal error in compute_tortuosity. No input'); 
    end
    
    if(nargin < 2)
        disp('Warning: no method selected in compute_tortuosity. Method=1 selected by default'); 
        method = 1;
    end
    
    points1 = points(:,1:end-2);
    points2 = points(:,2:end-1);
    points3 = points(:,3:end);
    
    Deltas = points(:,1:end-1) - points(:,2:end);
    
    mean_Deltas = (Deltas(:,1:end-1) + Deltas(:,2:end))/2; % mean difference of neighboring points
    Deltas2 = Deltas(:,1:end-1) - Deltas(:,2:end); % difference of differences
    
    curvature_sign = sign(mean_Deltas(1,:) .* Deltas2(2,:) - mean_Deltas(2,:) .* Deltas2(1,:));
    
    ABC = [points1(:)'; points2(:)'; points3(:)'];
    
    [r,centers] = find_circle_through_3_points(ABC);
    r = r .* curvature_sign;
    r(isnan(r))=0; 
    
    
    switch(method)         
        case 1
            L_arc = sum(sqrt(Deltas(1,:) .^2 + Deltas(2,:) .^2));
            L_chord = norm(points(:,end) - points(:,1));
            tau = L_arc / L_chord - 1;
            
        case 2
            tau = sum(sqrt(mean_Deltas(1,:) .^2 + mean_Deltas(2,:) .^2) ./ abs(r));
            
        case 3
            tau = sum(sqrt(mean_Deltas(1,:) .^2 + mean_Deltas(2,:) .^2) ./ (r .* r));
            
        case 4
            L_arc = sum(sqrt(Deltas(1,:) .^2 + Deltas(2,:) .^2));
            tau = sum(sqrt(mean_Deltas(1,:) .^2 + mean_Deltas(2,:) .^2) ./ abs(r)) / L_arc;
            
        case 5
            L_arc = sum(sqrt(Deltas(1,:) .^2 + Deltas(2,:) .^2));
            tau = sum(sqrt(mean_Deltas(1,:) .^2 + mean_Deltas(2,:) .^2) ./ (r .* r)) / L_arc;
            
        case 6
            L_chord = norm(points(:,end) - points(:,1));
            tau = sum(sqrt(mean_Deltas(1,:) .^2 + mean_Deltas(2,:) .^2) ./ abs(r)) / L_chord;
            
        case 7
            L_chord = norm(points(:,end) - points(:,1));
            tau = sum(sqrt(mean_Deltas(1,:) .^2 + mean_Deltas(2,:) .^2) ./ (r .* r)) / L_chord;
            
        otherwise
            tau = NaN;

    end % switch(method)
    
    
    
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
