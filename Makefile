.PHONY: setup start release deploy

export MIX_ENV ?= dev

setup:
	mix deps.get && mix compile

start:
	mix clean
	iex --name btgs_proxy@127.0.0.1 -S mix run --no-halt

release: MIX_ENV=prod
release:
	mix deps.get && mix compile && mix clean && mix release --overwrite
	tar -zcf btgs_proxy.tar.gz -C _build/prod/rel http_proxy
	_build/prod/rel/http_proxy/bin/http_proxy start

deploy:
	mkdir -p deploy
	cd deploy && wget -c https://github.com/diegomanuel/binance-to-google-sheets-proxy/releases/download/v0.1.0/btgs_proxy.tar.gz
	cd deploy && tar -xzf btgs_proxy.tar.gz && rm btgs_proxy.tar.gz
	deploy/http_proxy/bin/http_proxy start
