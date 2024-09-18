module Jekyll
  class GameActionTag < Liquid::Tag

    def initialize(tag_name, text, tokens)
      super
      @action = text.strip
    end

    def render(context)
      current_lang = context.registers[:site].config['active_lang'] || context.registers[:page]['lang']

      action_button = case @action
                        when 'drop'
                          "Q"
                        when 'swap'
                          "F"
                        when 'advancements'
                          "L"
                        when 'attack'
                          case current_lang
                            when 'ru'
                              "ЛКМ"
                            when 'uk'
                              "ЛКМ"
                            else
                              "LMB"
                            end
                        when 'use'
                          case current_lang
                            when 'ru'
                              "ПКМ"
                            when 'uk'
                              "ПКМ"
                            else
                              "RMB"
                            end
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
