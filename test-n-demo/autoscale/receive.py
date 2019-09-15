#!/usr/bin/env python

import pika

credentials = pika.PlainCredentials('rabbitmq', 'znwk2BaTLAqowMrv')
parameters = pika.ConnectionParameters('rabbitmqsrv.test-n-demo.svc.cluster.local',
                                   5672,
                                   '/',
                                   credentials)

connection = pika.BlockingConnection(parameters)
channel = connection.channel()
method_frame, header_frame, body = channel.basic_get('hello')
if method_frame:
    print('Received message', body)
    channel.basic_ack(method_frame.delivery_tag)
else:
    print('No message available')

connection.close()
