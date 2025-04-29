#!/bin/bash
sleep 10
rosservice call /link_attacher_node/attach "model_name_1: 'uav0_camera'
link_name_1: 'camera_link'
model_name_2: 'iris0'
link_name_2: 'base_link'"
