pipeline {
    agent any

   stages {
     stage('Checkout SCM') {
        steps {
              git url: 'https://github.com/pkmisma/cloud-domain-assessment.git',
              credentialsId: '0a76630c-e1a1-4355-9b23-a3efd004154a'
     }
     stage('Terraform Init') {
        steps {
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