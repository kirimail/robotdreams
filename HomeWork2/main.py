from config import load_config
import requests
import json
from requests import HTTPError
import datetime
import os


def get_jwt_token(url, username, password):
    headers = {'content-type': 'application/json'}
    data = {"username": username, "password": password}
    res = requests.post(url, data=json.dumps(data), headers=headers)
    jwt_token = 'JWT ' + res.json()['access_token']
    return jwt_token


def app():
    config = load_config("dev")

    token = get_jwt_token(config['authurl'], config['username'], config['password'])

    if not os.path.exists('data'):
        os.makedirs('data')

    for n in range(int(config['daysback'])):
        date = (datetime.datetime.now() - datetime.timedelta(days=n)).strftime('%Y-%m-%d')

        try:
            headers = {'authorization': token}
            data = {'date': date}
            r = requests.get(config['dataurl'], params=data, headers=headers, timeout=int(config['timeout']))
            r.raise_for_status()

            with open(f'./data/{date}.json', 'w') as json_file:
                json.dump(r.json(), json_file)
        except HTTPError as exception:
            print(exception)
            continue


if __name__ == '__main__':
    app()
