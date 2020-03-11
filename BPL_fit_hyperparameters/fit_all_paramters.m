% Script to train BPL_fit hyperparameters
% Run this from the BPL_fit_hyperparameters folder

% 1. Create train/validation script
cd library_data
split_for_validation

% 2. Learning affine parameters
cd ../learn_affine
run_fit_affine_model

% 3. Learning number of strokes model
cd ../learn_number
run_model_number

% 4. Learning number of sub-strokes model
cd ../learn_nsubstroke
run_nsubstroke_model

% 5. Learning the stroke position model
cd ../learn_positions
setup_position
run_learn_position

% 6. Learning the action primitive model
cd ../learn_primitives
setup_clustering
run_clustering
% (3) run "run_model_selection(nval).m" to evaluate each of these GMMs, as well as their
% corresponding Hidden Markov Models, on the marginal likelihood of the validation data.
% "nval" is the number of validation points to use to compare models (use "5" or "10" for fast comparison.)
run_model_selection(5)
% This creates a plot showing the training log-probability versus the test log-probability.


% 7. 4. Finally, to compile a new prior, run the script `run_make_library.m`.
% Before running this, make sure that the file names and the number of primitives in
% `library_active_set.m` corresponds to the files you just generated.
cd ../
run_make_library





