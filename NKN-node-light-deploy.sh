#!/bin/bash

NKN_DIR="/var/lib/nkn"
NKN_COMMERCIAL_DIR="$NKN_DIR/nkn-commercial"
NKN_LOG_DIR="$NKN_DIR/Log"

# 受益地址 填到 /root/nkn_beneficiary_addr 文件中 不要有空格 和换行
# 格式错误 或者 地址错误 使用 脚本作者的地址
# BENEFICIARY_ADDR=`cat /root/nkn_beneficiary_addr`

# 改为 参数形式 如 ./nkn.sh NKNUiweUj8HsNiogrngitVuxTSdJXviF7W3F
BENEFICIARY_ADDR=$1

if [ ${#BENEFICIARY_ADDR} != 36 ];then
    BENEFICIARY_ADDR="NKNUiweUj8HsNiogrngitVuxTSdJXviF7W3F"
fi
echo $BENEFICIARY_ADDR

rm -rf $NKN_DIR

mkdir -p $NKN_COMMERCIAL_DIR

#step 1
apt-get update -qq
apt-get install -y unzip net-tools psmisc git htop nano haveged supervisor nginx

# step 2.1 (nkn config.mainnet.json)
cd $NKN_DIR
wget https://raw.githubusercontent.com/nknorg/nkn/master/config.mainnet.json
mv config.mainnet.json config.json
sed -i '3i "SyncMode": "light",' config.json
sed -i "3s/^/  /" config.json

# step 2.2 (nkn-commercial)
cd $NKN_COMMERCIAL_DIR
wget -N https://commercial.nkn.org/downloads/nkn-commercial/linux-amd64.zip
sleep 1
unzip linux-amd64.zip
mv linux-amd64/nkn-commercial ./
rm -rf linux-amd64.zip linux-amd64

cat <<EOF > /tmp/config.json
{
  "beneficiaryAddr": "$BENEFICIARY_ADDR",
  "dataDir": "$NKN_COMMERCIAL_DIR",
  "nkn-node": {
    "args": "--chaindb $NKN_DIR/ChainDB --log $NKN_DIR/Log --config $NKN_DIR/config.json"
  }
}
EOF

mv /tmp/config.json $NKN_COMMERCIAL_DIR/config.json

# step 2.3 (nkn-commercial install)
cd $NKN_COMMERCIAL_DIR
$NKN_COMMERCIAL_DIR/nkn-commercial install
# step 2.3

exit 0