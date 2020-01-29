%
% Compute the Gamma log-likelihood
%
% Input
%  data: [n x 1] vector of observations
%  c: [scalar] category we want to score
%  thetas: [nclass x 2] gamma parameters for each category
%
% Output
%  logY: [n x 1] log-likelihood for each observation
function logY = gammalike(data,c,thetas)
    assert(isvector(data));
    n = numel(data);
    assert(size(thetas,2)==2);
    Y = gampdf(data(:),thetas(c,1),thetas(c,2));
    logY = log(Y(:));
end