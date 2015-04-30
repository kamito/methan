# -*- coding: utf-8 -*-

require 'methan/server'

use Rack::Static, {
      urls: ["/static"],
      root: Dir::pwd,
    }
run Rack::Cascade.new([Rack::File.new("./"), Methan::Server.new])
