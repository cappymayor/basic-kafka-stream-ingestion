# OVERVIEW
 A low-level stream processing ingestion that starts from producing messages to Kafka Topic and another Consumer app processing the messages into the data lake , the messages in the data lake are then made available in Glue, the underlying Glue table is then queryable in Redshift using the Redshift Spectrum feature.

# ARCHITECTURE


<img width="1279" alt="Screenshot 2024-08-22 at 01 07 38" src="https://github.com/user-attachments/assets/a63e7441-8320-48cf-adf2-1704dfd7fa95">


# Tech stacks used
- Python
- Kafka
- Terraform
- Docker
- CI/CD (Github Action)
- AWS Service
  - IAM
  - S3
  - Glue
  - Redshift
  - Redshift Spectrum
 
# REPOSITORY LAYOUT
- .github
  - This folder contain the CI/CD pipeline that listen to any push and run the corresponding job
  - This folder contains the workflow folder
    - python_check.yaml contain a CI job that checks if any python code written is syntactically correct and properly formatted, if it doesn't, the job fails.
    - terraform_check.yaml contain a CI job that checks if the terraform configuration file is properly formatted and also if its syntactically correct, if both are not met, the job fail
    - cd.yaml is a CD job that triggers only when the python_check.yaml job triggers, it then build the image based on the Dockerfile and push to Dockerhub.

- external_schema
   - This contains a sql file called schema.sql, the command create an EXTERNAL SCHEMA based on the s3 object catalog in Glue data catalog.
- infrastructure
   - This folder contain terraform configuration file that provision those resources in AWS
     - data_lake.tf: This create an s3 bucket in AWS for storage
     - glue_database.tf: This creates a Glue database in AWS to hold the objects we store in s3 in form of a table. This is not a relational database.
     - iam.tf: This creates some IAM resources, like IAM user for our consumer application to be able to interact with AWS.
     - provider.tf: This is the file containing the provider we want to use terraform to communicate with. In our case its aws.
     - redshift.tf: This is the file containing the full provisioning of our Redshift cluster, this is our Data warehouse.
- kafka
  - producer.py: This file contains the producer application that write message to Kafka
  - consumer.py: This file contains the consumer application that will read from Kafka
- .gitignore
  - ignore venv folder and some terraform related files to be pushed to the github repository
- Dockerfile
  - file containing instruction that will enable us create an image based on our app
- requirements.txt
  - containing dependency library that are used in linting our codes.
 
   
  
