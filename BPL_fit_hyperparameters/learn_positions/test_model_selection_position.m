%
% Generate synthetic data from a position model, and see
% if we can recover the exact parameters using cross-validation
%
%
% Parameters
clump_id = 2;
nbin_per_side = 15;
prior_count = 4;

% Generate data
xlm = [-10 10];
ylm = [-10 10];

n_train = 1e5; % number of training points from each slice
n_test = 1000; % number of test points
n_train_last = 100;% number of datapoints from last slice;

% Shape of the distributions
mu = [-5 -5];
Sigma = eye(2);
data1 = mvnrnd(mu,Sigma,n_train);

mu = [0 0];
Sigma = eye(2);
data2 = mvnrnd(mu,Sigma,n_train);

mu = [5 5];
Sigma = eye(2);
data3 = mvnrnd(mu,Sigma,n_train);
data4 = mvnrnd(mu,Sigma,n_train_last);

% Distribution to fit the histogram model to 
data_train = [data1; data2; data3; data4];
indx_train = [ones(n_train,1); 2*ones(n_train,1); 3*ones(n_train,1); 4*ones(n_train_last,1)];
GT = SpatialModel(data_train,indx_train,clump_id,xlm,ylm,nbin_per_side,prior_count);

figure
GT.plot();
title('ground truth distribution');

% create validation set
indx_test = [ones(n_test,1); 2*ones(n_test,1); 3*ones(n_test,1); 4*ones(n_test,1)];
data_test = GT.sample(indx_test);

fprintf(1,'Ground truth parameters\n');
fprintf(1,'  number of bins: %d\n',nbin_per_side);
fprintf(1,'  additive count: %d\n',prior_count);
fprintf(1,'  clump at: %d\n',clump_id);

model_selection_position(data_train,indx_train,data_test,indx_test,xlm,ylm);