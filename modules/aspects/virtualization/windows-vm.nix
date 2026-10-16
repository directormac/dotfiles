# Declarative Windows VM with QEMU / Libvirt and Looking Glass
{ den, ... }:
{
  den.aspects.virtualization.windows-vm = {
    includes = with den.aspects; [
      virtualization.libvirt
      virtualization.looking-glass
    ];

    nixos =
      { pkgs, ... }:
      let
        winVmXml = pkgs.writeText "windows-vm.xml" ''
          <domain type='kvm'>
            <name>win11</name>
            <memory unit='GiB'>16</memory>
            <currentMemory unit='GiB'>16</currentMemory>
            <vcpu placement='static'>8</vcpu>
            <os>
              <type arch='x86_64' machine='q35'>hvm</type>
              <loader readonly='yes' type='pflash'>${pkgs.OVMF.fd}/FV/OVMF_CODE.fd</loader>
              <boot dev='hd'/>
            </os>
            <features>
              <acpi/>
              <apic/>
              <hyperv mode='custom'>
                <relaxed state='on'/>
                <vapic state='on'/>
                <spinlocks state='on' threshold='8191'/>
                <vendor_id state='on' value='randomid'/>
              </hyperv>
              <kvm>
                <hidden state='on'/>
              </kvm>
            </features>
            <cpu mode='host-passthrough' check='none'>
              <topology sockets='1' dies='1' cores='4' threads='2'/>
            </cpu>
            <clock offset='localtime'>
              <timer name='rtc' tickpolicy='catchup'/>
              <timer name='pit' tickpolicy='delay'/>
              <timer name='hpet' present='no'/>
              <timer name='hypervclock' present='yes'/>
            </clock>
            <devices>
              <emulator>${pkgs.qemu_kvm}/bin/qemu-system-x86_64</emulator>
              <disk type='file' device='disk'>
                <driver name='qemu' type='qcow2' discard='unmap'/>
                <source file='/var/lib/libvirt/images/win11.qcow2'/>
                <target dev='vda' bus='virtio'/>
              </disk>
              <interface type='network'>
                <source network='default'/>
                <model type='virtio'/>
              </interface>
              <shmem name='looking-glass'>
                <model type='ivshmem-plain'/>
                <size unit='M'>128</size>
              </shmem>
              <tpm model='tpm-crb'>
                <backend type='emulator' version='2.0'/>
              </tpm>
              <graphics type='spice' autoport='yes'>
                <listen type='address' address='127.0.0.1'/>
                <image compression='off'/>
              </graphics>
              <video>
                <model type='qxl'/>
              </video>
            </devices>
          </domain>
        '';

        windowsVmScript = pkgs.writeShellApplication {
          name = "windows-vm";

          runtimeInputs = [
            pkgs.libvirt
            pkgs.qemu
          ];

          text = ''
            case "''${1:-run}" in
              define)
                echo "Defining Windows 11 VM in libvirt..."
                virsh define ${winVmXml}
                echo "Domain win11 defined."
                ;;
              start)
                echo "Starting Windows 11 VM..."
                virsh start win11
                ;;
              stop)
                echo "Stopping Windows 11 VM..."
                virsh shutdown win11
                ;;
              create-disk)
                disk_path="/var/lib/libvirt/images/win11.qcow2"
                size="''${2:-64G}"
                if [ -f "$disk_path" ]; then
                  echo "Disk $disk_path already exists."
                else
                  sudo mkdir -p /var/lib/libvirt/images
                  sudo qemu-img create -f qcow2 "$disk_path" "$size"
                  echo "Created $disk_path ($size)."
                fi
                ;;
              xml)
                cat ${winVmXml}
                ;;
              *)
                echo "Usage: windows-vm [define|start|stop|create-disk <size>|xml]"
                exit 1
                ;;
            esac
          '';

          meta.description = "Declarative manager and launcher for the Windows Looking Glass VM";
        };
      in
      {
        environment.systemPackages = [ windowsVmScript ];
      };
  };
}
