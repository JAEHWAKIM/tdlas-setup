1. ./setup.sh
2. reboot
3. ./nvme_setting.sh

`nvme_setting.sh`는 기존 파티션이나 파일시스템이 감지되면 디스크를 초기화하지
않습니다. 파티션이 없는 빈 NVMe 디스크를 초기화할 때만 `INITIALIZE` 확인이
필요합니다.

자동 삭제 기능은 `/mnt/nvme`가 실제 NVMe 장치에 마운트된 경우에만 동작하며,
디스크 사용량이 80%를 초과할 때 생성 후 365일이 지난 디렉터리를 한 번에 하나씩
삭제합니다.

MariaDB는 외부 조회를 위해 3306 포트에 바인딩되며, `tdlas_reader` 계정만
설치 유형에 해당하는 테이블(`record_log`, `channel_data`, `file_data` 또는
`results`)을 조회할 수 있습니다.
이 계정의 비밀번호는 설치 시 별도로 입력해야 합니다.