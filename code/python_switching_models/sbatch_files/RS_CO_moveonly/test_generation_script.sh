#!/bin/bash

# This is a test script to see if I can write code into a script
subject='RS'
taskname='CO'

for iState in `seq 2 2 40`
do
	for iFold in `seq 1 10`
	do
		echo "$iState $iFold"
		printf "#!/bin/bash\n#SBATCH --job-name=%i_%i\n#SBATCH --array=2-80:5\n" $iState $iFold > test_script_file_state_${iState}_fold_${iFold}.sh
		printf "#SBATCH --output=/dali/nicho/caleb/git/intermittent_control_project/code/python_switching_models/out_files/%s_%s/rSLDS_%s_%i.out" $subject $taskname  "%a" $iState >> test_script_file_state_${iState}_fold_${iFold}.sh
		printf "#SBATCH --output=/dali/nicho/caleb/git/intermittent_control_project/code/python_switching_models/out_files/%s_%s/rSLDS_%s_%i.out" $subject $taskname  "%a" $iState >> test_script_file_state_${iState}_fold_${iFold}.sh
	done
done