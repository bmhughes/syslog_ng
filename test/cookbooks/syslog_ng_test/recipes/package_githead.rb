#
# Cookbook:: syslog_ng_test
# Recipe:: package_githead
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

syslog_ng_install '' do
  package_source 'githead'
  packages_exclude %w(syslog-ng-debuginfo syslog-ng-debugsource syslog-ng-libdbi)
  action :install
end
