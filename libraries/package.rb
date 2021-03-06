#
# Cookbook:: syslog_ng
# Library:: package
#
# Copyright:: Ben Hughes <bmhughes@bmhughes.co.uk>, All Rights Reserved.
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
    module PackageHelpers
      include SyslogNg::Cookbook::ConfigHelpers

      def default_packages(repo_include: nil, repo_exclude: nil)
        filter_output = " | grep -i 'syslog-ng' | awk '{print $1}' | grep -Po '(syslog-ng)((-[a-zA-Z0-9]+)?)+' | sort -u".freeze

        case node['platform_family']
        when 'rhel', 'amazon', 'fedora'
          package_command = platform?('fedora') || (platform_family?('rhel') && platform_version.to_i > 7) ? 'dnf' : 'yum'

          command = "#{package_command} -q search syslog-ng"
          command.concat(" --disablerepo=* --enablerepo=#{repo_include.join(',')}") if repo_include
          command.concat(" --disablerepo=#{repo_exclude.join(',')}") if repo_exclude
          command.concat(filter_output)

          log_chef(:info, "RHEL selected, command will be '#{command}'")
        when 'debian'
          log_chef(:warn, 'Repository inclusion and exclusion is not supported with APT') if repo_include || repo_exclude

          command = 'apt-cache search syslog-ng'
          command.concat(filter_output)

          log_chef(:info, "Debian selected, command will be '#{command}'")
        else
          raise "repo_get_packages: Unsupported platform #{node['platform_family']}."
        end

        package_search_cmd = shell_out(command)
        package_search_cmd.error!
        packages = package_search_cmd.stdout.split(/\n+/)

        raise 'No packages found to install' if packages.empty?

        log_chef(:info, "Found #{packages.count} packages to install")
        log_chef(:debug, "Packages to install are: #{packages.join(', ')}.")

        packages
      end
    end
  end
end
