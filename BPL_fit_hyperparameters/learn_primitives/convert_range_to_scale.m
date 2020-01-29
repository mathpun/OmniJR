% Inverse of this function
% ----
% Convert the "scale" of a sub-stroke to the number
% of pixels it actually covered in the longest dimension
%
function vscales = convert_range_to_scale(vranges,ps)
    invscales = vranges ./ ps.newscale_ss;
    vscales = 1./invscales;
end