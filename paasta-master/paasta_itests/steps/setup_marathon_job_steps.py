# Copyright 2015 Yelp Inc.
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

import contextlib
import sys

from behave import when, then
import mock

sys.path.append('../')
from paasta_tools import setup_marathon_job
from paasta_tools import marathon_tools

fake_service_name = 'fake_complete_service'
fake_instance_name = 'fake_instance'
fake_appid = 'fake--complete--service.fake--instance.gitdeadbeef.configdeadbeef2'
fake_service_marathon_config = marathon_tools.MarathonServiceConfig(
    fake_service_name,
    fake_instance_name,
    {},
    {'docker_image': 'test-image'},
)
fake_service_config = {
    'id': fake_appid,
    'container': {
        'docker': {
            'portMappings': [{'protocol': 'tcp', 'containerPort': 8888, 'hostPort': 0}],
            'image': u'localhost/fake_docker_url',
            'network': 'BRIDGE'
        },
        'type': 'DOCKER',
        'volumes': [
            {'hostPath': u'/nail/etc/habitat', 'containerPath': '/nail/etc/habitat', 'mode': 'RO'},
            {'hostPath': u'/nail/etc/datacenter', 'containerPath': '/nail/etc/datacenter', 'mode': 'RO'},
            {'hostPath': u'/nail/etc/ecosystem', 'containerPath': '/nail/etc/ecosystem', 'mode': 'RO'},
            {'hostPath': u'/nail/etc/rntimeenv', 'containerPath': '/nail/etc/rntimeenv', 'mode': 'RO'},
            {'hostPath': u'/nail/etc/region', 'containerPath': '/nail/etc/region', 'mode': 'RO'},
            {'hostPath': u'/nail/etc/sperregion', 'containerPath': '/nail/etc/sperregion', 'mode': 'RO'},
            {'hostPath': u'/nail/etc/topology_env', 'containerPath': '/nail/etc/topology_env', 'mode': 'RO'},
            {'hostPath': u'/nail/srv', 'containerPath': '/nail/srv', 'mode': 'RO'},
            {'hostPath': u'/etc/boto_cfg', 'containerPath': '/etc/boto_cfg', 'mode': 'RO'}]
    },
    'instances': 1,
    'mem': 300,
    'args': [],
    'backoff_factor': 2,
    'cpus': 0.25,
    'uris': ['file:///root/.dockercfg'],
    'backoff_seconds': 1,
    'constraints': None
}


@when(u'we create a complete app')
def create_complete_app(context):
    with contextlib.nested(
        mock.patch('paasta_tools.marathon_tools.create_complete_config'),
        mock.patch('paasta_tools.marathon_tools.load_marathon_config', return_value=context.marathon_config),
        mock.patch('paasta_tools.marathon_tools.load_system_paasta_config', return_value=context.system_paasta_config),
        mock.patch('paasta_tools.bounce_lib.load_system_paasta_config', return_value=context.system_paasta_config),
        mock.patch('paasta_tools.setup_marathon_job.load_system_paasta_config',
                   return_value=context.system_paasta_config),
    ) as (
        mock_create_complete_config,
        _,
        _,
        _,
        mock_load_system_paasta_config,
    ):
        mock_create_complete_config.return_value = fake_service_config
        mock_load_system_paasta_config.return_value.get_cluster = mock.Mock(return_value=context.cluster)
        print marathon_tools.load_marathon_config()
        return_tuple = setup_marathon_job.setup_service(
            service=fake_service_name,
            instance=fake_instance_name,
            client=context.marathon_client,
            marathon_config=context.marathon_config,
            service_marathon_config=fake_service_marathon_config,
            soa_dir=None,
        )
        assert return_tuple[0] == 0
        assert 'deployed' in return_tuple[1]


@then(u'we should see it in the list of apps')
def see_it_in_list(context):
    assert fake_appid in marathon_tools.list_all_marathon_app_ids(context.marathon_client)


@then(u'we can run get_app on it')
def can_run_get_app(context):
    assert context.marathon_client.get_app(fake_appid)
