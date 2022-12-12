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
            sh 'sudo terraform init -no-color'
}
        }
     }
     stage('Terraform plan') {
        steps {
            dir('Terraform/') {
            sh 'sudo terraform plan -no-color'
}
        }
     }
     stage ('Approval') {
      when {
         not {
            equals expected: true, actual: false
         }
      }
      steps {
         script {
            input message: 'proceed to apply', ok: 'Apply'
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
        sh 'ansible-playbook -i inventory web-server.yaml -u ubuntu --private-key /home/ismail/web-app.pem'
       }        
     }
    }
}
}