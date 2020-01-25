module Artillery
  class Shot
    @@focuses = Set(Symbol).new
    def self.focuses(*focuses)
      Shell::Meta.new({
        :focuses => focuses.to_a
      })
    end

    def focus
      #de TODO: Give back a broker which answers only to #[hook] if @@focuses[hook] exists, and returns a proxy to Freed::Mind[hook]
      @@focuses
    end

    def self.add_focus(hook)
      @@focuses.add(hook)
    end
  end
  class Armory
    @@focuses = Set(Symbol).new
    def self.organize
      organize { |vector|
        unless vector[:meta].nil?
          if meta = vector[:meta]?
            if (hooks = meta[:focuses]) && hooks.is_a?(Array)
              Gnosis.info "Added #{vector[:method].to_s.upcase}#{vector[:path]} on #{vector[:object]} with data hooks: #{hooks}"
              hooks.each { |hook|
                @@focuses.add(hook)
                get_class(vector[:object]).add_focus(hook)
              }
            end
          end
        end
      }
      Gnosis.info( "Focus hooks present: #{@@focuses}")
    end
  end
end
