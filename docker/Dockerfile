FROM parity/parity:v1.11.8

RUN apt-get update && apt-get install -y curl jq && apt-get clean

COPY . /eth-env
WORKDIR /eth-env

ENTRYPOINT []

CMD ./run-parity.sh
