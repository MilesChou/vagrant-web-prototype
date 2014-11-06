#!/usr/bin/make -f

.PHONY: install rebuild composer.phar update update-dep

install:
	vagrant up
	vagrant reload

rebuild:
	vagrant destroy --force
	make install

composer.phar:
	curl -sS https://getcomposer.org/installer | php

update: composer.phar
	./composer.phar dumpautoload

update-dep: composer.phar
	./composer.phar selfupdate
	./composer.phar update

