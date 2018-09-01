FROM nginx:alpine

RUN apk add -u --update py-pip && pip install awscli

ADD ./nginx.conf /etc/nginx/nginx.conf
ADD ./entrypoint.sh /entrypoint.sh
CMD ["/entrypoint.sh"]
