%
% Compute a distribution on the number of strokes
% in the dataset
% 
% Cut it off at the first cardinality that has
% no entries in the histogram
%
% Input is a nested cell array of the dataset
%
% In previous version, the first element indexes for "zero strokes"
% now, it indexes for 1 stroke
%
% Output
%   pkappa: [max_ns x 1] distribution on number of strokes in dataset
%
function pkappa = fit_number_model(dataset,verbose)

    if ~exist('verbose','var')
        verbose = true;
    end

    nalpha = length(dataset);
    nstroke = [];
    for a=1:nalpha % each alphabet
       alpha = dataset{a};
       nchar = length(alpha);
       for c=1:nchar
          char = alpha{c}; % each character
          nreps = length(char);
          for r=1:nreps % each replication
             rep = char{r};
             nstroke = [nstroke; length(rep)];
          end
       end
    end

    % make distribution
    ps = defaultps_clustering;
    max_ns = ps.max_ns;
    freq = zeros(max_ns,1);
    for i=1:max_ns
       freq(i) = sum(nstroke==i); 
    end    
    pkappa = freq ./ sum(freq);
    
    if verbose
        pos = [680   865   580   233];
        figure;
        bar(freq);
        title('Number of strokes');
        ylabel('frequency');
        set(gcf,'Position',pos);
%         printpdf('number_model');
        print('number_model', '-dpng');
    end
    
end