#!/bin/bash

# This is a script to write code into a script automatically
subject='rj'
taskname='RTP'
skip = 4
max_dim = 80
max_state = 40
for iState in `seq 2 $skip $max_state`
do
	for iDim in `seq 2 $skip $max_dim`
	do
	time=`python get_runtime.py $iDim $iState`
	let next_dim=$iDim+$skip
	# echo "$time"
		for iFold in `seq 1 5`
		do
			for iPickle in `seq 0 1`
			do
				# echo "$iDim $iState $iFold $iPickle"
				printf "#!/bin/bash\n#SBATCH --job-name=%i_%i_%i_%i\n" $iDim $iState $iFold $iPickle > sbatch_${iDim}_dims_${iState}_states_fold_${iFold}_train-model_${iPickle}.sh
				printf "#SBATCH --output=/project/nicho/caleb/git/intermittent_control_project/code/python_switching_models/out_files/%s_%s/rSLDS_%i_dims_%i_states_fold_%i_%i.out\n" $subject $taskname  $iDim $iState $iFold $iPickle >> sbatch_${iDim}_dims_${iState}_states_fold_${iFold}_train-model_${iPickle}.sh
				printf "#SBATCH --output=/project/nicho/caleb/git/intermittent_control_project/code/python_switching_models/error_files/%s_%s/rSLDS_%i_dims_%i_states_fold_%i_%i.err\n" $subject $taskname  $iDim $iState $iFold $iPickle >> sbatch_${iDim}_dims_${iState}_states_fold_${iFold}_train-model_${iPickle}.sh
				printf "#SBATCH --time=%i:00:00\n" $time >> sbatch_${iDim}_dims_${iState}_states_fold_${iFold}_train-model_${iPickle}.sh
				printf "#SBATCH --mem-per-cpu=48G\n#SBATCH --account=pi-nicho\n#SBATCH --partition=caslake\n" >> sbatch_${iDim}_dims_${iState}_states_fold_${iFold}_train-model_${iPickle}.sh
				printf "module load python/anaconda-2021.05\nsource activate /project/nicho/caleb/git/intermittent_control_project/data/ssm_midway_python_environment/\n" >> sbatch_${iDim}_dims_${iState}_states_fold_${iFold}_train-model_${iPickle}.sh
				printf "python /project/nicho/caleb/git/intermittent_control_project/code/python_switching_models/run_param_search.py %i %i %i %s %s %i\n" $iDim $iFold $iState $subject $taskname $iPickle>> sbatch_${iDim}_dims_${iState}_states_fold_${iFold}_train-model_${iPickle}.sh
				if [[ $iPickle -eq 1 ]];
				then
					printf "sbatch --dependency=afterany:\$SLURM_JOB_ID sbatch_${iDim}_dims_${iState}_states_fold_${iFold}_train-model_0.sh" >> sbatch_${iDim}_dims_${iState}_states_fold_${iFold}_train-model_${iPickle}.sh				
				elif [[ $iPickle -eq 0 ]]
				then
					if [[ $iDim < $max_dim ]]
					then
						printf "sbatch --dependency=afterany:\$SLURM_JOB_ID sbatch_%i_dims_${iState}_states_fold_${iFold}_train-model_1.sh" $next_dim>> sbatch_${iDim}_dims_${iState}_states_fold_${iFold}_train-model_${iPickle}.sh				
					fi
				fi
			done
		done
	done
done