%
% Split the background set into a "fitting" set and a "validation"
% set
%
% This is done within each alphabet, not across alphabets
%

% Parameters
rand_reset();
perc_train = .75;

load('data_background_processed','D');
O = D;

names = O.names;
images = O.images;
nalpha = length(names);

D_train = cell(nalpha,1);
D_test = cell(nalpha,1);
I_train = cell(nalpha,1);
I_test = cell(nalpha,1);

to_remove_train = [];
to_remove_test = [];

for a=1:nalpha
    
    nchar = length(images{a});
    ntest = floor(nchar*(1 - perc_train));
    ntrain = nchar-ntest;
    
    perm = randperm(nchar);
    
    itrain = perm(1:ntrain);
    itest = perm(ntrain+1:end);
    
    if ntrain > 0
        D_train{a} = O.get('drawings',a,itrain,[],true);
        I_train{a} = O.get('image',a,itrain,[],true);
    end
    
    if ntest > 0
        D_test{a}  = O.get('drawings',a,itest,[],true);
        I_test{a}  = O.get('image',a,itest,[],true);
    end
    
    if ntrain == 1
       D_train{a} = num2cell(D_train{a}, 1);
       I_train{a} = num2cell(I_train{a}, 1);
    end
    
    if ntest == 1
       D_test{a} = num2cell(D_test{a}, 1);
       I_test{a} = num2cell(I_test{a}, 1);
    end
    
    if ntrain == 0
        to_remove_train = [to_remove_train a];
    end
    if ntest == 0
        to_remove_test = [to_remove_test a];
    end
end

for a=1:length(to_remove_train)
    I_train((to_remove_train(a) - (a - 1)):(to_remove_train(a) - (a - 1))) = [];
    D_train((to_remove_train(a) - (a - 1)):(to_remove_train(a) - (a - 1))) = [];
end

for a=1:length(to_remove_test)
    I_test((to_remove_test(a) - (a - 1)):(to_remove_test(a) - (a - 1))) = [];
    D_test((to_remove_test(a) - (a - 1)):(to_remove_test(a) - (a - 1))) = [];
end

% disp(I_train)
D = Dataset(D_train,I_train,names);
save('background_fit','D');

D = Dataset(D_test,I_test,names);
save('background_val','D');