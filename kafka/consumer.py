import json
import logging

import awswrangler as wr
import boto3
import pandas as pd
from quixstreams import Application

logging.basicConfig(format='%(asctime)s %(levelname)s:%(name)s:%(message)s')
logging.getLogger().setLevel(20)

client = boto3.client('ssm')


access_key = client.get_parameter(
    Name='/dev/data_consumer/access_key'
)

secret_key = client.get_parameter(
    Name='/dev/data_consumer/secret_key'
)

session = boto3.Session(
            aws_access_key_id=access_key["Parameter"]["Value"],
            aws_secret_access_key=secret_key["Parameter"]["Value"],
            region_name="eu-central-1"
    )


def data_consumer():
    """
    Basic consumer application reading from
    a kafka topic, write it to s3 and register the
    object in a glue data catalog database..
    """
    app = Application(
        broker_address="localhost:9092",
        consumer_group="faker-data-consumer",
        auto_offset_reset="earliest",
    )

    with app.get_consumer() as consumer:
        consumer.subscribe(["random-profile"])

        while True:
            event_poll = consumer.poll(10)

            if event_poll is None:
                logging.info("Waiting for event from kafka...")
            else:
                value = json.loads(event_poll.value())
                logging.info("message deserialised ")
                df = pd.json_normalize(value)
                wr.s3.to_parquet(
                    df=df,
                    path="s3://random-profile-extraction/random_customers/",
                    boto3_session=session,
                    mode="append",
                    database="random_profile",
                    table="random_customers",
                    schema_evolution=True,
                    dataset=True
                )
                logging.info("Message written to s3")
