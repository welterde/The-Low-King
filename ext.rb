
begin
  require 'opengl'

  module Gosu
    class Image
      def retro!
        # Since it might crash at random intervals on my macbook, let's do it 3 times, and then give up
        if !do_retro
          if !do_retro(false)
            if !do_retro(false)
              puts "ERROR: Failed 3 times in a row. Giving up to retrofy textures."
            end
          end
        end
      end
    
      def do_retro( verbose = true )
        begin
          glBindTexture(GL_TEXTURE_2D, gl_tex_info.tex_name)
          glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_NEAREST)
          glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_NEAREST)
        rescue
          puts "WARNING: Failed to bind texture or something..." if verbose
          return false
        end
        true
      end
    end
  end

rescue LoadError

  module Gosu
    class Image
      def retro!
        # Stub. opengl gem does not exist
      end
    end
  end

end