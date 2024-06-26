module Mixpal
  class Tracker
    attr_reader :events, :user_updates, :revenue_updates, :identity, :alias_user, :js_snippets

    STORAGE_KEY = 'mixpal'

    def initialize(args = {})
      extend Mixpal.configuration.helper_module

      @events = []
      @user_updates = []
      @revenue_updates = []
      @js_snippets = []

      @identity = args[:identity]
    end

    def register_user(properties)
      @alias_user = true
      update_user(properties)
    end

    def update_user(properties)
      user_updates << Mixpal::User.new(properties)
    end

    def track(name, properties = {})
      events << Mixpal::Event.new(name, properties)
    end

    def track_charge(amount, properties = {})
      revenue_updates << Mixpal::Revenue.new(amount, properties)
    end

    def add_js_snippet(snippet)
      js_snippets << Mixpal::Snippet.new(snippet)
    end

    def render
      ''.tap do |html|
        html << '<script type="text/javascript">'
        html << "mixpanel.alias(\"#{identity}\");" if alias_user
        html << "mixpanel.identify(\"#{identity}\");" if identity
        html << events.map(&:render).join('')
        html << user_updates.map(&:render).join('')
        html << revenue_updates.map(&:render).join('')
        html << js_snippets.map(&:render).join('')
        html << '</script>'
      end.html_safe
    end

    def store!(session)
      session[STORAGE_KEY] = to_store
    end

    def restore!(session)
      data = session[STORAGE_KEY] || {}

      @alias_user = data['alias_user']
      @identity ||= data['identity']

      if data['events']
        @events = data['events'].map { |e| Mixpal::Event.from_store(e) }
      end

      if data['user_updates']
        @user_updates = data['user_updates'].map { |u| Mixpal::User.from_store(u) }
      end

      if data['revenue_updates']
        @revenue_updates = data['revenue_updates'].map { |u| Mixpal::Revenue.from_store(u) }
      end

      if data['js_snippets']
        @js_snippets = data['js_snippets'].map { |u| Mixpal::Snippet.from_store(u) }
      end

      session.delete(STORAGE_KEY)
    end

    private

    def to_store
      {
        'alias_user' => alias_user,
        'identity' => identity,
        'events' => events.map(&:to_store),
        'user_updates' => user_updates.map(&:to_store),
        'revenue_updates' => revenue_updates.map(&:to_store),
        'js_snippets' => js_snippets.map(&:to_store)
      }
    end
  end
end
