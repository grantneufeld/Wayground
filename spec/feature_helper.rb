require 'rails_helper'

# validate the generated html
require 'html_validation'
include PageValidations

module PageValidations

  # This is a reworking of HaveValidHTML (html_validation gem)
  # to allow passing in options, and overriding the folder to store data.
  #
  # Assign working data folder (a string path; can be relative to project directory):
  #   HaveTidyHTML.folder_for_data = 'tmp/page_validation'
  # Assign command line flags to be used for all calls:
  #   HaveTidyHTML.add_default_flag('--accessibility-check 1')
  # Assign options to be used for all calls (unless specifically overridden):
  #   HaveTidyHTML.default_options = { ignore_proprietary: false }
  # Display the html in error responses:
  #   HaveTidyHTML.show_html_in_failures = true
  # For rspec, you can then test your result html in specs/features like:
  #   expect(page).to have_tidy_html(options: { ignore_proprietary: true })
  class HaveTidyHTML
    @folder_for_data = nil
    @default_options = {}
    @html_in_failures = false

    def self.folder_for_data=(path)
      @folder_for_data = path
    end

    def self.folder_for_data
      @folder_for_data
    end

    # e.g., '--accessibility-check 1'
    def self.add_default_flag(command_line_flag)
      HTMLValidation.default_tidy_flags << command_line_flag
    end

    def self.default_options=(new_options = {})
      @default_options = Hash(new_options)
    end

    def self.default_options
      @default_options
    end

    def self.show_html_in_failures=(truth)
      @html_in_failures = truth
    end

    def self.show_html_in_failures
      @html_in_failures
    end

    def initialize(options: {})
      @tidy_options = HaveTidyHTML.default_options.merge(options)
    end

    attr_reader :tidy_options

    def matches?(page)
      validator = HTMLValidation.new(
        HaveTidyHTML.folder_for_data, HTMLValidation.default_tidy_flags, tidy_options
      )
      @validation = validator.validation(page.body, page.current_url)
      @validation.valid?
    end

    def description
      'have valid HTML'
    end

    def failure_message_for_should
      "#{@validation.resource} Invalid html " \
      "(fix or run 'html_validation review' to add exceptions)\n" \
      " #{@validation.resource} exceptions:\n #{@validation.exceptions}\n\n" \
      " #{@validation.html if HaveTidyHTML.show_html_in_failures}"
    end
    alias failure_message failure_message_for_should
    # alias :failure_message :failure_message_for_should

    def failure_message_for_should_not
      "#{@validation.resource} Expected valid? to fail but didn't. " \
      "Did you accidentally accept these validation errors?\n" \
      " #{@validation.resource} exceptions:\n" \
      " #{@validation.exceptions}\n\n #{@validation.html if HaveTidyHTML.show_html_in_failures}"
    end
    alias failure_message_when_negated failure_message_for_should_not
    # alias :failure_message_when_negated :failure_message_for_should_not
  end

  def have_tidy_html(options: {})
    HaveTidyHTML.new(options: options)
  end

end

HaveTidyHTML.show_html_in_failures = false
HaveTidyHTML.folder_for_data = 'tmp/page_validation'
# HaveTidyHTML.add_default_flag('--accessibility-check 1')
HaveTidyHTML.default_options = { ignore_proprietary: true }
