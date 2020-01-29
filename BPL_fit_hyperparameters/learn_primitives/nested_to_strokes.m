%
%  Flatten a nested structure, such that each cell
%  in the new structure is a single stroke
%
%  Input
%   nested_cell: nested cell array, where the top level is alphabets
%
function cell_stks = nested_to_strokes(nested_cell)

    cell_stks = [];
    nalpha = length(nested_cell);
    
    for a=1:nalpha % each alphabet
        alpha = nested_cell{a};
        nchar = length(alpha);
        
        for c=1:nchar % each character
            char = alpha{c};
            nrep = length(char);
             
            for r=1:nrep % each drawer
               rep = char{r};
               ns = length(rep);
                
               for i=1:ns % each stroke
                   
                  stk = rep{i};
                  if ~isempty(stk)
                    cell_stks = [cell_stks; {stk}];
                  end
               
               end
               
            end
        end
    end
    
end