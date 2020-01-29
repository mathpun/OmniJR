% Convert the "scale" of a sub-stroke to the number
% of pixels it actually covered in the longest dimension
function myrange = convert_scale_to_range(vscales,ps)
    invscales = 1./vscales;
    myrange = invscales .* ps.newscale_ss;
end