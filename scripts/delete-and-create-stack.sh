#!/bin/bash

source scripts/.env

aws cloudformation wait stack-delete-complete --stack-name "$STACK_NAME" && ./scripts/create-stack
