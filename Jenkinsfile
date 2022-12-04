pipeline {
    agent any
    //tool name: 'terraform', type: 'terraform'
   stages {
     stage('Checkout the SCM') {
        steps {
              git 'https://github.com/pkmisma/cloud-domain-assessment.git'
     }
     }
     stage('Terraform Init') {
        steps {
            dir('Terraform/') {
}
            sh 'terraform init'
        }
     }
     stage('Terraform plan') {
        steps {
            sh 'terraform plan'
        }
     }
     stage('Terraform Apply') {
        steps {
            sh 'terraform apply --auto-approve'
        }
     }
        
    }
   
}