module WebSDL
  class << self
    def run(klass, options={})
      frames = []
      EM.run(
        EM::WebSocket.start(options) do |socket|
          f = klass.new
          screen = f.open_screen
          frames << f
          f.frames = frames

          socket.onopen do
            EventMachine::add_periodic_timer(0.1) {
              screen.socket = socket
              Event.lock(socket) {
                f.mainloop(screen)
              }
            }
          end

          socket.onmessage do |msg|
            msgs = msg.split(/:/)
            event_klass = Event.const_get(msgs.shift) rescue nil
            break unless event_klass
            Event.push(socket, event_klass.new(*msgs.map(&:to_f)))
            Event.lock(socket) {
              f.mainloop(screen)
            }
          end

        end
      )
    end
  end

  class Surface
    attr_reader :w, :h
    def initialize(w, h, buffered)
      @w, @h = w, h
      @buffered = buffered
      @buffer = []
    end

    def buffered?
      @buffered
    end

    attr_reader :socket
    def socket=(socket)
      @socket = socket
      wsend("#{@w}px", "#{@h}px", :setDimension)
    end

    def wsend(*msg)
      if buffered?
        @buffer.concat msg
      else
        @socket.send(msg.join(":"))
      end
    end

    def draw_rect(x, y, w, h, color, fill=false, alpha=nil)
      wsend(
        to_webcolor(color, alpha),
        fill ? :fillStyle : :strokeStyle,
        x, y, w, h,
        fill ? :fillRect : :strokeRect)
    end

    def fill_rect(x, y, w, h, color)
      draw_rect(x, y, w, h, color, true)
    end

    def draw_circle(x, y, r, color, fill=false, aa=false, alpha=nil)
    end

    alias fillRect fill_rect
    alias drawRect draw_rect

    private
    def to_webcolor(color, alpha=nil)
      case color
      when String
        color
      when Numeric
        r = [color].pack("N").unpack("C4")
        r.push(r.shift)
        a = r.pop
        r.map!{|v|(v*a.quo(0xff)).to_i}
        r.push alpha.quo(0xff).to_f if alpha

        case r.size
        when 3
          "rgb(#{r.join(',')})"
        when 4
          "rgba(#{r.join(',')})"
        end
      else
        color
      end
    end
  end

  class Screen < Surface
    def self.open(w, h, depth, flags)
      new(w, h, !!(flags & SDL::DOUBLEBUF))
    end

    def flip
      @socket.send(@buffer.join(":"))
      @buffer.clear
    end
  end

  module Event
    class << self
      @@events = {}

      def lock(socket, &block)
        @@current_socket = socket
        block.call
        @@current_socket = nil
      end

      def poll
        @@events[@@current_socket].shift if @@events.has_key? @@current_socket
      end

      def push(s, e)
        @@events[s] = [] unless @@events.has_key? s
        @@events[s].push(e)
      end
    end

    MouseMotion = Struct.new(:x, :y)
  end
end


# fallback
module WebSDL
  class << self
    ORIGINAL_SDL = SDL
    def const_missing(c)
      ORIGINAL_SDL.const_get(c)
    end

    def init(i);end
  end

  class Surface
    def method_missing(m, *a, &b)
      $stderr.puts "Warning: not implemented #{m}"
    end
  end
end
