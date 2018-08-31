FROM parity/parity:stable

RUN apt-get update && apt-get install -y curl jq && apt-get clean

COPY . /eth-env
WORKDIR /eth-env

ENTRYPOINT []

CMD ./run-parity.sh
