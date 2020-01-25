require "./initialize"

module Freed
  class Thought
    def initialize(@hook : Symbol)
      Gnosis.info("Thought hook initialized: #{@hook}")
    end
  end
end

require "./overrides/artillery"

#de TODO: Used on the remote side to access and operate on Freed::Focus instances within running instance of Freed::Mind