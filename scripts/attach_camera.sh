#!/bin/bash
sleep 5
rosservice call /link_attacher_node/attach "model_name_1: 'iris0'
link_name_1: 'base_link'
model_name_2: 'uav0_camera'
link_name_2: 'camera_link'"
