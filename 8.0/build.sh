#!/bin/bash

docker buildx build --platform linux/arm64 --tag thotp/mysql-server:8.0.23 .
