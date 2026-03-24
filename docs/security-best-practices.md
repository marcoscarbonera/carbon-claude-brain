# Security Best Practices

This document provides additional security recommendations for using carbon-claude-brain safely.

## Credential Management

### Local Inkdrop Credentials

The Inkdrop credentials are stored in plaintext at `~/.carbon-brain/config` with `600` permissions. While this is acceptable for a local-only server, follow these best practices:

**Do:**
- ✅ Use a **different password** from your Inkdrop Cloud account
- ✅ Use a strong, unique password for the local server
- ✅ Keep the local Inkdrop server **disabled when not in use**
- ✅ Regularly rotate your local server password (every 3-6 months)
- ✅ Verify file permissions: `ls -l ~/.carbon-brain/config` should show `-rw-------`

**Don't:**
- ❌ Share the config file or commit it to version control
- ❌ Reuse passwords from other services
- ❌ Leave the Inkdrop local server running 24/7 if not needed
- ❌ Store sensitive production credentials in Obsidian/Inkdrop notes

### Obsidian Vault Security

**Vault Location:**
- Store your vault in an encrypted partition if possible (FileVault on macOS, LUKS on Linux)
- Avoid cloud-synced folders if the vault contains sensitive project information
- Use Obsidian's official sync for encrypted cloud storage (paid feature)

**Sensitive Information:**
- Never store production API keys, passwords, or tokens in notes
- Use placeholders like `[REDACTED]` or `<YOUR_API_KEY>` in documentation
- If you must reference credentials, use a password manager and link to it

## Network Security

### Inkdrop Local Server

The local HTTP server runs on `localhost:19840` and should **never** be exposed to the network:

**Verify it's local-only:**
```bash
# Check that Inkdrop server only binds to localhost
lsof -i :19840 | grep LISTEN
# Should show 127.0.0.1:19840, NOT 0.0.0.0:19840
```

**Firewall rules:**
- Ensure your firewall blocks external access to port 19840
- On macOS: System Settings → Network → Firewall → Options
- On Linux: `sudo ufw deny 19840` or equivalent

### SSH and Remote Access

If you access your development machine remotely:
- Use SSH key authentication, not passwords
- Disable SSH password authentication in `/etc/ssh/sshd_config`
- Consider using a VPN for remote access
- Never expose Inkdrop's port over SSH port forwarding to untrusted networks

## File System Security

### Permissions

Verify correct permissions after installation:

```bash
# Config file should be readable/writable only by you
ls -l ~/.carbon-brain/config
# Output: -rw------- (600)

# Hooks should be executable only by you
ls -l ~/.claude/hooks/carbon-brain-*.sh
# Output: -rwx------ (700) or -rwxr-xr-x (755)

# Activity log should be private
ls -l ~/.carbon-brain/activity.log
# Output: -rw------- (600) recommended
```

**Fix incorrect permissions:**
```bash
chmod 600 ~/.carbon-brain/config
chmod 600 ~/.carbon-brain/activity.log
chmod 700 ~/.claude/hooks/carbon-brain-*.sh
```

### Backup Security

If you backup your vault or config:
- **Encrypt backups** that contain the config file
- Use tools like `gpg`, `age`, or `7z` with strong passwords
- Store backups in encrypted cloud storage or external drives
- Test backup restoration periodically

**Example encrypted backup:**
```bash
# Backup with encryption
tar czf - ~/.carbon-brain ~/path/to/vault | \
  gpg --symmetric --cipher-algo AES256 -o carbon-brain-backup.tar.gz.gpg

# Restore
gpg -d carbon-brain-backup.tar.gz.gpg | tar xzf -
```

## Multi-User Systems

If multiple users access the same machine:

### Isolation
- Each user should have their own Inkdrop account and vault
- Do not share `~/.carbon-brain/config` between users
- Use separate Obsidian vaults per user

### Shared Projects
- For team projects, use Obsidian Sync (paid) or Git for version control
- **Never commit** personal preferences or Inkdrop journals to shared repos
- Keep project context in Git, personal notes in local-only vault

## Audit and Monitoring

### Regular Security Checks

**Monthly review:**
```bash
# Check for unusual file modifications
find ~/.carbon-brain -type f -mtime -30 -ls

# Review activity log for unexpected tool usage
tail -100 ~/.carbon-brain/activity.log

# Verify no unexpected hooks registered
cat ~/.claude/settings.json | grep carbon-brain
```

**Look for:**
- Unexpected modifications to config file
- Unusual activity patterns in logs
- New hooks or skills you didn't install

### Credential Rotation

**Every 3-6 months:**
1. Change Inkdrop local server password
2. Update `~/.carbon-brain/config` with new credentials
3. Test that hooks still work: `/carbon-brain-test`

## Incident Response

If you suspect compromise:

### Immediate Actions
1. **Disconnect from network** if actively under attack
2. **Change all passwords** (Inkdrop Cloud, local server, OS account)
3. **Review logs** for unauthorized access
4. **Check crontab/launchd** for persistence mechanisms

### Investigation
```bash
# Check for modified system files
ls -lart ~/.*history
ls -lart ~/.ssh/
ls -lart ~/.carbon-brain/

# Review Claude Code hooks
cat ~/.claude/settings.json

# Check running processes
ps aux | grep -E "(inkdrop|node|curl)"
```

### Recovery
1. Uninstall carbon-claude-brain: `./uninstall.sh`
2. Remove config: `rm -rf ~/.carbon-brain`
3. Audit your Obsidian vault for malicious content
4. Reinstall with fresh credentials
5. Consider reporting the incident (see SECURITY.md)

## Advanced Security

### Optional Enhancements

**1. Encrypted Config Storage (Advanced)**

Use `age` or `gpg` to encrypt the config file:

```bash
# Install age: brew install age (macOS) or apt install age (Linux)

# Encrypt config
age -p ~/.carbon-brain/config > ~/.carbon-brain/config.age
rm ~/.carbon-brain/config

# Modify hooks to decrypt on-the-fly
# (Requires entering password on each session start)
```

**2. Process Isolation**

Run Inkdrop in a container or VM for additional isolation:
- Docker container with network isolated to localhost only
- Virtual machine with no network bridging
- macOS sandboxing with restricted entitlements

**3. Audit Logging**

Enable system audit logging for file access:

**macOS:**
```bash
sudo audit -s  # Enable auditing
sudo praudit /var/audit/* | grep carbon-brain
```

**Linux:**
```bash
sudo auditctl -w ~/.carbon-brain -p rwa -k carbon-brain-access
sudo ausearch -k carbon-brain-access
```

## Security Tools

Recommended security tools to use alongside carbon-claude-brain:

1. **Password Managers**: 1Password, Bitwarden, KeePassXC
2. **Disk Encryption**: FileVault (macOS), LUKS (Linux), BitLocker (Windows)
3. **Backup Tools**: Restic, Borg, Time Machine (encrypted)
4. **Network Monitors**: Little Snitch (macOS), OpenSnitch (Linux)
5. **Antivirus**: ClamAV, Malwarebytes (if concerned about malware)

## Compliance Considerations

If using for work/business:

- **Check company policies** on local credential storage
- **GDPR/Privacy**: Don't store PII in plaintext notes
- **Data retention**: Configure log rotation appropriately
- **Audit requirements**: May need encrypted backups with retention

## Reporting Security Issues

If you discover a security vulnerability in carbon-claude-brain:

1. **Do NOT** open a public GitHub issue
2. Report via [Security Advisory](https://github.com/marcoscarbonera/carbon-claude-brain/security/advisories/new)
3. Include reproduction steps, impact assessment, and suggested fixes
4. Allow time for patch before public disclosure

See [SECURITY.md](../SECURITY.md) for full vulnerability disclosure policy.

## Additional Resources

- [Obsidian Security Best Practices](https://obsidian.md/security)
- [Inkdrop Security](https://docs.inkdrop.app/manual/security)
- [OWASP Secure Coding Practices](https://owasp.org/www-project-secure-coding-practices-quick-reference-guide/)
- [CIS Benchmarks](https://www.cisecurity.org/cis-benchmarks) for OS hardening

---

**Remember:** Security is a process, not a product. Regularly review and update your security practices as threats evolve.
