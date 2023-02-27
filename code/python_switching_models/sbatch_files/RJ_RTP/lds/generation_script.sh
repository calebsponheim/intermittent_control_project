#!/bin/bash

# This is a script to write code into a script automatically
subject='rj'
taskname='RTP'

for iFold in `seq 1 5`
do
	echo "$iFold"
	printf "#!/bin/bash\n#SBATCH --job-name=f_%i\n#SBATCH --array=2-80\n" $iFold > sbatch_dims_2-80_fold_${iFold}.sh
	printf "#SBATCH --output=/project/nicho/caleb/git/intermittent_control_project/code/python_switching_models/out_files/%s_%s/LDS_%s_%s.out\n" $subject $taskname  "%a" $iFold >> sbatch_dims_2-80_fold_${iFold}.sh
	printf "#SBATCH --output=/project/nicho/caleb/git/intermittent_control_project/code/python_switching_models/error_files/%s_%s/LDS_%s_%s.err\n" $subject $taskname  "%a"  $iFold >> sbatch_dims_2-80_fold_${iFold}.sh
	printf "#SBATCH --time=1:00:00\n#SBATCH --mem-per-cpu=48G\n#SBATCH --account=pi-nicho\n#SBATCH --partition=caslake\n" >> sbatch_dims_2-80_fold_${iFold}.sh
	printf "module load python/anaconda-2021.05\nsource activate /project/nicho/caleb/git/intermittent_control_project/data/ssm_midway_python_environment/\n" >> sbatch_dims_2-80_fold_${iFold}.sh
	printf "python /project/nicho/caleb/git/intermittent_control_project/code/python_switching_models/LDS_param_search.py %i %s %s \$SLURM_ARRAY_TASK_ID " $iFold $taskname $subject >> sbatch_dims_2-80_fold_${iFold}.sh
done