%
% Preprocessing steps:
%  1) Interpolate raw data 
% Then break the strokes in to sub-strokes.
%
% Required files (https://github.com/brendenlake/omniglot/tree/master/matlab):
%    data_background.mat
%    data_evaluation.mat 
% 
% Output
%    data_background_processed.mat
%    data_evaluation_processed.mat
%
function omniglot_preprocess
    
    load('omniJr','drawings','images','names','timing');
    
    % Parameters
    ps = defaultps_preprocess;
    tint = ps.tint;

    % Augment with time as third dimension
    drawings_aug = drawings;
    nalpha = length(drawings);
    for a=1:nalpha
        nchar = length(drawings{a});
        for c=1:nchar
            nrep = length(drawings{a}{c});
            for r=1:nrep
                ns = length(drawings{a}{c}{r});
                for s=1:ns
                   drawings_aug{a}{c}{r}{s}(:,3) = timing{a}{c}{r}{s}; 
                end
            end
        end
    end
    
    disp("Converting to uniform time");
    % Convert to uniform time
    ufunc = @(stk) uniform_time_lerp(stk(:,1:2),stk(:,3),tint);
    udrawings = apply_to_nested(drawings_aug,ufunc);

    disp("Partitioning into sub strokes");
    % Partition into sub-strokes
    pfunc = @(stk) partition_strokes(stk,ps.dthresh,ps.max_sequence);
    pdrawings = apply_to_nested(udrawings,pfunc);
    
    disp("Converting to uniform space");
    % Convert to uniform in space
    sfunc = @(stk) uniform_space_lerp(stk,ps.space_int);
    pdrawings = apply_to_nested(pdrawings,sfunc);
    
    disp("Creating dataset");
    % Create dataset
    D = Dataset(pdrawings,images,names);
    
    save('data_background_processed','D');
end