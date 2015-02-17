# ceol - proof of concept

```
[[ -d .go-ipfs ]] || docker run --rm -v $PWD/.go-ipfs/:/root/.go-ipfs/ maybebtc/go-ipfs init
docker run -d --name=ipfs-daemon -it -p 4001:4001 -p 4002:4002/udp -p 5001:5001 -p 8080:8080 -v $PWD/.go-ipfs/:/root/.go-ipfs/ maybebtc/go-ipfs

docker build -t ceol .
docker run --rm -it -v $PWD:/app -w /app --link=ipfs-daemon:ipfs ceol bash
 > bin/ceol-add Gemfile
```
