#!/bin/bash
sleep 10
rosservice call /link_attacher_node/attach "model_name_1: 'iris1'
link_name_1: 'base_link'
model_name_2: 'cam1'
link_name_2: 'camera_link'"
