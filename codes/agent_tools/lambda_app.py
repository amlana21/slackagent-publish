
import json
import os
import boto3





def get_named_parameter(event, name):
    """
    Get a parameter from the lambda event
    """
    if len(event.get('parameters', [])) == 0:
        return ""
    else:
        return next(item for item in event['parameters'] if item['name'] == name)['value']


def get_s3_metrics():
    """
    Returns S3 bucket count, largest bucket name and its size, and total S3 bucket size in JSON format. Takes the metric type as a parameter.
    If the metric type is not provided, it defaults to 'size'.
    """
    
    from botocore.exceptions import ClientError
    s3 = boto3.client('s3')
    try:
        buckets = s3.list_buckets().get('Buckets', [])
        bucket_sizes = []
        total_size = 0
        largest_bucket = {'Name': None, 'Size': 0}
        s3_resource = boto3.resource('s3')
        for bucket in buckets:
            bucket_name = bucket['Name']
            size = 0
            try:
                b = s3_resource.Bucket(bucket_name)
                for obj in b.objects.all():
                    size += obj.size
            except Exception:
                size = 0
            bucket_sizes.append({'Name': bucket_name, 'Size': size})
            total_size += size
            if size > largest_bucket['Size']:
                largest_bucket = {'Name': bucket_name, 'Size': size}
        result = {
            'bucket_count': len(buckets),
            'largest_bucket_name': largest_bucket['Name'],
            'largest_bucket_size': largest_bucket['Size'],
            'total_s3_size': total_size
        }
        return result
    except ClientError as e:
        return {'error': str(e)}
    
def get_ec2_metrics():
    """
    Returns EC2 instance count, largest instance type, and total EC2 instance size in JSON format.
    """
    from botocore.exceptions import ClientError
    ec2 = boto3.client('ec2')
    try:
        instances = ec2.describe_instances().get('Reservations', [])
        instance_count = 0
        largest_instance = {'InstanceType': None, 'vCPUs': 0}
        total_vcpus = 0
        instance_type_vcpus = {
            't2.micro': 1, 't2.small': 1, 't2.medium': 2, 't2.large': 2,
            'm5.large': 2, 'm5.xlarge': 4, 'm5.2xlarge': 8, 'm5.4xlarge': 16,
            # ... add more as needed ...
        }
        for reservation in instances:
            for instance in reservation['Instances']:
                instance_count += 1
                instance_type = instance['InstanceType']
                vcpus = instance_type_vcpus.get(instance_type, 1)  # Default to 1 if unknown
                total_vcpus += vcpus
                if vcpus > largest_instance['vCPUs']:
                    largest_instance = {'InstanceType': instance_type, 'vCPUs': vcpus}
        result = {
            'instance_count': instance_count,
            'largest_instance_type': largest_instance['InstanceType'],
            'largest_instance_vcpus': largest_instance['vCPUs'],
            'total_ec2_vcpus': total_vcpus
        }
        return result
    except ClientError as e:
        return {'error': str(e)}


    

def lambda_handler(event, context):
    # get the action group used during the invocation of the lambda function
    actionGroup = event.get('actionGroup', '')

    # name of the function that should be invoked
    function = event.get('function', '')

    # parameters to invoke function with
    parameters = event.get('parameters', [])
    input_param= get_named_parameter(event, 'metric_type')

    try:

        if function == 'get_s3_metrics':
            response = str(get_s3_metrics())
            responseBody = {'TEXT': {'body': json.dumps(response)}}
        elif function == 'get_ec2_metrics':
            response = str(get_ec2_metrics())
            responseBody = {'TEXT': {'body': json.dumps(response)}}
        else:
            responseBody = {'TEXT': {'body': 'Invalid function'}}

        action_response = {
            'actionGroup': actionGroup,
            'function': function,
            'functionResponse': {
                'responseBody': responseBody
            }
        }

        function_response = {'response': action_response, 'messageVersion': event['messageVersion']}
        print("Response: {}".format(function_response))
    except Exception as e:
        print("Error: {}".format(e))
        function_response = {
            'response': {
                'actionGroup': actionGroup,
                'function': function,
                'functionResponse': {
                    'responseBody': {'TEXT': {'body': str(e)}}
                }
            },
            'messageVersion': event['messageVersion']
        }

    return function_response


if __name__ == "__main__":
    print(lambda_handler({'messageVersion': '1.0','function':'get_weather_details'}, None))

