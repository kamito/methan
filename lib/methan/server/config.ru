# -*- coding: utf-8 -*-

require 'methan/server'

public_dir = File.join(File.expand_path(File.dirname(__FILE__)), "public")

use Rack::Static, {
  urls: ["/static", "/images", "favicon.ico"],
  root: public_dir,
}
run Methan::Server.new
