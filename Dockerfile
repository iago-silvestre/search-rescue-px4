# Use the official PX4 development image with ROS Noetic
FROM px4io/px4-dev-ros-noetic

# Set noninteractive mode for apt
ENV DEBIAN_FRONTEND=noninteractive

# Update package list and install additional dependencies
RUN apt-get update && apt-get install -y \
    git \
    wget \
    curl \
    unzip \
    python3-pip \
    python3-rosinstall \
    python3-rosinstall-generator \
    python3-wstool \
    ros-noetic-rosbridge-suite \
    openjdk-21-jdk \
    x11-xserver-utils \
    && rm -rf /var/lib/apt/lists/*

# Install GeographicLib datasets for MAVROS
RUN wget https://raw.githubusercontent.com/mavlink/mavros/master/mavros/scripts/install_geographiclib_datasets.sh \
    && chmod +x install_geographiclib_datasets.sh \
    && ./install_geographiclib_datasets.sh

# Create catkin workspace and clone search-rescue-px4
RUN mkdir -p ~/catkin_ws/src && cd ~/catkin_ws/src && \
    git clone https://github.com/iago-silvestre/search-rescue-px4.git

# Build catkin workspace
WORKDIR /root/catkin_ws
RUN /bin/bash -c "source /opt/ros/noetic/setup.bash && catkin_make"

# Install Jason BDI
WORKDIR /root
RUN git clone https://github.com/jason-lang/jason.git ~/jason && \
    cd ~/jason && \
    ./gradlew config

# Update bashrc with required environment variables
RUN echo "source /opt/ros/noetic/setup.bash" >> ~/.bashrc && \
    echo "source ~/catkin_ws/devel/setup.bash" >> ~/.bashrc && \
    echo "source ~/PX4-Autopilot/Tools/simulation/gazebo-classic/setup_gazebo.bash ~/PX4-Autopilot ~/PX4-Autopilot/build/px4_sitl_default" >> ~/.bashrc && \
    echo "export ROS_PACKAGE_PATH=\$ROS_PACKAGE_PATH:~/PX4-Autopilot" >> ~/.bashrc && \
    echo "export ROS_PACKAGE_PATH=\$ROS_PACKAGE_PATH:~/PX4-Autopilot/Tools/simulation/gazebo-classic/sitl_gazebo-classic" >> ~/.bashrc && \
    echo "export GAZEBO_PLUGIN_PATH=\$GAZEBO_PLUGIN_PATH:/usr/lib/x86_64-linux-gnu/gazebo-11/plugins" >> ~/.bashrc && \
    echo "export ROS_PACKAGE_PATH=\$ROS_PACKAGE_PATH:~/catkin_ws" >> ~/.bashrc && \
    echo "export JASON_HOME=~/jason" >> ~/.bashrc && \
    echo "export PATH=\$JASON_HOME/bin:\$PATH" >> ~/.bashrc && \
    echo "export GAZEBO_MODEL_PATH=\$GAZEBO_MODEL_PATH:~/catkin_ws/src/search-rescue-px4/models" >> ~/.bashrc

# Clone and setup PX4-Autopilot
RUN git clone --recursive https://github.com/PX4/PX4-Autopilot.git /root/PX4-Autopilot && \
    cd /root/PX4-Autopilot && \
    bash ./Tools/setup/ubuntu.sh && \
    DONT_RUN=1 make px4_sitl_default gazebo-classic

# Expose the display for GUI-based applications
ENV DISPLAY=:0

# Set working directory and source environment at container startup
WORKDIR /root
ENTRYPOINT ["/bin/bash", "-c", "git pull && source ~/.bashrc && exec bash"]
