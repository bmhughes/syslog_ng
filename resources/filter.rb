#
# Cookbook:: syslog_ng
# Resource:: filter
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

include SyslogNg::Cookbook::GeneralHelpers

property :config_dir, String,
          default: lazy { "#{syslog_ng_config_dir}/filter.d" },
          description: 'Directory to create configuration file in'

property :cookbook, String,
          default: 'syslog_ng',
          description: 'Cookbook to source configuration file template from'

property :template, String,
          default: 'syslog-ng/filter.conf.erb',
          description: 'Template to use to generate the configuration file'

property :owner, String,
          default: lazy { default_syslog_ng_user },
          description: 'Owner of the generated configuration file'

property :group, String,
          default: lazy { default_syslog_ng_group },
          description: 'Group of the generated configuration file'

property :mode, String,
          default: '0640',
          description: 'Filemode of the generated configuration file'

property :description, String,
          description: 'Unparsed description to add to the configuration file'

property :parameters, [Hash, String, Array],
          default: {},
          description: 'Filter(s) parameters and options'

property :blocks, [Hash, Array],
          description: 'Array of blocks to reference without parameters or a Hash of blocks to reference with parameters'

action :create do
  template "#{new_resource.config_dir}/#{new_resource.name}.conf" do
    cookbook new_resource.cookbook
    source new_resource.template

    owner new_resource.owner
    group new_resource.group
    mode new_resource.mode
    sensitive new_resource.sensitive

    variables(
      name: new_resource.name,
      description: new_resource.description ? new_resource.description : new_resource.name,
      filter: new_resource.parameters,
      blocks: new_resource.blocks
    )
    helpers(SyslogNg::Cookbook::FilterHelpers)
    action :create
  end
end

action :delete do
  file "#{new_resource.config_dir}/#{new_resource.name}.conf" do
    action :delete
  end
end
