pipeline {
    agent any

    environment {
        AWS_DEFAULT_REGION = 'us-east-1'
        ECR_REPO = '194719009061.dkr.ecr.us-east-1.amazonaws.com/my-app'
        IMAGE_TAG = "build-${env.BUILD_NUMBER}"
        EC2_USER = 'ec2-user'
        EC2_HOST = 'ec2-54-89-165-214.compute-1.amazonaws.com'
        PRIVATE_KEY_PATH = 'C:/keys/Electricaa-key.pem'
    }

    stages {
        stage('Clean Workspace') {
            steps {
                // Delete Electricaa folder if it exists to avoid git clone errors
                bat 'rmdir /s /q Electricaa || echo Electricaa folder not present, continuing'
            }
        }

        stage('Clone Code') {
            steps {
                bat 'git clone -b main https://github.com/Yemmmyc/Electricaa.git'
            }
        }

        stage('Build Docker Image') {
            steps {
                bat """
                docker build -t my-app:%IMAGE_TAG% .
                docker tag my-app:%IMAGE_TAG% %ECR_REPO%:%IMAGE_TAG%
                """
            }
        }

        stage('Push to ECR') {
            steps {
                withCredentials([usernamePassword(credentialsId: 'aws-credentials', usernameVariable: 'AWS_ACCESS_KEY_ID', passwordVariable: 'AWS_SECRET_ACCESS_KEY')]) {
                    bat """
                    aws configure set aws_access_key_id %AWS_ACCESS_KEY_ID%
                    aws configure set aws_secret_access_key %AWS_SECRET_ACCESS_KEY%
                    aws configure set default.region %AWS_DEFAULT_REGION%

                    aws ecr get-login-password --region %AWS_DEFAULT_REGION% | docker login --username AWS --password-stdin %ECR_REPO%
                    docker push %ECR_REPO%:%IMAGE_TAG%
                    """
                }
            }
        }

        stage('Deploy to EC2') {
            steps {
                bat """
                powershell -Command "icacls '%PRIVATE_KEY_PATH%' /reset"
                powershell -Command "icacls '%PRIVATE_KEY_PATH%' /inheritance:r"
                powershell -Command "icacls '%PRIVATE_KEY_PATH%' /grant:r '%USERNAME%:R'"

                ssh -i %PRIVATE_KEY_PATH% -o StrictHostKeyChecking=no %EC2_USER%@%EC2_HOST% ^
                "aws ecr get-login-password --region %AWS_DEFAULT_REGION% | docker login --username AWS --password-stdin %ECR_REPO% && ^
                docker pull %ECR_REPO%:%IMAGE_TAG% && ^
                docker stop my-app || exit 0 && ^
                docker rm my-app || exit 0 && ^
                docker run -d --name my-app -p 80:80 %ECR_REPO%:%IMAGE_TAG%"
                """
            }
        }
    }
}


