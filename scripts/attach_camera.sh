#!/bin/bash

DRONE_MODEL="$1"
DRONE_LINK="$2"
CAMERA_MODEL="$3"
CAMERA_LINK="$4"

sleep 10

rosservice call /link_attacher_node/attach <<EOF
model_name_1: '${DRONE_MODEL}'
link_name_1: '${DRONE_LINK}'
model_name_2: '${CAMERA_MODEL}'
link_name_2: '${CAMERA_LINK}'
EOF