import boto3
import requests
import json
import gzip
import time
import os
from io import BytesIO

# AWS S3 configuration
AWS_ACCESS_KEY_ID = os.environ.get('AWS_ACCESS_KEY_ID')
AWS_SECRET_ACCESS_KEY = os.environ.get('AWS_SECRET_ACCESS_KEY')
AWS_REGION = 'us-east-1'  # Replace with your desired region
DESTINATION_BUCKET = 'valorent-datasets'  # Replace with your bucket name

# Source S3 configuration
SOURCE_S3_BUCKET_URL = "https://vcthackathon-data.s3.us-west-2.amazonaws.com"

# (game-changers, vct-international, vct-challengers)
LEAGUE = "game-changers"

# (2022, 2023, 2024)
YEAR = 2022

# Initialize S3 client
s3_client = boto3.client('s3', 
                         region_name=AWS_REGION,
                         aws_access_key_id=AWS_ACCESS_KEY_ID,
                         aws_secret_access_key=AWS_SECRET_ACCESS_KEY)

def transfer_gzip_to_s3(file_name):
    remote_file = f"{SOURCE_S3_BUCKET_URL}/{file_name}.json.gz"
    response = requests.get(remote_file, stream=True)

    if response.status_code == 200:
        gzip_bytes = BytesIO(response.content)
        with gzip.GzipFile(fileobj=gzip_bytes, mode="rb") as gzipped_file:
            json_content = gzipped_file.read()
            
        # Upload to S3
        try:
            s3_client.put_object(Bucket=DESTINATION_BUCKET, 
                                 Key=f"{file_name}.json", 
                                 Body=json_content)
            print(f"{file_name}.json transferred to S3")
            return True
        except Exception as e:
            print(f"Error uploading {file_name}.json to S3: {str(e)}")
            return False
    elif response.status_code == 404:
        # Ignore if file not found
        return False
    else:
        print(response)
        print(f"Failed to download {file_name}")
        return False

def transfer_esports_files():
    directory = f"{LEAGUE}/esports-data"
    esports_data_files = ["leagues", "tournaments", "players", "teams", "mapping_data"]
    for file_name in esports_data_files:
        transfer_gzip_to_s3(f"{directory}/{file_name}")

def transfer_games():
    start_time = time.time()

    # Download mapping data
    mapping_data_key = f"{LEAGUE}/esports-data/mapping_data.json"
    response = s3_client.get_object(Bucket=DESTINATION_BUCKET, Key=mapping_data_key)
    mappings_data = json.loads(response['Body'].read().decode('utf-8'))

    game_counter = 0

    for esports_game in mappings_data:
        s3_game_file = f"{LEAGUE}/games/{YEAR}/{esports_game['platformGameId']}"

        response = transfer_gzip_to_s3(s3_game_file)
        
        if response:
            game_counter += 1
            if game_counter % 10 == 0:
                print(f"----- Processed {game_counter} games, current run time: {round((time.time() - start_time)/60, 2)} minutes")

if __name__ == "__main__":
    transfer_esports_files()
    transfer_games()
