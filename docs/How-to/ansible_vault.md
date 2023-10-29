# ansible vault management

ansible password are encoded with a gpg key store in ansible/misc
to renew password follow this workflown

```sh
# Generate a new password for the default vault
pwgen -s 64 default-pw

# Re-encrypt all default vaults
ansible-vault rekey --new-vault-password-file ./default-pw \
  $(git grep -l 'ANSIBLE_VAULT;1.1;AES256$')

# Save the new password in encrypted form
# (replace "RECIPIENT" with your email)
gpg -r RECIPIENT -o misc/vault--password.gpg -e default-pw

# Ensure the new password is usable
ansible-vault view misc/vaults/vault_hcloud.yml

# Remove the unencrypted password file
rm new-default-pw
```

script `vault-keyring-client.sh` is set in ansible.cfg as vault_password_file to decrypt the gpg file
