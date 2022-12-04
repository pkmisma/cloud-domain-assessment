pipeline {
    agent any
   stages {
     stage('Checkout the SCM') {
        steps {
              git 'https://github.com/pkmisma/cloud-domain-assessment.git'
     }
     }
     stage('Terraform Init') {
        steps {
            dir('Terraform/') {
            sh 'terraform init'
}
        }
     }
     stage('Terraform plan') {
        steps {
            dir('Terraform/') {
            sh 'terraform plan'
}
        }
     }
     stage('Terraform Apply') {
        steps {
            dir('Terraform/') {
            sh 'terraform apply --auto-approve'
}
        }
     }
     stage('Install web-server and modify the index.html') {
       steps {
        dir('Ansible/') {
        sh 'ansible-playbook -i inventory web-server.yaml -vvv'
       }        
     }
    }
}
}