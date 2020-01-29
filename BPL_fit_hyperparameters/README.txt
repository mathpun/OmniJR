** Fitting hyperparemters for BPL code **
https://github.com/brendenlake/BPL

****
To begin, make sure BPL and this directory (and all sub-directories) are in your Matlab path.

To compile a new prior, run the script:
"run_make_library.m"
****

This requires a lot of pre-computed prior components, which we describe how to learn below.

Step 1: Creating training/validation split of the background data.

    Enter "library_data" directory
    run "split_for_validation.m"
    
    Divides "training" images into two sets: "fit" and "validation"
    
    75% of the data is used in the fit set
    This is divided per character, rather than per alphabet.

    Output:
    "background_fit.mat"
    "background_val.mat"

Step 2: Learning hyperparameters for observed variables
These variables CAN be computed from the supervised stroke data in a straightforward way.

    Learning affine parameters
        enter "learn_affine" directory
        run_fit_affine_model.m

    Learning number of strokes model
        enter "learn_number" directory
        run_model_number.m

    Learning number of sub-strokes model
        enter "learn_nsubstroke" directory
        run_nsubstroke_model.m

    Learning the stroke position model
        enter "learn_positions" directory
        run "setup_position.m" : creates data set of just positions
            -> "position_fit.mat" and "position_val.mat"
        run_learn_position.m

    Learning the action primitive model
        1) run "setup_clustering.m"  to whiten data for the purposes of clustering
            -> "init_fit.mat" and "init_val.mat"
        2) run "run_clustering.m" to fit a Gaussian Mixture Model(GMMs) with EM,
           then clusters the dataset using that model.
            -> "fit_EM_models_june6.mat"
        3) run "run_model_selection(nval).m" to evaluate each of these GMMs, as well as their
           corresponding Hidden Markov Models, on the marginal likelihood of the validation data.
           "nval" is the number of validation points to use to compare models (use "5" or "10" for fast comparison.)
            -> "primitive_model_june6.mat"

        This creates a plot showing the training log-probability versus the test log-probability.

        For the paper, we used the HMM with 1250 primitives.

Step 3: Learning hyperparameters for latent variables
These variables can not be computed from the supervised stroke data in a straightforward way.

    First, I fit a large set of motor programs to images using the hyperparameters computed through Step 2. For the values we haven't learned yet, corresponding to latent variables such as relations and token-level variables, I used the values from the previous NIPS paper. 

    *"Lake, B. M., Salakhutdinov, R., and Tenenbaum, J. B. (2013). One-Shot Learning by Inverting a Compositional Causal Process. Advances in Neural Information Processing Systems 26."*

    This set of hyperparameters is saved as "library_data/previous_library.mat" which needs to be converted to the new library format with the Library.legacylib method.

    The learned motor programs are saved in "library_data/models_for_latent_variables.mat". Also, they are paired so each motor program was refit to a new image of that character for the purpose of computing the token variance parameters.

    Learning the relations model
        enter "learn_relations" directory
        run_learn_relations.m

    Learning the token variance model
        enter "learn_token_variance" directory
        run_token_models.m