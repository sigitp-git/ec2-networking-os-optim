Ensure that your reserved kernel memory is sufficient to sustain a high rate of packet buffer allocations (the default value may be too small).
Open (as root or with sudo) the /etc/sysctl.conf file with the editor of your choice.

Add the vm.min_free_kbytes line to the file with the reserved kernel memory value (in kilobytes) for your instance type. As a rule of thumb, you should set this value to between 1-3% of available system memory, and adjust this value up or down to meet the needs of your application.

vm.min_free_kbytes = 1048576
sudo sysctl -p
sudo sysctl -a 2>&1 | grep min_free_kbytes
sudo reboot


1  tracepath amazon.com
    2  tracepath amazon.com
    3  cat /sys/devices/system/clocksource/clocksource0/current_clocksource
    4  sudo sysctl -a 2>&1 | grep min_free_kbytes
    5  sudo yum install -y numactl
    6  lscpu | grep NUMA
    7  cat /sys/devices/system/cpu/cpu0/topology/thread_siblings_list
    8  ifconfig
    9  ip link show eth0
   10  ip link sudo ip link set dev eth0 mtu 1500
   11  sudo ip link set dev eth0 mtu 1500
   12  ip link show eth0
   13  history
sh-4.2$

Run myapp on cpus 2,4,6,8 and allocate memory only to local memory where the process runs.
$numactl -l --physcpubind=2,4,6,8 myapp

Run multithreaded application myapp with its memory interleaved on all CPUs to achieve balanced latency across all application threads.
$numactl --interleave=all myapp

Run process on cpus that are part of node 0 with memory allocated on node 0 and 1.
$numactl --cpunodebind=0 --membind=0,1 myapp



For example, Amazon instance x1.32xlarge has four numa nodes. Each with 32 vcpu and 480 MB of memory. Distance between nodes is the same due to mesh topology
$ numactl --hardware
available: 4 nodes (0-3)
node 0 cpus: 0 1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 64 65 66 67 68 69 70 71 72 73 74 75 76 77 78 79
node 0 size: 491822 MB
node 0 free: 484600 MB
node 1 cpus: 16 17 18 19 20 21 22 23 24 25 26 27 28 29 30 31 80 81 82 83 84 85 86 87 88 89 90 91 92 93 94 95 node 1 size: 491900 MB
node 1 free: 488717 MB
node 2 cpus: 32 33 34 35 36 37 38 39 40 41 42 43 44 45 46 47 96 97 98 99 100 101 102 103 104 105 106 107 108 109 110 111 node 2 size: 491900 MB
node 2 free: 488907 MB
node 3 cpus: 48 49 50 51 52 53 54 55 56 57 58 59 60 61 62 63 112 113 114 115 116 117 118 119 120 121 122 123 124 125 126 127 node 3 size: 491899 MB
node 3 free: 488951 MB
node distances:
node 0 1 2 3
0: 10 20 20 20 1: 20 10 20 20 2: 20 20 10 20 3: 20 20 20 10
------
Current shell or process memory allocation policy, cpu and memory binding can be listed using: $ numactl --show
policy: default
preferred node: current
physcpubind: 0 1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18 19 20 21 22 23 24 25 26 27 28 29 30 31 32 33 34 35 36 37 38 39 40 41 42 43 44 45 46 47 48 49 50 51 52 53 54 55 56 57 58 59 60 61 62 63 64 65 66 67 68 69 70 71 72 73 74 75 76 77 78 79 80 81 82 83 84 85 86 87 88 89 90 91 92 93 94 95 96 97 98 99 100 101 102 103 104 105 106 107 108 109 110 111 112 113 114 115 116 117 118 119 120 121 122 123 124 125 126 127
cpubind: 0 1 2 3 nodebind: 0 1 2 3 membind: 0 1 2 3




numa hit (local memory) and miss (remote memory) statistics $numastat
  numa_hit numa_miss numa_foreign interleave_hit local_node other_node Where:
node0 node1 node2 37703880 43310766
0 0
0 0 208782 209249 35355762 40684734 2348118 2626032
0 0
node3 45362620
0 0
208783 42747490
2615130
40991721
209259 38274373
     2717348


- numa_hit is the number of allocations which were intended for that node and succeeded there.
- numa_miss shows the count of allocations that were intended for this node, but ended up on another node due to memory
constraints.
- numa_foreign is the number of allocations that were intended for another node, but ended up on this node. Each numa_foreign
event has a numa_miss on another node.
- interleave_hit is the count of interleave policy allocations which were intended for a specific node and were successful.

- local_node is a value that is incremented when a process running on the node allocated memory on the same node.

- other_node is incremented when a process running on another node allocated memory on that node.


per process numa specific statistics.
$ numastat -p $$
Per-node process memory usage (in MBs) for PID 22028 (bash)
Node 0 Node 1 Node 2 --------------- --------------- ---------------
Huge
Heap
Stack
Private
---------------- --------------- --------------- --------------- Total 3.71 0.20 0.13
0.00 0.00 0.00 2.01 0.04 0.09 0.02 0.01 0.00 1.68 0.16 0.04
Node 3 Total --------------- ---------------
Huge
Heap
Stack
Private
---------------- --------------- --------------- Total 0.03 4.07
0.00 0.00 0.03 2.16 0.00 0.03 0.00 1.89
/proc/<pid>/numa_maps shows information about process memory area allocated from numa nodes.
$cat /proc/61623/numa_maps
00400000 default file=/bin/bash mapped=182 mapmax=6 active=158 N0=178 N2=4
006ef000 default file=/bin/bash anon=1 dirty=1 N0=1
006f0000 default file=/bin/bash anon=9 dirty=9 N0=3 N2=2 N3=4
006f9000 default anon=6 dirty=6 N0=3 N2=3
026d1000 default heap anon=553 dirty=553 N0=10 N1=6 N2=270 N3=267
7f1f3b9bd000 default file=/lib/x86_64-linux-gnu/libnss_files-2.19.so mapped=3 mapmax=29 N0=3 7f1f3b9c7000 default file=/lib/x86_64-linux-gnu/libnss_files-2.19.so
..
Where:
- N<node>=<pages>: pages mapped by this process only in various numa nodes. Example N0=178, N2=4. Means 178 pages are allocated on Node0 and 4 pages on Node2.
- file: backing store for the memory area. If pages are generated due to COW pages, then there will anon pages. - heap: process heap area
- stack: process stack area
- huge: huge pages mapped in process area
- anon<pages>: anonymous pages
- dirty<pages>: modified or dirty pages
- mapped <pages>: mapped pages from the backing store. Only shown if different from the count of anon and dirty pages
- mapmax<count>: Number of processes mapping this page. Sign of sharing of memory area.
- swapcache<count>: Number of pages that have an associated entry on a swap device
- active<pages>: Number of pages in the active list. if count is shown that there may some inactive pages exist in the memory
area that may have get removed by swapper soon.
- writeback<pages>: Number of pages that are currently in process of written out.




numa API:
getcpu: determine cpu and NUMA node the calling thread is running
get_mempolicy: Retrieve numa memory policy for process. Tells which node contains the address
set_mempolicy: Sets numa memory policy for process (default, preferred, interleave)
move_pages: move individual pages of a process to other node
mbind: Sets memory policy (bind mode) for particular memory range or node.

sh-4.2$
