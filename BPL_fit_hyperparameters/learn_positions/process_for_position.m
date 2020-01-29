%
% Given a nested cell array of drawings,
% returns a flat list of all of the start positions
% 
function [dset_start,dset_id] = process_for_position(drawings)

    dset_start = [];
    dset_id = [];

    nalpha = length(drawings);
    for a=1:nalpha
        alpha = drawings{a};
        nchar = length(alpha);
        for c=1:nchar
            char = alpha{c};
            nrep = length(char);
            for r=1:nrep
                rep = char{r};
                ns = length(rep);
                for s=1:ns
                   stroke = rep{s};
                   stk_start = stroke{1}(1,:);
                   stk_id = s;
                   
                   % store important components
                   dset_start = [dset_start; stk_start];
                   dset_id = [dset_id; stk_id];
                end
            end
        end
    end
    
end