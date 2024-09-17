module Jekyll
  class GameActionTag < Liquid::Tag

    def initialize(tag_name, text, tokens)
      super
      @action = text.strip
    end

    def render(context)
      action_button = case @action
                        when 'drop'
                          "Q"
                        when 'swap'
                          "F"
                        when 'advancements'
                          "L"
                        when 'attack'
                          "LMB"
                        when 'use'
                          "RMB"
                        when 'sneak'
                          "LShift"
                        when 'sprint'
                          "LCtrl"
                        when 'jump'
                          "Space"
                        end

      %Q{<span class="game-action-key mc-gold">#{action_button}</span>}
    end
  end
end

Liquid::Template.register_tag('game_action', Jekyll::GameActionTag)
