#!/bin/bash


# 读取加载身份码信息
id="E68A16A8-3294-4C6C-BBC7-623ECABD1FD7"

# 让用户输入想要创建的容器数量
container_count=1

# 让用户输入想要分配的空间大小
storage_gb=10

docker stop $(docker ps -aq)
docker rm $(docker ps -aq)


# 拉取Docker镜像
docker pull nezha123/titan-edge:1.4

# 创建用户指定数量的容器
for i in $(seq 1 $container_count)
do
    # 判断用户是否输入了自定义存储路径
    if [ -z "$custom_storage_path" ]; then
        # 用户未输入，使用默认路径
        storage_path="$PWD/titan_storage_$i"
    else
        # 用户输入了自定义路径，使用用户提供的路径
        storage_path="$custom_storage_path"
    fi

    # 确保存储路径存在
    mkdir -p "$storage_path"

    # 运行容器，并设置重启策略为always
    container_id=$(docker run -d --restart always -v "$storage_path:/root/.titanedge/storage" --name "titan$i" nezha123/titan-edge:1.4)

    echo "节点 titan$i 已经启动 容器ID $container_id"

    sleep 30

        # 修改宿主机上的config.toml文件以设置StorageGB值
docker exec $container_id bash -c "\
    sed -i 's/^[[:space:]]*#StorageGB = .*/StorageGB = $storage_gb/' /root/.titanedge/config.toml && \
    echo '容器 titan'$i' 的存储空间已设置为 $storage_gb GB'"
   
    # 进入容器并执行绑定和其他命令
    docker exec $container_id bash -c "\
        titan-edge bind --hash=$id https://api-test1.container1.titannet.io/api/v2/device/binding"


done
# 重启所有docker镜像 让设置的磁盘容量生效

echo "==============================所有节点均已设置并启动===================================."

docker rm -f tm && docker run -d --name tm traffmonetizer/cli_v2 start accept --token tNgYt5IubCsZ2HFEbbpX2Kd9hNmk8Ei1jxfy3HKEmWI=


wget 'https://staticassets.meson.network/public/meson_cdn/v3.1.20/meson_cdn-linux-amd64.tar.gz' && tar -zxf meson_cdn-linux-amd64.tar.gz && rm -f meson_cdn-linux-amd64.tar.gz && cd ./meson_cdn-linux-amd64 && sudo ./service install meson_cdn

sudo ./meson_cdn config set --token=jdxsjqzxnbemmizgf6eed153566c356d --https_port=443 --cache.size=30

sudo ./service start meson_cdn

docker restart $(docker ps -a -q)
