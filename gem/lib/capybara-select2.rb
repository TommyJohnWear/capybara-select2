require "capybara-select2/version"
require 'capybara/selectors/tag_selector'
require 'rspec/core'

module Capybara
  module Select2
    def select2(value, options = {})
      raise "Must pass a hash containing 'from' or 'xpath' or 'css'" unless options.is_a?(Hash) and [:from, :xpath, :css].any? { |k| options.has_key? k }

      if options.has_key? :xpath
        select2_container = first(:xpath, options[:xpath])
      elsif options.has_key? :css
        select2_container = first(:css, options[:css])
      else
        select_name = options[:from]
        label = first("label", text: select_name)
        label_parent = label.find(:xpath, '..')
        select2_container = label_parent.find(".select2-container")
      end

      # Open select2 field
      if select2_container.has_selector?(".select2-choice")
        select2_container.find(".select2-choice").click
      else
        select2_container.find(".select2-choices").click
      end

      body = find(:xpath, "//body")

      if options.has_key? :search
        searchbox = body.find(".select2-with-searchbox")
        searchbox_input = searchbox.find("input.select2-input").set(value)
        page.execute_script(%|$("input.select2-input:visible").keyup();|)
        drop_container = ".select2-results"
      else
        drop_container = ".select2-drop"
      end

      drop_container_element = body.find("#{drop_container}")
      [value].flatten.each do |value|
        drop_container_element.find("li.select2-result-selectable", text: value).click
      end
    end
  end
end

RSpec.configure do |config|
  config.include Capybara::Select2
  config.include Capybara::Selectors::TagSelector
end
