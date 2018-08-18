FROM parity/parity:v1.10.3

RUN apt-get update && apt-get install -y curl jq && apt-get clean

COPY . /eth-env
WORKDIR /eth-env

ENTRYPOINT []

CMD /eth-env/run-parity.sh
