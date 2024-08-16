import logging

import pandas as pd
from faker import Faker

logging.basicConfig(format='%(asctime)s %(levelname)s:%(name)s:%(message)s')
logging.getLogger().setLevel(20)



def random_profile_data_generator(total_records: int):
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

    df = pd.DataFrame(
        [sample.profile() for profile in range(total_records)])
    # logging.info(f"Dataframe created with {df.shape[1]}\
    #                           records and {df.shape[0]} columns")
