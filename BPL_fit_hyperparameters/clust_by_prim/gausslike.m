%
% Compute the Gaussian log-likelihood
%
% Input
%  data: [n x dim] rows are observations
%  c: [scalar] category we want to score
%  mu: [nclass x dim] rows are categories
%  Sigma: [dim x dim x nclass] category covariance
%
% Output
%  ll: [n x 1] log-likelihood of each observation
% 
function ll = gausslike(data,c,mu,Sigma)
    assert(isscalar(c));
    [~,dim] = size(data);
    assert(size(mu,2)==dim);
    assert(size(Sigma,1)==dim);
    mymu = mu(c,:);
    mySigma = Sigma(:,:,c);
    llrow = mvnormpdfln(data',mymu',[],mySigma);
    ll = llrow(:);
end