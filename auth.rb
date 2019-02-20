#!/usr/bin/ruby
require 'rotp'
require 'quirc'
require 'oily_png'
require 'pathname'

require 'clipboard'

def totps(imgs)
  imgs.map do |img_path|
    img = ChunkyPNG::Image.from_file(img_path)
    params = CGI.parse URI.parse(Quirc.decode(img).first.payload).query
    ROTP::TOTP.new(params['secret'][0], issuer: params['issuer'][0])
  end
end

if ARGV.empty?
  puts 'Need at least one QR image file'
  exit 1
end

imgs = if File.directory? ARGV[0]
         Pathname.new(ARGV[0]).children.map(&:to_path)
       else
         ARGV
       end

totps = totps imgs

stop_time = Time.now + 30

puts "\n" * totps.length

begin
  while Time.now < stop_time
    print "\033[F" * totps.length
    totps.each do |totp|
      code = totp.now
      puts code + "\t" + totp.issuer
      Clipboard.copy code if totps.length == 1
    end
    sleep 1
  end
rescue Interrupt
  puts "\r"
  exit
end
