FROM ethereum/client-go:release-1.13

ADD genesis.json .
RUN geth init genesis.json

ARG password
ARG privatekey
RUN echo $password > .pass \
    && echo $privatekey > .pkey \
    && geth account import --password .pass .pkey \
    && rm ~/.ethereum/geth/nodekey \
    && rm -f .pkey

ENTRYPOINT ["geth"]
