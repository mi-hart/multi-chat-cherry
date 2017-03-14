import groovy.json.JsonSlurperClassic

node('docker-host') {
    stage('Checkout') {
        checkout scm
    }
    try {
        def containersToBuild = []
        stage('Prepare Docker containers') {
            sh 'python src/scripts/docker_build.py'
            def ContainerFile = readFile('docker/build_order.json')
            def ContainerMap = mapToList(new JsonSlurperClassic().parseText(ContainerFile))
            for (architecture in ContainerMap) {
                def archName = architecture.getKey()
                def archData = architecture.getValue()
                echo "Running builds for ${archName}"
                stage(archName) {
                    for (image in archData) {
                        echo "Building ${image} from ${archName}"
                        def buildName = "deforce/lc-${archName}-${image}"
                        buildDockerImage(archName, image, buildName)
                        if (image.equals('testing')) {
                            containersToBuild.add(buildName)
                        }
                    }
                }
            }
        }
        stage('Build') {
            def container = containersToBuild[0]
            stage(container) {
                echo "Running Build for ${container}"
                def docker_image = docker.image(container)
                docker_image.inside {
                    stage('Themes') {
                        buildThemes()
                    }
                    stage('Configuration') {
                        sh '/bin/sh src/jenkins/prep_config.sh'
                    }
                }
            }
        }
        stage('Testing') {
            for (container in containersToBuild) {
                stage(container) {
                    echo "Running Build for ${container}"
                    def docker_image = docker.image(container)
                    docker_image.inside {
                        stage('Run Chat') {
                            sh '/bin/sh src/jenkins/run_chat.sh'
                            try {
                                sh 'ps aux | grep -v grep | grep main.py'
                            }
                            finally {
                                sh 'cat chat.log'
                            }
                        }
                    }
                }
            }
        }
    }
    finally {
        stage('Cleanup') {
            sh 'docker rmi -f $(docker images | grep \'^<none>\' | awk \'{print \$3}\') || true'
            // deleteDir()
        }
    }
}

def buildThemes() {
    // Creates themes.json
    sh 'python src/scripts/get_themes.py'
    def ThemesJson = readFile('themes.json')
    def ThemesList = new JsonSlurperClassic().parseText(ThemesJson)
    echo "${ThemesList}"
    for (def Theme : ThemesList) {
        sh "/bin/sh src/jenkins/test_theme.sh ${Theme}"
        sh "/bin/sh src/jenkins/build_theme.sh ${Theme}"
    }
}

def buildDockerImage(archName, image, buildName) {
    sh "docker build -t ${buildName} -f docker/dockerfiles/${archName}/${image}/Dockerfile ."
}

@NonCPS
def mapToList(depmap) {
    def dlist = []
    for (def entry2 in depmap) {
        dlist.add(new java.util.AbstractMap.SimpleImmutableEntry(entry2.key, entry2.value))
    }
    dlist
}