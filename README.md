# Bash Password Manager

Based on `openssl enc`.

@author Mattia Corvaglia

---

## Initialization

1. Clone this repository into your home and rename the folder, e.g. `.pwd-mng`.
2. Add an alias into your `.zshrc` or `.bash_profile` configuration file to be able to run the script from everywhere:
  ```sh
  # add this line into .zshrc
  alias pass='~/.pwd-mng/pass.sh'

  # Save & close the file, then update the shell environment
  source .zshrc
  ```
3. Edit the following variables of the `pass.sh` script:
  ```
  LOCALE_PATH="/path/to/locale/folder"
  REMOTE_PATH="/path/to/dropbox/"
  ```
4. Create a new file, e.g. `pwd.txt`, and insert into it all the passwords you want to protect (you can use Markdown format or every other depending your preferences).
5. Run `pass -i ` to generate the first version of your encrypted password file.
6. Run `pass -c` to clean the folder.

---

## Features

```
    -h, --help                    Print this help.

    -v, --version                 Print script version.

    -i [file], --init [file]      Initialize the password file providing
                                  an input file to be encrypted.

    -l, --list                    List the content of the password folder.

    -g, --get                     Decrypt the password file for reading.

    -e, --edit                    Decrypt the password file for editing.

    -s, --save                    Save changes encrypting the password file
                                  just edited, locally and remotly.
                                  (Remotly versioned with current date)

    -c, --clean                   Remove all the temporary files.

    -f [name], --find [name]      Search for name in the password file.

    -r, --restore                 Restore the password file to the
                                  previous state.

```

---

## Remote versioned backup

Every time you save changes locally, a copy of the encrypted file is made in the `REMOTE_PATH`, with this format:
```
/path/to/dropbox/2024-07-23_pwd.aes
```

