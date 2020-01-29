%%
load('background_fit','D');
list = D.get('all');
list = flatten_nested(list);

%%
n = numel(list);
vns = zeros(n,1); % number of strokes in each character
cell_nsub = cell(n,1); % number of sub-strokes for each stroke of character
for i=1:n

    drawing = list{i}.drawing;
    ns = numel(drawing);
    vns(i)= ns;

    % number of sub-strokes in each stroke
    mycell = zeros(ns,1);
    for sid=1:ns
       mycell(sid) = numel(drawing{sid});         
    end    
    cell_nsub{i} = mycell;

end

%% fit number of sub-stroke models
ps = defaultps_clustering;
max_ns = ps.max_ns;
max_nsub = ps.max_nsub;
pmat_nsub = zeros(max_ns,max_nsub);
for sid=1:max_ns 
    sel = vns==sid;
    list_nsub = cell2mat(cell_nsub(sel));    
    pmat_nsub(sid,:) = fit_nsubstroke_model(list_nsub);   
end

%%
nplot = max_ns;
ncol = 5;
nrow = ceil(nplot/ncol);
my_ylim = [0 1];
my_xlim = [0 11];
figure;
for i=1:nplot
    subplot(nrow,ncol,i);
    bar(pmat_nsub(i,:));
    title(makestr('character with ',i,' stroke'));
    xlim(my_xlim);
    ylim(my_ylim);
end

%%
save('nsub_model_june6','pmat_nsub');