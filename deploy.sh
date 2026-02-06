#!/bin/bash

# Configuration des variables
REGION="us-east-1"
ENDPOINT="https://redesigned-couscous-pjpr9p56qg5wc6xrr-4566.app.github.dev/"
LAMBDA_NAME="EC2Manager"
ROLE_ARN="arn:aws:iam::000000000000:role/lambda-role"

echo "--- 🚀 Démarrage du déploiement API-Driven ---"

# 1. Création d'une instance EC2 factice (la cible)
echo "📦 Création de l'instance EC2..."
INSTANCE_ID=$(awslocal ec2 run-instances \
    --image-id ami-df5629a8 \
    --count 1 \
    --instance-type t2.micro \
    --query 'Instances[0].InstanceId' \
    --output text)
echo "✅ Instance EC2 créée : $INSTANCE_ID"

# 2. Préparation de la fonction Lambda
echo "⚡ Préparation de la fonction Lambda..."
zip function.zip handler.py

# Création de la fonction dans LocalStack
awslocal lambda create-function \
    --function-name $LAMBDA_NAME \
    --runtime python3.9 \
    --zip-file fileb://function.zip \
    --handler handler.lambda_handler \
    --role $ROLE_ARN

# 3. Création de l'API Gateway
echo "🌐 Configuration de l'API Gateway..."
API_ID=$(awslocal apigateway create-rest-api --name 'EC2-API' --query 'id' --output text)
PARENT_ID=$(awslocal apigateway get-resources --rest-api-id $API_ID --query 'items[0].id' --output text)

# Création de la ressource /manage
RES_ID=$(awslocal apigateway create-resource --rest-api-id $API_ID --parent-id $PARENT_ID --path-part manage --query 'id' --output text)

# Création de la méthode POST
awslocal apigateway put-method --rest-api-id $API_ID --resource-id $RES_ID --http-method POST --authorization-type "NONE"

# Liaison de l'API avec la Lambda
awslocal apigateway put-integration \
    --rest-api-id $API_ID \
    --resource-id $RES_ID \
    --http-method POST \
    --type AWS_PROXY \
    --integration-http-method POST \
    --uri arn:aws:apigateway:$REGION:lambda:path/2015-03-31/functions/arn:aws:lambda:$REGION:000000000000:function:$LAMBDA_NAME/invocations

# Déploiement de l'API
awslocal apigateway create-deployment --rest-api-id $API_ID --stage-name prod

echo "--- 🎯 Déploiement terminé ---"
echo "ID de votre instance : $INSTANCE_ID"
echo "URL de votre API : https://<VOTRE_URL_CODESPACE_4566>/restapis/$API_ID/prod/_user_request_/manage"