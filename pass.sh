#!/bin/bash
# ------------------------------------------------------------------------------
# version         2.0.0
# author          Mattia Corvaglia
# license         GNU General Public License
#
# ------------------------------------------------------------------------------

SCRIPT_NAME="$(basename ${0})"
BASE_PATH="/path/to/files/"
ENC_FILE="$BASE_PATH.pwd_enc.txt"
BACKUP_FILE="$BASE_PATH.pwd_bkp.txt"
TEMP_FILE="$BASE_PATH.pwd_tmp.txt"
GHOST_FILE="$BASE_PATH.pwd_chk.txt"
REMOTE_FILE="/path/to/dropbox/.pwd_enc.txt"

# ------------------------------------------------------------------------------
function usage {
echo "
SYNOPSIS
    $SCRIPT_NAME [-h|-g|-c|-e|-s|-l] [-f] [arg ...]

DESCRIPTION
    Bash client for managing password file.

OPTIONS

    -h, --help                    Print this help.

    -v, --version                 Print script version.

    -l, --list                    List the content of the password folder.

    -g, --get                     Get the decrypted password file for reading.

    -e, --edit                    Get the decrypted password file for editing.

    -s, --save                    Save the password file just edited.

    -c, --clean                   Remove all the temporary files.

    -f [name], --find [name]      Search for name in the password file.

    -r, --restore                 Restore the password folder to the
                                  previous state.

EXAMPLES
    $SCRIPT_NAME -f google

"
  exit
}

# ------------------------------------------------------------------------------
function version {
echo "
IMPLEMENTATION
    version         2.0.0
    author          Mattia Corvaglia
    license         GNU General Public License

"
  exit
}

# ------------------------------------------------------------------------------
function invalid_opt {
  echo "Invalid option: $1"
  echo "Use -h for getting help."
  exit 1
}

# ------------------------------------------------------------------------------
function decrypt {
  # Get the passphrase
  PASSPRHASE=""
  echo -n "Enter the password: "
  read -s PASSPRHASE
  echo ""

  # Decrypt the file
  openssl enc -aes-256-cbc -base64 -md sha-256 -d -in $ENC_FILE -out $TEMP_FILE -k $PASSPRHASE 2> /dev/null

  # Check the exit status
  if [ $? -ne 0 ]
  then
    echo "Invalid password!"
    rm $TEMP_FILE
    unset PASSPRHASE
    exit 1
  fi
}

# ------------------------------------------------------------------------------
function encrypt {
  # Get the passphrase
  PASSPRHASE=""
  echo -n "Enter the password: "
  read -s PASSPRHASE
  echo ""

  # Check the passphrase
  openssl enc -aes-256-cbc -base64 -md sha-256 -d -in $BACKUP_FILE -out $GHOST_FILE -k $PASSPRHASE 2> /dev/null

  # Check the exit status
  if [ $? -ne 0 ]
  then
    echo "Invalid password!"
    unset PASSPRHASE
    exit 1
  else
    # Encrypt the new secret file
    openssl enc -aes-256-cbc -base64 -md sha-256 -salt -in $TEMP_FILE -out $ENC_FILE -k $PASSPRHASE 2> /dev/null

    if [ $? -ne 0 ]
    then
      echo "Error while encrypting the new file."
      rm $GHOST_FILE
      rm $ENC_FILE
      unset PASSPRHASE
      exit 1
    fi
  fi

  rm $TEMP_FILE
  rm $GHOST_FILE
  rm $BACKUP_FILE
}

# ------------------------------------------------------------------------------
function show {
  decrypt
  open $TEMP_FILE
  echo "Remember to run \"pass -c|--clean\" to clean the temporary files."
}

# ------------------------------------------------------------------------------
function doctor {
  ls -lart $BASE_PATH
}

# ------------------------------------------------------------------------------
function clean {
  rm $TEMP_FILE
  echo "The password folder has been cleaned."
}

# ------------------------------------------------------------------------------
function restore {
  mv $BACKUP_FILE $ENC_FILE
  rm $TEMP_FILE
  echo "The password file has been restored to the previous state."
}

# ------------------------------------------------------------------------------
function edit {
  decrypt
  mv $ENC_FILE $BACKUP_FILE
  open $TEMP_FILE
  echo "Remember to run \"pass -s|--save\" for saving changes."
  echo "In case of errors, run \"pass -r|--restore\" to restore the password file."
}

# ------------------------------------------------------------------------------
function save {
  encrypt
  cp $ENC_FILE $REMOTE_FILE
  echo "The password file has been updated."
}

# ------------------------------------------------------------------------------
function find {
  if [ -z "$1" ]
  then
    echo "Invalid option. You must provide a name after -f option."
    exit 1
  fi
  decrypt
  cat $TEMP_FILE | grep $1
  rm $TEMP_FILE
}

# ------------------------------------------------------------------------------
while [ "$#" -gt 0 ]
do
  case "$1" in
    -f|--find) find "$2" ;;
    -g|--get) show ;;
    -c|--clean) clean ;;
    -l|--list) doctor ;;
    -e|--edit) edit ;;
    -s|--save) save ;;
    -h|--help) usage ;;
    -v|--version) version ;;
    -r|--restore) restore ;;
    -*) invalid_opt "$1" ;;
    *) break ;;
  esac
  shift
done

# Unset all the variables
unset PASSPRHASE
unset BASE_PATH
unset ENC_FILE
unset TEMP_FILE
unset BACKUP_FILE
unset GHOST_FILE
unset REMOTE_FILE

exit