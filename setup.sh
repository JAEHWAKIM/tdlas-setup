#!/bin/bash

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
export TDLAS_HOSTNAME=$HOSTNAME

#type (tdlas, das, wms)
read -p "설치 유형을 입력하시오 (ex: tdlas, das, wms): " TYPE
export TDLAS_TYPE=$TYPE

#device name
read -p "장치 이름을 입력하시오 (ex: KITECH-TDLAS): " DEVICE_NAME
export TDLAS_DEVICE_NAME=$DEVICE_NAME

#device serial number
read -p "장치 일련번호를 입력하시오 (ex: 0x1125A001): " DEVICE_SERIAL_NUMBER
export TDLAS_DEVICE_SERIAL_NUMBER=$DEVICE_SERIAL_NUMBER

#database name
read -p "데이터베이스 이름을 입력하시오 (ex: tdlas): " DB_NAME
export TDLAS_DB_NAME=$DB_NAME

#database user
read -p "데이터베이스 사용자 이름을 입력하시오 (ex: easyrnd): " DB_USER
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
export TDLAS_DB_PASSWORD=$DB_PASSWORD

#decryption key
read -p "암호화 키를 입력하시오 (32자 이상 권장): " DECRYPTION_KEY
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


# 파일명 앞 2자리가 숫자인 .sh 파일을 찾아서 정렬
# sort -V 옵션은 01, 05, 10 순서와 같이 자연스러운 버전 정렬을 수행합니다.
# .cpt 확장자를 가진 파일은 제외
for script in $(ls | grep '^[0-9][0-9]-.*\.sh' | grep -v '\.cpt$' | sort -V); do
    echo "--- $script 를 실행합니다 ---"
    # 실행 권한이 있는지 확인하고 없으면 추가
    if [ ! -x "$script" ]; then
        chmod +x "$script"
        echo "  > 실행 권한을 추가했습니다."
    fi
    # 서브 스크립트 실행
    ./"$script"
    if [ $? -ne 0 ]; then
        echo "  > 오류: $script 실행에 실패했습니다. 계속 진행합니다."
    fi
    echo "--- $script 실행 완료 ---"
    echo ""
done

echo "=========================================="
echo "=== 모든 스크립트 실행이 완료되었습니다 ==="
echo "=========================================="