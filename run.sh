#!/bin/bash

export AMQP_USERNAME=guest
export AMQP_PASSWORD=guest
export AMQP_HOST=128.199.89.247
export AMQP_PORT=5672
export AMQP_EXCHANGE=push_broker
export AMQP_QUEUE=message
export AMQP_DELIVERY_EXCHANGE=push_broker_delivery
export AMQP_DELIVERY_QUEUE=message_delivery
export AMQP_PREFETCH_COUNT=10
export AMQP_POOL_SIZE=10
export DEFAULT_QOS=0
export MESSAGE_SERVICE_URL=http://localhost:5005/v1
export MESSAGE_SERVICE_AUTH_TOKEN=YWRtaW46YWRtaW4=
export JWT_SECRET=sdk
export AES_KEY=com.datacultr.experience.sdk.256
export KAFKA_PORT=9092
export KAFKA_HOST=128.199.89.247

./_rel/emqx/bin/emqx console
