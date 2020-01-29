%
% Seach over position model parameters using cross-validation:
%  1) number of bins in histogram
%  2) prior counts in each bin
%  3) number of different position models (clump at index)
%
%  Evaluate and choose the best on the held-out data
%
%  Load training data
load('position_fit','data_start','data_id');
train_start = data_start;
train_id = data_id;
clear data_start data_id
load('position_val','data_start','data_id');
test_start = data_start;
test_id = data_id;

%fixed edge bounds for the histogram - Charlie Snell
xlim = [-10 105]
ylim = [-10 105]
pModel = model_selection_position(train_start,train_id,test_start,test_id, xlim, ylim);
save('position_model_june6','pModel');