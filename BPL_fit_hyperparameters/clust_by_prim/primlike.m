%
% Compute the log-likelihood of data drawn from the primitive model,
%   which includes the shape and scale of a sub-stroke
%
% Input
%  data: [n x dim+1] rows of observations
%  c: [scalar] category we want to score
%  mu: [nclass x dim] rows are categories
%  Sigma: [dim x dim x nclass] category covariance
%  thetas: [nclass x 2] gamma parameters for each category
%
% Output
%  ll: [n x 1] log-likelihood of each observation
%
function ll = primlike(data,c,mu,Sigma,thetas)
    [n,dim] = size(data);
    [nclass,dim] = size(mu);
    cpt = 1:dim;
    ll = gausslike(data(:,cpt),c,mu,Sigma) + gammalike(data(:,end),c,thetas);
end