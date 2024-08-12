# Bash Password Manager

Bash client for macOS and Linux, based on `openssl enc` (`libreSSL enc`) command.

@author Mattia Corvaglia

---

## Encryption Mode

* **Cipher**: `AES-256-CBC` Advanced Encryption Standard (AES) with a 256-bit key in Cipher Block Chaining (CBC) mode.
* **Encoding** (after encryption): `Base64`
* **Digest Algorithm**: `sha256`
* Randomly generated salt


---

## Initialization

1. Clone this repository into your home and rename the folder, e.g. `.pwd-mng`.
2. Add an alias into your `.bash_profile` or `.zshrc` configuration file to be able to run the script from everywhere:
  ```sh
  # add this line into .bash_profile
  alias pass='~/.pwd-mng/pass.sh'

  # Save & close the file, then update the shell environment
  source .zshrc
  ```
3. Edit the following variables of the `pass.sh` script:
  ```sh
  LOCALE_PATH="/path/to/locale/folder/"
  REMOTE_PATH="/path/to/dropbox/or/icloud/"
  ```
4. Create a new file, e.g. `pwd.txt`, and insert into it all the passwords you want to protect.  
  (You can use Markdown markup or every other depending your preferences).
5. Run `pass -i ` to generate the first version of your encrypted password file.
6. Run `pass -c` to clean the folder.

---

## Features

| Command Option | Description |
|----------------|-------------|
| `-h, --help` | Print this help. |
| `-v, --version` | Print script version. |
| `-i [file], --init [file]` | Initialize the password file providing an input file to be encrypted. |
| `-l, --list` | List the content of the password folder. |
| `-g, --get` | Decrypt the password file for reading. |
| `-e, --edit` | Decrypt the password file for editing. |
| `-s, --save` | Save changes encrypting the password file just edited, locally and remotly.  (Remotly versioned  with current date)
| `-c, --clean` | Remove all the temporary files. |
| `-f [name], --find [name]` | Search for name in the password file. |
| `-r, --restore` | Restore the password file to the previous state. |

---

## Remote Versioned Backup

Every time you save changes locally with `pass -s|--save`, a copy of the encrypted file is made in the `REMOTE_PATH`, with this format:
```
/path/to/dropbox/YYYY-mm-dd_pwd.aes
```