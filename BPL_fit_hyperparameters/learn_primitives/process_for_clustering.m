%
% Process a raw dataset for clustering, by fitting splines
%  and removing small strokes
%
% Input
%  pdrawings: [nested cell] of normalized trajectories
%
% Output
%
%  cell_data: [n x 1 cell] each cell is a stroke, which is an array
%   where rows are the spline control points of the sub-strokes in that
%   stroke
% 
%  data: [m x dim] all sub-strokes are flattened into a single array
%
%  cell_scales and scales: same as data, but rather than control points,
%   its the applied scale
%
%  pdrawings_norm : [nested cell] original data but now whitened  
%  bspline_substks : [nested cell] splines fit to whitened sub-strokes
function [cell_data,data,cell_scales,scales,pdrawings_norm,bspline_substks] = process_for_clustering(pdrawings,ps)

    if ~exist('ps','var')
        ps = defaultps_clustering();
    end
        
    % remove strokes that are short in distance and time
    pdrawings = remove_short_stk(pdrawings,ps.minlen_ss,inf);
            % remove anything less than specific length

    % normalize the sub-strokes for clustering
    [pdrawings_norm,~,pdrawings_scales] = normalize_dataset(pdrawings,ps.newscale_ss);

    % fit b-spline to each of the sub-strokes
    bspline_substks = apply_to_nested(pdrawings_norm,@(x)fit_bspline_to_traj(x,ps.ncpt));
    
    % remove nesting structure, such that we just
    % have a cell array of strokes
    % Create list of individual strokes
    cell_stks = nested_to_strokes(bspline_substks);
    cell_scales = nested_to_strokes(pdrawings_scales);
    if isempty(cell_stks)
       cell_data = [];
       cell_scales = [];
       data = [];
       scales = [];
       return
    end
    dim = numel(cell_stks{1}{1});
    n = length(cell_stks);
    cell_data = cell(n,1);
    for i=1:n
        stk = cell_stks{i};
        nsub = length(stk);
        dat = zeros(nsub,dim); % data
        scs = zeros(nsub,1); % scales
        for b=1:nsub
            dat(b,:) = vec(stk{b});
            scs(b) = cell_scales{i}{b}(1);
        end    
        cell_data{i} = dat;
        cell_scales{i} = scs;
    end
    
    % create a single matrix of data
    data = [];
    scales = [];
    for i=1:n
       data = [data; cell_data{i}]; 
       scales = [scales; cell_scales{i}];
    end
    
end