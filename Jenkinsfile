pipeline {
    agent { node { label 'node' } }

    environment {
        AWS_DEFAULT_REGION = 'us-east-1'
        ANSIBLE_HOST_KEY_CHECKING = 'False'
    }

    stages {
        stage('Install Ansible') {
            steps {
                script {
                    def ansibleInstalled = sh(script: 'which ansible', returnStatus: true)
                    if (ansibleInstalled != 0) {
                        echo "Ansible is not installed. Installing now..."
                        sh '''
                            sudo apt-add-repository -y ppa:ansible/ansible
                            sudo apt update
                            sudo apt install -y ansible
                        '''
                    } else {
                        echo "Ansible is already installed. Skipping installation."
                    }
                }
            }
        }

        stage('Checkout code') {
            steps {
                script {
                    if (!fileExists('.git')) {
                        checkout scm
                    } else {
                        sh '''
                            git checkout main
                            git pull origin pipeline-test
                        '''
                    }    
                }  
            }
        }

        stage('Terraform Actions') {
            steps {
                script {
                    if (params.TERRAFORM_ACTION.contains('init')) {
                        echo "Running 'terraform init'..."
                        case 'init':
                            echo "About to run 'terraform init'..."
                            sh '/usr/local/bin/terraform init'
                            sh '/usr/local/bin/terraform init'
                    }
                    if (params.TERRAFORM_ACTION.contains('apply')) {
                        echo "Running 'terraform apply'..."
                        sh '/usr/local/bin/terraform apply -auto-approve'
                        env.EC2_PUBLIC_IP = sh(script: "terraform output instance_public_ip", returnStdout: true).trim()
                    }
                    if (params.TERRAFORM_ACTION.contains('destroy')) {
                        echo "Running 'terraform destroy'..."
                        sh '/usr/local/bin/terraform destroy -auto-approve'

                    }
                }
            }
        }

        stage('Wait for EC2 to be healthy') {
            steps {
                script {
                    // Adjust the sleep time or implement a better check for EC2 health if necessary
                    sleep time: 120, unit: 'SECONDS'
                }
            }
        }

        stage('Run Ansible Playbook') {
            steps {
                withCredentials([sshUserPrivateKey(credentialsId: 'ansible-ssh-keys', keyFileVariable: 'SSH_KEY')]) {
                    sshagent(credentials: ['ansible-ssh-keys']) {
                        sh '''#!/bin/bash
                        ansible all -i "${EC2_PUBLIC_IP}," -m ping --private-key=$SSH_KEY -u ubuntu
                        ansible-playbook -i "${EC2_PUBLIC_IP}," /home/ubuntu/jenkins/workspace/Build-MiTech-Web/install.yml --private-key=$SSH_KEY -u ubuntu -e target="${EC2_PUBLIC_IP}"
                        '''
                    }
                }
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
