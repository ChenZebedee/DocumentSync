# libvirt 学习

## libvirt start

```java
    try {
        connect = new Connect(CONN_URI, false);
        Domain vm = connect.domainLookupByName(name);
        vm.create();
    } catch (LibvirtException e) {
            closeConnect();
            throw new BusinessException(ErrorEnum.E_3000002_HOST_RUNNING.getErrorCode(), e.getMessage() + ":" + name);
    }
```

## libvirt stop

```java
    try {
        connect = new Connect(CONN_URI, false);
        Domain vm = connect.domainLookupByName(name);
        vm.shutdown();
    } catch (LibvirtException e) {
            closeConnect();
            throw new BusinessException(ErrorEnum.E_3000002_HOST_RUNNING.getErrorCode(), e.getMessage() + ":" + name);
    }
```

## libvirt create 创建

### libvirt create xml // 待测试

```xml
<domain type="kvm">
    <uuid>${uuid}</uuid>
    <name>${name}</name>
    <memory unit="${memoryUnit}">${memorySize}</memory>
    <currentMemory unit="${memoryUnit}">${memorySize}</currentMemory>
    <vcpu>${vcpu}</vcpu>
    <os>
        <type arch="x86_64">hvm</type>
        <boot dev="hd" />
    </os>

    <features>
        <acpi />
        <apic />
        <pae />
    </features>

    <clock offset="utc" />
    <on_poweroff>destroy</on_poweroff>
    <on_reboot>restart</on_reboot>
    <on_crash>destroy</on_crash>

    <devices>
        <emulator>/usr/bin/qemu-system-x86_64</emulator>

        <disk type="file" device="disk">
            <driver name="qemu" type="qcow2" />
            <source file="${filePath}" />
            <target dev="vda" bus="virtio" />
        </disk>
        <disk type="file" device="disk">
            <driver name="qemu" type="qcow2" />
            <source file="${dataFilePath}" />
            <target dev="vdb" bus="virtio" />
        </disk>
        <interface type="bridge">
            <mac address='${macAddress}' />
            <source bridge="virbr0" />
            <model type='virtio' />
        </interface>


        <input type="mouse" bus="ps2" />
        <input type='keyboard' bus='ps2' />
        <input type='tablet' bus='usb'>
            <address type='usb' bus='0' port='1' />
        </input>

        <hostdev mode='subsystem' type='pci' managed='yes'>
            <source>
                <address domain='0x0000' bus='0x01' slot='0x00' function='0x0' />
            </source>
            <boot order='1' />
            <address type='pci' domain='0x0000' bus='0x03' slot='0x00' function='0x0' />
        </hostdev>
        <graphics type="vnc" port="${vncPort}" autoport="no" listen="0.0.0.0" keymap="en-us" />
    </devices>
</domain>
```

## 创建镜像

qemu-img create -f qcow2 /qcow/debian11_3.img 100G

## cup穿透

```xml
<cpu mode='host-passthrough' check='none' migratable='on'>
    <topology sockets='1' dies='1' cores='4' threads='1'/>
</cpu>

<iothreads>2</iothreads>
  <iothreadids>
    <iothread id='1'/>
    <iothread id='2'/>
  </iothreadids>
  <cputune>
    <vcpupin vcpu='0' cpuset='1'/>
    <vcpupin vcpu='1' cpuset='2'/>
    <vcpupin vcpu='2' cpuset='3'/>
    <vcpupin vcpu='3' cpuset='4'/>
    <emulatorpin cpuset='5-6'/>
    <iothreadpin iothread='1' cpuset='5'/>
    <iothreadpin iothread='2' cpuset='6'/>
  </cputune>
```

## 机器类型

改成 pc-q35-5.2

## Debian 安装

### 1. 替换apt源

```shell
cat << EOF > /etc/apt/sources.list
deb https://mirrors.aliyun.com/debian/ bullseye main non-free contrib
deb-src https://mirrors.aliyun.com/debian/ bullseye main non-free contrib
deb https://mirrors.aliyun.com/debian-security/ bullseye-security main
deb-src https://mirrors.aliyun.com/debian-security/ bullseye-security main
deb https://mirrors.aliyun.com/debian/ bullseye-updates main non-free contrib
deb-src https://mirrors.aliyun.com/debian/ bullseye-updates main non-free contrib
deb https://mirrors.aliyun.com/debian/ bullseye-backports main non-free contrib
deb-src https://mirrors.aliyun.com/debian/ bullseye-backports main non-free contrib
EOF
apt update
```

### 2. 安装

```shell
apt install qemu-kvm libvirt-clients libvirt-daemon-system bridge-utils virtinst libvirt-daemon
```

### 3. 配置qemu

```shell

```
