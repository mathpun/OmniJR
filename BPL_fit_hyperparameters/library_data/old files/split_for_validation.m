%
% Split the background set into a "fitting" set and a "validation"
% set
%
% This is done within each alphabet, not across alphabets
%

% Parameters
rand_reset();
perc_train = .75;

% load('data_background_processed','D');
load('/Users/mashabelyi/UCBerkeley/courses/Research/Omniglot/BPL/data/data_background_processed/', 'D')
O = D;

names = O.names;
images = O.images;
nalpha = length(names);

D_train = cell(nalpha,1);
D_test = cell(nalpha,1);
I_train = cell(nalpha,1);
I_test = cell(nalpha,1);
for a=1:nalpha
    
    nchar = length(images{a});
    ntrain = floor(nchar*perc_train);
    ntest = nchar-ntrain;
    
    perm = randperm(nchar);
    
    itrain = perm(1:ntrain);
    itest = perm(ntrain+1:end);
    
    D_train{a} = O.get('drawings',a,itrain);
    D_test{a}  = O.get('drawings',a,itest);
    I_train{a} = O.get('image',a,itrain);
    I_test{a}  = O.get('image',a,itest);
end

D = Dataset(D_train,I_train,names);
save('background_fit','D');

D = Dataset(D_test,I_test,names);
save('background_val','D');