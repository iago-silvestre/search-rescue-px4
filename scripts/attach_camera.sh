#!/bin/bash
sleep 10

MODEL1="$1"
LINK1="$2"
MODEL2="$3"
LINK2="$4"

rosservice call /link_attacher_node/attach "model_name_1: '${MODEL1}' link_name_1: '${LINK1}' model_name_2: '${MODEL2}' link_name_2: '${LINK2}'"
