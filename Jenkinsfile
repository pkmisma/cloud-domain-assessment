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
            tool name: 'terraform', type: 'terraform'
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