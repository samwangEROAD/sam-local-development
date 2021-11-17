# Start local portal with built portal war
* Run `../get-login.sh` first which logs in with your okta account and aws ecr, then run `../start.sh`

* By default, the local portal points to dev environment Database and upstream/downstream service and uses dev [depot-configuration](https://github.com/eroad/depot-configuration/blob/434cfc7c221acefc785ee0958a358e6ae0f7bedb/configuration/dev.yml#L1136). 

* You can run `export DEPOT_ENVIRONMENT=test` to switch to test environment before you run `../start.sh`
    * Or you can update the file ../start.sh once for all, changing 'dev' to 'test' in this line: "export DEPOT_ENVIRONMENT=${DEPOT_ENVIRONMENT:=dev}"

# Start local portal with PR image
* Run the command below in your terminal(replace the number with your actual PR number). It points to test environment by default.

`./run-pr.sh 5198`
## Troubleshooting
|Error|Solution|
|---|---|
|`bash: ./run-pr.sh: Permission denied`|run `chmod +x ./run-pr.sh`|
|`Error: Cannot perform an interactive login from a non TTY device`|comment the 44th line and uncomment the 43rd line in the file run-pr.sh |

# Change /etc/hosts for visiting local portal with the domain "eroad.com" 
You should add `127.0.0.1 localhost.eroad.com` to the end of `/etc/hosts` file, then you can visit portal with `http://localhost.eroad.com` in your browser.

# Change a value of a toggle feature
By default, local portal will use the [configurations](https://github.com/eroad/depot-configuration) in respective environment.
 
You can set/update a value of a toggle for your local by setting the value in dynamicconfig.properties(or pr-test/dynamicconfig-pr.properties), e.g.:
`auth.entrypoint.forceHttp=false` 

