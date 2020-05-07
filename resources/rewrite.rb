#
# Cookbook:: syslog_ng
# Resource:: rewrite
#
# Copyright:: 2020, Ben Hughes <bmhughes@bmhughes.co.uk>
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

include SyslogNg::Cookbook::GeneralHelpers

property :config_dir, String,
          default: lazy { "#{syslog_ng_config_dir}/rewrite.d" }

property :cookbook, String,
          default: 'syslog_ng'

property :template, String,
          default: 'syslog-ng/rewrite.conf.erb'

property :owner, String,
          default: lazy { syslog_ng_user }

property :group, String,
          default: lazy { syslog_ng_group }

property :mode, String,
          default: '0640'

property :function, String,
          required: true,
          equal_to: %w(subst set unset groupset groupunset credit-card-mask set-tag clear-tag)

property :match, String

property :replacement, String

property :field, String

property :value, String

property :values, [String, Array]

property :flags, [String, Array]

property :tags, String

property :condition, String

property :additional_options, Hash,
          default: {}

property :configuration, Array

property :description, String

action :create do
  rewrite = if new_resource.configuration.nil?
              case new_resource.function
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
              when 'unset groupunset'
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
              when 'set-tag clear-tag'
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
              end
            else
              new_resource.configuration
            end

  template "#{new_resource.config_dir}/#{new_resource.name}.conf" do
    cookbook new_resource.cookbook
    source new_resource.template

    owner new_resource.owner
    group new_resource.group
    mode new_resource.mode
    sensitive new_resource.sensitive

    variables(
      name: new_resource.name,
      description: new_resource.description.nil? ? new_resource.name : new_resource.description,
      rewrite: rewrite
    )
    helpers(SyslogNg::Cookbook::RewriteHelpers)

    action :create
  end
end

action :delete do
  file "#{new_resource.config_dir}/#{new_resource.name}.conf" do
    action :delete
  end
end
