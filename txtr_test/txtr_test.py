#! /usr/bin/env python

import json
import socket

from flask import Flask

app = Flask(__name__)


@app.route('/', methods=['GET'])
def index():
    return 'Server Works!'


@app.route('/api/messages', methods=['GET'])
def get_messages():
    messages = [
        {
            'id': 1,
            'name': 'joe',
            'address': '+1 908 555 1212',
            'body': 'test message 1',
            'read': False,
            'sent': False,
        },
        {
            'id': 2,
            'name': 'fred',
            'address': '+1 908 555 1212',
            'body': 'test message 1',
            'read': False,
            'sent': True,
        },
    ]
    return json.dumps(messages)

@app.route('/api/login', methods=['POST'])
def post_login():
    return 'fakeToken'


@app.route('/api/phone', methods=['GET'])
def get_phone():
    s = socket.socket(socket.AF_INET, socket.SOCK_DGRAM)
    s.connect(("8.8.8.8", 1))
    ip = s.getsockname()[0]
    name = 'TEST Phone'
    phone = {
        'ip': ip,
        'name': name,
        'device': 'Dummy',
    }
    return json.dumps(phone)


# @app.get('/api/contacts', _getContacts);
# @app.post('/api/login', _postLogin);
# @app.get('/api/phone', _getPhone);
# @app.get('/api/updates', _getUpdates);
# @app.post('/api/message', _postMessage);
# @app.route('/greet')


if __name__ == '__main__':
    app.run(debug=True, port=3956, ssl_context='adhoc', host='0.0.0.0')
