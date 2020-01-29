%
% Learn the parameters of the relation model.
%
% Begin by setting a flat prior on the mixing prob. of relations.
% Then given a set of fit models, re-optimize the relation for each stroke.

% Compute the new mixing probabilities and the variance around the
% relations.
% 
function run_learn_relations

    load('previous_library','lib');
    oldlib = lib;
    lib = Library();
    lib.legacylib(oldlib);
    
    load('models_for_latent_variables','list_fit');
    
    n = numel(list_fit);
    list_M = cell(n,1);
    for i=1:n
        list_M{i} = list_fit{i}.M_base;
    end

    % optimize the relations, since
    % I changed the form of marginalization over the eval. variable
    fairlib = lib.copy();
    rel = fairlib.rel;
    rel.mixprob = ones(4,1);
    fairlib.setfield('rel',rel);
    opt_relations(list_M,fairlib);
    
    % compute parameters
    mixprob = get_type_mix(list_M);
    vsigma = get_pos_sd(list_M);
    sigma_x = vsigma(1);
    sigma_y = vsigma(2);
    
  save('relation_model_june6','sigma_x','sigma_y','mixprob');
end

%%
function opt_relations(list_M,lib)
    n = numel(list_M);
    for i=1:n   
        argmax_relations(lib,list_M{i}); 
    end
end

%%
function mixprob = get_type_mix(list_M)
    
    %% get all of the relation types in the mix
    list_type =[];
    n = numel(list_M);
    for i=1:n
        M = list_M{i};
        ns = M.ns;
        for sid=2:ns        
            R = M.S{sid}.R;
            list_type = [list_type; {R.type}];
        end
    end

    %%
    R = Relation();
    types = R.types_allowed;
    nt = numel(types);    
    mixprob = zeros(nt,1);
    for i=1:nt        
        mixprob(i) = mean(strcmp(types{i},list_type));        
    end
    
    %% 
    for i=1:nt
       fprintf(1,'  %s = %s\n',types{i},makestr(mixprob(i))); 
    end
    
end

function vsigma = get_pos_sd(list_M)
    
    %% get all of the relation types in the mix
    list_pos_base = [];
    list_pos_token = [];
    n = numel(list_M);
    for i=1:n
        M = list_M{i};
        ns = M.ns;
        for sid=2:ns                   
            previous_strokes = M.S(1:sid-1);
            R = M.S{sid}.R;
            pos_base = getAttachPoint(R,previous_strokes);
            pos_token = M.S{sid}.pos_token;
            list_pos_base = [list_pos_base; pos_base];
            list_pos_token = [list_pos_token; pos_token];
        end
    end

   pos_diff = (list_pos_base - list_pos_token).^2;
   pos_diff = mean(pos_diff,1);
   vsigma = sqrt(pos_diff);
   
   fprintf(1,'  sigma_x = %s\n',makestr(vsigma(1))); 
   fprintf(1,'  sigma_y = %s\n',makestr(vsigma(2)));     
end