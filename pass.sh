#!/bin/bash
# ------------------------------------------------------------------------------
# version         2.0.0
# author          Mattia Corvaglia
# license         GNU General Public License
#
# ------------------------------------------------------------------------------

SCRIPT_NAME="$(basename ${0})"

LOCALE_PATH="/path/to/locale/folder"
REMOTE_PATH="/path/to/dropbox/"
REMOTE_SUFFIX="_pwd.aes"

FILE_ENC="$LOCALE_PATH.pwd.aes"
FILE_TMP="$LOCALE_PATH.tmp.txt"
FILE_BKP="$LOCALE_PATH.bkp.aes"
FILE_CHK="$LOCALE_PATH.chk.txt"

# ------------------------------------------------------------------------------
function usage {
echo "
SYNOPSIS
    $SCRIPT_NAME [-h|-g|-c|-e|-s|-l] [-f|-i [arg ...]]

DESCRIPTION
    Bash client for managing password file.

OPTIONS

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
  PASSPRHASE=""
  echo -n "Enter the password: "
  read -s PASSPRHASE
  echo ""

  # Decrypt the file
  openssl enc -aes-256-cbc -base64 -d -in $FILE_ENC -out $FILE_TMP -k $PASSPRHASE 2> /dev/null

  # Check the exit status
  if [ $? -ne 0 ]
  then
    echo "Invalid password!"
    rm $FILE_TMP 2> /dev/null
    unset PASSPRHASE
    exit 1
  fi
}

# ------------------------------------------------------------------------------
function encrypt {
  PASSPRHASE=""
  echo -n "Enter the password: "
  read -s PASSPRHASE
  echo ""

  # Check the passphrase
  openssl enc -aes-256-cbc -base64 -d -in $FILE_BKP -out $FILE_CHK -k $PASSPRHASE 2> /dev/null

  # Check the exit status
  if [ $? -ne 0 ]
  then
    echo "Invalid password!"
    rm $FILE_CHK
    unset PASSPRHASE
    exit 1
  else
    # Encrypt the new secret file
    openssl enc -aes-256-cbc -base64 -salt -in $FILE_TMP -out $FILE_ENC -k $PASSPRHASE 2> /dev/null

    if [ $? -ne 0 ]
    then
      echo "Error while encrypting the new file."
      rm $FILE_CHK
      rm $FILE_ENC
      unset PASSPRHASE
      exit 1
    fi
  fi

  rm $FILE_TMP
  rm $FILE_CHK
  rm $FILE_BKP
}

# ------------------------------------------------------------------------------
function show {
  decrypt
  open $FILE_TMP
  echo "Remember to run \"pass -c|--clean\" to clean the temporary files."
}

# ------------------------------------------------------------------------------
function doctor {
  ls -FGlAhp $LOCALE_PATH
}

# ------------------------------------------------------------------------------
function clean {
  rm $FILE_TMP
  echo "The password folder has been cleaned."
}

# ------------------------------------------------------------------------------
function restore {
  mv $FILE_BKP $FILE_ENC
  rm $FILE_TMP
  echo "The password file has been restored to the previous state."
}

# ------------------------------------------------------------------------------
function edit {
  decrypt
  mv $FILE_ENC $FILE_BKP
  open $FILE_TMP
  echo "Remember to run \"pass -s|--save\" for saving changes."
  echo "In case of errors, run \"pass -r|--restore\" to restore the password file."
}

# ------------------------------------------------------------------------------
function save {
  encrypt
  NOW=$(date '+%Y-%m-%d')
  cp $FILE_ENC $REMOTE_PATH$NOW$REMOTE_SUFFIX
  echo "The password file has been updated."
}

# ------------------------------------------------------------------------------
function find {
  if [ -z "$1" ]
  then
    echo "Invalid option. You must provide a name after -f|--find option."
    exit 1
  fi
  decrypt
  cat $FILE_TMP | grep $1
  rm $FILE_TMP
}

# ------------------------------------------------------------------------------
function init {
  if [ -z "$1" ]
  then
    echo "Invalid option. You must provide a file after -i|--init option."
    exit 1
  fi
  mv $1 $FILE_TMP
  openssl enc -aes-256-cbc -base64 -salt -in $FILE_TMP -out $FILE_ENC 2> /dev/null
  if [ $? -ne 0 ]
  then
    echo "Error while encrypting the new file."
    rm $FILE_TMP
    unset PASSPRHASE
    exit 1
  fi
  rm $FILE_TMP
}

# ------------------------------------------------------------------------------
while [ "$#" -gt 0 ]
do
  case "$1" in
    -i|--init) init "$2" ;;
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
unset LOCALE_PATH
unset FILE_ENC
unset FILE_TMP
unset FILE_BKP
unset FILE_CHK
unset REMOTE_PATH
unset REMOTE_SUFFIX

exit