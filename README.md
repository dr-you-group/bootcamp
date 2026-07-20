# 2026 부트캠프 심화반 실습 환경 연결 매뉴얼

## 1. 심화반 1일차: SCRAP 접속

SCRAP은 학생별로 배부된 `.rdp` 파일을 통해 원격 환경에 접속한 뒤 이용합니다.

### Windows

1. 배부받은 `.rdp` 파일을 더블클릭합니다.
2. 원격 데스크톱 연결 창에서 접속합니다.
3. 원격 환경의 웹 브라우저에서 아래 주소로 접속합니다.

```text
https://scrap.yuhs.ac
```

`.rdp` 파일이 바로 실행되지 않는 경우 Windows 검색창에서 `원격 데스크톱 연결` 또는 `RDP`를 검색하여 프로그램을 실행한 뒤, 배부받은 `.rdp` 파일을 엽니다.

### macOS

1. App Store에서 Microsoft의 **Windows App**을 설치합니다.
2. Windows App을 실행합니다.
3. 배부받은 `.rdp` 파일을 import합니다.
4. 가져온 원격 접속 항목을 실행합니다.
5. 원격 환경의 웹 브라우저에서 아래 주소로 접속합니다.

```text
https://scrap.yuhs.ac
```

---

## 2. 심화반 2일차: CDM 및 AI 모델 개발 실습

심화반 2일차에는 팀별로 배부된 접속 주소와 계정 정보를 이용합니다.

### 팀별 GPU 서버

팀별 프로젝트와 AI 모델 개발 실습은 각 팀에 배부된 GPU 서버의 JupyterLab에서 진행합니다.

운영진이 팀별로 전달한 다음 정보를 사용하여 접속합니다.

- GPU 서버 주소
- 팀 ID
- 팀 비밀번호

```
개인용 Colab 실습을 위한 데이터셋은 아래 링크를 통해 다운받으실 수 있습니다. (당일 개방 예정)
https://drive.google.com/drive/folders/1EUpzMBmxcxHB_KwhBBsrJEKQeugv_6Mm?usp=drive_link
```

### OHDSI ATLAS

```text
https://atlas.[xxx].sslip.io/atlas
```

팀별로 배부된 계정으로 로그인합니다.

### RStudio Server

```text
https://rstudio.[xxx].sslip.io/
```

팀별로 배부된 계정으로 로그인합니다.
각 서버의 전체 주소는 채널에서 확인하실 수 있습니다.

---

## 3. 실습자료 저장소

실습자료는 아래 GitHub 저장소에서 확인할 수 있습니다.

[dr-you-group/bootcamp](https://github.com/dr-you-group/bootcamp)

```bash
git clone https://github.com/dr-you-group/bootcamp.git
cd bootcamp
```

서버에 저장소가 이미 준비되어 있는 경우 기존 `bootcamp` 디렉터리를 사용합니다.

---

## 4. 실습자료 디렉터리 구조

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

### `data_load/`

CDM 데이터베이스 연결, 코호트 구성, CXR 영상 연결 실습자료입니다.

```text
data_load/
├── 01_connect_cdm.R
├── 02_build_tb_cohort.R
├── 03_load_cxr_images.ipynb
└── README.md
```

실습 순서는 다음과 같습니다.

1. `01_connect_cdm.R`: OMOP CDM 데이터베이스 연결
2. `02_build_tb_cohort.R`: 실습 대상 코호트 구성
3. `03_load_cxr_images.ipynb`: 코호트 정보와 CXR 영상 연결

### `ECG/`

심전도 데이터를 이용한 심방세동 분류 실습자료입니다.

```text
ECG/
├── afib_concepts.csv
├── afib_data.csv
└── afib_ecg_tutorial.ipynb
```

- `afib_concepts.csv`: 심방세동 관련 concept 정보
- `afib_data.csv`: ECG 실습 데이터
- `afib_ecg_tutorial.ipynb`: ECG 데이터 처리 및 모델 개발 실습

### `CXR/`

흉부 X-ray 데이터를 이용한 폐렴 분류 실습자료입니다.

```text
CXR/
├── CNN_폐렴분류_실습용.ipynb
├── CNN_폐렴분류_실습용_정리본.ipynb
├── Pnuemonia.R
├── negative_control.csv
└── positive_pneumonia.csv
```

- `CNN_폐렴분류_실습용.ipynb`: 참여자 실습용 Notebook
- `CNN_폐렴분류_실습용_정리본.ipynb`: 실습 참고용 Notebook
- `Pnuemonia.R`: 폐렴 코호트 관련 R script
- `negative_control.csv`: 폐렴 음성군 정보
- `positive_pneumonia.csv`: 폐렴 양성군 정보
