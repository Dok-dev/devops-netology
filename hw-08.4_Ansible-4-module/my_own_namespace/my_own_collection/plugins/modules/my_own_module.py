#!/usr/bin/python

# GNU General Public License v3.0+ (see COPYING or https://www.gnu.org/licenses/gpl-3.0.txt)
from __future__ import (absolute_import, division, print_function)
__metaclass__ = type
import os
from ansible.module_utils._text import to_bytes

DOCUMENTATION = r'''
---
module: my_own_module

short_description: This is my test module

# If this is part of a collection, you need to use semantic versioning,
# i.e. the version is of the form "2.5.0" and not "2.4".
version_added: "1.0.0"

description: This is my longer description explaining my test module.

options:
    name:
        description: This is the message to send to the test module.
        required: False
        type: str
    path:
        description: Path to file
        type: str
        required: True
    rewrite:
        type:bool
        required: False
        default: True
    content:
        type: str
        required: True
    new:
        description:
            - Control to demo if the result of this module is changed or not.
            - Parameter description can be a list as well.
        required: false
        type: bool
# Specify this value according to your collection
# in format of namespace.collection.doc_fragment_name
extends_documentation_fragment:
    - my_namespace.my_own_collection.my_doc_fragment_name

author:
    - Your Name (@Dok-dev )
'''

EXAMPLES = r'''
# Pass in a message
- name: Test with a message
  my_namespace.my_own_collection.my_own_module:
    name: hello world

# pass in a message and have changed true
- name: Test with a message and changed output
  my_namespace.my_own_collection.my_own_module:
    name: hello world
    new: true

# fail the module
- name: Test failure of the module
  my_namespace.my_own_collection.my_own_module:
    name: fail me
'''

RETURN = r'''
# These are examples of possible return values, and in general should use other names for return values.
original_message:
    description: The original name param that was passed in.
    type: str
    returned: always
    sample: 'hello world'
message:
    description: The output message that the test module generates.
    type: str
    returned: always
    sample: 'goodbye'
'''

from ansible.module_utils.basic import AnsibleModule


def run_module():
    # define available arguments/parameters a user can pass to the module
    module_args = dict(
        name=dict(type='str', required=False, default='netology.txt'),
        path=dict(type='str',  required=True),
        rewrite=dict(type='bool', required=False, default=True),
        new=dict(type='bool', required=False, default=False),
        content=dict(type='str',  required=True)
    )

    # seed the result dict in the object
    # we primarily care about changed and state
    # changed is if this module effectively modified the target
    # state will include any data that you want your module to pass back
    # for consumption, for example, in a subsequent task
    result = dict(
        changed=False,
        original_message='',
        message=''
    )

    # the AnsibleModule object will be our abstraction working with Ansible
    # this includes instantiation, a couple of common attr would be the
    # args/params passed to the execution, as well as if the module
    # supports check mode
    module = AnsibleModule(
        argument_spec=module_args,
        supports_check_mode=True
    )


    # manipulate or modify the state as needed (this is going to be the
    # part where your module will do what it needs to do)
    result['original_message'] = module.params['name']
    result['message'] = 'goodbye'

    # use whatever logic you need to determine whether or not this module
    # made any modifications to your target
    if module.params['new']:
        result['changed'] = True

    # during the execution of the module, if there is an exception or a
    # conditional state that effectively causes a failure, run
    # AnsibleModule.fail_json() to pass in the message and the result
    if module.params['name'] == 'fail me':
        module.fail_json(msg='You requested this to fail', **result)

    # in the event of a successful module execution, you will want to
    # simple AnsibleModule.exit_json(), passing the key/value results

    generate_path = os.path.join(module.params['path'], module.params['name'])

    need_recreate = os.access(generate_path, os.F_OK) and not module.params['rewrite']

    if module.check_mode or need_recreate:
        result['original_message'] = 'already exists'
        result['changed'] = False
        module.exit_json(**result)
    else:
        try:
            os.makedirs(module.params['path'], exist_ok=True)
            with open(generate_path, 'wb') as newone:
                newone.write(str.encode(module.params['content'], encoding='utf-8'))
            result['original_message'] = 'Successful created'
            result['message'] = 'goodbye'
            result['changed'] = True
            module.exit_json(**result)
        except OSError as err:
            module.fail_json(msg='You requested this to fail. ' + 'OS error: {0}'.format(err), **result)


def main():
    run_module()


if __name__ == '__main__':
    main()

