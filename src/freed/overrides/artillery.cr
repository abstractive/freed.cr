module Artillery
  class Shot
    def self.focuses(*focuses)
      Shell::Meta.new({
        :focuses => focuses.to_a
      })
    end
  end
  class Armory
    @@hooks = Set(Symbol | Shell::MetaType).new
    def self.organize
      organize { |vector|
        unless vector[:meta].nil?
          if meta = vector[:meta]? #de [:data]
            if (hooks = meta[:focuses]) && hooks.is_a?(Array)
              Artillery.log "Added #{vector[:method].to_s.upcase}#{vector[:path]} on #{vector[:object]} with data hooks: #{hooks} #{typeof(hooks)}"
              hooks.each { |hook| @@hooks.add(hook)}
            end
          end
        end
      }
      Artillery.log( "Hooks present: #{@@hooks}")
    end
  end
end
