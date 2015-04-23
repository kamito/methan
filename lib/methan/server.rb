# coding: utf-8

require "erb"
require "rack"
require "redcarpet"
require "methan/md_renderer"
require "methan/util"


module Methan

  class Server

    DEFAULT_HOST = "0.0.0.0"
    DEFAULT_PORT = 5550

    class << self

      def rackup(args={})
        args[:'Host'] = args.delete('host') if args['host']
        args[:'Port'] = args.delete('port') if args['port']
        options = {
          environment: ENV['RACK_ENV'] || "development",
          pid:         nil,
          'Port':        DEFAULT_PORT,
          'Host':        DEFAULT_HOST,
          'AccessLog':   [],
          config:      File.join(File.dirname(__FILE__), 'server/config.ru'),
        }
        options.update(args.deep_symbolize_keys)
        ENV["RACK_ENV"] = options[:environment]
        Rack::Server.start(options)
      end

    end

    ROUTES = {
      "GET:/style.css" => :style_css,
      "GET:/" => :index,
    }

    def initialize(app=nil)
      @app = app
    end

    # Rack interface method.
    def call(env)
      req = ::Rack::Request.new(env)
      route_method = nil
      ROUTES.each do |route, method|
        http_method, path = route.split(":", 2)
        if req.path == path and http_method.to_s.upcase == req.request_method.to_s.upcase
          route_method = "#{http_method.to_s.downcase}_#{method.to_s}".to_sym
          break
        end
      end

      response = nil
      if not route_method.nil? and self.respond_to?(route_method, true)
        response = self.send(route_method, req)
      else
        ## show
        filename = req.path.dup
        filename = filename.gsub(/^\//, "")
        filename = "#{filename}.md" unless filename =~ /^\.md$/
        showpath = File.join(Dir.pwd, filename)
        puts showpath
        if File.exists?(showpath)
          response = get_show(req)
        end
      end

      # 404 not found
      response = gen_404_response() if response.nil?
      # response finished
      response.finish
    end

    def get_style_css(req)
      filepath = File.join(File.dirname(__FILE__), "server/static/style.css")
      src = File.read(filepath)
      gen_response(src, 200, {'Content-Type' => 'text/css'})
    end

    def get_index(req)
      current_dir = Dir.pwd
      path = File.join(current_dir, "**/*.md")
      # bindings
      @files = Dir.glob(path).map do |file|
        file_id = file.gsub(current_dir, "")
        file_id = file_id.gsub(/\.md$/, "").gsub(/^\//, "")
        dat = {
          id: file_id,
          name: File.basename(file),
          path: file,
        }
        File.open(file) do |f|
          title = f.gets
          title = title.force_encoding('utf-8').gsub(/^\#\s+/, "").gsub(/\s+\#$/, "").strip
          dat[:title] = title
        end
        dat
      end
      @files.sort!{|a, b| a[:id] <=> b[:id] }
      @files.reverse!
      src = File.read(make_template_path("index.html.erb"))
      erb = ERB.new(src)
      body = erb.result(binding)
      return gen_response(body)
    end

    def get_show(req)
      path = req.path.dup
      file_id = path.gsub(/^\//, "")
      if file_id =~ /\.md$/
        filename = file_id
        file_id  = file_id.gsub(/\.md$/, "")
      else
        filename = "#{file_id}.md"
      end
      filepath = File.join(Dir.pwd, filename)

      # bindings
      @file_id  = file_id
      @filename = filename
      @src = File.read(filepath)
      @html = markdown_to_html(@src)

      # to html
      src = File.read(make_template_path("show.html.erb"))
      erb = ERB.new(src)
      body = erb.result(binding)
      return gen_response(body)
    end

    # Convert Markdown source to HTML.
    # @param [String] src Markdown source.
    def markdown_to_html(src)
      render_options = {
        prettify: true,
      }
      renderer = MdRenderer.new(render_options)
      extensions = {
        no_intra_emphasis: true,
        autolink: true,
        tables: true,
        fenced_code_blocks: true,
        strikethrough: true,
        underline: true,
        quote: true,
        footnotes: true,
      }
      md = ::Redcarpet::Markdown.new(renderer, extensions)
      html = md.render(src)
      return html
    end

    # Generate Rack::Response
    # @param [String] body Response body.
    # @param [Fixnum] status Status code.
    # @param [Hash] headers Headers.
    # @return [Rack::Response]
    def gen_response(body, status=200, headers={})
      response = Rack::Response.new do |r|
        r.status = status
        r['Content-Type'] = "text/html" unless headers.key?('Content-Type')
        headers.each do |key, val|
          r[key] = val
        end
        r.write body
      end
      return response
    end

    # Generate 404 Response
    # @return [Rack::Response]
    def gen_404_response()
      response = gen_response("<h1>404 Not Found</h1>", 404)
      return response
    end

    # Generate ERB template file path.
    # @param [String] filename template file name.
    # @return [String]
    def make_template_path(filename)
      return File.join(templates_dir, filename)
    end

    # Return templates directory path.
    # @return [String]
    def templates_dir
      return File.join(File.dirname(__FILE__), 'server/templates')
    end
  end

end
