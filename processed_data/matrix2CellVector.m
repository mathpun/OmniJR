%x is a m x n x ... matrix (with potentially leading ones) then
%y is a m x 1 cell array where each element is n x ...
function y = matrix2CellVector(x)
    %disp(class(x));
    if ~iscell(x)
        xSize = size(x);
        firstDim = xSize(1);
        y = mat2cell(x, ones([1, firstDim]));
        for i = 1:length(y)
            s = size(y{i});
            if length(s) > 2
                %disp("NOO");
                y{i} = reshape(y{i}, s(2:length(s)));
            end
        end
    else
        y = x;
    end
    %disp(class(y));
end