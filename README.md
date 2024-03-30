# mail-checker
Use `telnet` and `dig` to check on the mail server if given email are valid.

## Usage
```bash
[ = ] Help Usage: ./mailcheck.sh [OPTION] ...
[ i ] Check if email is in mail server records (telnet dig)
        -h --help                Display this help page
        AUTO MODE:               Check if given email is in mail server records
        PIPE MODE:               Check for each email from pipe (separator:EOF)
        MANUAL MODE:
        -e --email               Check on the previously set email server (default: gmail)
        -d --domain              Set email server by extracting it from dns record of the domain
        -s --mx-server           Set the given email server to checking server

Info: to avoid anti-spam protection take mesures (proxy...)
```

## Example

|||
|:--:|:--:|
|![image](https://github.com/lostsh/mail-checker/assets/43549864/016d4cc3-f0ac-41ce-b9d8-899a669d9243)|![image](https://github.com/lostsh/mail-checker/assets/43549864/8deb23f0-0032-44ef-b302-96c229ad7bcb)|

