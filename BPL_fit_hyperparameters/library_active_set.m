%
% List of file names for which the individual modules
% are stored.
%
function as = library_active_set()

    as = struct;

    % simple
    as.affine = 'affine_model_june6';
    as.number = 'number_model_june6';
    as.position = 'position_model_june6';
    as.nsub = 'nsub_model_june6';
    
    % primitives
    as.primitives = 'primitive_model_june6';
    as.nprim = 1250; % number of primitives that we want
    
    % special
    as.relations = 'relation_model_june6'; 
    as.tokenvar = 'tokenvar_model_june6';
   
end