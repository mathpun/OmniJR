% Fit the token-level variance parameters
% given a previous set of model fits.
load('models_for_latent_variables','list_fit');   
n = numel(list_fit);
matches = cell(n,1);
for i=1:n
    list_fit{i}.M_refit.setSampleType(1);
    matches{i} = {list_fit{i}.M_base; list_fit{i}.M_refit};
end

%%
TM = TokenModel(matches);
sigma_shape = TM.compute_shape_var_lb;
sigma_invscale = TM.compute_scale_var_lb;
sigma_seval = TM.compute_seval_var_lb;


%%
save('tokenvar_model_june6','sigma_shape','sigma_invscale','sigma_seval');