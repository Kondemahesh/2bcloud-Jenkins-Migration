#!/bin/bash
set -e

# Global file names
PREP_FILE="prep.txt"
COMBINED_FILE="combined.txt"

# Prepare step
prepareRun() {
    RUN_ID=$(uuidgen)
    echo "Preparation stage: RunID=${RUN_ID}"
    echo "Build Number: ${BUILD_NUMBER:-local}"
    echo "RunID=${RUN_ID}" > "$PREP_FILE"
}

# Run a job with job name argument
runJob() {
    local jobName=$1
    if [ ! -f "$PREP_FILE" ]; then
        echo "Error: $PREP_FILE not found. Run prepareRun first."
        exit 1
    fi
    echo "${jobName} running with $(cat $PREP_FILE)" > "${jobName}.log"
    echo "${jobName} complete"
}

# Integrate multiple job logs
integrateJobs() {
    local jobNames=("$@")
    cat "${jobNames[@]/%/.log}" > "$COMBINED_FILE"
    echo "Integration complete: $COMBINED_FILE created"
}

# Deploy step
deploy() {
    if [ ! -f "$COMBINED_FILE" ]; then
        echo "Error: $COMBINED_FILE not found. Run integrateJobs first."
        exit 1
    fi
    echo "Deploy step using combined results:"
    cat "$COMBINED_FILE"
}
