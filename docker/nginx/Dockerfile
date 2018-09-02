FROM nginx:alpine

RUN apk add -u --update py-pip && pip install awscli

ADD ./nginx.conf /etc/nginx/conf.d/template.conf
ADD ./entrypoint.sh /entrypoint.sh
CMD ["/entrypoint.sh"]
