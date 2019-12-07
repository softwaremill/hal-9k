#!/usr/bin/env groovy

properties([
  buildDiscarder(
    logRotator(artifactDaysToKeepStr: '', artifactNumToKeepStr: '', daysToKeepStr: '', numToKeepStr: '10')
  ),
  disableConcurrentBuilds(),
  [$class: 'GithubProjectProperty', displayName: 'Bob the Bot', projectUrlStr: 'https://github.com/softwaremill/janusz-the-bot/'],
  overrideIndexTriggers(false),
  pipelineTriggers([
    githubPush(),
    pollSCM('H/15 * * * *')
  ])
])

String getDockerTag() {
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
"""
) {
  node(POD_LABEL) {
    try {
      stage('Checkout') {
        checkout scm
        dockerTag = "CD-${currentBuild.number}-${getDockerTag()}"
      }
      container('docker') {
        stage('Build docker image') {
          sh "docker build -t softwaremill/janusz-the-bot:${dockerTag} ."
        }
      }
      if (env.BRANCH_NAME == 'master') {
        container('docker') {
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
            withCredentials([
              string(credentialsId: 'BOB_THE_BOT_SLACK_TOKEN', variable: 'SLACK_TOKEN'),
              string(credentialsId: 'BOB_THE_BOT_SLACK_VERIFICATION_TOKEN', variable: 'SLACK_VERIFICATION_TOKEN'),
              string(credentialsId: 'BOB_THE_BOT_MYSQL_USER', variable: 'MYSQL_USER'),
              string(credentialsId: 'BOB_THE_BOT_MYSQL_PASSWORD', variable: 'MYSQL_PASSWORD'),
              string(credentialsId: 'BOB_THE_BOT_MYSQL_ROOT_PASSWORD', variable: 'MYSQL_ROOT_PASSWORD'),
            ]) {
              sh "helm version"
              sh "helm env"
              sh "helm dependency update helm/janusz-the-bot/"
              sh "helm list -a"
              sh """
                helm upgrade --install --atomic\
                  --set image.tag=$dockerTag,\
                  --set slack.token=${env.SLACK_TOKEN},\
                  --set slack.verificationToken=${env.SLACK_VERIFICATION_TOKEN},\
                  --set mysql.mysqlRootPassword=${env.MYSQL_ROOT_PASSWORD},\
                  --set mysql.mysqlUser=${env.MYSQL_USER},\
                  --set mysql.mysqlPassword=${env.MYSQL_PASSWORD}\
                  janusz-the-bot ./helm/janusz-the-bot
                """
            }
          }
        }
      }
    } catch (e) {
      currentBuild.result = 'FAILED'
      throw e
    }
  }
}
