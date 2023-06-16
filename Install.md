# Installing Development Dependencies

<hr>

<h4 align="center">
<a href="link here">Repositry</a>
</h4>

### After installing OS(arch and windows prefered) on WSL or container

### Dependencies

#### For Windows - Windows 11 or Windows 10

<h3><a href="https://scoop.sh">Scoop</a></h3>

```powershell
# Optional: Needed to run a remote script the first
Set-ExecutionPolicy RemoteSigned -Scope CurrentUser
# Install Scoop
irm get.scoop.sh | iex
```

#### For Admin

Installation under the administrator console has been disabled by default for security considerations. If you know what you are doing and want to install Scoop as administrator. Please download the installer and manually execute it with the `-RunAsAdmin` parameter in an elevated console. Here is the example:

```powershell
irm get.scoop.sh -outfile 'install.ps1'
.\install.ps1 -RunAsAdmin [-OtherParameters ...]
# I don't care about other parameters and want a one-line command
iex "& {$(irm get.scoop.sh)} -RunAsAdmin"
```

<h4><a href="https://github.com/PowerShell/PowerShell">Powershell</a></h4>

```powershell

```

 <h4><a href="">Powershell</a></h4>
 <h4><a href="">Powershell</a></h4>
 <h4><a href="">Powershell</a></h4>
 <h4><a href="">Powershell</a></h4>
 <h4><a href="">Powershell</a></h4>

#### For Linux - Arch based
