import boto3
import json

def lambda_handler(event, context):
    ec2 = boto3.client('ec2', endpoint_url="https://redesigned-couscous-pjpr9p56qg5wc6xrr-4566.app.github.dev/", region_name="us-east-1")
    
    # Récupérer l'action (start/stop) et l'ID depuis la requête HTTP
    body = json.loads(event.get('body', '{}'))
    action = body.get('action', 'start')
    instance_id = body.get('instance_id')

    if action == 'start':
        ec2.start_instances(InstanceIds=[instance_id])
        msg = f"Instance {instance_id} démarrée"
    else:
        ec2.stop_instances(InstanceIds=[instance_id])
        msg = f"Instance {instance_id} arrêtée"

    return {
        'statusCode': 200,
        'body': json.dumps({'message': msg})
    }