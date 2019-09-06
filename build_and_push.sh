#!/usr/bin/env bash

docker build -t loadup/android_ci .
docker push loadup/android_ci
