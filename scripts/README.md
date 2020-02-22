# Setup

1. Copy config.sh.template to config.sh and edit config.sh with the values.
1. 1. You can replace the way that CUSER and CPASS are retrieved as long as the variable names are the same.
    Feel free to make use of CP/CCP to retrieve these values, or prompt for them.
* Run the scripts!


Script Name | Use
----------- | ---
config.sh.tempalte | Rename this file to config.sh and edit to set your DAP instance configuration. See Setup step.
authenticate.sh | Load the config.sh file and then authenticates to the DAP api and retrieves an auth token. The authentication header is stored in $AUTH_TOKEN
variables_delete.txt | Used in the variables_delete.sh script to delete variables. One variable path per line.
variables_delete.sh | Script that deletes variables.
variable_setvalue.sh | Set a variable value. Usage: `variable_setvalue.sh <path> <value>`
policy_replace.sh | Replace a policy branch. Usage: `policy_replace.sh <path> <policy_file>`
resources_list.sh | Lists all resources. It may be good to pipe the output of this to 'jq'.
