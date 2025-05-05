pipeline {
    agent any

    parameters {
        choice(name: 'ENV', choices: ['dev', 'pre-prod', 'prod'], description: 'Choose the environment to deploy')
    }

    environment {
        GCP_PROJECT_ID = 'lustrous-drake-412814'
    }

    stages {
        stage('Set Environment Config') {
            steps {
                script {
                    if (params.ENV == 'dev') {
                        env.CLUSTER_NAME = "gke-dev-cluster"
                        env.REGION = "us-central1"
                        env.ZONE = "us-central1-a"
                    } else if (params.ENV == 'pre-prod') {
                        env.CLUSTER_NAME = "gke-preprod-cluster"
                        env.REGION = "us-east1"
                        env.ZONE = "us-east1-b"
                    } else if (params.ENV == 'prod') {
                        env.CLUSTER_NAME = "gke-prod-cluster"
                        env.REGION = "europe-west1"
                        env.ZONE = "europe-west1-b"
                    }
                }
            }
        }

        stage('Provision GKE Infra') {
            steps {
                withCredentials([file(credentialsId: 'gcp-service-account-key', variable: 'GCP_KEY_FILE')]) {
                    script {
                        // Secure shell usage
                        sh '''
                            echo "Activating service account"
                            gcloud auth activate-service-account --key-file=$GCP_KEY_FILE

                            echo "Setting GCP project and region"
                            gcloud config set project ''' + env.GCP_PROJECT_ID + '''
                            gcloud config set compute/region ''' + env.REGION + '''

                            echo "Creating smaller GKE cluster for testing..."
                            gcloud container clusters create ''' + env.CLUSTER_NAME + ''' \
                                --zone=''' + env.ZONE + ''' \
                                --num-nodes=1 \
                                --disk-type=pd-standard \
                                --disk-size=30 \
                                --quiet
                        '''
                    }
                }
            }
        }

        stage('Post Setup') {
            steps {
                echo "✅ GKE cluster '${CLUSTER_NAME}' for '${ENV}' environment has been created."
            }
        }
    }
}
