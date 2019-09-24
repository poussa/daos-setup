export DAOS_PATH=/opt/src/daos-stack/daos
export CPATH=$DAOS_PATH/install/include:$CPATH
export PATH=$DAOS_PATH/install/bin:$DAOS_PATH/install/sbin:$PATH
export CRT_PHY_ADDR_STR="ofi+sockets"
export OFI_INTERFACE=enp65s0f0
export VOS_BDEV_CLASS=nvme
export urifile=/tmp/report.uri

export LD_LIBRARY_PATH=$DAOS_PATH/install/lib:$DAOS_PATH/install/lib64:/usr/lib64

PMEM_LIST="pmem1"
DAOS_USER=daos
DAOS_GRP=daos

# For mounting dfuse wo/ orterun
export DAOS_SINGLETON_CLI=1
export CRT_ATTACH_INFO_PATH=/tmp/

ORTERUN="orterun --allow-run-as-root -np 1 --ompi-server file:${urifile}"

function _daos_prepare_pmem() {
    # PMEM devs need to be in interleaved AppDirect mode (one per socket)
    daos_server storage prepare --scm-only
}

function _daos_prepare_nvme() {
    # Use only P4800x
    daos_server storage prepare --nvme-only --pci-whitelist 5e:00.0
}

function _daos_storage_format() {
    # rm -rf /mnt/daos
    # umount /mnt/daos
    # _daos_run_root
    daos_shell -i storage format
} 

function _daos_reset_nvme() {
    daos_server storage prepare --nvme-only --reset
}

function _daos_scan() {
    daos_server storage scan
}

function _daos_setup_user() {
    sudo adduser $DAOS_USER
    sudo passwd $DAOS_USER
    sudo groupadd $DAOS_GRP
    sudo usermod -a -G $DAOS_GRP $DAOS_USER

    for dev in $PMEM_LIST; do
        sudo mount /dev/$dev /mnt/daos
        sudo chown $DAOS_USER.$DAOS_GRP /mnt/daos
    done
}

function _daos_setup_dirs() {
    DIRS="/var/run/daos_agent /var/run/daos_server"

    for dir in $DIRS; do
        sudo mkdir $dir
        sudo chown $DAOS_USER $dir
        sudo chmod 0774 $dir
    done
}

function _daos_run() {
    orterun \
        -np 1 \
        --hostfile hostfile \
        --enable-recovery \
        --report-uri report.uri \
    daos_server \
        -t 1 \
        -i \
        -o /home/spoussa/src/daos-config/daos_server_wolfpass4.yaml    
}

function _daos_run_root() {
    orterun \
        --allow-run-as-root \
        -n 1 \
        --hostfile hostfile \
        --enable-recovery \
        --report-uri /tmp/report.uri \
    daos_server \
        --insecure \
        -t 1 \
        --config=/home/spoussa/src/daos-config/daos_server_wolfpass4.yaml \
	start \
	-a /tmp
	

}

function _daos_agent_run() {
    daos_agent \
        --insecure \
        -o /home/spoussa/src/daos-config/daos_agent_wolfpass4.yaml
}

function _daos_pool_create() {
    $ORTERUN dmg create --size=10G
}

function _daos_pool_destroy() {
    $ORTERUN dmg destroy --pool $1
}

function _daos_pool_query() {
    $ORTERUN dmg query --svc 0 --pool $1
}

function _daos_container_list() {
    #$ORTERUN daos pool list-containers --pool $1 --svc 0 # not implemented yet
    daos container query --svc=0 --path=/tmp/container-1
}

function _daos_container_create() {
    # 3838f949-bd7f-491c-939a-b8a61a0bd373
    $ORTERUN daos container create --pool=$1 --type=POSIX --svc=0
}

function _daos_container_create_with_path() {
    # 3838f949-bd7f-491c-939a-b8a61a0bd373
    $ORTERUN daos container create --pool=$1 --type=POSIX --svc=0 --path=/tmp/container-1 --oclass=S1 --chunk_size=4K
}


function _daos_mount_hl() {
    # p: 3838f949-bd7f-491c-939a-b8a61a0bd373
    # c: bfd123ba-7b83-4b3b-aa41-8601d4d9cb58
    $ORTERUN dfuse_hl /tmp/daos -o default_permissions -s -f -p $1 -c $2 -l 0 &
    mount -t fuse
}

function _daos_mount() {
    dfuse -p $1 -c $2 -s 0 -m /tmp/daos -S
}

function _daos_umount() {
    fusermount -u /tmp/daos
}

function _daos_test() {
    $ORTERUN daos_test    
}
