require_relative '../helpers/strings_helper'

module Shoulda
  module Matchers
    module ActiveModel
      def validate_helm_values_of(attribute)
        ValidateHelmValuesOfMatcher.new(attribute)
      end

      class ValidateHelmValuesOfMatcher
        include ::StringsHelper

        def initialize(attribute)
          @attribute = attribute
        end

        def matches?(subject)
          value = subject.public_send(@attribute)
          value.nil? || (!blank_string?(value) && Hash === value)
        end

        def does_not_match?(subject)
          value = subject.public_send(@attribute)
          !value.nil? && !(Hash === value)
        end

        def failure_message
          "Expected an #{@attribute}, to be a Helm Value (Hash)"
        end

        def failure_message_when_negated
          "Didn't expect #{@attribute}, to be a Helm Value (Hash)"
        end

        def description
          "validate that :#{@attribute} can be a Helm Value (Hash)"
        end
      end
    end
  end
end
