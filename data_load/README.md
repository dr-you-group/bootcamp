# 실습: CDM(RStudio) → 코호트 → 흉부 X선 이미지(Jupyter)

## 목적
학생이 **RStudio 실습 환경에서 시작해 Jupyter 환경까지 하나로 연결**하는 흐름을 체험한다.
핵심은 두 환경을 잇는 다리(코호트 CSV)를 직접 만들어 보는 것이다.

## 데이터 흐름
```
RStudio (R)                              Jupyter (Python)
-----------                              ----------------
CDM DB (PostgreSQL)                       tb_cohort.csv 읽기
   |  DatabaseConnector 로 접속               |
결핵 코호트 구성                     ===>   local_path 로 CXR DICOM 내려받기
   |  + CXR local_path 붙이기                |
tb_cohort.csv 저장 ----------------------> 흉부 X선 이미지 렌더
```
`outputs/tb_cohort.csv` 파일 하나가 두 환경을 잇는 다리다.
컬럼은 `subject_id, study_id, local_path` (local_path = CXR DICOM 의 GCS 경로).

## 시간표와 파일
| 시간 | 활동 | 파일 | 환경 |
|------|------|------|------|
| 12:30-12:40 | CDM 연결 | `01_connect_cdm.R` | RStudio |
| 12:40-12:50 | 결핵 코호트 구성 | `02_build_tb_cohort.R` | RStudio |
| 12:50-13:00 | CXR 이미지 로드 | `03_load_cxr_images.ipynb` | Jupyter |

## 실행 순서
1. **RStudio**에서 `01` → `02` 를 순서대로 실행.
   - `01`: `DatabaseConnector` 로 CDM DB(PostgreSQL)에 접속하는 것이 곧 CDM 연결임을 확인한다.
     실제 병원 CDM 도 이렇게 DB 안에 있다.
   - `02`: `condition_occurrence` 로 결핵 환자를 판정하고,
     `image_occurrence` 에서 그 환자들의 CXR `local_path` 를 붙여
     `outputs/tb_cohort.csv` (subject_id, study_id, local_path) 를 만든다.
     `person_id` 는 int64 라 R 로 꺼내면 정밀도가 깨진다. 조인은 전부 SQL 안에서 끝낸다.
2. **Jupyter**에서 `03_load_cxr_images.ipynb` 를 실행.
   - RStudio가 만든 `tb_cohort.csv` 를 찾아 읽고, `local_path` 로 CXR DICOM 을
     GCS에서 내려받아 흉부 X선 이미지를 렌더링한다.

## 데이터셋 규모 (참고)
- 결핵 환자(condition_occurrence 기준): 183명
- 그중 CXR 보유: 76명 / 857장

## 설계 원칙
- 진단은 오직 `condition_occurrence`(CDM)로만 판정한다.
- CXR 원본 DICOM 은 GCS 버킷에 있다. 노트북은 코호트에서 몇 장만 골라 내려받아
  렌더링한다(시연용).
- `image_occurrence.local_path` 는 데이터를 만든 서버 기준 경로(`s3://...` 또는 마운트 경로)다.
  `02` 가 `/Datasets/` 뒤쪽만 살려 `gs://` 접두사로 갈아끼운다.

## 접속 정보 / 사전조건
- CDM DB: `10.60.0.2:15432`, database `mimiciv_cdm`, schema `cdm`
- 비밀번호는 코드에 적지 않고 환경변수로: `Sys.setenv(CDM_DB_PASSWORD = "...")`
- R: `DatabaseConnector`, `dplyr` / JDBC 드라이버는 `/opt/ohdsi/jdbc/postgresql`
- Python: `pydicom`, `pylibjpeg`(+libjpeg, openjpeg), `gcsfs`, `numpy`, `pandas`,
  `matplotlib`, `tqdm` (노트북이 없으면 자동 설치)
- GCS 인증: `gcloud auth application-default login` (또는 서비스계정)
- 버킷: `gs://zarathu-edu-mimic-data-ethereal-mind-460209-e0`
