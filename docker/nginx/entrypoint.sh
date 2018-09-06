#!/bin/sh
set -e

if [ -n "$S3_PATH_TO_API_KEY" ]
then
  echo "loading api key from $S3_PATH_TO_API_KEY"
  export API_KEY=$(aws s3 cp "s3://$S3_PATH_TO_API_KEY" -)
  # aws s3 cp $S3_PATH_TO_API_KEY /etc/nginx/conf.d/template.conf
else
  echo "\$S3_PATH_TO_API_KEY not set, did you mean for this API to be open to the internet?"
fi

# replaces too many thing (everything with a dollar sign)
# envsubst < /etc/nginx/conf.d/template.conf > /etc/nginx/nginx.conf

# source:
# https://github.com/docker-library/docs/issues/496#issuecomment-370452557
envsubst "`env | awk -F = '{printf \" $$%s\", $$1}'`" < /etc/nginx/conf.d/template.conf > /etc/nginx/nginx.conf

# cat /etc/nginx/nginx.conf

nginx -g "daemon off;"
