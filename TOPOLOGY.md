# Fleet Topology

Auto-generated visualizations of the nix-config fleet's
aspect-resolution pipeline, scope tree, and data flow.

## Scope Topology

```mermaid
graph TD
  host_nixos_system_x86_64_linux["host: nixos"]
  host_nixos_system_x86_64_linux_user_artifex(["user: artifex"])
  host_sandbox_system_x86_64_linux["host: sandbox"]
  host_sandbox_system_x86_64_linux_user_artifex(["user: artifex"])
  host_super_system_x86_64_linux["host: super"]
  host_super_system_x86_64_linux_user_artifex(["user: artifex"])
  system_x86_64_linux["flake-system: system=x86_64-linux"]

  system_x86_64_linux --> host_nixos_system_x86_64_linux
  host_nixos_system_x86_64_linux --> host_nixos_system_x86_64_linux_user_artifex
  system_x86_64_linux --> host_sandbox_system_x86_64_linux
  host_sandbox_system_x86_64_linux --> host_sandbox_system_x86_64_linux_user_artifex
  system_x86_64_linux --> host_super_system_x86_64_linux
  host_super_system_x86_64_linux --> host_super_system_x86_64_linux_user_artifex

  style host_nixos_system_x86_64_linux fill:#a6e3a1,stroke:#a6e3a1,color:#1e1e2e
  style host_nixos_system_x86_64_linux_user_artifex fill:#fab387,stroke:#fab387,color:#1e1e2e
  style host_sandbox_system_x86_64_linux fill:#a6e3a1,stroke:#a6e3a1,color:#1e1e2e
  style host_sandbox_system_x86_64_linux_user_artifex fill:#fab387,stroke:#fab387,color:#1e1e2e
  style host_super_system_x86_64_linux fill:#a6e3a1,stroke:#a6e3a1,color:#1e1e2e
  style host_super_system_x86_64_linux_user_artifex fill:#fab387,stroke:#fab387,color:#1e1e2e
  style system_x86_64_linux fill:#94e2d5,stroke:#94e2d5,color:#1e1e2e
```

## Policy Resolution

```mermaid
graph TD
  flake(["flake"])
  host_nixos_system_x86_64_linux["host: nixos"]
  host_nixos_system_x86_64_linux_user_artifex(["user: artifex"])
  host_sandbox_system_x86_64_linux["host: sandbox"]
  host_sandbox_system_x86_64_linux_user_artifex(["user: artifex"])
  host_super_system_x86_64_linux["host: super"]
  host_super_system_x86_64_linux_user_artifex(["user: artifex"])
  system_x86_64_linux["flake-system: system=x86_64-linux"]

  system_x86_64_linux -->|system-to-os-outputs| host_nixos_system_x86_64_linux
  host_nixos_system_x86_64_linux -->|host-to-hm-users| host_nixos_system_x86_64_linux_user_artifex
  system_x86_64_linux -->|system-to-os-outputs| host_sandbox_system_x86_64_linux
  host_sandbox_system_x86_64_linux -->|host-to-hm-users| host_sandbox_system_x86_64_linux_user_artifex
  system_x86_64_linux -->|system-to-os-outputs| host_super_system_x86_64_linux
  host_super_system_x86_64_linux -->|host-to-hm-users| host_super_system_x86_64_linux_user_artifex
  flake -->|flake-to-systems| system_x86_64_linux

  style flake fill:#89b4fa,stroke:#89b4fa,color:#1e1e2e
  style host_nixos_system_x86_64_linux fill:#a6e3a1,stroke:#a6e3a1,color:#1e1e2e
  style host_nixos_system_x86_64_linux_user_artifex fill:#fab387,stroke:#fab387,color:#1e1e2e
  style host_sandbox_system_x86_64_linux fill:#a6e3a1,stroke:#a6e3a1,color:#1e1e2e
  style host_sandbox_system_x86_64_linux_user_artifex fill:#fab387,stroke:#fab387,color:#1e1e2e
  style host_super_system_x86_64_linux fill:#a6e3a1,stroke:#a6e3a1,color:#1e1e2e
  style host_super_system_x86_64_linux_user_artifex fill:#fab387,stroke:#fab387,color:#1e1e2e
  style system_x86_64_linux fill:#94e2d5,stroke:#94e2d5,color:#1e1e2e
```

## Pipe Flow

```mermaid
graph LR
  note(["No pipe flows detected"])
```

## Pipe Sequence

```mermaid
sequenceDiagram
    participant none as No hosts
```

## Fleet Summary

# Fleet Summary

## Topology

- **0** environments, **3** hosts, **1** users
- Scope chain: flake → flake-system → host → user
- Trace entries: 557

## Environments

| Environment | Hosts | Host Count | Users |
| ------------- | ------- | ------------ | ------- |

## Aspects by Host

| Host | Aspect Count | Aspects |
| ------ | -------------- | --------- |
| nixos | 7 | define-user/artifex@nixos, host/resolve(dev), hostname/os, impermanence, inputs'/os, nixos, self'/os |
| sandbox | 5 | define-user/artifex@sandbox, hostname/os, inputs'/os, sandbox, self'/os |
| super | 7 | define-user/artifex@super, host/resolve(dev), hostname/os, impermanence, inputs'/os, self'/os, super |

## Pipes

| Pipe | Scope Boundary | Producers | Collectors |
| ------ | ---------------- | ----------- | ------------ |
| cache | flake-system: system=x86_64-linux | nixos, super |  |
| cacheHome | flake-system: system=x86_64-linux | nixos, sandbox, super |  |
| codium-extensions | flake-system: system=x86_64-linux | nixos, super |  |
| codium-settings | flake-system: system=x86_64-linux | nixos, super |  |
| devenv | flake-system: system=x86_64-linux | nixos, super |  |
| homeManagerModules | flake-system: system=x86_64-linux | nixos, super |  |
| isWorkstation | flake-system: system=x86_64-linux | nixos, sandbox, super |  |
| nixpkgs-overlays | flake-system: system=x86_64-linux | nixos, sandbox, super |  |
| persist | flake-system: system=x86_64-linux | nixos, sandbox, super |  |
| persistHome | flake-system: system=x86_64-linux | nixos, sandbox, super |  |
| tests | flake-system: system=x86_64-linux | nixos, super |  |

## Policies

| Policy | Fires at |
| -------- | ---------- |
| flake-to-systems | flake |
| apps-to-flake | flake-system |
| checks-to-flake | flake-system |
| devShells-to-flake | flake-system |
| legacyPackages-to-flake | flake-system |
| packages-to-flake | flake-system |
| system-to-os-outputs | flake-system |
| host-to-hm-users | host |
| host-to-users | host |
| os-to-host | host |
| artifex/to-hosts | user |
| hm-user-detect | user |
| host-aspects-project | user |
| project-user-overlays | user |
| user-to-host | user |
