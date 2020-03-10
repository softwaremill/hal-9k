#!/usr/bin/env groovy

properties([
  buildDiscarder(
    logRotator(artifactDaysToKeepStr: '', artifactNumToKeepStr: '', daysToKeepStr: '', numToKeepStr: '10')
  ),
  disableConcurrentBuilds(),
  [$class: 'GithubProjectProperty', displayName: 'Janusz the Bot', projectUrlStr: 'https://github.com/softwaremill/janusz-the-bot/'],
  overrideIndexTriggers(false),
  pipelineTriggers([
    githubPush(),
    pollSCM('H/15 * * * *')
  ])
])

String getGitHash() {
  return sh(script: 'git describe --always --tags --abbrev=7', returnStdout: true)?.trim()
}

serviceAccount = "sml-internal-jenkins"

podTemplate(yaml: """
apiVersion: v1
kind: Pod
spec:
  serviceAccountName: ${serviceAccount}
  securityContext:
    runAsUser: 0
  volumes:
    - name: cache
      emptyDir: {}
    - name: dockersock
      hostPath:
          path: /var/run/docker.sock
  containers:
  - name: docker
    resources:
    image: docker:stable
    command:
    - cat
    tty: true
    volumeMounts:
      - name: dockersock
        mountPath: "/var/run/docker.sock"
  - name: helm
    image: lachlanevenson/k8s-helm:v3.0.0
    command:
    - cat
    tty: true
  - name: node
    image: node:8.16.2-alpine3.10
    command:
    - cat
    tty: true
"""
) {
  node(POD_LABEL) {
    stage('Checkout') {
      checkout scm
      dockerTag = "CD-${currentBuild.number}-${getGitHash()}"
    }
    container('node') {
      stage('Compile') {
        sh 'npm install --global coffeescript'
        sh 'coffee -c -p scripts > /dev/null'
      }
    }
    container('docker') {
      stage('Build docker image') {
        sh "docker build -t softwaremill/janusz-the-bot:${dockerTag} ."
      }
      stage('Publish docker image') {
        withCredentials([usernamePassword(credentialsId: 'docker-hub-credentials', passwordVariable: 'DOCKER_PASSWORD', usernameVariable: 'DOCKER_USERNAME')]) {
          sh """
              docker login -u \${DOCKER_USERNAME} -p \${DOCKER_PASSWORD}
              docker push softwaremill/janusz-the-bot:${dockerTag}
            """
        }
      }
    }
    container('helm') {
      stage('Deploy') {
        if (env.BRANCH_NAME == 'master') {
          withCredentials([file(credentialsId: 'janusz-secrets', variable: 'secrets')]) {
            sh """
              helm dependency update helm/janusz-the-bot/
              helm upgrade --install --atomic\
                --set image.tag=${dockerTag}\
                -f ${env.secrets}\
                janusz-the-bot ./helm/janusz-the-bot
             """
          }
        } else {
          echo 'Not a master branch, skipping deploy'
        }
      }
    }
  }
}
