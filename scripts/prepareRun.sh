def call() {
    echo "pipelineUtils library loaded"
}

def prepareRun() {
    def runId = UUID.randomUUID().toString()
    echo "Preparation stage: RunID=${runId}"
    echo "Build Number: ${env.BUILD_NUMBER}"
    writeFile file: "prep.txt", text: "RunID=${runId}\n"
    stash includes: "prep.txt", name: "prepData"
    return runId
}

def runJob(String jobName) {
    unstash "prepData"
    sh """
      echo "${jobName} running with \$(cat prep.txt)" > ${jobName}.log
    """
    stash includes: "${jobName}.log", name: "${jobName}Data"
    echo "${jobName} complete"
}



def integrateJobs(List jobNames) {
    jobNames.each { unstash "${it}Data" }
    sh "cat ${jobNames.collect { it + '.log' }.join(' ')} > combined.txt"
    stash includes: "combined.txt", name: "integrationData"
    echo "Integration complete"
}

def deploy() {
    unstash "integrationData"
    echo "Deploy step using combined results:"
    sh "cat combined.txt"
}
