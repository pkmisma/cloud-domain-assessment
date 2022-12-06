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
            sh 'terraform init -no-color'
}
        }
     }
     stage('Terraform plan') {
        steps {
            dir('Terraform/') {
            sh 'terraform plan -no-color'
}
        }
     }
     stage('Terraform Apply') {
        steps {
            dir('Terraform/') {
            sh 'terraform apply --auto-approve -no-color'
}
        }
     }
     stage('Install web-server and modify the index.html') {
       steps {
        dir('Ansible/') {
        sh "ansible-playbook -i inventory web-server.yml -u ubuntu --private-key /home/ismail/demo.pem ansible_ssh_common_args='-o StrictHostKeyChecking=no'"
       }        
     }
    }
}
}