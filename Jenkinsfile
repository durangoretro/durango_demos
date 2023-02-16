pipeline {
    agent any

    stages {
        stage('Build') {
            steps {
                sh '''
			make clean pong.bin
                '''
            }
        }
        stage('Deploy') {
            steps {
            	sh '''
			echo 'Deploy...'
            		scp $WORKSPACE/pong.bin jenkins@aquila.emiliollbb.net:/var/www/html/roms/pong.bin
            		scp $WORKSPACE/pong.bin jenkins@piscis.emiliollbb.net:/var/www/html/roms/pong.bin
            		scp $WORKSPACE/pong.bin jenkins@aries.emiliollbb.net:/var/www/roms/pong.bin
            	'''
            }
        }
        
    }
}

