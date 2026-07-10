# =====================================================================
# 목표: CDM 표준 vocabulary 로 결핵 concept을 정의하고,
#       condition_occurrence 에서 결핵 환자를 찾아 코호트를 만든다.
#       그 환자들의 흉부 X선(CXR) 인스턴스 경로(local_path)를 붙여
#       tb_cohort.csv (subject_id, study_id, local_path) 로 저장한다.
#       => 이 CSV 가 RStudio 실습을 Jupyter 실습으로 잇는 "다리" 이다.
#
# 진단 판정 원칙(MI-CDM 규칙): 진단은 오직 condition_occurrence 로만 한다.
# =====================================================================

library(DatabaseConnector)
library(dplyr)

# 01_connect_cdm.R 을 먼저 실행해 conn / CDM_SCHEMA 를 만들어 둔다.
if (!exists("conn")) source("01_connect_cdm.R")

OUT_DIR <- file.path(getwd(), "outputs")
dir.create(OUT_DIR, showWarnings = FALSE, recursive = TRUE)

# local_path 는 데이터를 만든 서버 기준 경로다. 행마다 접두사가 제각각이다.
#   ECG: /home/ubuntu/dryou_mount/Datasets/ECG/...
#   CXR: s3://dryou-workspace/Datasets/MIMIC-CXR/...
# 공통인 '/Datasets/...' 뒤쪽만 살리고 앞을 우리 버킷으로 갈아끼운다.
GCS_PREFIX <- "gs://zarathu-edu-mimic-data-ethereal-mind-460209-e0"

to_gcs <- function(path) {
  out <- sub("^.*?(/Datasets/.*)$", paste0(GCS_PREFIX, "\\1"), path)
  bad <- !startsWith(out, GCS_PREFIX)
  if (any(bad)) stop("'/Datasets/' 를 못 찾은 경로가 있다: ", out[which(bad)[1]])
  out
}

lower_names <- function(df) { names(df) <- tolower(names(df)); df }

# --- 1. 결핵 concept 정의 -------------------------------------------
# 먼저 ICD 코드로 결핵 concept을 살핀다.
# 결핵 ICD: ICD-10-CM A15~A19, ICD-9-CM 010~018
cat("[1] ICD 코드로 본 결핵 concept\n")
querySql(conn, sprintf(
  "SELECT concept_id, vocabulary_id, concept_code, concept_name
     FROM %s.concept
    WHERE vocabulary_id IN ('ICD10CM','ICD9CM')
      AND (concept_code ~ '^A1[5-9]' OR concept_code ~ '^01[0-8]')
    LIMIT 6", CDM_SCHEMA)) %>%
  lower_names() %>%
  print()

# 실제 코호트 판정은 "standard concept" 으로 한다.
# SNOMED 'Tuberculosis' 표준 concept_id = 434557
# concept_ancestor 로 그 하위 개념까지 모두 펼친다.
TB_STANDARD <- 434557L

n_desc <- querySql(conn, sprintf(
  "SELECT COUNT(DISTINCT descendant_concept_id) AS n
     FROM %s.concept_ancestor WHERE ancestor_concept_id = %d",
  CDM_SCHEMA, TB_STANDARD))[[1]]
cat("\n[2] 결핵 standard concept 하위 개념 수:", n_desc, "\n")

# --- 2. 결핵 환자 + 그 환자의 영상 인스턴스 -------------------------
# image_occurrence 에는 ECG 와 CXR 이 섞여 있다. 경로로 갈라낸다.
#   ECG : .../Datasets/ECG/...
#   CXR : .../Datasets/MIMIC-CXR/...
cat("[3] 결핵 환자의 영상 modality 구성:\n")
querySql(conn, sprintf(
  "WITH tb AS (
     SELECT descendant_concept_id AS cid
       FROM %1$s.concept_ancestor WHERE ancestor_concept_id = %2$d),
   tb_person AS (
     SELECT DISTINCT co.person_id
       FROM %1$s.condition_occurrence co JOIN tb ON co.condition_concept_id = tb.cid)
   SELECT c.concept_name AS modality, COUNT(*) AS n
     FROM %1$s.image_occurrence io
     JOIN tb_person tp ON io.person_id = tp.person_id
     LEFT JOIN %1$s.concept c ON c.concept_id = io.modality_concept_id
    GROUP BY c.concept_name ORDER BY n DESC", CDM_SCHEMA, TB_STANDARD)) %>%
  lower_names() %>%
  print()

# 결핵 환자의 CXR 인스턴스만 뽑는다. subject_id 는 person 에서 붙인다.
cohort_raw <- querySql(conn, sprintf(
  "WITH tb AS (
     SELECT descendant_concept_id AS cid
       FROM %1$s.concept_ancestor WHERE ancestor_concept_id = %2$d),
   tb_person AS (
     SELECT DISTINCT co.person_id
       FROM %1$s.condition_occurrence co JOIN tb ON co.condition_concept_id = tb.cid)
   SELECT p.person_source_value AS subject_id, io.local_path
     FROM %1$s.image_occurrence io
     JOIN tb_person tp ON io.person_id = tp.person_id
     JOIN %1$s.person p ON p.person_id = io.person_id
    WHERE io.local_path LIKE '%%/MIMIC-CXR/%%'", CDM_SCHEMA, TB_STANDARD)) %>%
  lower_names()

if (nrow(cohort_raw) == 0) {
  stop("결핵 환자의 CXR 인스턴스가 없다. 위 modality 표를 보고 ",
       "image_occurrence 에 CXR 이 실려 있는지 확인할 것.")
}

# --- 3. 경로 변환 & study_id 추출 -----------------------------------
# local_path 예:
#   s3://dryou-workspace/Datasets/MIMIC-CXR/files/p15/p15689523/s54023788/<uid>.dcm
# 여기서 s########  부분이 study_id 이다.
cohort <- cohort_raw %>%
  mutate(
    subject_id = as.character(subject_id),
    study_id   = sub(".*/s([0-9]+)/.*", "\\1", local_path),
    local_path = to_gcs(local_path)
  ) %>%
  select(subject_id, study_id, local_path) %>%
  arrange(subject_id, study_id)

cat("[4] CXR 를 가진 결핵 환자:",
    length(unique(cohort$subject_id)), "명 /",
    nrow(cohort), "장(CXR 인스턴스)\n")

# --- 4. 브릿지 파일 저장 --------------------------------------------
out_csv <- file.path(OUT_DIR, "tb_cohort.csv")
write.csv(cohort, out_csv, row.names = FALSE)

cat("\n[완료] 코호트 저장 =>", out_csv, "\n")
cat("컬럼: subject_id, study_id, local_path (CXR DICOM 의 GCS 경로)\n")
cat("이 파일을 Jupyter(03_load_cxr_images.ipynb)에서 읽어\n")
cat("결핵 환자의 흉부 X선 이미지를 로드한다.\n\n")
cat("코호트 미리보기:\n")
print(head(cohort, 5))
