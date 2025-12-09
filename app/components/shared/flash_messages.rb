# frozen_string_literal: true

module Components
  module Shared
    class FlashMessages < Components::Base
      def initialize(flash:)
        @flash = flash
      end

      def view_template
        return if @flash.empty?

        div(class: "fixed top-4 right-4 z-[100] flex flex-col gap-2 max-w-sm w-full sm:top-20") do
          @flash.each do |type, message|
            next if message.blank?
            render_flash(type.to_sym, message)
          end
        end
      end

      private

      def render_flash(type, message)
        variant = flash_variant(type)

        Alert(variant: variant, class: "shadow-lg") do
          div(class: "flex items-start gap-3") do
            render flash_icon(type)
            div(class: "flex-1") do
              AlertTitle { flash_title(type) }
              AlertDescription { message }
            end
            button(
              type: "button",
              class: "text-current opacity-70 hover:opacity-100",
              onclick: safe("this.closest('[role=alert]').remove()")
            ) do
              render Components::Icons::X.new(size: :sm)
            end
          end
        end
      end

      def flash_variant(type)
        case type
        when :notice, :success then :success
        when :alert, :error then :destructive
        when :warning then :warning
        else nil
        end
      end

      def flash_icon(type)
        case type
        when :notice, :success then Components::Icons::CheckCircle.new(size: :sm)
        when :alert, :error then Components::Icons::ExclamationCircle.new(size: :sm)
        when :warning then Components::Icons::ExclamationCircle.new(size: :sm)
        else Components::Icons::InformationCircle.new(size: :sm)
        end
      end

      def flash_title(type)
        case type
        when :notice, :success then "Success"
        when :alert, :error then "Error"
        when :warning then "Warning"
        else "Notice"
        end
      end
    end
  end
end
