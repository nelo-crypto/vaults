# Vaults

A simple vault implementation.

## Start docker service

```bash
sudo service docker start
```

## Build the Docker container

```bash
sudo docker build -t <image-name> .
```

## Run the Docker container

```bash
sudo docker run -it --name <container-name> <image-name> /bin/sh;
```

## Set private key `env` variable inside the Docker container

```bash
export PRIVATE_KEY=<PrivateKey>
```

## Compiling the contracts

```shell
truffle compile
```

## Migration files

### Deploy migration

Will run the `1_deploy.js` migration to deploy the contracts on the specified blockchain.

```shell
truffle migrate --network hecomainnet -f 1 --to 1
```

### Reinvest migration

```shell
truffle migrate --network hecomainnet -f 2 --to 2
```

### Add liquidity migration

```shell
truffle migrate --network hecomainnet -f 3 --to 3
```

### Running emergency exit migration

```shell
truffle migrate --network hecomainnet -f 4 --to 4
```

### Changing the master migration

```shell
truffle migrate --network hecomainnet -f 5 --to 5
```

## Useful commands

### List all the Docker container images

```bash
sudo docker image ls
```

Will also tell image creation date/time, useful to check the id of the latest.

### Get contract size

```shell
truffle run contract-size
```