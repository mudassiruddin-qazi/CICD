pipeline {
    agent any

    parameters {
        choice(name: 'ENV', choices: ['dev', 'pre-prod', 'prod'], description: 'Choose the environment to deploy')
    }

    environment {
        GCP_PROJECT_ID = 'lustrous-drake-412814'
        REGION = 'us-central1'
        ZONES = 'us-central1-a,us-central1-b,us-central1-c,us-central1-d'
    }

    stages {
        stage('Set Environment Config') {
            steps {
                script {
                    if (params.ENV == 'dev') {
                        env.CLUSTER_NAME = "gke-dev-cluster"
                    } else if (params.ENV == 'pre-prod') {
                        env.CLUSTER_NAME = "gke-preprod-cluster"
                    } else if (params.ENV == 'prod') {
                        env.CLUSTER_NAME = "gke-prod-cluster"
                    }
                }
            }
        }

        stage('Provision GKE Infra') {
            steps {
                withCredentials([file(credentialsId: 'gcp-service-account-key', variable: 'GCP_KEY_FILE')]) {
                    script {
                        sh '''
                            echo "Activating GCP service account"
                            gcloud auth activate-service-account --key-file=$GCP_KEY_FILE

                            echo "Setting GCP project and compute region"
                            gcloud config set project ''' + env.GCP_PROJECT_ID + '''
                            gcloud config set compute/region ''' + env.REGION + '''

                            echo "Creating GKE cluster with autoscaling and custom machine type"
                            gcloud container clusters create ''' + env.CLUSTER_NAME + ''' \
                                --region=''' + env.REGION + ''' \
                                --node-locations=''' + env.ZONES + ''' \
                                --num-nodes=1 \
                                --enable-autoscaling \
                                --min-nodes=0 \
                                --max-nodes=6 \
                                --machine-type=n1-custom-4-6144 \
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
                echo "✅ GKE cluster '${CLUSTER_NAME}' for '${ENV}' has been created in ${REGION} with autoscaling."
            }
        }
    }
}
