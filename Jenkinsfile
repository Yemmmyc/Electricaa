pipeline {
    agent any

    environment {
        AWS_DEFAULT_REGION = 'us-east-1'
        ECR_REPO = '123456789012.dkr.ecr.us-east-1.amazonaws.com/my-app'
        IMAGE_TAG = "build-${env.BUILD_NUMBER}"
        EC2_USER = 'ec2-user'
        EC2_HOST = 'ec2-xx-xx-xx-xx.compute-1.amazonaws.com'
    }

    stages {
        stage('Clone Code') {
            steps {
                git branch: 'main', url: 'https://github.com/Yemmmyc/Electricaa.git'
            }
        }

        stage('Build Docker Image') {
            steps {
                sh """
                docker build -t my-app:$IMAGE_TAG .
                docker tag my-app:$IMAGE_TAG $ECR_REPO:$IMAGE_TAG
                """
            }
        }

        stage('Push to ECR') {
            steps {
                sh """
                aws ecr get-login-password --region $AWS_DEFAULT_REGION | docker login --username AWS --password-stdin $ECR_REPO
                docker push $ECR_REPO:$IMAGE_TAG
                """
            }
        }

        stage('Deploy to EC2') {
            steps {
                sshagent(['ec2-ssh-key']) {
                    sh """
                    ssh -o StrictHostKeyChecking=no $EC2_USER@$EC2_HOST << EOF
                        aws ecr get-login-password --region $AWS_DEFAULT_REGION | docker login --username AWS --password-stdin $ECR_REPO
                        docker pull $ECR_REPO:$IMAGE_TAG
                        docker stop my-app || true
                        docker rm my-app || true
                        docker run -d --name my-app -p 80:80 $ECR_REPO:$IMAGE_TAG
                    EOF
                    """
                }
            }
        }
    }
}
