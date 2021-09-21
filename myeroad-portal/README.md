# MyEroad Portal

### Usage

Run MyEroad Portal `PR-1203` locally:

```bash
cd myeroad-portal
./run-pr.sh 1203 
```

You will see something like this in command line output:
```
web_1  | ----------------------------------------------
web_1  | [OK] Serving static files from ./myeroad-portal-build
web_1  | [OK] Using the fallback file index.html
web_1  | [OK] Listening on http://localhost:3000
web_1  | ----------------------------------------------
```

You should also add `127.0.0.1 localhost.eroad.com` to the end of `/etc/hosts` file, then you can visit myeroad with `http://localhost.eroad.com:3000` in your browser.

If you cannot run `run-pr.sh` as executable, please run `chmod +x ./run-pr.sh` in `myeroad-portal` and try again.

If you get the error, then comment the 44th line and uncomment the 43rd line in the file run-pr.sh.

```Error: Cannot perform an interactive login from a non TTY device```