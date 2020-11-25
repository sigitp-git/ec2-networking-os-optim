sh-4.2$ modinfo ena
filename:       /lib/modules/4.14.193-149.317.amzn2.x86_64/kernel/drivers/amazon/net/ena/ena.ko
version:        2.2.10g
license:        GPL
description:    Elastic Network Adapter (ENA)
author:         Amazon.com, Inc. or its affiliates
srcversion:     D73EB01C3E7F61C6125D9FC
alias:          pci:v00001D0Fd0000EC21sv*sd*bc*sc*i*
alias:          pci:v00001D0Fd0000EC20sv*sd*bc*sc*i*
alias:          pci:v00001D0Fd00001EC2sv*sd*bc*sc*i*
alias:          pci:v00001D0Fd00000EC2sv*sd*bc*sc*i*
alias:          pci:v00001D0Fd00000051sv*sd*bc*sc*i*
depends:
retpoline:      Y
intree:         Y
name:           ena
vermagic:       4.14.193-149.317.amzn2.x86_64 SMP mod_unload modversions
sig_id:         PKCS#7
signer:
sig_key:
parm:           debug:Debug level (0=none,...,16=all) (int)
parm:           rx_queue_size:Rx queue size. The size should be a power of 2. Max value is 8K
 (int)
parm:           force_large_llq_header:Increases maximum supported header size in LLQ mode to 224 bytes, while reducing the maximum TX queue size by half.
 (int)
parm:           num_io_queues:Sets number of RX/TX queues to allocate to device. The maximum value depends on the device and number of online CPUs.
 (int)
sh-4.2$


sigitp@host:~/Documents/ec2-networking-os-optim$ aws ec2 describe-instances --instance-ids i-df234234234wkwkwkw --query "Reservations[].Instances[].EnaSupport"
[
    true
]

sh-4.2$ ethtool -i eth0
driver: ena
version: 2.2.10g
firmware-version:
expansion-rom-version:
bus-info: 0000:00:05.0
supports-statistics: yes
supports-test: no
supports-eeprom-access: no
supports-register-dump: no
supports-priv-flags: no
sh-4.2$

aws ec2 modify-instance-attribute --instance-id instance_id --ena-support

Ubuntu-DKMS
-----------
sudo apt-get install -y build-essential dkms
