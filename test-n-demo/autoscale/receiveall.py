#!/usr/bin/env python

import pika

credentials = pika.PlainCredentials('rabbitmq', 'znwk2BaTLAqowMrv')
parameters = pika.ConnectionParameters('rabbitmqsrv.test-n-demo.svc.cluster.local',
                                   5672,
                                   '/',
                                   credentials)

connection = pika.BlockingConnection(parameters)
channel = connection.channel()

channel.queue_declare(queue='hello')

def callback(ch, method, properties, body):
    print(" [x] Received %r" % body)

channel.basic_consume(callback,
                      queue='hello',
                      no_ack=True)

connection.close()
