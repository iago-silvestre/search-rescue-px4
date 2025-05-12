#!/bin/bash
# Pull latest git changes
git pull

# Ensure all .sh scripts are executable
find /root/catkin_ws/src/search-rescue-px4/scripts -type f -name "*.sh" -exec chmod +x {} +

# Source the bashrc (only works for interactive shells; may not persist here)
source ~/.bashrc

# Start a new interactive bash session
exec bash