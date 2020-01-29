% Create the library, which is the prior distribution on MotorPrograms

% Load in pre-computed model pieces
ps = defaultps_clustering;
as = library_active_set();
lib = Library(as);

% Remove rare primitives
tormv = lib.shape.freq < ps.minsize_table;
keep = ~tormv;
lib.restrict_library(keep);

save('mylib_omniJR','lib');