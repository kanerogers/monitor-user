require 'sinatra'
require 'file-tail'

conns = []
get '/' do
  erb :index
end

get '/subscribe' do
  content_type 'text/event-stream'
  stream(:keep_open) do |out|
    conns << out
    out.callback { conns.delete(out) }
  end
end


Thread.new do
  puts "Ready to go."
  File::Tail::Logfile.tail("test_file", :backward => 10) do |line|
    puts "Got line."
    puts line
    conns.each do |out|
      out << "event: boom\n"
      out << "data: #{line}\n"
      out << "\n"
    end
    puts "OK finished."
  end 
end

__END__

@@ index
  <article id="log"></article>
 
  <script>
    var source = new EventSource('/subscribe');
 
    source.addEventListener('boom', function (event) {
      log.innerText += '\n' + event.data;
    }, false);
  </script>
