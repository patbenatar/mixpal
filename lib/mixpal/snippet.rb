module Mixpal
  class Snippet
    attr_reader :snippet

    def initialize(snippet)
      @snippet = snippet
    end

    def render
      snippet.html_safe
    end

    def to_store
      {
        'snippet' => snippet
      }
    end

    def self.from_store(data)
      new(data['snippet'])
    end
  end
end
