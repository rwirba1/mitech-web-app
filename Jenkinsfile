pipeline {
    agent any

    environment {
        AWS_DEFAULT_REGION = 'us-east-1' // Replace with your region
        AWS_ACCESS_KEY_ID = credentials('') // Store your AWS access key as a Jenkins secret
        AWS_SECRET_ACCESS_KEY = credentials('') // Store your AWS secret key as a Jenkins secret
    }

    stages {
        stage('Checkout code') {
            steps {
                // Clone your repository containing application files, playbook, and Terraform files
                checkout scm
            }
        }

        stage('Terraform Init & Apply') {
            steps {
                script {
                    // Initialize and apply Terraform configurations
                    sh 'terraform init'
                    sh 'terraform apply -auto-approve'
                    // Capture the public IP from Terraform output
                    env.EC2_PUBLIC_IP = sh(script: "terraform output instance_public_ip", returnStdout: true).trim()
                }
            }
        }

        stage('Wait for EC2 to be healthy') {
            steps {
                script {
                    // Adjust the sleep time or implement a better check for EC2 health if necessary
                    sleep 120
                }
            }
        }

        stage('Run Ansible Playbook') {
            steps {
                script {
                    // Run the Ansible playbook to deploy your application
                    // Run the Ansible playbook and pass the EC2 public IP as an extra variable
                    sh "ansible-playbook -i ${env.EC2_PUBLIC_IP}, install.yml --extra-vars 'target=${env.EC2_PUBLIC_IP}'"
                }
            }
        }
    }
    
    post {
        always {
            // Add steps that you always want to run after the pipeline, even if a stage fails.
            sh 'echo "This will always run"'
                
        }
        success {
            // Add steps to run after the pipeline completes successfully.
            sh 'echo "Build Was Successfull"'
                
        }
        failure {
            // Add steps to run if the pipeline fails.
            sh 'echo "Build Failed"'
               
        }
    }
}
            
