FROM ubuntu:18.04

# Make APT non-interactive
RUN echo 'APT::Get::Assume-Yes "true";' > /etc/apt/apt.conf.d/99semaphore
RUN echo 'DPkg::Options "--force-confnew";' >> /etc/apt/apt.conf.d/99semaphore
RUN echo 'Acquire::Check-Valid-Until no;' >> /etc/apt/apt.conf
RUN if grep -q jessie /etc/apt/sources.list ;then echo 'deb http://cdn-fastly.deb.debian.org/debian/ jessie main'>/etc/apt/sources.list; echo 'deb-src http://cdn-fastly.deb.debian.org/debian/ jessie main'>>/etc/apt/sources.list; echo 'deb http://security.debian.org/ jessie/updates main'>>/etc/apt/sources.list;echo 'deb-src http://security.debian.org/ jessie/updates main'>>/etc/apt/sources.list; echo 'deb http://archive.debian.org/debian jessie-backports main'>>/etc/apt/sources.list; echo 'deb-src http://archive.debian.org/debian jessie-backports main'>>/etc/apt/sources.list;fi
ENV DEBIAN_FRONTEND=noninteractive

# Install Packages
RUN mkdir -p /usr/share/man/man1
RUN apt-get update
RUN apt-get install -y \
    git \
    coreutils \
    docker \
    mercurial \
    xvfb \
    vim \
    apt \
    locales \
    sudo \
    apt-transport-https \
    ca-certificates \
    openssh-client \
    software-properties-common \
    build-essential \
    patch \
    ruby-dev \
    zlib1g-dev \
    liblzma-dev \
    tar \
    lsb-core \
    lsb-release \
    gzip \
    parallel \
    net-tools \
    netcat \
    unzip \
    zip \
    bzip2 \
    lftp \
    gnupg \
    curl \
    wget \
    jq \
    tree \
    ruby-full
RUN ln -sf /usr/share/zoneinfo/Etc/UTC /etc/localtime
RUN locale-gen C.UTF-8 || true
ENV LANG=C.UTF-8
RUN gem install bundler -v '1.17.3'

# Install node
RUN curl -sL https://deb.nodesource.com/setup_12.x | bash - \
    && apt-get install -y nodejs

# Entrypoint
CMD ["/bin/sh"]

# Android deps
ENV DEBIAN_FRONTEND=noninteractive
ENV ANDROID_HOME /opt/android-sdk-linux
ENV ANDROID_SDK_ROOT /opt/android-sdk-linux
RUN dpkg --add-architecture i386
RUN apt-get update -qq && apt-get install -y \
    openjdk-8-jdk libc6:i386 libstdc++6:i386 libgcc1:i386 libncurses5:i386 libz1:i386 \
    xvfb lib32z1 lib32stdc++6 build-essential \
    libcurl4-openssl-dev libglu1-mesa libxi-dev libxmu-dev \
    libglu1-mesa-dev

# Additional deps
RUN apt-get purge maven maven2 \
    && apt-get update \
    && apt-get -y install maven gradle \
    && mvn --version \
    && gradle -v

# Download Android SDK
RUN cd /opt \
    && wget -q https://dl.google.com/android/repository/sdk-tools-linux-4333796.zip -O android-sdk-tools.zip \
    && unzip -q android-sdk-tools.zip -d ${ANDROID_HOME} \
    && rm android-sdk-tools.zip
ENV PATH=${ANDROID_HOME}/emulator:${ANDROID_HOME}/tools:${ANDROID_HOME}/tools/bin:${ANDROID_HOME}/platform-tools:${PATH}

# Install Android SDK
RUN mkdir ~/.android && echo '### User Sources for Android SDK Manager' > ~/.android/repositories.cfg
RUN yes | sdkmanager --licenses && yes | sdkmanager --update
RUN sdkmanager "tools" "platform-tools"
# RUN sdkmanager "emulator" "tools" "platform-tools"
RUN yes | sdkmanager \
    "platforms;android-28" \
    "build-tools;28.0.3"
#    "platforms;android-27" \
#    "platforms;android-26" \
#    "platforms;android-25" \
#    "build-tools;28.0.2" \
#    "build-tools;28.0.1" \
#    "build-tools;28.0.0" \
#    "build-tools;27.0.3" \
#    "build-tools;27.0.2" \
#    "build-tools;27.0.1" \
#    "build-tools;27.0.0" \
#    "build-tools;26.0.2" \
#    "build-tools;26.0.1" \
#    "build-tools;25.0.3"

# Download Google Cloud SDK
#RUN echo "deb https://packages.cloud.google.com/apt cloud-sdk-`lsb_release -c -s` main" | sudo tee -a /etc/apt/sources.list.d/google-cloud-sdk.list
#RUN curl https://packages.cloud.google.com/apt/doc/apt-key.gpg | sudo apt-key add -
#RUN sudo apt-get update -qq
#RUN sudo apt-get install -y -qq google-cloud-sdk \
#    && gcloud config set core/disable_usage_reporting true \
#    && gcloud config set component_manager/disable_update_check true

# Additional packages ARM simmulator
#RUN apt-get install -y libqt5widgets5
#ENV LD_LIBRARY_PATH ${ANDROID_HOME}/tools/lib64:${ANDROID_HOME}/emulator/lib64:${ANDROID_HOME}/emulator/lib64/qt/lib

# CleanUp
RUN apt-get clean
RUN sdkmanager "platforms;android-28"
