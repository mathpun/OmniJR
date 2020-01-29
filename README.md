# Omniglot JR

Code and documentation for the OmniglotJR project.

Place all the files under a shared root directory

    .
    ├── BPL                   		# Brenden's BPL code, edited to work with OmniJR
    ├── BPL_fit_hyperparameters 	# Training BPL files, edited for OmniJR
    ├── fileGenerators              # preporcessing files
    ├── processed_data              # preporcessing files
    └── Omniglot_JR_ALL2            # OminJR data (see setup steps)


### Setup

1. Clone/download this repository to a local directory on your computer

2. Download the [OminglotJR dataset from dropbox](https://berkeley.app.box.com/folder/72843943893) (you may need to get permission to access this folder). Place the downloaded `Omniglot_JR_ALL2` folder into the root directory of this repository

The dataset is organized by alphabet / character number 
This corresponds to the [Original omniglot dataset](https://github.com/brendenlake/omniglot)

3. Install Matab on your computer along with the following toolbox dependencies

* Optimization Toolbox
* Statistics Toolbox (before 2015a) OR Statistics and machine learning toolbox
* Image Processing toolbox
* Curve fitting toolbox
* [Lightspeed](https://github.com/tminka/lightspeed) Matlab toolbox (available on GitHub -- its easiest to download the lightspeed folder and place it into your OmniglotJR root directory)

After downloading lightspeed, navigate into the lightspeed directory inside matlab and run
```
install_lightspeed
```

### Preprocess Data

1. From the root directory, run the `downSampleAll.py` script on the OminglotJR data. This code downsmples the OmniglotJR images from 600x600 to 105x105 and stores the resulting image in a new folder.
```
python fileGenerators/downSampleAll.py Omniglot_JR_ALL2
```
This will create a new folder called `Downsampled_Omniglot_JR_ALL2` in your directory

2. Run `fileGenerator.py` on the Downsampled directory. This code parses the OmniglotJR images and transofrms them into a format that the BPL program code can understand.
```
python fileGenerators/fileGenerator.py Downsampled_Omniglot_JR_ALL2
```
This will add requisite data files to procesesed_data folder

3. Convert `JSON` data into `Matlab` files. In matlab, navigate to the `processed_data` directory and run `datasetGenerator.m`
```
cd processed_data
run datasetGenerator.m
```
This will generate a new file `omniJrRaw.mat` in `processed_data`

4. Reformat contents of `omniJrRaw.mat` file to match those used BPL. From the same directory run `cleanse.m`
```
run cleanse.m
```
This will generate `omniJr.mat`. This file serves as input for the next step.

### Setup BPL

1. Set up matlab to have access to all the code by adding `BPL` and `BPL_fit_hyperparameters` paths. Navigate to the the project root directory in matlab and run
```
addpath(genpath(pwd))
addpath(genpath('BPL'))
addpath(genpath('BPL_fit_hyperparameters'))
addpath(genpath('lightspeed'))
```

2. Copy the `omniJr.mat` file generated in the previous section (step 4) into `BPL/data`

3. Inside `BPL/data` run `omniglot_preprocess`. This will take up to 10 minutes. It will generate `data_background_processed.mat` in the same `data` folder.
```
cd BPL/data
run omniglot_preprocess.m
```

### Train BPL - learn hyperparameters

1. Step 1: Creating training/validation split of the background data.

```
    Enter "library_data" directory
    run "split_for_validation.m"
    
    Divides "training" images into two sets: "fit" and "validation"
    
    75% of the data is used in the fit set
    This is divided per character, rather than per alphabet.

    Output:
    "background_fit.mat"
    "background_val.mat"
```


2. Step 2: Learning hyperparameters for observed variables
These variables CAN be computed from the supervised stroke data in a straightforward way.

```
    Learning affine parameters
        enter "learn_affine" directory
        run_fit_affine_model.m

    Output:
    "affine_model_june6.mat"
```

```
    Learning number of strokes model
        enter "learn_number" directory
        run_model_number.m
```

```
    Learning number of sub-strokes model
        enter "learn_nsubstroke" directory
        run_nsubstroke_model.m
```

```
    Learning the stroke position model
        enter "learn_positions" directory
        run "setup_position.m" : creates data set of just positions
            -> "position_fit.mat" and "position_val.mat"
        run_learn_position.m
```

```
    Learning the action primitive model
    enter "learn_primitives" directory
        1) run "setup_clustering.m"  to whiten data for the purposes of clustering
            -> "init_fit.mat" and "init_val.mat"
        2) run "run_clustering.m" to fit a Gaussian Mixture Model(GMMs) with EM,
           then clusters the dataset using that model.
            -> "fit_EM_models_june6.mat"
        3) run "run_model_selection(nval).m" to evaluate each of these GMMs, as well as their
           corresponding Hidden Markov Models, on the marginal likelihood of the validation data.
           "nval" is the number of validation points to use to compare models (use "5" or "10" for fast comparison.)
            -> "primitive_model_june6.mat"
```
This creates a plot showing the training log-probability versus the test log-probability.

Note the number of primitives that the model learns. The output should be something like
```
>> run_model_selection(10)
Best HMM model
  score = -124.506
  primitives = 1250
  regularization = 1


Best GMM model
  score = -123.959
  primitives = 1250
```
For the paper, we used the HMM with 1250 primitives.


3. Step 3: Learning hyperparameters for latent variables
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


** Fitting hyperparemters for BPL code **
https://github.com/brendenlake/BPL


4. Finally, to compile a new prior, run the script `run_make_library.m`.
Before running this, make sure that the file names and the number of primitives in `library_active_set.m` corresponds to the files you just generated.


### Run BPL

Once the hyperparameter training (section 6) is complete - grab the mylib_ominJR.m file from the BPL_fit_hyperparameters  directory and place it in the BPL/ directory. Rename the file to library.mat. This acts as input for demo_fit.m

Now you can run demo_fit and other scripts in the BPL folder and it will use the new primitives learned in the previous steps.

* Run 'plot_primitives.m' to visualize what the extracted primitives look like
