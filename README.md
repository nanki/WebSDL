# WebSDL - Ruby/SDL with HTML5 technology
WebSDL is a library which provides Ruby/SDL interface on top of WebSocket and Canvas.

## Overview
On the server-side, WebSDL translates the Ruby/SDL API call into a serialized command sequence -- temporarily called 'PostCanvas' --
and translates it to the Canvas API call on the browser-side.

Likewise, the JavaScript events on the browser-side are translated into the Ruby/SDL events on the server-side.

## Requirements
 * [Ruby/SDL](http://www.kmc.gr.jp/~ohai/rubysdl.en.html)
 * [EventMachine](http://rubyeventmachine.com/)
 * [em-websocket](http://github.com/igrigorik/em-websocket)
 * WebSocket and Canvas capable web browser.

## Demo
To run native SDL version.

    $ ruby -Ilib samples/sample1.rb

You should use `rsdl` command on Mac OSX.

    $ rsdl -Ilib samples/sample1.rb

To run WebSDL version.

    $ ruby -Ilib samples/sample1.rb web
    $ open samples/test.html

## Instruction
Here is a sample code, which draws a black background.

    require 'websdl'

    class TestFrame < Frame
      def open_screen
        SDL::Screen.open(640, 480, 32, SDL::DOUBLEBUF)
      end

      def mainloop(screen)
        while event = SDL::Event.poll
          # ...
        end
        screen.fill_rect(0, 0, screen.w, screen.h, 0)
        screen.flip
      end
    end

    # switch to WebSDL
    SDL = WebSDL

    SDL.init(SDL::INIT_VIDEO)
    SDL.run(TestFrame)

To enable multi-user functionality, WebSDL provides Frame class, something like Java Servlet.

Frame#open\_screen
:  is a callback which should return an instance of SDL::Screen.

Frame#mainloop
:  is application's main loop.

Frame#frames
:  stores all 'active' instances of Frame.


## Known issues
 * All implementations and functions are *Proof-of-Concept* quality.
 * There are few functions. Actually, only SDL::Surface#draw\_rect and SDL::Event::MouseMotion are implemented.

## Contact
 @nanki / nanki at dotswitch.net / <http://blog.netswitch.jp/>
