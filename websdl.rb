require 'em-websocket' 
require 'sdl'

autoload :WebSDL, 'websdl/websdl'

module SDL
  def self.run(klass, options={})
    f = klass.new
    s = f.open_screen
    f.frames = [f]
    loop {
      f.mainloop(s)
    }
  end
end

class Frame
  attr_accessor :frames
  def open_screen;end
  def mainloop(screen);end
end
