#!/bin/bash

# Function to XOR a string with a key
xor_encrypt_decrypt() {
  local input="$1"
  local key="$2"
  local output=""
  for ((i=0; i<${#input}; i++)); do
    output+=$(printf "\\x$(printf %x "$(( $(printf '%d' "'${input:$i:1}") ^ $(printf '%d' "'${key:$((i % ${#key})):1}") ))")")
  done
  echo "$output"
}

# Function to encrypt a string using XOR and base64
xor_encrypt_string() {
  local string="$1"
  local key="$2"
  local encrypted_string
  encrypted_string=$(xor_encrypt_decrypt "$string" "$key" | base64)
  echo "$encrypted_string"
}

# Function to decrypt a string using XOR and base64
xor_decrypt_string() {
  local encrypted_string="$1"
  local key="$2"
  local decrypted_string
  decrypted_string=$(echo "$encrypted_string" | base64 --decode | xor_encrypt_decrypt "$(cat)" "$key")
  echo "$decrypted_string"
}

# Only encrypt/decrypt the text that lt than key's length. so make key longer if u want to xor a long content
GLOBAL_XOR_KEY="XOR_LENGTH_IS_ME_19"


# Example usage
STRING="Hello_World"

ENCRYPTED_STRING=$(xor_encrypt_string "$STRING" "$GLOBAL_XOR_KEY")
echo "Encrypted string: $ENCRYPTED_STRING"
DECRYPTED_STRING=$(xor_decrypt_string "$ENCRYPTED_STRING" "$GLOBAL_XOR_KEY")
echo "Decrypted string: $DECRYPTED_STRING"

STRING="You're right"

ENCRYPTED_STRING=$(xor_encrypt_string "$STRING" "$GLOBAL_XOR_KEY")
echo "Encrypted string: $ENCRYPTED_STRING"
DECRYPTED_STRING=$(xor_decrypt_string "$ENCRYPTED_STRING" "$GLOBAL_XOR_KEY")
echo "Decrypted string: $DECRYPTED_STRING"


VALUE_STRING_1=$(xor_decrypt_string "ECo+MyMaGSgmJDsK" "$GLOBAL_XOR_KEY")
VALUE_STRING_2=$(xor_decrypt_string "ASAneD4gbjU9Lzc9Cg==" "$GLOBAL_XOR_KEY")
echo "VALUE_STRING_1 string: $VALUE_STRING_1"
echo "VALUE_STRING_2 string: $VALUE_STRING_2"
