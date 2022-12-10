.PHONY: setup start stop release daemon logs

export MIX_ENV ?= dev

setup:
	@mkdir -p priv/ssl
	CPP=cpp EGREP=egrep KERL_CONFIGURE_OPTIONS="--without-javac --without-wx" asdf install
	mix deps.get && mix compile

start:
	iex --name btgs_proxy@127.0.0.1 -S mix run --no-halt

stop:
	_build/prod/rel/http_proxy/bin/http_proxy stop

release: MIX_ENV=prod
release:
	mix deps.get && mix compile && mix release --overwrite
	tar -zcf btgs_proxy.tar.gz -C _build/prod/rel http_proxy
	${MAKE} daemon

daemon:
	_build/prod/rel/http_proxy/bin/http_proxy daemon
	${MAKE} logs

logs:
	tail -f _build/prod/rel/http_proxy/tmp/log/*
