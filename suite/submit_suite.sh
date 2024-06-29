
# Configuration
NUM_TOTAL=2000
BATCH_SIZE=10
NUM_JOBS=$((NUM_TOTAL / BATCH_SIZE))

NUM_HOD=1

FROM_SCRATCH=0
DRY_RUN=0

CFG_NBODY=3gpch
SIM=borgpm
RUN_DIR=/home/mattho/git/ltu-cmass
BASE_DIR=/home/mattho/git/ltu-cmass/data/inf_3gpch/$SIM/L3000-N384

VARIABLES="NUM_TOTAL=$NUM_TOTAL,BATCH_SIZE=$BATCH_SIZE,NUM_HOD=$NUM_HOD,FROM_SCRATCH=$FROM_SCRATCH,DRY_RUN=$DRY_RUN,CFG_NBODY=$CFG_NBODY,SIM=$SIM,RUN_DIR=$RUN_DIR,BASE_DIR=$BASE_DIR"

# Move to job directory
JOB_DIR=/home/mattho/git/ltu-cmass/suite

# 1 - nbody
echo "Submitting nbody jobs..."
JOBID=$(qsub -t 0-$((NUM_JOBS-1)) -v $VARIABLES $JOB_DIR/1_nbody.sh )
JOBID="${JOBID%%.*}"
echo "JOBID: ${JOBID}"

# 2 - rho_to_survey
echo "Submitting rho_to_survey jobs..."
JOBID=$(qsub -t 0-$((NUM_JOBS-1)) -v $VARIABLES -W depend=afteranyarray:$JOBID $JOB_DIR/2_rho_to_survey.sh)
JOBID="${JOBID%%.*}"
echo "JOBID: ${JOBID}"

# # non-dependent
# echo "Submitting rho_to_survey jobs..."
# JOBID=$(qsub -t 0-$((NUM_JOBS-1)) -v $VARIABLES $JOB_DIR/2_rho_to_survey.sh)
# JOBID="${JOBID%%.*}"
# echo "JOBID: ${JOBID}"
