# Used commands to generate

## Option 1: Unprotected Keys

Generate a `master.age` in a hidden secrets folder:

```sh
mkdir -p .secrets
age-keygen -o .secrets/master.age
```

Generate a `master.pub` from that file:

```sh
age-keygen -y .secrets/master.age > master.pub
```

## Option 2: Password-Protected Keys

Generate a keypair and encrypt the private key with a password immediately:

```sh
mkdir -p .secrets
age-keygen | age -p -o .secrets/master.age
```

Generate the `master.pub` from the password-protected private key:

```sh
age -d .secrets/master.age | age-keygen -y > master.pub
```

## Usage

### Encrypting a Secret (e.g., Linux Passwords or SSH Keys)

- `echo -n`: Sends string data without a trailing newline.
- `-r $(cat master.pub)`: Reads your public key as the recipient.
- `-a`: Formats the output as text (ASCII-armored) instead of binary.
- `-o`: Saves the encrypted result to a file.

**For a text string / password:**

```sh
echo -n "MyLinuxUserPassword123!" | age -r \$(cat master.pub) -a -o user_password.age
```

**For an SSH Private Key file (e.g., id_ed25519):**

```sh
age -r \$(cat master.pub) -a -o id_ed25519.age ~/.ssh/id_ed25519
```

### Decrypting

```sh
age -d -i .secrets/master.age user_password.age
```

# DevOps Secrets Management Guide (age + SecretSpec)

This guide covers generating master cryptographic keys using `age` and integrating them into project workflows with `SecretSpec`.

---

## 🔑 Part 1: Managing Master Keys (`age`)

Always run generation commands from a secure location and **do not** commit master private keys to the repository.

- **Unprotected Keys:** Generate a private key and its public counterpart `master.pub`.
- **Password-Protected Keys (Recommended):** Generate and encrypt the private key immediately with a password.

---

## ⚙️ Part 2: Project Setup (`SecretSpec`)

Configure SecretSpec inside your repository to manage application secrets.

1. **Create the Project Roster (`secrets.age.recipients`):** Place your public key (`master.pub`) into this file in your project root.
2. **Configure the Manifest (`secretspec.toml`):** Map your application secrets to the `age` provider in this configuration file.
3. **Load Your Identity:** Export your private key via the `AGE_IDENTITY` environment variable before running SecretSpec commands.

---

## 🚀 Part 3: Usage & Operations

- **SecretSpec Commands:** Use `secretspec set <KEY>` to save/update secrets and `secretspec get <KEY>` to retrieve them.
- **Manual Encryption/Decryption:** You can also use `age` directly to manually encrypt or decrypt raw strings, files, or SSH keys.

---

## ⚠️ Git Commit Strategy

- **SAFE to commit:** `secretspec.toml`, `secrets.age.recipients`, and encrypted secret files.
- **NEVER commit:** Local master private keys (e.g., `.secrets/master.age`). Ensure local secret directories are added to `.gitignore`.
