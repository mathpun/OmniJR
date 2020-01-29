%
% Fit the affine model
%
% load('background_fit','D');
load('omniJr_split/background_fit', 'D');
nested_images = D.get('images');
affine = fit_affine_params(nested_images);
save('affine_model_june6','affine');