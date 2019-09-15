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

channel.basic_publish(exchange='',
                  routing_key='hello',
                  body='Hello W0rld!')
print(" [x] Sent 'Hello World!'")
connection.close()
