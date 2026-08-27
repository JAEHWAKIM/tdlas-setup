#!/bin/bash
set -euo pipefail

# 이 스크립트는 현재 디렉토리에서 '숫자-이름.sh' 형식의 모든 스크립트를 찾아 순서대로 실행합니다.

# 현재 스크립트가 있는 디렉토리로 이동
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"
cd "$SCRIPT_DIR"

echo "=========================================="
echo "=== 우분투 초기 설정 스크립트를 시작합니다 ==="
echo "=========================================="

export TDLAS_SETUP=true

#hostname
read -p "호스트명을 입력하시오 (ex: tdlas-pi): " HOSTNAME
if [[ ! "$HOSTNAME" =~ ^[A-Za-z0-9][A-Za-z0-9.-]*$ ]]; then
    echo "호스트명이 올바르지 않습니다."
    exit 1
fi
export TDLAS_HOSTNAME=$HOSTNAME

#type (tdlas, das, wms)
read -p "설치 유형을 입력하시오 (ex: tdlas, das, wms): " TYPE
if [[ ! "$TYPE" =~ ^(tdlas|das|wms)$ ]]; then
    echo "설치 유형은 tdlas, das 또는 wms여야 합니다."
    exit 1
fi
export TDLAS_TYPE=$TYPE

#device name
read -p "장치 이름을 입력하시오 (ex: KITECH-TDLAS): " DEVICE_NAME
if [ -z "$DEVICE_NAME" ]; then
    echo "장치 이름은 비워둘 수 없습니다."
    exit 1
fi
export TDLAS_DEVICE_NAME=$DEVICE_NAME

#device serial number
read -p "장치 일련번호를 입력하시오 (ex: 0x1125A001): " DEVICE_SERIAL_NUMBER
if [ -z "$DEVICE_SERIAL_NUMBER" ]; then
    echo "장치 일련번호는 비워둘 수 없습니다."
    exit 1
fi
export TDLAS_DEVICE_SERIAL_NUMBER=$DEVICE_SERIAL_NUMBER

#database name
read -p "데이터베이스 이름을 입력하시오 (ex: tdlas): " DB_NAME
if [[ ! "$DB_NAME" =~ ^[A-Za-z0-9_]+$ ]]; then
    echo "데이터베이스 이름은 영문, 숫자, 밑줄만 사용할 수 있습니다."
    exit 1
fi
export TDLAS_DB_NAME=$DB_NAME

#database user
read -p "데이터베이스 사용자 이름을 입력하시오 (ex: easyrnd): " DB_USER
if [[ ! "$DB_USER" =~ ^[A-Za-z0-9_]+$ ]]; then
    echo "데이터베이스 사용자 이름은 영문, 숫자, 밑줄만 사용할 수 있습니다."
    exit 1
fi
export TDLAS_DB_USER=$DB_USER

#database password
while true; do
    read -s -p "데이터베이스 비밀번호를 입력하시오: " DB_PASSWORD
    echo
    read -s -p "비밀번호를 다시 입력하시오: " DB_PASSWORD_CONFIRM
    echo
    if [ "$DB_PASSWORD" == "$DB_PASSWORD_CONFIRM" ]; then
        break
    else
        echo "비밀번호가 일치하지 않습니다. 다시 시도하십시오."
    fi
done
if [ -z "$DB_PASSWORD" ]; then
    echo "데이터베이스 비밀번호는 비워둘 수 없습니다."
    exit 1
fi
export TDLAS_DB_PASSWORD=$DB_PASSWORD

# external read-only database password
while true; do
    read -s -p "외부 조회 전용 DB 비밀번호를 입력하시오: " DB_READONLY_PASSWORD
    echo
    read -s -p "비밀번호를 다시 입력하시오: " DB_READONLY_PASSWORD_CONFIRM
    echo
    if [ "$DB_READONLY_PASSWORD" == "$DB_READONLY_PASSWORD_CONFIRM" ]; then
        break
    else
        echo "비밀번호가 일치하지 않습니다. 다시 시도하십시오."
    fi
done
if [ -z "$DB_READONLY_PASSWORD" ]; then
    echo "외부 조회 전용 DB 비밀번호는 비워둘 수 없습니다."
    exit 1
fi
export TDLAS_DB_READONLY_PASSWORD=$DB_READONLY_PASSWORD

#decryption key
read -s -p "암호화 키를 입력하시오 (32자 이상 권장): " DECRYPTION_KEY
echo
if [ -z "$DECRYPTION_KEY" ]; then
    echo "암호화 키는 비워둘 수 없습니다."
    exit 1
fi
export TDLAS_DECRYPTION_KEY=$DECRYPTION_KEY

#display rotate
while true; do
    read -p "디스플레이 회전 각도를 입력하시오 (0, 90, 180, 270): " DISPLAY_ROTATE
    if [[ "$DISPLAY_ROTATE" =~ ^(0|90|180|270)$ ]]; then
        break
    else
        echo "유효하지 않은 입력입니다. 0, 90, 180, 270 중 하나를 입력하십시오."
    fi
done
export TDLAS_DISPLAY_ROTATE=$DISPLAY_ROTATE


mapfile -t scripts < <(find . -maxdepth 1 -type f -name '[0-9][0-9]-*.sh' -printf '%f\n' | sort -V)
for script in "${scripts[@]}"; do
    echo "--- $script 를 실행합니다 ---"
    # 실행 권한이 있는지 확인하고 없으면 추가
    if [ ! -x "$script" ]; then
        chmod +x "$script"
        echo "  > 실행 권한을 추가했습니다."
    fi
    # 서브 스크립트 실행
    ./"$script"
    echo "--- $script 실행 완료 ---"
    echo ""
done

echo "=========================================="
echo "=== 모든 스크립트 실행이 완료되었습니다 ==="
echo "=========================================="