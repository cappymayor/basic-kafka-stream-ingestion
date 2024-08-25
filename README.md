# OVERVIEW
 A low-level stream processing ingestion that starts from producing messages to Kafka Topic and another Consumer app processing the messages into the data lake , the messages in the data lake are then made available in Glue, the underlying Glue table is then queryable in Redshift using the Redshift Spectrum feature.

 *NOTE: This streaming pipeline is not recommended in production, this pipeline writes one message at a time to s3, which generates lots of small files in s3, reading small small files in s3 is VERY EXPENSIVE when you are doing a fiull scan of the entire objects in the bucket. This is only a basic pipeline to give people the full picture of the usage of Kafka and with couple of technologies.*

# ARCHITECTURE


![grover_data_lake_setup (1)](https://github.com/user-attachments/assets/db608035-8746-4e83-a26e-87b3ade69526)



# ARCHITECTURE SUMMARY
- Source of our events is from [Faker library](https://faker.readthedocs.io/en/master/)
- A producer application written in python captures random events from faker and write to a Kafka topic.
- A consumer application on the other end read from the topic in Kafka and write to s3, the consumer also register the object in the glue catalog database in a specific table. The consumer must have the permission to do that. Make sure you understand AWS IAM.
- Data Engineer who build the pipeline can already have a first look of the data by quering the Glue table from Athena.
- To be able to query the data on the fly in Redshift, we leverage a Redshift spectrum. In this case, Redshift must have the permission to read  the underlying obkect in s3 and the underlying glue table which the s3 object is cataloged.

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
 
   
# RESOURCES
- Run kafka locally: https://kafka.apache.org/quickstart
  - make sure to install Java locally first
    - Mac user can run  `brew install openjdk` on their terminal, make sure you have brew installed, if not just run `/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"` on your terminal.
    - Windows can follow this https://www.java.com/download/ie_manual.jsp
- Build producer and consumer application Using QuixStreams. Full Documentation here https://quix.io/docs/get-started/welcome.html
  - Producer: https://www.youtube.com/watch?v=D2NYvGlbK0M&list=PL5gMntduShmyJd2fsflN1jwLW9XtDMFAX&index=6
  - Consumer: https://www.youtube.com/watch?v=eCsSAzTy5cE&list=PL5gMntduShmyJd2fsflN1jwLW9XtDMFAX&index=4

