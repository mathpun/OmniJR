%
% Build a model of the affine warp of applied to each image.
% 
% The raw images are converted into their "center of mass"
% and "range." We then compute the mean for each character.
%
% Rather than modeling this data in the raw, we want to model
% it as a transformation from the mean for that character.
% To do so, compute the affine warp from the mean statistics
% for that character to each image (scale and translation).
% We then model that as a Gaussian.
%
function affine = fit_affine_params(nested_images)
    
    % create grouped images
    dim = 4; % format is [com(1) com(2) range(1) range(2)]
    nalpha = length(nested_images);
    grouped_images = [];
    for a=1:nalpha
        grouped_images = [grouped_images; nested_images{a}];
    end
    
    % extract the com and range from raw image data
    ngroups = length(grouped_images);
    gdata = cell(ngroups,1);
    for g=1:ngroups
       group = grouped_images{g};
       n = length(group);
       gdata{g} = zeros(n,dim);
       for i=1:n
%           disp(grouped_images{11})
          img = grouped_images{g}{i};
          com = UtilImage.img_com(img);
%           if g == 16 & i == 12
%             n15 = 5;
%           end
          range = UtilImage.img_range(img);
          gdata{g}(i,:) = [com(:)' range(:)'];
       end
    end

    % get the group mean
    gmean = zeros(ngroups,dim);
    for g=1:ngroups
       dats = gdata{g};
       gmean(g,:) = mean(dats,1);
    end
    
    % compute all affine warps
    adata = [];
    for g=1:ngroups
       mymean = gmean(g,:);
       target_com = mymean(1:2);
       target_range = mymean(3:4);
       dats = gdata{g};
       n = size(dats,1);
       for i=1:n
           curr_com = dats(i,1:2);
           curr_range = dats(i,3:4);
           A = compute_affine_transform(curr_com,curr_range,...
               target_com,target_range);
           adata = [adata; A'];
       end       
    end
    
    % compute affine parameters
    affine = struct;
    affine.mu_scale = [1 1];
    affine.mu_xtranslate = 0;
    affine.mu_ytranslate = 0;
    % fixes NaN covarience and std issue by setting covarience values to 0
    % - Charlie
    temp_vals = adata(:,1:2);
    temp_vals(isinf(temp_vals)) = 0;
    affine.Sigma_scale = cov( temp_vals, 1);
    affine.sigma_xtranslate = nanstd( adata(:,3) );
    affine.sigma_ytranslate = nanstd( adata(:,4) );
end

% compute the desired transformation.
%
% Assumes everything was computed in MOTOR coordinates.
% 
function A = compute_affine_transform(curr_com,curr_range,target_com,target_range)

    assert(isvector(curr_com) && isvector(curr_range) && ...
           isvector(target_com) && isvector(target_range));
    
    curr_com = curr_com(:);
    curr_range = curr_range(:);
    target_com = target_com(:);
    target_range = target_range(:);
    
    shift = (target_com - curr_com);
    scale = target_range ./ curr_range;
    
    A = [scale; shift];
end