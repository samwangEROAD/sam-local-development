# start local portal with PR image
run the command below in your terminal(replace the number with your actual PR number).

`./run-pr.sh 5198`

If you cannot run `run-pr.sh` as executable, please run `chmod +x ./run-pr.sh` in `portal` and try again.

You should also add `127.0.0.1 localhost.eroad.com` to the end of `/etc/hosts` file, then you can visit portal with `http://localhost.eroad.com` in your browser.

If you get the error, then comment the 44th line and uncomment the 43rd line in the file run-pr.sh.

```Error: Cannot perform an interactive login from a non TTY device```
