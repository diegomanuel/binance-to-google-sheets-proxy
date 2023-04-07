# Binance to Google Sheets Add-On Proxy!

This is a basic proxy server implementation in **Elixir**, based on [http_proxy](https://github.com/KazuCocoa/http_proxy) lib.  
I've added some tweaks, like `HTTPS` support and make it work with Binance API.

You'll need the latest [Binance to Google Sheets Add-On](https://github.com/diegomanuel/binance-to-google-sheets) version in your spreadsheet and configure the `USE_PROXY` value at `misc/config.gs`.  
You'll also need to setup the proxy URLs at `appsscript.json` under `urlFetchWhitelist` section.

## Why?

Binance decided to block API requests coming from restricted countries like USA, from which the Google servers in where our spreadsheets run are located.  
That broke several platforms, including the spreadsheet add-on: https://github.com/diegomanuel/binance-to-google-sheets/issues/142


The idea is to have a proxy server, located anywhere we want, that acts as a _tunnel_ for the spreadsheet's requests.  
The proxy solution could be also done with `nginx`, but I went with Elixir because I love it and because I can/want.

## How it works?

If you take a look at `config/config.exs` you'll see the `proxies` section:
```
proxies: [
    %{port: 4000, to: "https://api.binance.com/"},
    %{port: 4001, to: "https://api1.binance.com/"},
    %{port: 4002, to: "https://api2.binance.com/"},
    %{port: 4003, to: "https://api3.binance.com/"},
    %{port: 4004, to: "https://fapi.binance.com/"},
    %{port: 4005, to: "https://dapi.binance.com/"}
  ],
```

Meaning that it'll start `6` servers on ports `4000` to `4005`, each one corresponding to different Binance APIs.

In the add-on side, at `misc/request.gs` the new function `_makeProxyApiUrl/1` has **the hardcoded corresponding ports** there:
```
  function _makeProxyApiUrl(opts) {
    if (opts["futures"]) {
      return USE_PROXY+":4004";
    }
    if (opts["delivery"]) {
      return USE_PROXY+":4005";
    }
    // Ports 4000 to 4003 (spot and others)
    return `${USE_PROXY}:400${Math.floor(Math.random() * 4) || '0'}`;
  }
```

This simple tweak in the add-on side allows to send all the requests through `USE_PROXY` host, defined at `misc/config.gs`.  
Example:
```
const USE_PROXY = "https://btgs.mydomain.io"; // or false
```
Requires to update the `urlFetchWhitelist` section at `appsscript.json` like:
```
  "urlFetchWhitelist": [
    "https://api.binance.com/",
    "https://api1.binance.com/",
    "https://api2.binance.com/",
    "https://api3.binance.com/",
    "https://fapi.binance.com/",
    "https://dapi.binance.com/",
    "https://btgs.mydomain.io:4000/",
    "https://btgs.mydomain.io:4001/",
    "https://btgs.mydomain.io:4002/",
    "https://btgs.mydomain.io:4003/",
    "https://btgs.mydomain.io:4004/",
    "https://btgs.mydomain.io:4005/"
  ]
```

## Installation

The steps below were run on Ubuntu 20, but should work in any other OS/instance with some adjustments.  

**NOTE:** By default the proxy will run on HTTP, but I encourage you to run **HTTPS** by getting a certificate and uncommenting the `https` section at `config/runtime.exs`.

#### 1. Install OS packages
```
sudo apt update -y
sudo apt install -y \
  git unzip curl wget build-essential automake autoconf \
  libssl-dev libncurses5-dev libssh-dev inotify-tools \
  software-properties-common bc m4 cmake gpg
```
#### 2. Install `asdf` package manager with erlang+elixir plugins
```
git clone https://github.com/asdf-vm/asdf.git ~/.asdf
echo ". $HOME/.asdf/asdf.sh" >> ~/.bashrc
source ~/.bashrc
asdf plugin add erlang
asdf plugin add elixir
```
#### 3. Clone the proxy repo and setup dependencies
```
git clone https://github.com/diegomanuel/binance-to-google-sheets-proxy.git
cd binance-to-google-sheets-proxy
make setup
```
**NOTE:** Answer `y` to all questions. This will take a while the 1st time, since it needs to build the Erlang's VM.
#### 4. HTTPS/SSL certificates (optional, recommended)
Copy your cert files **privkey.pem** and **fullchain.pem** to `binance-to-google-sheets-proxy/priv/ssl/` and uncomment the `https` section at `config/runtime.exs`:
```
config :http_proxy,
  https: %{
    keyfile: "priv/ssl/privkey.pem",
    certfile: "priv/ssl/fullchain.pem"
  }
```
#### 5. Check if the proxy server works
```
make start
```
You should see one `HttpProxy.Handle` per port listening for connections.  
Check if the spreadsheet is working fine, you should see logs in the proxy console with incoming requests and `status=200` responses.  
**NOTE:** You'll need to open your instance's `4000-4005` TCP ports, so the proxy can be accessed from Google servers making the requests for your spreadsheet.
#### 6. Generate and run the release, check the logs
```
make release
```
It will start the proxy server **in daemon/background mode** and `tail -f` the output logs.  
You can run `make stop` to gracefully stop the background proxy server.  
You can run `make logs` to see the logs anytime.  

**NOTE:** When running `make release` it will also generate `btgs_proxy.tar.gz`.  
That release bundle can be deployed in any other _similar_ instance and run it without needing to setup anything.  
Just uncompress and run `http_proxy/bin/http_proxy start` or `daemon`.

## Enjoy your spreadsheet!
