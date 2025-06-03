pipeline {
    agent any

    environment {
        AWS_DEFAULT_REGION = 'us-east-1'
        ECR_REPO = '123456789012.dkr.ecr.us-east-1.amazonaws.com/my-app'
        IMAGE_TAG = "build-${env.BUILD_NUMBER}"
        EC2_USER = 'ec2-user'
        EC2_HOST = 'ec2-xx-xx-xx-xx.compute-1.amazonaws.com'
        PRIVATE_KEY = credentials('ec2-ssh-key') // Use SSH private key stored in Jenkins credentials
    }

    stages {
        stage('Clone Code') {
            steps {
                git 'https://github.com/youruser/your-repo.git'
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
                sh """
                ssh -o StrictHostKeyChecking=no -i $PRIVATE_KEY $EC2_USER@$EC2_HOST << EOF
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

