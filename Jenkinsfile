pipeline {
    agent { node { label 'node' } }

    environment {
        AWS_DEFAULT_REGION = 'us-east-1'
        ANSIBLE_HOST_KEY_CHECKING = 'False'
    }

    stages {
        stage('Install Ansible') {
            steps {
                // ... (unchanged)
            }
        }

        stage('Checkout code') {
            steps {
                // ... (unchanged)
            }
        }

        stage('Terraform Actions') {
            steps {
                script {
                    switch(params.TERRAFORM_ACTION) {
                        case 'init':
                            echo "About to run 'terraform init'..."
                            sh '/usr/local/bin/terraform init'
                            break
                        case 'plan':
                            echo "Running 'terraform plan'..."
                            sh '/usr/local/bin/terraform plan'
                            break
                        case 'apply':
                            echo "Running 'terraform apply'..."
                            sh '/usr/local/bin/terraform apply -auto-approve'
                            echo "Getting the EC2 public IP..."
                            env.EC2_PUBLIC_IP = sh(script: "terraform output instance_public_ip", returnStdout: true).trim()
                            break
                        default:
                            echo "Unknown Terraform action. Skipping."
                    }
                }
            }
        }

        stage('Wait for EC2 to be healthy') {
            when {
                expression { return params.TERRAFORM_ACTION == 'apply' }
            }
            steps {
                // ... (unchanged)
            }
        }

        stage('Run Ansible Playbook') {
            when {
                expression { return params.RUN_ANSIBLE }
            }
            steps {
                // ... (unchanged)
            }
        }
    }

    post {
        always {
            sh 'echo "This will always run"'
        }
        success {
            sh 'echo "Build Was Successfull"'
        }
        failure {
            sh 'echo "Build Failed"'
        }
    }
}
