pipeline { 
    agent any

    environment {
        AWS_DEFAULT_REGION = 'us-east-1'
        ECR_REPO = '194719009061.dkr.ecr.us-east-1.amazonaws.com/my-app'
        IMAGE_TAG = "build-${env.BUILD_NUMBER}"
        EC2_USER = 'ec2-user'
        EC2_HOST = 'ec2-54-89-165-214.compute-1.amazonaws.com'   // Updated to real hostname
        PRIVATE_KEY_PATH = 'C:/keys/Electricaa-key.pem' 
    }

    stages {
        stage('Fix PEM Permissions') {
            steps {
                powershell '''
                $keyPath = "C:\\keys\\Electricaa-key.pem"

                # Remove inherited permissions
                icacls $keyPath /inheritance:r

                # Grant read permission to current user
                $user = $env:USERNAME
                icacls $keyPath /grant:r "$user:R"

                # Remove permissions for Users and Authenticated Users groups
                icacls $keyPath /remove "Users"
                icacls $keyPath /remove "Authenticated Users"
                '''
            }
        }

        stage('Clone Code') {
            steps {
                git branch: 'main', url: 'https://github.com/Yemmmyc/Electricaa.git'
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

                    for /f "tokens=* usebackq" %%p in (`aws ecr get-login-password --region %AWS_DEFAULT_REGION%`) do (
                        echo %%p | docker login --username AWS --password-stdin %ECR_REPO%
                    )
                    docker push %ECR_REPO%:%IMAGE_TAG%
                    """
                }
            }
        }

        stage('Deploy to EC2') {
            steps {
                bat """
                ssh -i %PRIVATE_KEY_PATH% -o StrictHostKeyChecking=no %EC2_USER%@%EC2_HOST% ^
                "aws ecr get-login-password --region %AWS_DEFAULT_REGION% | docker login --username AWS --password-stdin %ECR_REPO% && ^
                docker pull %ECR_REPO%:%IMAGE_TAG% && ^
                docker stop my-app || rem && ^
                docker rm my-app || rem && ^
                docker run -d --name my-app -p 80:80 %ECR_REPO%:%IMAGE_TAG%"
                """
            }
        }
    }
}



