%
% Compute a distribution on the number of sub-strokes
% in the dataset
% 
% Cut it off at the first cardinality that has
% no entries in the histogram
%
% Input
%  list_nsub: [n x 1] list of number of sub-strokes
%
% Output
%   p_nsub: [max_nsub x 1] distribution on number of sub-strokes in dataset
%
function p_nsub = fit_nsubstroke_model(list_nsub,verbose)

    if ~exist('verbose','var')
        verbose = false;
    end  
    assert(isvector(list_nsub));
        
    % make distribution
    ps = defaultps_clustering;
    max_nsub = ps.max_nsub;
    freq = zeros(max_nsub,1);
    for i=1:max_nsub
       freq(i) = sum(list_nsub==i); 
    end
    
    p_nsub = freq ./ sum(freq);
    
    if verbose
        pos = [680   865   580   233];
        figure;
        bar(freq);
        title('Number of sub-strokes');
        ylabel('frequency');
        set(gcf,'Position',pos);
        print('number_model', '-dpng');
    end
    
end