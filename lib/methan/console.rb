
require "thor"
require "methan/version"

module Methan


  class Console < Thor

    desc "version", "show version"
    def version
      show(Methan::VERSION)
    end


    private

    def show(message)
      puts message
    end
  end

end
