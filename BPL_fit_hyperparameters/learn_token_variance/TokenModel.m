classdef TokenModel < BetterHandle
    %
    % TOKENMODEL Estimate the token-level variance parameters
    %  for stroke shape, inverse scale, and along relation
    %
    % Use to compute estimate of token-level variance:
    %   compute_shape_var_lb
    %   compute_scale_var_lb
    %   compute_seval_var_lb
    %
    
    properties
        matches % list of list of matched motor programs, where each list in the list
                % has been matched for scale (to the mean)
    end
    
    properties (SetAccess = private)
        relmatch % subset of matches that have an "attach along" relation
        scalematch % subset of matches that have more than one sub-stroke
    end
    
    properties (Dependent)
       ndat_matches
    end
    
    methods
        
        % 
        % TokenModel constructor
        %
        % HMM: primitive class
        % SM: scale model
        function this = TokenModel(matches)           
            this.matches = matches;
            n = numel(matches);
            for i=1:n
%               fprintf(1,'checking match %d of %d\n',i,n);
                M1 = matches{i}{1};
                M2 = matches{i}{2};
                assert(this.is_match(M1,M2));                                
            end            
            this.compute_matches();            
        end
        
        % get the number of models in the match cell array
        function total = get.ndat_matches(this)
           n = numel(this.matches);
           total = 0;
           for i=1:n
               match = this.matches{i};
               total = total + numel(match);               
           end            
        end

        %
        % Compute a lower bound on the estimate
        % of the token-level shape variance, by
        % ignoring the primitive means and just computing the
        % standard variance esimate
        %        
        function [lb,outliers] = compute_shape_var_lb(this)           
            shapeget = @(x,bid) vec(x.shapes_token(:,:,bid))';
            data_shapes = extract_per_stroke(this.matches,shapeget);            
            
            % Treat each dimension of the shape variables as separate
            n = numel(data_shapes);
            ddim = numel(data_shapes{1}(1,:));
            flat_data_shapes = [];
            flat_data_ids = [];
            for i=1:n
               for sel_dim = 1:ddim
                    flat_data_shapes = [flat_data_shapes; {data_shapes{i}(:,sel_dim)}];
                    flat_data_ids = [flat_data_ids; i];
               end
            end
            data_shapes = flat_data_shapes;
             
            % remove outliers
            rmv = rmv_outlier_iter(data_shapes);
            data_shapes(rmv) = [];
            n = numel(data_shapes);
            outliers = unique(flat_data_ids(rmv));
            
            % compute mean for each group
            mean_shape = zeros(n,numel(sel_dim));    
            for i=1:n
                mean_shape(i,:) = mean(data_shapes{i},1);
            end         
            
            % square difference between mean and item
            sqdiff = [];
            for i=1:n
                shapes = data_shapes{i};
                m = size(shapes,1);
                mymu = repmat(mean_shape(i,:),[m 1]);
                sqdiff = [sqdiff; (shapes(:)-mymu(:)).^2];
            end            
            mse = mean(sqdiff);
            lb = sqrt(mse);
            
        end        
       
        %
        % Compute a lower bound on the estimate
        % of the token-level scale variance, by
        % ignoring the primitive priors and just computing the
        % standard variance esimate
        %  
        function lb = compute_scale_var_lb(this)            
            invscaleget = @(x,bid) x.invscales_token(bid);
            data_invscales = extract_per_stroke(this.scalematch,invscaleget);
            
            % remove outliers
            rmv = rmv_outlier_iter(data_invscales);
            data_invscales(rmv) = [];
            n = numel(data_invscales);
            
            % compute mean inv-scale for each group
            mean_invscale = zeros(n,1);            
            for i=1:n
                mean_invscale(i) = mean(data_invscales{i});
            end        
            
            % square difference between mean and the item
            sqdiff = [];
            for i=1:n
                invscales = data_invscales{i};
                sqdiff = [sqdiff; (invscales(:)-mean_invscale(i)).^2];
            end            
            mse = mean(sqdiff);
            lb = sqrt(mse);
        end

        %
        % Compute a lower bound on the estimate
        % of the token-level attachment position parameter
        %         
        function lb = compute_seval_var_lb(this)           
           if isempty(this.relmatch)
               warning('no valid relations found'); 
               lb = 0;
               return
           end
           nr = numel(this.relmatch);
           data_seval = cell(nr,1);
           for i=1:nr
              data_seval{i} = this.relmatch{i}.v_eval_spot_token;
           end
           
           % remove outliers
           rmv = rmv_outlier_iter(data_seval);
           data_seval(rmv) = [];
           
           % compute mean value for each match
           n = numel(data_seval);
           mean_seval = zeros(n,1);            
           for i=1:n
               mean_seval(i) = mean(data_seval{i});
           end            
           
           % mean squared deviation from mean
           sqdiff = [];   
           for i=1:n
               sevals = data_seval{i};
               sqdiff = [sqdiff; (sevals(:)-mean_seval(i)).^2];
           end            
           mse = mean(sqdiff);
           lb = sqrt(mse);
           
        end
       
         % plot all of the matches found
        function plot_matches(this)
            img = false(105);
            n = numel(this.matches);
            figure(1)            
            for i=1:n
                clf
                match = this.matches{i};
                nm = numel(match);
                for j=1:nm
                    subplot(2,nm,j);
                    plot_motor_to_image(img,this.matches{i}{j}.motor_warped);
                    title('rescaled');
                end      
                input('press enter to continue\n','s');
            end            
        end
        
        % plot all of SCALE matches found (subset of matches)
        function plot_scale_matches(this)
            img = false(105);
            n = numel(this.scalematch);
            figure(1)            
            for i=1:n
                clf
                match = this.scalematch{i};
                nm = numel(match);
                for j=1:nm
                    subplot(1,nm,j);
                    plot_motor_to_image(img,match{j}.motor_warped);
                end
                input('press enter to continue\n','s');
            end            
        end
        
        % plot all of RELATION matches found (subset of matches)
        function plot_relation_matches(this)
            img = false(105);
            n = numel(this.relmatch);
            figure(1)            
            for i=1:n
                clf
                match = this.relmatch{i}.models;
                nm = numel(match);
                for j=1:nm
                    subplot(1,nm,j);
                    plot_motor_to_image(img,match{j}.motor_warped);
                end
                input('press enter to continue\n','s');
            end            
        end
        
    end
    
    methods (Access = private)
        
         
      % Get the matches given the soft primitive analysis
      function compute_matches(this)                            
            this.compute_scale_matches;
            this.compute_rel_matches;                     
      end
      
      % select characters with more than one sub-stroke
      function compute_scale_matches(this)
          n = numel(this.matches);
          sel = false(n,1);
          for i=1:n
             list_match = this.matches{i};
             M = list_match{1};
             nsub = count_substroke(M);
             sel(i) = nsub > 1;
          end          
          this.scalematch = this.matches(sel);    
      end
      
      % select strokes in matched characters that have an attachment relation
      function compute_rel_matches(this)
          relmatch = [];
          n = numel(this.matches);
          for i=1:n
             models = this.matches{i};   
             for sid=models{1}.ns
               [is_same,v_eval_spot_token,v_traj_len] = same_relation(models,sid);
               if is_same
                    indx = numel(relmatch)+1;
                    relmatch{indx}.v_eval_spot_token = v_eval_spot_token;
                    relmatch{indx}.v_traj_len = v_traj_len;
                    relmatch{indx}.models = models;
               end
             end
           end
           this.relmatch = relmatch;
      end    
        
      
      % Are two characters a match?
      % They must have all the same strokes, defined up to a tolerance,
      % and none of the sub-strokes should be smaller than a predefined
      % threshold
      function y = is_match(this,M1,M2)
            
            % check number of strokes match
            y = true;
            if M1.ns ~= M2.ns
               y = false;
               return
            end
            
            % check the number of sub-strokes match
            ns = M1.ns;            
            for sid=1:ns
                nsub1 = size(M1.S{sid}.ids,1);
                nsub2 = size(M2.S{sid}.ids,1);                
                if nsub1 ~= nsub2
                    y = false;
                    return
                end
            end                    
            
      end
      
    end
    
end

% extract 
function list = extract_per_stroke(mymatches,fget)           
    list = [];
    n = numel(mymatches);
    for i=1:n
       ns = mymatches{i}{1}.ns;               
       for sid=1:ns
           nsub = size(mymatches{i}{1}.S{sid}.ids,1);
           for bid=1:nsub                   
               v_item = [];
               nm = numel(mymatches{i});
               for j = 1:nm
                   item = fget(mymatches{i}{j}.S{sid},bid); 
                   v_item = [v_item; item];
               end                 
               list = [list; {v_item}];
           end
       end                
    end
end        

function nsub = count_substroke(M)
    nsub = 0;
    for sid=1:M.ns
        nsub = nsub + M.S{sid}.nsub;
    end
end

% Do the "models" have the same "attach" relation for stroke sid?
%
% Meaning, they must attach to the same stroke, and then 
%  attach to the same sub-stroke in that stroke.
%
% Input
%   models: [nm x 1 cell] list of models
%   sid: stroke index
%
% Output
%  is_same: [logical scalar] are all of the mdoels the same?
%  v_eval_spot_token: [nm x 1] token-level attachment spot
%  v_traj_lens [nm x 1]: the total length (in pxels) of the relevant
%       sub-stroke trajectory
%  
function [is_same,v_eval_spot_token,v_traj_lens] = same_relation(models,sid)
   nm = numel(models);
   types = cell(nm,1);
   v_subid_spot = nan(nm,1);
   v_attach_spot = nan(nm,1);
   v_eval_spot_token = nan(nm,1);
   v_traj_lens = nan(nm,1);
   for subid=1:nm
      R = models{subid}.S{sid}.R;
      types{subid} = R.type;
      if strcmp(R.type,'mid')
          v_subid_spot(subid) = R.subid_spot;
          v_attach_spot(subid) = R.attach_spot;
          v_eval_spot_token(subid) = R.eval_spot_token;
          
          % compute the length along the trajectory
          traj = models{subid}.motor_warped{R.attach_spot}{R.subid_spot};
          v_traj_lens(subid) = sum_pair_dist(traj);
      end
   end

   % assure relations are the same
   is_same = true;
   for ii=2:nm
      if ~strcmp(types{ii},'mid')
         is_same = false;
      end
      if v_subid_spot(ii) ~= v_subid_spot(ii-1)
         is_same = false;                     
      end
      if v_attach_spot(ii) ~= v_attach_spot(ii-1)
         is_same = false; 
      end
   end

end

% Remove outliers recurisvely. If we have removed
% any new outliers (compared to input "rmv"), then
% we should apply function recursively
function rmv = rmv_outlier_iter(cell_v,rmv)
   
    ps = defaultps_clustering;

    % compute mean statistic for each group
    n = numel(cell_v);
    
    vmean = zeros(n,1);
    for i=1:n
        vmean(i) = mean(cell_v{i});
    end
    
    % compute difference from mean
    cell_diff = cell(n,1);
    for i=1:n
       cell_diff{i} = cell_v{i}-vmean(i); 
    end
    
    % find data points to remove
    if ~exist('rmv','var')        
        rmv = false(n,1);
    end
    oldrmv = rmv;
    assert(numel(rmv)==n);
    cell_sub = cell_diff;
    cell_sub(rmv) = [];
    diff = cell_to_vec(cell_sub);
    sd = std(diff);
    
    for i=1:n
       if any(abs(cell_diff{i}) > ps.outlier_thresh_sd*sd)
          rmv(i) = true; 
       end
    end
    
    % recursive call
    nrmv = sum(rmv) - sum(oldrmv);
    if nrmv > 0
        rmv = rmv | rmv_outlier_iter(cell_v,rmv);
    end
    
    figure(1);
    clf
    subplot(2,1,1);    
    [~,xcenters] = hist(diff,100);
    nelem_in = hist(cell_to_vec(cell_diff(~rmv)),xcenters);
    nelem_out = hist(cell_to_vec(cell_diff(rmv)),xcenters);
    Y = [nelem_in(:) nelem_out(:)];
    bar(xcenters,Y);
    legend('data','outlier');
    
end

% verticall concat a cell array
function v = cell_to_vec(mycell)
    n = numel(mycell);
    v = [];
    for i=1:n
        v = [v; mycell{i}(:)];
    end
end

% 
% Distance along a trajectory 
%
% D: [n x 2] trajectory
% 
% Output
%  s: sum of each step-wise distance
%
function s = sum_pair_dist(D)
    x1 = D(1:end-1,:);
    x2 = D(2:end,:);
    z = sqrt(sum((x1-x2).^2,2));
    s = sum(z);
end