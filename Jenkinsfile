void setBuildStatus(String message, String state, String repo_url) {
  step([
      $class: "GitHubCommitStatusSetter",
      reposSource: [$class: "ManuallyEnteredRepositorySource", url: repo_url],
      contextSource: [$class: "ManuallyEnteredCommitContextSource", context: "ci/jenkins/build-status"],
      errorHandlers: [[$class: "ChangingBuildStatusErrorHandler", result: "UNSTABLE"]],
      statusResultSource: [ $class: "ConditionalStatusResultSource", results: [[$class: "AnyBuildResult", message: message, state: state]] ]
  ]);
}

pipeline {
    agent any

    stages {
        stage('Placeholder') {
            steps {
                echo 'No Jenkins tasks configured. Pipeline reserved for future use.'
            }
        }
    }
    post {
        always {
            setBuildStatus("Build succeeded", "SUCCESS", "${GIT_URL}");
        }
    }
}
