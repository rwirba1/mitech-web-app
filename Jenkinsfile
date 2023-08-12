pipeline {
    agent { node { label 'node' } }

    environment {
        AWS_DEFAULT_REGION = 'us-east-1' // Replace with your region
        ANSIBLE_HOST_KEY_CHECKING = 'False'
        //PATH = "/usr/local/bin/terraform:${env.PATH}"

    }
    stages {
        stage('Install Ansible') {
            steps {
                script {
                    echo "Installing Ansible..."
                    sh '''
                        sudo apt-add-repository -y ppa:ansible/ansible
                        sudo apt update
                        sudo apt install -y ansible
                    '''
                }
            }
        }
    
        stage('Checkout code') {
            steps {
                script {
                    if (!fileExists('KNOWN_FILE_OR_DIR')) {
                // Clone your repository containing application files, playbook, and Terraform files
                        checkout scm
                    } else {
                        "File already exist. Skipping cloning."
                    }    
                }  
            }
        }

        stage('Terraform Init & Apply') {
            steps {
                script {
                    // Initialize and apply Terraform configurations
                    echo "About to run 'terraform init'..."
                    sh '/usr/local/bin/terraform init'
                    echo "'terraform init' completed. Running 'terraform apply'..."
                    sh '/usr/local/bin/terraform apply -auto-approve'
                    echo "Getting the EC2 public IP..."
                    // Capture the public IP from Terraform output
                    env.EC2_PUBLIC_IP = sh(script: "terraform output instance_public_ip", returnStdout: true).trim()
                }
            }
        }

        stage('Wait for EC2 to be healthy') {
            steps {
                script {
                    // Adjust the sleep time or implement a better check for EC2 health if necessary
                    sleep 20
                }
            }
        }

        stage('Run Ansible Playbook') {
            steps {
                script {
                    ansiblePlaybook(
                        playbook: '/home/ubuntu/jenkins/workspace/Build-MiTech-Web/install.yml',
                        inventory: "${env.EC2_PUBLIC_IP},",
                        credentialsId: 'ansible-ssh-keys',
                        become: true,
                        extraVars: "target=env.EC2_PUBLIC_IP
                        // Run the Ansible playbook to deploy your application
                        //  Run the Ansible playbook and pass the EC2 public IP as an extra variable
                       ]
                    )    
                }
            }
        }
    }
    
    post {
        always {
            node('node') {
            // Add steps that you always want to run after the pipeline, even if a stage fails.
                sh 'echo "This will always run"'
            }        
        }
        success {
            node('node') {
            // Add steps to run after the pipeline completes successfully.
                sh 'echo "Build Was Successfull"'
            }    
        }
        failure {
            node('node') {
            // Add steps to run if the pipeline fails.
                sh 'echo "Build Failed"'
            }  
        }
    }
}
            
