# KVM based F5 VM standup Examples

KVM (Linux Kernel Virtualization) is very accessible and common, often based on qemu emulation.

There are many vendor implementations of this that layer on different management, but **virt-install** is a common simple way to stand up a vm on CLI.

When needing to pass additional details to the VM on initial boot, **cloud-init** configs can be used.

Once stood-up, these can be inspected/adjusted with **virsh** tool.

## F5 BIG-IP Normal Example

When using the standard VE image, requires at least 2 interfaces.
One for mangement, one for data (tmm), more can be added as desired for more data interfaces.
Alternative 1-NIC variants images are available if needed.

Can also be found on [My F5 Downloads](https://my.f5.com/manage/s/downloads)

```bash
virt-install --name simple-kvm-f5-bigip-ve \
        --ram 16384 \
        --vcpus=4 \
        --network type=default,model=virtio \
        --network type=bridge,source=br0,source_mode=bridge,model=virtio \
        --disk path=/var/lib/libvirt/images/vms/BIGIP-17.5.1-0.0.7.qcow2,bus=virtio,format=qcow2  \
        --accelerate \
        --os-variant rhl9 \
        --virt-type kvm \
        --noautoconsole \
        --import \
        --graphics vnc

```


## F5 CE Example - For F5 Distributed Cloud (DC) aka XC

First obtain the image and generate an onboarding Token.
Both can be obtained via API calls or via Web Console.

Obtain download link/image.
Can be found from Web Console, copy download link.

Be aware different Hypervisors have different published images, and there are older v1 images and newer v2 images.
Example Link, in this case for KVM Image for CEv2.
```text
https://downloads.volterra.io/releases/rhel/9/x86_64/images/securemeshV2/f5xc-ce-9.2025.39-20250628061635.qcow2
```

Requires cloud init config first with onboarding key similar to the example below.
Many changes may be desired, but most common ones would be adding static IP, Gateway, DNS and NTP for 'SLO' interface.
Additional changes can be made for setting user data, adding ssh keys for auth, adding 'SLI' interface details, etc.

```yaml
#cloud-config
write_files:
- path: /etc/vpm/user_data
  permissions: 0644
  owner: root
  content: |
    token: {{ token_variable_here }}
    #slo_ip: Un-comment and set Static IP/mask for SLO if needed.
    #slo_gateway: Un-comment and set default gateway for SLO when static IP is  needed.

```

Then can create vm.
Example below uses single NIC, which would be assigned to 'SLO', also using bridge neworking.
Most common changes would be adjusting or adding more NICs, adjusting disk image reference, and resources.

```bash
virt-install --name simple-kvm-f5-ce \
        --ram 16384 \
        --vcpus=4 \
        --network type=bridge,source=br0,source_mode=bridge,model=virtio \
        --disk path=/var/lib/libvirt/images/vms/f5xc-ce-9.2025.39-20250628061635.qcow2,bus=virtio,format=qcow2  \
        --cloud-init user-data=user-data.txt \
        --accelerate \
        --os-variant rhl9 \
        --virt-type kvm \
        --noautoconsole \
        --import \
        --graphics vnc

```


## Virsh Tool commands

```bash
# Show running VMs (domains)
virsh list
# Show all, including powered off VMs (domains)
virsh list --all
```