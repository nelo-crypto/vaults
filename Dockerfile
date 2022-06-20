# syntax=docker/dockerfile:1
FROM node:17-alpine
COPY . /usr/src/app
WORKDIR /usr/src/app
RUN apk add git;
RUN yarn global add truffle@5.4.26
RUN yarn global add web3@1.6.1
RUN yarn add dotenv@10.0.0
RUN yarn add @truffle/hdwallet-provider
RUN yarn add truffle-contract-size
RUN npm update