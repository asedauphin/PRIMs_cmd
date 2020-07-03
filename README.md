# PRIMs_cmd

Command line version of the PRIMs cognitive architecture developed by Dr Niels Taatgen from the ACT-R architecture by Dr John Anderson.
I removed all the graphics to run the model systematically using the batch mode.

This version of the architecture includes an optional autonomous goal selection function enabling the agent to select the next goal it is going to perform after each trial.

## Goal selection

The main modifications are done in the Task.swift and the BatchRun.swift files.

## How to run it

The code is written in Swift 4.0.

To run PRIMs from your terminal write: 

directory='/???' #directory in which the file is installed 
prims='/PRIMs_cmd/Build/Products/Debug/PRIMs_cmd' #path towards the executable application
bprims = '/???/bprimsfile.bprims' #path towards the bprims file PRIMs has to execute
output='/???' #path of the directory in which the output file will be written by PRIMs

index = 0
maxTrials= 10000 #nupmber of trials per simulation
threshold = 20 #minimal number of trials from which the progress driven goal selection function was executed 
distance = 80 #d parameter in the progress driven condition

- "$directory$prims" -c "$bprims" "$output" #for standard batchfile execution
- "$directory$prims" -r "$bprims" $index $maxTrials "$output" #for random goal selection after each trial
- "$directory$prims" -a "$bprims" $index $maxTrials $threshold $distance "$output" #for a progress driven goal selection



To execute 100 simulations in the random and progress driven conditions you can use: 

- for index in {0..100} ; do "$directory$prims" -r "$bprims" $index $maxTrials "$output" ; done #for random goal selection after each trial
- for index in {0..100} ; do "$directory$prims" -a "$bprims" $index $maxTrials $threshold $distance "$output" ; done #for a progress driven goal selection


## Contact

This version was developped until June 2020. You can email me at: asedauphin@gmail.com if needed. 
