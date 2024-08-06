# Bash Password Manager

Based on `openssl enc`.

@author Mattia Corvaglia

---

## Features

```
    -h, --help                    Print help.

    -v, --version                 Print script version.

    -l, --list                    List the content of the password folder.

    -g, --get                     Get the decrypted password file for reading.

    -e, --edit                    Get the decrypted password file for editing.

    -s, --save                    Save the password file just edited.

    -c, --clean                   Remove all the temporary files.

    -f [name], --find [name]      Search for name in the password file.

    -r, --restore                 Restore the password folder to the
                                  previous state.

```

---

## Configuration

Initialize the following variable:

```
BASE_PATH="/path/to/files/"
REMOTE_FILE="/path/to/dropbox/.pwd_enc.txt"
```

