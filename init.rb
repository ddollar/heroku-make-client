$:.unshift File.expand_path("../vendor/multipart-post/lib", __FILE__)

require "heroku/command/base"
require "net/http/post/multipart"
require "tmpdir"
require "uri"

class Heroku::Command::Make < Heroku::Command::Base

  # make [COMMAND]
  #
  # build a piece of software for the heroku cloud using COMMAND as a build command
  # if no COMMAND is specified, a sensible default will be chosen for you
  #
  #  -n, --name   NAME    # the name of the library (will default to the directory name)
  #  -o, --output FILE    # output build artifacts to this filemake [COMMAND]
  #  -p, --prefix PREFIX  # the build/install prefix of the software
  #  -v, --verbose        # show the full build output
  #
  def index
    name = options[:name] || File.basename(Dir.pwd)
    output = options[:output] || "/tmp/#{name}.tgz"

    make_server = ENV["MAKE_SERVER"] || "http://heroku-make.herokuapp.com"
    make_server_uri = URI.parse(make_server)

    prefix = options[:prefix] || "/app/vendor/#{name}"
    command = args.first || "./configure --prefix #{prefix} && make install"

    source_dir = Dir.pwd

    Dir.mktmpdir do |dir|
      display ">> Packaging local directory for upload"
      %x{ tar czvf #{dir}/input.tgz . 2>&1 }

      File.open("#{dir}/input.tgz", "r") do |input|
        request = Net::HTTP::Post::Multipart.new "/make",
          "code" => UploadIO.new(input, "application/octet-stream", "input.tgz")

        display ">> Building with: #{command}"
        response = Net::HTTP.start(make_server_uri.host, make_server_uri.port) do |http|
          http.request(request) do |response|
            response.read_body do |chunk|
              print chunk if options[:verbose]
            end
          end
        end

        display ">> Downloading build artifacts to: #{output}"

        File.open(output, "w") do |output|
          begin
            output.print RestClient.get(response["X-Output-Location"])
          rescue Exception => ex
            display ex.inspect
          end
        end
      end
    end
  end

end
