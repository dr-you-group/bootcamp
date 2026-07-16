## 0. 시작 전 준비사항

다음 항목을 미리 확인합니다.

- 개인별로 배부된 SCRAP 접속용 `.rdp` 파일
- 소속 팀 번호: `01`–`10`
- 팀별 GPU 서버 주소와 계정
- 팀별 `traineeNN` 계정과 비밀번호
- Chrome 또는 Microsoft Edge 최신 버전
- 안정적인 인터넷 연결
- macOS 사용자는 Microsoft의 **Windows App** 설치

### 보안 원칙

- 이 문서에 표시된 `NN`, `***`, `[MASKED]`는 자리표시자입니다.
- 예시 비밀번호를 실제 비밀번호로 입력하지 마십시오.
- 팀별 서버 주소, 계정, 비밀번호를 다른 팀과 공유하지 마십시오.
- 계정이나 비밀번호를 Notebook, R script, 화면 캡처, 메신저, Git 저장소에 기록하지 마십시오.
- SCRAP 및 실습 서버에서 확인한 환자 단위 자료를 개인 PC, 외부 클라우드, 이메일 또는 공개 저장소로 반출하지 마십시오.
- 공용 또는 타인의 PC에서는 브라우저의 비밀번호 저장 기능을 사용하지 마십시오.

---

## 1. 실습 환경 개요

| 구분 | 환경 | 용도 | 접속 방식 |
|---|---|---|---|
| 심화반 1일차 | SCRAP | CDW 검색 및 코호트 추출 실습 | 개별 `.rdp` 파일로 원격 Windows 접속 후 브라우저에서 접속 |
| 심화반 2일차 | OHDSI ATLAS | OMOP CDM 코호트 정의 및 탐색 | 웹 브라우저 |
| 심화반 2일차 | RStudio Server | CDM 연결, 코호트 구성, 결과 파일 생성 | 웹 브라우저 |
| 심화반 2일차 | JupyterHub | 공통 Jupyter 실습 환경 | 웹 브라우저 |
| 심화반 2일차·팀 프로젝트 | 팀별 GPU JupyterLab | ECG·CXR 모델 개발 및 팀별 프로젝트 | 팀별 전용 URL과 계정 |

---

# 심화반 1일차: SCRAP 접속

## 2. SCRAP 접속 구조

SCRAP은 개인 PC의 브라우저에서 직접 접속하는 방식이 아닙니다.

```text
개인 PC
  └─ 개별 배부된 .rdp 파일 실행
       └─ 원격 Windows 환경 접속
            └─ 원격 환경의 웹 브라우저 실행
                 └─ https://scrap.yuhs.ac 접속
```

배부된 `.rdp` 파일에는 원격접속에 필요한 서버 정보가 포함되어 있습니다. 파일명이나 내부 설정을 임의로 수정하지 마십시오.

---

## 3. Windows에서 접속

### 3.1 `.rdp` 파일을 직접 실행하는 방법

1. 운영진에게 받은 `.rdp` 파일을 PC에 저장합니다.
2. 파일을 더블클릭합니다.
3. **원격 데스크톱 연결** 창이 열리면 `연결`을 누릅니다.
4. 계정 입력 창이 나타나면 개별 배부받은 계정과 비밀번호를 입력합니다.
5. 인증서 또는 원격 컴퓨터 확인 창이 나타나면 접속 대상이 배부받은 환경과 일치하는지 확인한 뒤 진행합니다.
6. 원격 Windows 화면이 나타나면 원격 환경의 브라우저를 실행합니다.
7. 주소창에 다음 주소를 입력합니다.

```text
https://scrap.yuhs.ac
```

### 3.2 `.rdp` 파일이 자동으로 열리지 않는 경우

1. Windows 작업 표시줄의 검색창 또는 시작 메뉴를 엽니다.
2. 다음 중 하나를 검색합니다.

```text
원격 데스크톱 연결
Remote Desktop Connection
RDP
mstsc
```

3. **원격 데스크톱 연결** 프로그램을 실행합니다.
4. `옵션 표시`를 누른 뒤 `열기`에서 배부받은 `.rdp` 파일을 선택합니다.
5. `연결`을 누르고 개별 계정으로 로그인합니다.

### 3.3 Windows 접속 오류 확인

- `.rdp` 파일 확장자가 `.rdp`인지 확인합니다.
- 파일을 메신저나 이메일 미리보기에서 열지 말고 PC에 내려받은 뒤 실행합니다.
- 계정 앞뒤에 공백이 들어가지 않았는지 확인합니다.
- 비밀번호의 대문자, 소문자, 숫자, 특수문자를 구분합니다.
- 원격 Windows에 접속한 뒤 SCRAP을 열어야 합니다. 개인 PC의 브라우저에서 먼저 접속하지 않습니다.

---

## 4. macOS에서 접속

macOS에서는 App Store에서 Microsoft의 **Windows App**을 설치해야 합니다.

### 4.1 Windows App 설치

1. Mac에서 **App Store**를 엽니다.
2. 검색창에 다음을 입력합니다.

```text
Windows App
```

3. 게시자가 Microsoft인지 확인합니다.
4. 앱을 설치하고 실행합니다.

### 4.2 `.rdp` 파일 가져오기

1. Windows App을 실행합니다.
2. 상단의 `+` 또는 추가 메뉴를 누릅니다.
3. `Import from RDP file` 또는 `.rdp 파일 가져오기`를 선택합니다.
4. 운영진에게 받은 `.rdp` 파일을 선택합니다.
5. 가져온 원격 PC 항목을 더블클릭합니다.
6. 계정 입력 창에서 개별 배부받은 계정과 비밀번호를 입력합니다.
7. 원격 Windows가 열리면 원격 환경의 브라우저에서 다음 주소로 접속합니다.

```text
https://scrap.yuhs.ac
```

### 4.3 macOS 접속 오류 확인

- 구형 **Microsoft Remote Desktop**이 아니라 현재 배포되는 **Windows App**을 사용합니다.
- `.rdp` 파일을 Finder에서 직접 실행했을 때 열리지 않으면 Windows App 내부에서 가져옵니다.
- 키보드 입력이 다르게 동작하면 한글·영문 입력 상태와 Caps Lock 상태를 확인합니다.
- 전체 화면에서 빠져나오려면 Windows App 상단 메뉴 또는 macOS의 전체 화면 해제 기능을 사용합니다.

---

## 5. SCRAP 접속 후 확인사항

원격 Windows에 접속한 뒤 다음 순서로 확인합니다.

1. 원격 환경의 브라우저가 정상적으로 실행되는지 확인
2. `https://scrap.yuhs.ac` 접속
3. SCRAP 로그인 화면 또는 초기 화면이 정상적으로 표시되는지 확인
4. 실습 중 생성한 코호트 조건과 추출 설정을 저장했는지 확인
5. 환자 단위 자료를 외부로 복사하거나 캡처하지 않았는지 확인
6. 실습 종료 후 SCRAP에서 로그아웃
7. 원격 Windows 세션 종료

원격 창의 `X`만 눌러 세션을 분리하면 원격 세션이 남아 있을 수 있습니다. 실습 종료 시에는 Windows의 로그아웃 메뉴를 사용합니다.

---

# 심화반 2일차: CDM 및 AI 모델 개발 실습

## 6. 팀별 계정 체계

### 6.1 팀별 GPU JupyterLab

팀 번호는 `01`–`10` 중 하나입니다.

```text
URL: https://gpu-teamNN.[MASKED-GPU-SERVER-IP].sslip.io/
ID:  teamNN
PW:  teamNN***
```

예시의 `NN`과 `***`를 그대로 입력하지 마십시오.  
운영진에게 배부받은 **자신의 팀 URL, 팀 ID, 실제 비밀번호**를 사용합니다.

팀별 GPU 서버 주소는 프로젝트 경쟁을 위해 팀별로 분리되어 있습니다.

- 다른 팀의 URL을 추측하거나 접속하지 마십시오.
- 다른 팀에 자신의 서버 주소나 로그인 정보를 전달하지 마십시오.
- 다른 팀 계정으로 접속을 시도하지 마십시오.

### 6.2 ATLAS·RStudio·JupyterHub 계정

공통 서비스의 계정 형식은 다음과 같습니다.

```text
ID: traineeNN
PW: traineeNN***
```

- `NN`은 팀별로 배정된 번호이며 범위는 `21`–`30`입니다.
- 팀 번호와 `traineeNN` 번호의 실제 대응 관계는 운영진이 팀별로 별도 배부합니다.
- 다른 팀의 `traineeNN` 번호를 추측하거나 사용하지 마십시오.
- `***`는 마스킹 표시이며 실제 비밀번호가 아닙니다.

---

## 7. 서비스별 접속 주소

### 7.1 OHDSI ATLAS

```text
https://atlas.34.158.208.140.sslip.io/atlas
```

주요 용도:

- OMOP CDM 데이터 구조 탐색
- Concept 검색
- Cohort Definition 작성
- 조건 포함·제외 기준 확인
- 코호트 구성 결과 검토

### 7.2 RStudio Server

```text
https://rstudio.34.158.208.140.sslip.io/
```

주요 용도:

- OMOP CDM 데이터베이스 연결
- SQL 및 R 기반 코호트 구성
- 분석 대상자 및 영상 경로 추출
- Jupyter에서 사용할 중간 CSV 생성

로그인:

```text
ID: traineeNN
PW: 개별 배부 비밀번호
```

### 7.3 JupyterHub

```text
https://jupyter.34.158.208.140.sslip.io/
```

주요 용도:

- 공통 Jupyter Notebook 실습
- Python 코드 실행
- 데이터 확인 및 시각화

로그인:

```text
ID: traineeNN
PW: 개별 배부 비밀번호
```

### 7.4 팀별 GPU JupyterLab

```text
https://gpu-teamNN.[MASKED-GPU-SERVER-IP].sslip.io/
```

주요 용도:

- ECG 모델 학습
- CXR 모델 학습
- GPU 기반 딥러닝 실습
- 팀별 프로젝트 개발
- 결과 파일 및 발표 자료 생성

로그인:

```text
ID: teamNN
PW: 개별 배부 비밀번호
```

---

## 8. 권장 접속 순서

CDM에서 코호트를 만들고 AI 모델 개발 환경으로 연결할 때 다음 순서를 사용합니다.

```text
1. ATLAS
   └─ CDM concept와 코호트 조건 확인

2. RStudio Server
   └─ CDM DB 연결
   └─ 코호트 구성
   └─ 모델 입력용 CSV 또는 경로 정보 생성

3. JupyterHub 또는 팀별 GPU JupyterLab
   └─ CSV 및 데이터 경로 확인
   └─ 데이터 전처리
   └─ 모델 학습
   └─ 성능 평가
   └─ 결과 저장

4. 팀별 프로젝트 폴더
   └─ Notebook, 코드, 결과, 발표 자료 정리
```

---

## 9. GitHub 실습 자료

실습 자료 저장소:

[dr-you-group/bootcamp](https://github.com/dr-you-group/bootcamp)

서버에 `bootcamp` 폴더가 이미 준비되어 있으면 기존 폴더를 사용합니다.  
폴더가 없는 경우에만 JupyterLab 또는 JupyterHub의 Terminal에서 다음 명령을 실행합니다.

```bash
git clone https://github.com/dr-you-group/bootcamp.git
cd bootcamp
```

이미 복제된 저장소를 최신 상태로 갱신할 때는 다음 명령을 사용합니다.

```bash
cd bootcamp
git pull
```

실습 중 원본 파일을 직접 덮어쓰지 말고, 팀 작업 폴더에 복사한 뒤 수정합니다.

---

## 10. 실습 자료 디렉터리 구조

2026년 7월 기준 저장소 구조는 다음과 같습니다.

```text
bootcamp/
├── CXR/
│   ├── CNN_폐렴분류_실습용.ipynb
│   ├── CNN_폐렴분류_실습용_정리본.ipynb
│   ├── Pnuemonia.R
│   ├── negative_control.csv
│   └── positive_pneumonia.csv
│
├── ECG/
│   ├── afib_concepts.csv
│   ├── afib_data.csv
│   └── afib_ecg_tutorial.ipynb
│
└── data_load/
    ├── 01_connect_cdm.R
    ├── 02_build_tb_cohort.R
    ├── 03_load_cxr_images.ipynb
    └── README.md
```

> `Pnuemonia.R`은 저장소에 등록된 실제 파일명입니다. 철자를 임의로 수정하면 파일을 찾지 못할 수 있습니다.

### 10.1 `data_load/`

RStudio에서 CDM 코호트를 구성한 뒤 Jupyter로 영상 데이터를 연결하는 실습입니다.

| 순서 | 파일 | 환경 | 역할 |
|---|---|---|---|
| 1 | `01_connect_cdm.R` | RStudio | OMOP CDM 데이터베이스 연결 |
| 2 | `02_build_tb_cohort.R` | RStudio | 코호트 구성 및 영상 경로 결합 |
| 3 | `03_load_cxr_images.ipynb` | Jupyter | 코호트 파일을 읽고 CXR 영상 로드 |
| 참고 | `README.md` | 공통 | 세부 실행 순서와 데이터 흐름 설명 |

핵심 연결 파일은 다음 경로에 생성됩니다.

```text
data_load/outputs/tb_cohort.csv
```

주요 컬럼:

```text
subject_id
study_id
local_path
```

연결 흐름:

```text
RStudio
  └─ CDM DB 연결
       └─ 코호트 구성
            └─ outputs/tb_cohort.csv 생성
                 └─ Jupyter에서 CSV 읽기
                      └─ local_path를 이용해 CXR 영상 로드
```

### 10.2 `ECG/`

AFib 탐지 실습 자료입니다.

| 파일 | 역할 |
|---|---|
| `afib_concepts.csv` | AFib 관련 concept 정보 |
| `afib_data.csv` | ECG 실습용 데이터 |
| `afib_ecg_tutorial.ipynb` | ECG 로드, 전처리, 모델 학습 및 평가 실습 |

### 10.3 `CXR/`

흉부 X-ray 분류 실습 자료입니다.

| 파일 | 역할 |
|---|---|
| `CNN_폐렴분류_실습용.ipynb` | 참여자 실습용 Notebook |
| `CNN_폐렴분류_실습용_정리본.ipynb` | 실습 정리·참고용 Notebook |
| `Pnuemonia.R` | CXR 실습 관련 R script |
| `negative_control.csv` | 음성 대조군 정보 |
| `positive_pneumonia.csv` | 폐렴 양성군 정보 |

---

## 11. 파일 실행 순서

### 11.1 CDM과 CXR 연결 실습

#### RStudio Server

1. `data_load/01_connect_cdm.R` 열기
2. 코드 셀 또는 스크립트를 위에서부터 순서대로 실행
3. CDM DB 연결 성공 여부 확인
4. `data_load/02_build_tb_cohort.R` 열기
5. 코호트 구성 코드 실행
6. 다음 파일이 생성되었는지 확인

```text
data_load/outputs/tb_cohort.csv
```

#### Jupyter 환경

1. `data_load/03_load_cxr_images.ipynb` 열기
2. Kernel이 정상적으로 연결되었는지 확인
3. 셀을 위에서부터 순서대로 실행
4. `tb_cohort.csv`를 정상적으로 읽는지 확인
5. CXR 영상이 렌더링되는지 확인

### 11.2 ECG 모델 실습

1. 팀별 GPU JupyterLab에 로그인
2. `ECG/afib_ecg_tutorial.ipynb` 열기
3. Kernel 확인
4. 데이터 로드 및 전처리 셀 실행
5. 모델 학습 셀 실행
6. 평가 지표와 예측 결과 확인
7. 팀 폴더에 결과 저장

### 11.3 CXR 모델 실습

1. 팀별 GPU JupyterLab에 로그인
2. `CXR/CNN_폐렴분류_실습용.ipynb` 열기
3. 데이터 경로와 입력 파일 확인
4. 전처리 및 DataLoader 셀 실행
5. CNN 모델 학습
6. 성능 평가 및 결과 시각화
7. 막히는 부분은 `CNN_폐렴분류_실습용_정리본.ipynb`와 비교

---

## 12. JupyterLab 기본 사용법

### 12.1 Terminal 열기

JupyterLab 화면에서 다음 순서로 엽니다.

```text
File → New → Terminal
```

또는 Launcher 화면에서 `Terminal`을 선택합니다.

### 12.2 Notebook 실행

1. `.ipynb` 파일을 더블클릭합니다.
2. 우측 상단에서 Kernel이 연결되어 있는지 확인합니다.
3. 셀을 선택하고 `Shift + Enter`를 누릅니다.
4. 실행 중인 셀은 `[*]`로 표시됩니다.
5. 실행이 끝나면 숫자 형태의 실행 순서가 표시됩니다.

### 12.3 저장

```text
Ctrl + S        Windows
Command + S     macOS
```

장시간 학습 전후로 반드시 저장합니다.

### 12.4 GPU 확인

Notebook 셀에서 다음 명령을 실행합니다.

```python
!nvidia-smi
```

PyTorch에서 GPU 사용 가능 여부를 확인할 때는 다음 코드를 실행합니다.

```python
import torch

print("CUDA available:", torch.cuda.is_available())

if torch.cuda.is_available():
    print("GPU:", torch.cuda.get_device_name(0))
```

`CUDA available: False`가 표시되면 팀별 GPU JupyterLab 주소로 접속했는지 먼저 확인합니다.

### 12.5 Kernel이 멈춘 경우

```text
Kernel → Interrupt Kernel
```

중단되지 않으면 다음을 사용합니다.

```text
Kernel → Restart Kernel
```

Kernel을 재시작하면 메모리에 있던 변수와 모델이 초기화됩니다. 필요한 셀을 처음부터 다시 실행합니다.

---

## 13. 팀별 프로젝트 권장 폴더 구조

원본 실습 자료와 팀 프로젝트 파일을 분리합니다.

```text
team_project/
├── README.md
├── notebooks/
│   ├── 01_data_preparation.ipynb
│   ├── 02_model_training.ipynb
│   └── 03_evaluation.ipynb
├── src/
│   ├── data.py
│   ├── model.py
│   └── evaluate.py
├── outputs/
│   ├── figures/
│   ├── tables/
│   └── models/
└── presentation/
    └── final_presentation.pptx
```

권장 원칙:

- 실습 원본 Notebook을 복사하여 팀 폴더에서 수정
- 파일명 앞에 실행 순서를 나타내는 번호 사용
- 모델, 그림, 표를 `outputs/` 아래에 분리
- 발표 자료는 `presentation/`에 저장
- 대용량 원자료와 환자 단위 자료는 팀 프로젝트 폴더나 Git 저장소에 복사하지 않음
- 최종 Notebook은 위에서부터 순차 실행 가능한 상태로 정리
- 사용한 데이터, 전처리, 모델, 평가 지표를 팀 `README.md`에 기록

---

## 14. 팀 프로젝트 최소 산출물

팀별 프로젝트 종료 전 다음 항목을 준비합니다.

1. 연구 또는 분석 질문
2. 사용 데이터와 대상 코호트 정의
3. 입력 변수와 결과 변수
4. 데이터 전처리 과정
5. 사용 모델과 선택 근거
6. 학습·검증 데이터 분할 방식
7. 주요 평가 지표
8. 결과 표 또는 그림
9. 한계점
10. 발표 자료
11. 재실행 가능한 Notebook 또는 script

---

## 15. 접속 문제 해결

### 15.1 URL이 열리지 않는 경우

- 주소 앞뒤에 공백이 없는지 확인합니다.
- `http://`가 아니라 `https://`인지 확인합니다.
- 팀 번호가 두 자리인지 확인합니다.

```text
올바른 형식: team01
잘못된 형식: team1
```

- 팀별 GPU 주소는 운영진이 배부한 원문을 복사해 사용합니다.
- 브라우저 새로고침 후에도 열리지 않으면 새 창에서 다시 접속합니다.
- VPN, 프록시, 광고 차단 확장 프로그램이 연결을 방해하는지 확인합니다.

### 15.2 로그인이 되지 않는 경우

- ID의 `NN`이 자신의 배정 번호인지 확인합니다.
- GPU 계정과 `traineeNN` 계정을 혼동하지 않았는지 확인합니다.
- 비밀번호 예시의 `***`를 실제로 입력하지 않았는지 확인합니다.
- Caps Lock과 한글 입력 상태를 확인합니다.
- 복사·붙여넣기 과정에서 비밀번호 앞뒤에 공백이 들어가지 않았는지 확인합니다.
- 여러 번 실패한 뒤에는 반복 시도하지 말고 운영진에게 계정 잠금 여부를 확인받습니다.

### 15.3 Jupyter에서 파일이 보이지 않는 경우

Terminal에서 현재 위치를 확인합니다.

```bash
pwd
ls -al
```

저장소 위치를 찾습니다.

```bash
find ~ -maxdepth 3 -type d -name bootcamp 2>/dev/null
```

저장소 폴더로 이동합니다.

```bash
cd /찾은/경로/bootcamp
```

### 15.4 `ModuleNotFoundError`가 발생하는 경우

Notebook의 설치 안내 셀을 먼저 실행합니다.  
임의로 전체 환경을 업그레이드하거나 핵심 패키지 버전을 변경하지 마십시오.

현재 Python 환경을 확인할 때는 다음 코드를 사용합니다.

```python
import sys

print(sys.executable)
print(sys.version)
```

### 15.5 GPU 메모리 부족 오류

다음 항목을 순서대로 조정합니다.

1. 이전 Notebook의 실행 중인 Kernel 종료
2. 불필요한 변수 삭제
3. batch size 축소
4. 이미지 크기 또는 sequence length 축소
5. 모델과 optimizer를 다시 생성하기 전 Kernel 재시작

PyTorch 메모리를 정리할 때는 다음 코드를 사용할 수 있습니다.

```python
import gc
import torch

gc.collect()

if torch.cuda.is_available():
    torch.cuda.empty_cache()
```

---

## 16. 실습 종료 전 체크리스트

### SCRAP

- [ ] 필요한 코호트 조건을 저장했다.
- [ ] 환자 단위 자료를 외부로 반출하지 않았다.
- [ ] SCRAP에서 로그아웃했다.
- [ ] 원격 Windows 세션에서 로그아웃했다.

### RStudio·ATLAS·JupyterHub

- [ ] 자신의 `traineeNN` 계정만 사용했다.
- [ ] 코드와 결과 파일을 저장했다.
- [ ] 계정 정보를 코드에 기록하지 않았다.
- [ ] 실습 종료 후 로그아웃했다.

### 팀별 GPU JupyterLab

- [ ] 자신의 팀 전용 주소와 계정만 사용했다.
- [ ] Notebook을 저장했다.
- [ ] 실행 중인 학습 작업을 확인했다.
- [ ] 불필요한 Kernel을 종료했다.
- [ ] 결과 파일을 팀 프로젝트 폴더에 정리했다.
- [ ] 다른 팀에 접속정보를 공유하지 않았다.

### 팀 프로젝트

- [ ] 최종 Notebook이 순서대로 실행된다.
- [ ] 데이터 전처리와 모델 설정이 기록되어 있다.
- [ ] 주요 평가 지표와 결과 그림이 포함되어 있다.
- [ ] 발표 자료가 저장되어 있다.
- [ ] 환자정보, 비밀번호, 서버 내부 주소가 발표 자료에 포함되지 않았다.

---

## 17. 접속정보 요약

```text
[심화반 1일차]

SCRAP
- 개별 .rdp 파일로 원격 Windows 접속
- 원격 Windows 내부 브라우저에서 접속
- https://scrap.yuhs.ac


[심화반 2일차]

OHDSI ATLAS
- https://atlas.34.158.208.140.sslip.io/atlas

RStudio Server
- https://rstudio.34.158.208.140.sslip.io/

JupyterHub
- https://jupyter.34.158.208.140.sslip.io/

공통 계정
- ID: traineeNN
- PW: 개별 배부
- NN: 팀별 배정 번호 21–30


[팀별 GPU 서버]

GPU JupyterLab
- URL: https://gpu-teamNN.[MASKED-GPU-SERVER-IP].sslip.io/
- ID: teamNN
- PW: 개별 배부
- NN: 팀 번호 01–10
```

---

## 18. 참고 저장소

- 실습 코드 및 자료: [dr-you-group/bootcamp](https://github.com/dr-you-group/bootcamp)
- 저장소의 파일 구성이나 실행 순서가 변경된 경우, 수업 당일 운영진의 안내를 우선합니다.
