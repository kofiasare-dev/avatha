FROM ethereum/client-go:release-1.13

ADD genesis.json .
RUN geth init genesis.json

ENTRYPOINT ["geth"]
