FROM ethereum/client-go:stable

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
