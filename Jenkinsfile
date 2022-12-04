pipeline {
    agent any

   stages {
     stage('Checkout the SCM') {
        steps {
              git 'https://github.com/pkmisma/cloud-domain-assessment.git'
     }
     }
     stage('Terraform Inirt') {
        steps {
            terraform Init
        }
     }
     stage('Terraform plan') {
        steps {
            terraform plan
        }
     }
     stage('Terraform Apply') {
        steps {
            terraform apply --auto-approve
        }
     }
        
    }
   
}