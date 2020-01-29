%
% Learn the number model
%
load('background_fit', 'D');
drawings = D.get('drawings');
pkappa = fit_number_model(drawings);
save('number_model_june6','pkappa');