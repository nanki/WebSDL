require 'rubygems'
gem 'rubysdl'
require 'sdl'
require 'websdl'

class TestFrame < Frame
  attr_reader :mx, :my, :color

  def initialize
    @color = 0xff000000 | (1..3).inject(0){|r,i|r << 8 | rand(0xff)}
    @mx = -100
    @my = -100
  end

  def open_screen
    SDL::Screen.open(640, 480, 32, SDL::HWSURFACE || SDL::DOUBLEBUF)
  end

  def mainloop(screen)
    screen.fill_rect(0, 0, screen.w, screen.h, 0)

    while event = SDL::Event.poll
      @mx, @my = event.x, event.y if SDL::Event::MouseMotion === event
    end

    frames.each do |f|
      screen.fill_rect(f.mx - 15, f.my - 15, 30, 30, f.color)
    end
    
    screen.flip
  end
end


SDL = WebSDL if ARGV.first == 'web'

SDL.init(SDL::INIT_VIDEO)
SDL.run(TestFrame, :host => '0.0.0.0', :port => 3000)
