import logging
import json
import time
import pandas
from datetime import datetime
from quixstreams import Application
from faker import Faker

logging.basicConfig(format='%(asctime)s %(levelname)s:%(name)s:%(message)s')
logging.getLogger().setLevel(20)


def random_profile():
    """
       Function that generates random profile for
       different individuals and build a pandas dataframe
       based on the number of profile specified.

       params:
            total_records: Total number of random profiles
            to generate, needs to be an integer, e.g 100, 2.
    """

    sample = Faker()
    logging.info("finished faker module instantiation")

    event_payload = {
        "full_name": sample.name(),
        "last_name": sample.last_name(),
        "card_provider": sample.credit_card_provider(),
        "credit_card_number": sample.credit_card_number(),
        "event_timestamp": datetime.now().strftime("%Y-%m-%d %H:%M:%S")
    }

    return event_payload


def event_sender():
    """
    Basic Producer application writing random
    data as event into Kafka
    """
    app = Application(
        broker_address="localhost:9092",
        loglevel="DEBUG",
    )

    with app.get_producer() as producer:
        while True:
            event = random_profile()
            producer.produce(
                topic="random-profile",
                value=json.dumps(event),
            )
            logging.info("Message sent to Kafka. Sleeping...")
            time.sleep(60)

event_sender()
