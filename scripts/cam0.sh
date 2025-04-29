#!/bin/bash
sleep 10
rosservice call /link_attacher_node/attach "model_name_1: 'iris0'
link_name_1: 'base_link'
model_name_2: 'cam0'
link_name_2: 'camera_link'"
