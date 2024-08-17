import requests
import time
import json
import logging
from quixstreams import Application


# def get_weather():
#     response = requests.get(
#         "https://api.open-meteo.com/v1/forecast",
#         params={
#             "latitude": 51.5,
#             "longitude": -0.11,
#             "current": "temperature_2m",
#         },
#     )

#     return response.json()

# response = json.dumps(get_weather())

# print(type(response))

x = {'age': 5, 'weight': '7.5'}

print(type(json.dumps(x)))