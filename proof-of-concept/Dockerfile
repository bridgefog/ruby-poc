FROM ruby:2.2.0

ENV BUNDLE_APP_CONFIG /app/.bundle
ENV BUNDLE_PATH /app/vendor/bundler
ENV BUNDLE_BIN /app/bin
ENV BUNDLE_DISABLE_SHARED_GEMS 1
ENV BUNDLE_JOBS 8
ENV BUNDLE_RETRY 3

RUN apt-get update \
 && apt-get install -y vim-tiny

WORKDIR /app
ADD . /app

RUN cp /app/vendor/ipfs/bin/ipfs.linux64 /usr/bin/ipfs

RUN bundle install

ENV IPFS_PATH /app/.go-ipfs
ENTRYPOINT ["/app/bin/docker-wrapper"]
