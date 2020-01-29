%
% Pre-process for learning position model
%
load('background_fit','D');
[data_start,data_id] = process_for_position(D.drawings);
save('position_fit','data_*');

%
% Pre-process the validation set
%
load('background_val','D');
[data_start,data_id] = process_for_position(D.drawings);
save('position_val','data_*');