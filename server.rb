require 'sinatra/base'
require 'eventmachine'
require 'eventmachine-tail'
require 'thin'

EM.run do
  connections = []
  class UserLiveLogging < Sinatra::Base
    get '/' do
      haml :index
    end

    get '/subscribe' do
      connections = settings.connections

      content_type 'text/event-stream'
      stream(:keep_open) do |out|
        connections << out
        out.callback { connections.delete(out) }
      end
    end
  end

  class Reader < EventMachine::FileTail
    def initialize(path, connections)
      @connections = connections
      startpos=-1
      super(path, startpos)
      puts "Tailing #{path}"
      @buffer = BufferedTokenizer.new
    end

    def receive_data(data)
      puts "GOT DATA."
      @buffer.extract(data).each do |line|
        @connections.each do |out|
          out << "event: boom\n"
          out << "data: #{line}\n"
          out << "\n"
        end
        puts "OK finished."
      end
    end
  end 

  Reader.new "./test_file", connections

  UserLiveLogging.set :connections, connections
  Thin::Server.start UserLiveLogging, '0.0.0.0', 3000
end
