
require "thor"
require "methan/version"


module Methan


  class Console < Thor

    desc "version", "show version"
    def version
      show Methan::VERSION
    end

    desc "new FILENAME", "Create a new memo"
    option :title, type: :string, desc: %q{Title}, aliases: "t"
    def new(filename)
      now = Time.now.strftime("%Y%m%d%H%M%S")
      pwd = Dir::pwd

      filename = "#{filename}.md" unless filename.split(".").last == "md"
      filename = "#{now}-#{filename}"
      filepath = File.join(pwd, filename)

      src = "# #{options[:title] || ''}\n"
      File.open(filepath, "w") do |io|
        io.write(src)
      end
      show "Create memo `#{filename} at #{pwd}`", :green
    end


    private

    def show(message, color=nil)
      prefix = case color
               when :red    then "\033[31m"
               when :green  then "\033[32m"
               when :yellow then "\033[33m"
               when :blue   then "\033[34m"
               else ""
               end
      suffix = prefix == "" ? "" : "\033[0m"
      puts "#{prefix}#{message}#{suffix}"
    end
  end

end
