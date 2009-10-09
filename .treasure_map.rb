def growl(message, image)
  message.gsub!("'",'')
  message.strip!
  system "growlnotify -n 'Beholder' -m '#{message}' --image #{image}" 
end

Beholder.runner = 'spec --options spec/spec.opts --require spec/setup.rb'
Beholder.on_success = lambda do |output| 
  growl 'It is all good, in the applebees neighborhood', '/Users/chad/Projects/spicycode/spicycode-beholder/images/good.png'
end
Beholder.on_failure = lambda do |output| 
  growl output, '/Users/chad/Projects/spicycode/spicycode-beholder/images/bad.png'
end
