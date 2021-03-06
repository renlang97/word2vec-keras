.PHONY: build compile run-it test train predict clean

TRAIN_SET_URL="http://mattmahoney.net/dc/text8.zip"

DIR=$(shell pwd)
DATA_DIR=$(DIR)/data
DOCKER_IMAGE="ozgurdemir/keras"
CONTAINER_NAME="word2vec-keras"
DOCKER_RUN=docker run --rm --name $(CONTAINER_NAME) -v $(DIR):/srv/ai -w /srv/ai/src

build:
	docker build . -t $(DOCKER_IMAGE)

compile:
	$(DOCKER_RUN) $(DOCKER_IMAGE) python3 setup.py build_ext --inplace

run-it:
	$(DOCKER_RUN) -it $(DOCKER_IMAGE) /bin/bash

test:
	$(DOCKER_RUN) $(DOCKER_IMAGE) python3 -m unittest

train: data/text8 compile
	$(DOCKER_RUN) $(DOCKER_IMAGE) python3 train.py --train ../data/text8 --embeddings ../data/embeddings.csv ${ARGS}

predict:
	$(DOCKER_RUN) -it $(DOCKER_IMAGE) python3 predict.py --embeddings ../data/embeddings.csv

data/text8: data/text8.zip
	unzip -o data/text8.zip -d $(DATA_DIR)
	touch $@

data/text8.zip:
	mkdir -p $(DATA_DIR)
	wget $(TRAIN_SET_URL) -O $@
	touch $@

clean:
	rm data/*
	rm -rf src/build
	rm -rf src/__pycache__/
	rm -rf src/src
	rm src/*.so
	rm src/*.c
