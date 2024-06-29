#PBS -N rho_to_survey
#PBS -q batch
#PBS -j oe
#PBS -o ${HOME}/data/jobout/cmass-${PBS_JOBID}-${PBS_JOBNAME}.log
#PBS -l walltime=12:00:00
#PBS -l nodes=1:ppn=32,mem=64gb

# activate cmass
module restore cmass
module load cuda/11.8
source /data80/mattho/anaconda3/bin/activate
conda activate cmass
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

    SKIP=0

    # ~~~~~ rho_to_halo ~~~~~
    if [ "$FROM_SCRATCH" -eq 0 ]; then
        check_file_existence halo_mass.npy
        SKIP=$?
    fi
    if [ "$SKIP" -eq 0 ]; then
        python -m cmass.bias.rho_to_halo sim=${SIM} nbody=${CFG_NBODY} nbody.lhid=${idx}
    fi
    

    # ~~~~~ remap_cuboid ~~~~~
    if [ "$FROM_SCRATCH" -eq 0 ]; then
        check_file_existence halo_cuboid_pos.npy
        SKIP=$?
    fi
    if [ "$SKIP" -eq 0 ]; then
        python -m cmass.survey.remap_cuboid sim=${SIM} nbody=${CFG_NBODY} nbody.lhid=${idx}
    fi

    # ~~~~~ apply_hod ~~~~~
    for ((j=0; j<NUM_HOD; j++))
    do
        if [ "$FROM_SCRATCH" -eq 0 ]; then
            check_file_existence hod/hod${j}_pos.npy
            SKIP=$?
        fi
        if [ "$SKIP" -eq 0 ]; then
            python -m cmass.bias.apply_hod sim=${SIM} nbody=${CFG_NBODY} nbody.lhid=${idx} bias.hod.seed=${j}
        fi
    done

    # ~~~~~ ngc_selection ~~~~~
    for ((j=0; j<NUM_HOD; j++))
    do
        if [ "$FROM_SCRATCH" -eq 0 ]; then
            check_file_existence obs/rdz${j}.npy
            SKIP=$?
        fi
        if [ "$SKIP" -eq 0 ]; then
            python -m cmass.survey.ngc_selection sim=${SIM} nbody=${CFG_NBODY} nbody.lhid=${idx} bias.hod.seed=${j}
        fi
    done

    # ~~~~~ Pk_nbkit ~~~~~
    for ((j=0; j<NUM_HOD; j++))
    do
        if [ "$FROM_SCRATCH" -eq 0 ]; then
            check_file_existence Pk/Pk${j}.npz
            SKIP=$?
        fi
        if [ "$SKIP" -eq 0 ]; then
            python -m cmass.summaries.Pk_nbkit sim=${SIM} nbody=${CFG_NBODY} nbody.lhid=${idx} bias.hod.seed=${j}
        fi
    done

    echo "~~~~~ Finished lhid=${idx} ~~~~~"
done
