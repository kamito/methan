# -*- coding: utf-8 -*-

require 'methan/server'

use Rack::Static, {
  urls: ["/static"],
  root: Dir::pwd,
}
run Methan::Server.new
