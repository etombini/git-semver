NAME=git-semver
VERSION ?= $(shell git describe --tags --always 2> /dev/null || \
			cat $(CURDIR)/.version 2> /dev/null || echo 0.0.0)

DIRS=etc lib bin sbin share
INSTALL_DIRS=$(shell find $(DIRS) -type d 2>/dev/null)
INSTALL_FILES=$(shell find $(DIRS) -type f 2>/dev/null)
DOC_FILES=*.md *.txt

PKG_DIR=pkg
PKG_NAME=$(NAME)-$(VERSION)
PKG=$(PKG_DIR)/$(PKG_NAME).tar.gz
SIG=$(PKG_DIR)/$(PKG_NAME).asc

PREFIX?=/usr/local
DOC_DIR=$(PREFIX)/share/doc/$(PKG_NAME)

pkg:
	mkdir -p $(PKG_DIR)

$(PKG): pkg
	git archive --output=$(PKG) --prefix=$(PKG_NAME)/ HEAD

build: $(PKG)

$(SIG): $(PKG)
	gpg --sign --detach-sign --armor $(PKG)

sign: $(SIG)

clean:
	rm -f $(PKG) $(SIG)

all: $(PKG) $(SIG)

test:

release: $(PKG) $(SIG) tag

install:
	for dir in $(INSTALL_DIRS); do mkdir -p $(PREFIX)/$$dir; done
	for file in $(INSTALL_FILES); do cp $$file $(PREFIX)/$$file; done
	mkdir -p $(DOC_DIR)
	cp -r $(DOC_FILES) $(DOC_DIR)/

local-install:
	mkdir -p $(HOME)/bin
	chmod +x bin/*
	cp bin/* $(HOME)/bin/

uninstall:
	for file in $(INSTALL_FILES); do rm -f $(PREFIX)/$$file; done
	rm -rf $(DOC_DIR)


.PHONY: build sign clean test tag release install uninstall all