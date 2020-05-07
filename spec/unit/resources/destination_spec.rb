#
# Cookbook:: syslog_ng
# Spec:: destination_spec
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

require 'spec_helper'

describe 'syslog_ng_destination' do
  step_into :syslog_ng_destination
  platform 'centos'

  context 'create syslog-ng destination config file' do
    recipe do
      syslog_ng_destination 'd_test_file_params' do
        driver 'file'
        path '/var/log/test/test_params.log'
        parameters(
          'flush_lines' => 10,
          'create-dirs' => 'yes'
        )
        action :create
      end
    end

    it 'Creates the destination config file correctly' do
      is_expected.to render_file('/etc/syslog-ng/destination.d/d_test_file_params.conf')
        .with_content(/# Destination - d_test_file_params/)
        .with_content(/destination d_test_file_params {/)
        .with_content(%r{file\("/var/log/test/test_params.log" flush_lines\(10\) create-dirs\(yes\)\);})
    end
  end
end
