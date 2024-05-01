FROM ethereum/client-go:stable

ADD genesis.json .
RUN geth init genesis.json

ENTRYPOINT ["geth"]
