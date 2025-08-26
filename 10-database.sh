#!/bin/bash

#10-database.sh
# MariaDB 초기 설정 스크립트

# MariaDB 설치 확인
if command -v mariadb &> /dev/null; then
    echo "MariaDB가 이미 설치되어 있습니다. 스크립트를 종료합니다."
    exit 0
fi

# MariaDB 설치
echo "MariaDB를 설치합니다..."
sudo apt update

packages=(
    mariadb-server
    mariadb-client
    libmariadb3
    libmariadb-dev
)

for package in "${packages[@]}"; do
    if ! dpkg -l | grep -q "^ii  $package "; then
        echo "Installing $package..."
        sudo apt install -y "$package"
    else
        echo "$package is already installed."
    fi
done

# 기본 데이터베이스 및 사용자 정보를 입력받기
read -p "데이터베이스 이름을 입력하세요: " DB_NAME
read -p "데이터베이스 사용자 이름을 입력하세요: " DB_USER
while true; do
    read -sp "데이터베이스 사용자 비밀번호를 입력하세요: " DB_PASS
    echo
    read -sp "비밀번호를 다시 입력하세요: " DB_PASS_CONFIRM
    echo
    if [ "$DB_PASS" == "$DB_PASS_CONFIRM" ]; then
        break
    else
        echo "비밀번호가 일치하지 않습니다. 다시 시도하세요."
    fi
done
echo

# 보안 설정
echo "MariaDB 보안 설정을 시작합니다..."
sudo mysql_secure_installation <<EOF

y
$DB_PASS
$DB_PASS
y
y
y
y
EOF

# bind-address 값을 0.0.0.0으로 수정
echo "bind-address 값을 0.0.0.0으로 수정합니다..."
sudo sed -i "s/^bind-address\s*=.*/bind-address = 0.0.0.0/" /etc/mysql/mariadb.conf.d/50-server.cnf

# MariaDB 서비스가 부팅 시 자동 시작되도록 설정
echo "MariaDB 서비스를 부팅 시 자동 시작되도록 설정합니다..."
sudo systemctl enable mariadb

# MariaDB 서비스 시작
echo "MariaDB 서비스를 시작합니다..."
sudo systemctl start mariadb

echo "기본 데이터베이스와 사용자를 생성합니다..."
sudo mysql -u root -p"$DB_PASS" <<EOF
-- 사용자 생성 (localhost 및 모든 호스트에서 접근 가능)
CREATE USER IF NOT EXISTS '$DB_USER'@'localhost' IDENTIFIED BY '$DB_PASS';
CREATE USER IF NOT EXISTS '$DB_USER'@'%' IDENTIFIED BY '$DB_PASS';

-- 사용자 권한 부여 (localhost 및 모든 호스트에서 데이터베이스 접근 가능)
GRANT ALL PRIVILEGES ON $DB_NAME.* TO '$DB_USER'@'localhost';
GRANT SELECT ON $DB_NAME.* TO '$DB_USER'@'%';

-- 변경 사항 적용
FLUSH PRIVILEGES;

-- 데이터베이스 생성 (존재하지 않을 경우)
CREATE DATABASE IF NOT EXISTS $DB_NAME;

-- DB선택
USE $DB_NAME;

-- 데이터베이스 테이블 생성
CREATE TABLE results(
    seq_no BIGINT NOT NULL AUTO_INCREMENT, -- 순번 (자동 증가)
    timestamp DATETIME,                    -- 타임스탬프
    model_no TINYINT,                      -- 모델 번호
    conc_value DOUBLE,                     -- 농도 값
    exist_data TINYINT(1),                 -- 데이터 존재 여부
    PRIMARY KEY (seq_no)                   -- 기본 키
);

-- 타임존 변경
SET GLOBAL TIME_ZONE='+09:00';
SET SESSION TIME_ZONE='+09:00';

EOF

cd "$(dirname "$0")"

if [ ! -d "./temp" ]; then
    mkdir ./temp
fi

cd ./temp
if [ ! -f "mariadb-connector-cpp-1.1.5-ubuntu-jammy-aarch64.tar.gz" ]; then
    wget https://dlm.mariadb.com/3907389/Connectors/cpp/connector-cpp-1.1.5/mariadb-connector-cpp-1.1.5-ubuntu-jammy-aarch64.tar.gz
fi

if [ ! -d "mariadb-connector-cpp-1.1.5-ubuntu-jammy-aarch64" ]; then
    tar -xvzf mariadb-connector-cpp-1.1.5-ubuntu-jammy-aarch64.tar.gz
fi

cd mariadb-connector-cpp-1.1.5-ubuntu-jammy-aarch64

sudo install -d /usr/include/mariadb/conncpp
sudo install -d /usr/include/mariadb/conncpp/compat

sudo install include/mariadb/* /usr/include/mariadb/
sudo install include/mariadb/conncpp/* /usr/include/mariadb/conncpp
sudo install include/mariadb/conncpp/compat/* /usr/include/mariadb/conncpp/compat

# 공유라이브러리 
sudo install -d /usr/lib/mariadb
sudo install -d /usr/lib/mariadb/plugin

sudo install lib/mariadb/libmariadbcpp.so /usr/lib
sudo install lib/mariadb/plugin/* /usr/lib/mariadb/plugin


echo "MariaDB 초기 설정이 완료되었습니다."