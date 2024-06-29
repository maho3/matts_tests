#PBS -N nbody
#PBS -q batch
#PBS -j oe
#PBS -o ${HOME}/data/jobout/cmass-${PBS_JOBID}-${PBS_JOBNAME}.log
#PBS -l walltime=12:00:00
#PBS -l nodes=1:ppn=32,mem=64gb

# activate borg
module restore myborg
source /data80/mattho/anaconda3/bin/activate
conda activate borg
cd ${RUN_DIR}

# define functions
check_file_existence() {
    local filename=$1
    # check if files exist
    SIM_DIR=${BASE_DIR}/$idx
    if [ -f ${SIM_DIR}/${filename} ]; then
        echo "~~~~~ Skipping lhid=${idx}, not running from scratch ~~~~~"
        return 1
    fi
    return 0
}

# run jobs
OFFSET=$((BATCH_SIZE*PBS_ARRAYID))
for ((i=0; i<BATCH_SIZE; i++))
do
    idx=$((OFFSET + i))
    echo "~~~~~ Running lhid=${idx} ~~~~~"

    # check if dry run
    if [ "$DRY_RUN" -eq 1 ]; then
        echo "~~~~~ Skipping lhid=${idx}, dry run ~~~~~"
        continue
    fi

    if [ "$FROM_SCRATCH" -eq 0 ]; then
        # check if files exist
        check_file_existence rho.npy
        if [ $? -eq 1 ]; then
            continue
        fi
    fi

    # gen ICs
    sh ./quijote_wn/gen_quijote_ic.sh 384 ${idx}

    # run borg
    python -m cmass.nbody.borgpm nbody=${CFG_NBODY} nbody.lhid=${idx}

    # clean up
    rm ./data/quijote/wn/N128/wn_${idx}.dat
done