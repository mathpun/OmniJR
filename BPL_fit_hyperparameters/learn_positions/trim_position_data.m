%
% Remove data the fall outside the bounding box
% 
% xlim: [1 x 2]
% ylim: [1 x 2[
function [data,rmv] = trim_position_data(data,xlim,ylim)

    xdata = data(:,1);
    ydata = data(:,2);
    
    xrmv = xdata < xlim(1) | xdata > xlim(2);
    yrmv = ydata < ylim(1) | ydata > ylim(2);
    rmv = xrmv | yrmv;
    
    data(rmv,:) = [];
end