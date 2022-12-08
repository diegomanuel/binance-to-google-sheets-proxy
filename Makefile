.PHONY: setup start prod

export MIX_ENV ?= dev

setup:
	mix deps.get && mix compile

start:
	mix clean
	iex --name btgs_proxy@127.0.0.1 -S mix run --no-halt

prod: MIX_ENV=prod
prod:
	mix deps.get && mix compile && mix clean
	iex --name btgs_proxy@127.0.0.1 -S mix run --no-halt
