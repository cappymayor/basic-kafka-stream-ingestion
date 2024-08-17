from quixstreams import Application
import awswrangler as wr
import boto3
import json

def data_consumer():
    app = Application(
        broker_address="localhost:9092",
        consumer_group="random-profile",
        auto_offset_reset="earliest",
    )

    with app.get_consumer() as consumer:
        consumer.subscribe(["random-profile"])

        while True:
            event_poll = consumer.poll(10)

            if event_poll is None:
                print("Waiting for event from kafka...")
            else:
                value = json.loads(event_poll.value())
                print(value)
            

data_consumer()