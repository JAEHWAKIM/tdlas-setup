#!/bin/bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/config_helpers.sh"

#10-database.sh
# MariaDB 초기 설정 스크립트

# MariaDB 설치 확인
if command -v mariadb &> /dev/null; then
    echo "MariaDB가 이미 설치되어 있습니다. 스크립트를 종료합니다."
else
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
fi

if [ "${TDLAS_SETUP}" = "true" ]; then
    DB_NAME="${TDLAS_DB_NAME}"
    DB_USER="${TDLAS_DB_USER}"
    DB_PASS="${TDLAS_DB_PASSWORD}"
    DB_READONLY_PASS="${TDLAS_DB_READONLY_PASSWORD}"
    DB_TYPE="${TDLAS_TYPE}"
else
    # 기본 데이터베이스 및 사용자 정보를 입력받기
    read -p "Database name: " DB_NAME
    read -p "Database user: " DB_USER
    while true; do
        read -sp "password: " DB_PASS
        echo
        read -sp "Confirm password: " DB_PASS_CONFIRM
        echo
        if [ "$DB_PASS" == "$DB_PASS_CONFIRM" ]; then
            break
        else
            echo "Passwords do not match. Please try again."
        fi
    done
    while true; do
        read -sp "External read-only password: " DB_READONLY_PASS
        echo
        read -sp "Confirm password: " DB_READONLY_PASS_CONFIRM
        echo
        if [ "$DB_READONLY_PASS" == "$DB_READONLY_PASS_CONFIRM" ]; then
            break
        else
            echo "Passwords do not match. Please try again."
        fi
    done
    read -p "DB TYPE (ex: tdlas): " DB_TYPE
    echo
fi

if [[ ! "$DB_NAME" =~ ^[A-Za-z0-9_]+$ || ! "$DB_USER" =~ ^[A-Za-z0-9_]+$ ]]; then
    echo "Database name and user may contain only ASCII letters, digits, and underscores."
    exit 1
fi
if [ -z "$DB_READONLY_PASS" ]; then
    echo "External read-only password must not be empty."
    exit 1
fi

DB_PASS_SQL=${DB_PASS//\'/\'\'}
DB_READONLY_PASS_SQL=${DB_READONLY_PASS//\'/\'\'}

# 외부 조회 전용 계정이 필요하므로 MariaDB는 외부 인터페이스에도 바인딩합니다.
echo "MariaDB를 외부 조회 가능하도록 설정합니다..."
set_config_value /etc/mysql/mariadb.conf.d/50-server.cnf bind-address 0.0.0.0 " = "

# MariaDB 서비스가 부팅 시 자동 시작되도록 설정
echo "MariaDB 서비스를 부팅 시 자동 시작되도록 설정합니다..."
sudo systemctl enable mariadb

# MariaDB 서비스 시작
echo "MariaDB 서비스를 시작합니다..."
sudo systemctl restart mariadb


TABLE_SQL="CREATE TABLE IF NOT EXISTS  results(
    seq_no BIGINT NOT NULL AUTO_INCREMENT, -- 순번 (자동 증가)
    timestamp DATETIME,                    -- 타임스탬프
    model_no TINYINT,                      -- 모델 번호
    conc_value DOUBLE,                     -- 농도 값
    exist_data TINYINT(1),                 -- 데이터 존재 여부
    PRIMARY KEY (seq_no)                   -- 기본 키
);"

if [ "$DB_TYPE" == "tdlas" ]; then
TABLE_SQL="
CREATE TABLE IF NOT EXISTS  record_log (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    timestamp DATETIME NOT NULL
);

CREATE TABLE IF NOT EXISTS  channel_data (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    record_id BIGINT NOT NULL,
    channel_id TINYINT(1) NOT NULL,
    mode_id TINYINT(1) NOT NULL,
    recipe_id TINYINT(1) NOT NULL,
    value DOUBLE NOT NULL,
    FOREIGN KEY (record_id) REFERENCES record_log(id)
);

CREATE TABLE IF NOT EXISTS  file_data (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    record_id BIGINT NOT NULL,
    FOREIGN KEY (record_id) REFERENCES record_log(id)
);"
fi

if [ "$DB_TYPE" == "tdlas" ]; then
    READONLY_GRANTS="
GRANT SELECT ON \`$DB_NAME\`.record_log TO 'tdlas_reader'@'%';
GRANT SELECT ON \`$DB_NAME\`.channel_data TO 'tdlas_reader'@'%';
GRANT SELECT ON \`$DB_NAME\`.file_data TO 'tdlas_reader'@'%';"
else
    READONLY_GRANTS="GRANT SELECT ON \`$DB_NAME\`.results TO 'tdlas_reader'@'%';"
fi

echo "기본 데이터베이스와 사용자를 생성합니다..."
sudo mariadb <<EOF
DROP USER IF EXISTS 'root'@'%';
DROP USER IF EXISTS ''@'localhost';
DROP DATABASE IF EXISTS test;
DELETE FROM mysql.db WHERE Db = 'test' OR Db LIKE 'test\\_%';
CREATE DATABASE IF NOT EXISTS \`$DB_NAME\`;
CREATE USER IF NOT EXISTS '$DB_USER'@'localhost' IDENTIFIED BY '$DB_PASS_SQL';
ALTER USER '$DB_USER'@'localhost' IDENTIFIED BY '$DB_PASS_SQL';
GRANT ALL PRIVILEGES ON \`$DB_NAME\`.* TO '$DB_USER'@'localhost';
DROP USER IF EXISTS 'tdlas_reader'@'%';
CREATE USER 'tdlas_reader'@'%' IDENTIFIED BY '$DB_READONLY_PASS_SQL';

-- 변경 사항 적용
FLUSH PRIVILEGES;

-- DB선택
USE \`$DB_NAME\`;

-- 데이터베이스 테이블 생성
${TABLE_SQL}

${READONLY_GRANTS}

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
