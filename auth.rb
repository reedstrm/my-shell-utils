#!/usr/bin/ruby
require "rotp"
require "quirc"
require "oily_png"
require "pathname"

require "clipboard"

def totps(imgs)
    imgs.map {
        |img_path|
        img = ChunkyPNG::Image.from_file(img_path)
        params = CGI::parse URI.parse(Quirc.decode(img).first.payload).query
        ROTP::TOTP.new(params['secret'][0],issuer: params['issuer'][0])
    }
end

begin
if ARGV.length == 0
    puts "Need at least one QR image file"
    exit 1 
end

if File::directory? ARGV[0]
        imgs = Pathname.new(ARGV[0]).children.map(&:to_path) 
else
    imgs = ARGV
end

totps = totps imgs

stop_time = Time.now + 30

puts "\n" * totps.length

begin
    while Time.now < stop_time
        print "\033[F" * totps.length
        totps.each {
            |totp|
            code = totp.now()
            puts code + "\t" + totp.issuer
            if totps.length == 1
                Clipboard.copy code
            end
            }
        sleep 1
        end
rescue Interrupt => e
    puts "\r"
    exit
end
end
