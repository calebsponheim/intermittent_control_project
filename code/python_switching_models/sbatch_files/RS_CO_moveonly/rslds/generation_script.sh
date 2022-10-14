#!/bin/bash

# This is a script to write code into a script automatically
subject='rs'
taskname='CO'

for iState in `seq 2 2 40`
do
	for iFold in `seq 1 5`
	do
		for iPickle in `seq 0 1`
		do
			echo "$iState $iFold $iPickle"
			printf "#!/bin/bash\n#SBATCH --job-name=%i_%i\n#SBATCH --array=2-80:2\n" $iState $iFold > sbatch_dims_2-80_state_${iState}_fold_${iFold}_train-model_${iPickle}.sh
			printf "#SBATCH --output=/project/nicho/caleb/git/intermittent_control_project/code/python_switching_models/out_files/%s_%s/rSLDS_%s_%i.out\n" $subject $taskname  "%a" $iState >> sbatch_dims_2-80_state_${iState}_fold_${iFold}_train-model_${iPickle}.sh
			printf "#SBATCH --output=/project/nicho/caleb/git/intermittent_control_project/code/python_switching_models/error_files/%s_%s/rSLDS_%s_%i.err\n" $subject $taskname  "%a" $iState >> sbatch_dims_2-80_state_${iState}_fold_${iFold}_train-model_${iPickle}.sh
			printf "#SBATCH --time=36:00:00\n#SBATCH --mem-per-cpu=48G\n#SBATCH --account=pi-nicho\n#SBATCH --partition=caslake\n" >> sbatch_dims_2-80_state_${iState}_fold_${iFold}_train-model_${iPickle}.sh
			printf "module load python/anaconda-2021.05\nsource activate /project/nicho/caleb/git/intermittent_control_project/data/ssm_midway_python_environment/\n" >> sbatch_dims_2-80_state_${iState}_fold_${iFold}_train-model_${iPickle}.sh
			printf "python /project/nicho/caleb/git/intermittent_control_project/code/python_switching_models/run_param_search.py \$SLURM_ARRAY_TASK_ID %i %i %s %s %i" $iFold $iState $subject $taskname $iPickle>> sbatch_dims_2-80_state_${iState}_fold_${iFold}_train-model_${iPickle}.sh
		done
	done
done