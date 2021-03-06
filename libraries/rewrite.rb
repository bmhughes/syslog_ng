#
# Cookbook:: syslog_ng
# Library:: rewrite
#
# Copyright:: Ben Hughes <bmhughes@bmhughes.co.uk>
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

require_relative '_config'

module SyslogNg
  module Cookbook
    module RewriteHelpers
      include SyslogNg::Cookbook::ConfigHelpers

      SYSLOG_NG_REWRITE_OPERATORS ||= %w(subst set unset groupset groupunset set-tag clear-tag credit-card-mask credit-card-hash).freeze

      def rewrite_config_builder
        new_resource.configuration || case new_resource.function
                                      when 'subst'
                                        [
                                          {
                                            'function' => new_resource.function,
                                            'match' => new_resource.match,
                                            'replacement' => new_resource.replacement,
                                            'value' => new_resource.value,
                                            'flags' => new_resource.flags,
                                            'condition' => new_resource.condition,
                                            'additional_options' => new_resource.additional_options,
                                          },
                                        ]
                                      when 'set'
                                        [
                                          {
                                            'function' => new_resource.function,
                                            'replacement' => new_resource.replacement,
                                            'value' => new_resource.value,
                                            'condition' => new_resource.condition,
                                            'additional_options' => new_resource.additional_options,
                                          },
                                        ]
                                      when 'unset', 'groupunset'
                                        [
                                          {
                                            'function' => new_resource.function,
                                            'field' => new_resource.field,
                                            'value' => new_resource.value,
                                            'values' => new_resource.values,
                                            'condition' => new_resource.condition,
                                            'additional_options' => new_resource.additional_options,
                                          },
                                        ]
                                      when 'groupset'
                                        [
                                          {
                                            'function' => new_resource.function,
                                            'field' => new_resource.field,
                                            'values' => new_resource.values,
                                            'condition' => new_resource.condition,
                                            'additional_options' => new_resource.additional_options,
                                          },
                                        ]
                                      when 'set-tag', 'clear-tag'
                                        [
                                          {
                                            'function' => new_resource.function,
                                            'tags' => new_resource.tags,
                                          },
                                        ]
                                      when 'credit-card-mask'
                                        [
                                          {
                                            'function' => new_resource.function,
                                            'value' => new_resource.value,
                                            'condition' => new_resource.condition,
                                            'additional_options' => new_resource.additional_options,
                                          },
                                        ]
                                      else
                                        raise ArgumentError, "Unsupported rewrite function '#{new_resource.function}' passed, should be one of: #{SYSLOG_NG_REWRITE_OPERATORS}."
                                      end
      end

      def rewrite_builder(parameters)
        raise ArgumentError, "rewrite_builder: Expected syslog-ng rewrite configuration attribute block to be a Hash, got a #{parameters.class}." unless parameters.is_a?(Hash)

        params = parameters.dup
        config_string = ''

        config_string.concat("#{params.delete('function')}(")
        config_string.concat(build_parameter_string(:rewrite, params))
        config_string.rstrip!
        config_string = config_string[0...-1] if config_string.end_with?(',')
        config_string.concat(')')

        config_string
      end
    end
  end
end
