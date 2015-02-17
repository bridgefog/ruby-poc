# ceol - proof of concept

```
[[ -d .go-ipfs ]] || docker run --rm -v $PWD/.go-ipfs/:/root/.go-ipfs/ maybebtc/go-ipfs init
# edit the .go-ipfs/config file to allow connections on 0.0.0.0 for Addresses.API and Addresses.Gateway
docker run -d --name=ipfs-daemon -it -p 4001:4001 -p 4002:4002/udp -p 5001:5001 -p 8080:8080 -v $PWD/.go-ipfs/:/root/.go-ipfs/ maybebtc/go-ipfs

docker build -t ceol .
cid=$(docker create ceol)
docker cp $cid:/app/vendor/bundler vendor/
docker rm $cid
docker run --rm -it -v $PWD:/app -w /app --link=ipfs-daemon:ipfs ceol bash
 > bin/ceol-add Gemfile
```
