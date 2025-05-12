#!/bin/bash
sleep 10
rosservice call /link_attacher_node/attach "model_name_1: 'iris2'
link_name_1: 'base_link'
model_name_2: 'cam2'
link_name_2: 'camera_link'"
sleep 5
rosservice call /gazebo/unpause_physics