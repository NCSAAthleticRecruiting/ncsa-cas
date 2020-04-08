#!groovy

def Boolean testFailure = false
def branch = env.BRANCH_NAME ? env.BRANCH_NAME : params.tag_or_branch
// The git committer for the current sha pointer.
def String committerInfo = ""
// buildUser is the current logged-in Jenkins user.
def buildUser = node { wrap([$class: 'BuildUser']) { env.BUILD_USER } }
def project = env.JOB_NAME.split("/")[1]
def dbName = "${project}_${branch}".replaceAll(/(\.|\/| *)/,'')
// Load common Jenkinsfile functions from the jenkins host
def test = node { load "/var/lib/jenkins/groovy-pipeline/test.groovy" }
def deploy = node { load "/var/lib/jenkins/groovy-pipeline/releaseDeploy.groovy" }

node {
  label("Build Image")
  stage('Checkout and build image artifact') {
    checkout scm
    sh 'git --no-pager show -s --format="%an -- %ae" | head -1 > committerInfo.txt'
    committerInfo = readFile('committerInfo.txt').trim()
    echo "committerInfo: ${committerInfo}"
    sh './script/build.sh'
  }
}

stage("Deploy") {
  // Start over and see if the user wants to promote the build to another env
  // IE staging to preprod OR preprod to production
  // The loop ends after you deploy to production, you select "No Deploy", or "Finish"
  deploy.targetLoop("", env.JOB_NAME, env.BUILD_URL, buildUser, committerInfo, branch)
}
