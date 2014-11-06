#!/usr/bin/make -f

.PHONY: install rebuild

install:
	vagrant up
	vagrant reload

rebuild:
	vagrant destroy --force
	make install

