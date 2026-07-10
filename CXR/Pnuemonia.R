# =====================================================================
# 목표: CDM 표준 vocabulary 로 폐렴 concept 을 정의하고,
#       condition_occurrence 에서 폐렴 환자(case)와 비폐렴 환자(control)를
#       찾아 각각 코호트를 만든다.
#       그 환자들의 흉부 X선(CXR) 인스턴스 경로(local_path)를 붙여
#       pneumonia_cohort.csv / control_cohort.csv 로 저장한다.
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

# 원시 결과(subject_id, local_path) -> 최종 코호트 형태로 정리
tidy_cohort <- function(df) {
  df %>%
    mutate(
      subject_id = as.character(subject_id),
      study_id   = sub(".*/s([0-9]+)/.*", "\\1", local_path),
      local_path = to_gcs(local_path)
    ) %>%
    select(subject_id, study_id, local_path) %>%
    arrange(subject_id, study_id)
}

# --- 1. 폐렴 concept 정의 -------------------------------------------
# 먼저 ICD 코드로 폐렴 concept 을 살핀다.
# 폐렴 ICD: ICD-10-CM J12~J18, ICD-9-CM 480~486
cat("[1] ICD 코드로 본 폐렴 concept\n")
querySql(conn, sprintf(
  "SELECT concept_id, vocabulary_id, concept_code, concept_name
     FROM %s.concept
    WHERE vocabulary_id IN ('ICD10CM','ICD9CM')
      AND (concept_code ~ '^J1[2-8]' OR concept_code ~ '^48[0-6]')
    LIMIT 6", CDM_SCHEMA)) %>%
  lower_names() %>%
  print()

# 실제 코호트 판정은 "standard concept" 으로 한다.
# SNOMED 'Pneumonia' 표준 concept_id = 255848
# concept_ancestor 로 그 하위 개념까지 모두 펼친다.
PNEUMONIA_STANDARD <- 255848L

n_desc <- querySql(conn, sprintf(
  "SELECT COUNT(DISTINCT descendant_concept_id) AS n
     FROM %s.concept_ancestor WHERE ancestor_concept_id = %d",
  CDM_SCHEMA, PNEUMONIA_STANDARD))[[1]]
cat("\n[2] 폐렴 standard concept 하위 개념 수:", n_desc, "\n")

# --- 2. 폐렴 환자 + 그 환자의 영상 인스턴스 -------------------------
# person_id 는 int64 라 R 로 꺼내면 정밀도가 깨진다(2^53 초과).
# 그래서 조인은 전부 DB 안(SQL)에서 끝내고, R 은 결과만 받는다.
#
# image_occurrence 에는 ECG 와 CXR 이 섞여 있다. 경로로 갈라낸다.
#   ECG : .../Datasets/ECG/...
#   CXR : .../Datasets/MIMIC-CXR/...
cat("[3] 폐렴 환자의 영상 modality 구성:\n")
querySql(conn, sprintf(
  "WITH pneu AS (
     SELECT descendant_concept_id AS cid
       FROM %1$s.concept_ancestor WHERE ancestor_concept_id = %2$d),
   pneu_person AS (
     SELECT DISTINCT co.person_id
       FROM %1$s.condition_occurrence co JOIN pneu ON co.condition_concept_id = pneu.cid)
   SELECT c.concept_name AS modality, COUNT(*) AS n
     FROM %1$s.image_occurrence io
     JOIN pneu_person pp ON io.person_id = pp.person_id
     LEFT JOIN %1$s.concept c ON c.concept_id = io.modality_concept_id
    GROUP BY c.concept_name ORDER BY n DESC", CDM_SCHEMA, PNEUMONIA_STANDARD)) %>%
  lower_names() %>%
  print()

# 폐렴 환자(case)의 CXR 인스턴스. subject_id 는 person 에서 붙인다.
case_raw <- querySql(conn, sprintf(
  "WITH pneu AS (
     SELECT descendant_concept_id AS cid
       FROM %1$s.concept_ancestor WHERE ancestor_concept_id = %2$d),
   pneu_person AS (
     SELECT DISTINCT co.person_id
       FROM %1$s.condition_occurrence co JOIN pneu ON co.condition_concept_id = pneu.cid)
   SELECT p.person_source_value AS subject_id, io.local_path
     FROM %1$s.image_occurrence io
     JOIN pneu_person pp ON io.person_id = pp.person_id
     JOIN %1$s.person p ON p.person_id = io.person_id
    WHERE io.local_path LIKE '%%/MIMIC-CXR/%%'", CDM_SCHEMA, PNEUMONIA_STANDARD)) %>%
  lower_names()

if (nrow(case_raw) == 0) {
  stop("폐렴 환자의 CXR 인스턴스가 없다. 위 modality 표를 보고 ",
       "image_occurrence 에 CXR 이 실려 있는지 확인할 것.")
}

# --- 3. 비폐렴 환자(control) ----------------------------------------
# NOT IN 은 서브쿼리에 NULL 이 하나라도 있으면 전체가 빈 결과가 된다.
# NOT EXISTS 를 쓴다.
#
# 주의: "폐렴 기록이 없다" != "폐렴이 아니다".
# 미기록/미방문 환자가 대조군에 섞인다. 최소한 condition_occurrence 에
# 기록이 하나라도 있는 환자로 좁혀 '진료를 받았지만 폐렴은 아니었던' 군을 만든다.
control_raw <- querySql(conn, sprintf(
  "WITH pneu AS (
     SELECT descendant_concept_id AS cid
       FROM %1$s.concept_ancestor WHERE ancestor_concept_id = %2$d),
   pneu_person AS (
     SELECT DISTINCT co.person_id
       FROM %1$s.condition_occurrence co JOIN pneu ON co.condition_concept_id = pneu.cid)
   SELECT p.person_source_value AS subject_id, io.local_path
     FROM %1$s.image_occurrence io
     JOIN %1$s.person p ON p.person_id = io.person_id
    WHERE io.local_path LIKE '%%/MIMIC-CXR/%%'
      AND NOT EXISTS (
        SELECT 1 FROM pneu_person pp WHERE pp.person_id = io.person_id)
      AND EXISTS (
        SELECT 1 FROM %1$s.condition_occurrence co2
         WHERE co2.person_id = io.person_id)", CDM_SCHEMA, PNEUMONIA_STANDARD)) %>%
  lower_names()

if (nrow(control_raw) == 0) {
  stop("비폐렴 CXR 인스턴스가 없다. 조건을 확인할 것.")
}

# --- 4. 경로 변환 & study_id 추출 -----------------------------------
# local_path 예:
#   s3://dryou-workspace/Datasets/MIMIC-CXR/files/p15/p15689523/s54023788/<uid>.dcm
# 여기서 s########  부분이 study_id 이다.
case_cohort    <- tidy_cohort(case_raw)
control_cohort <- tidy_cohort(control_raw)

cat("[4] CXR 를 가진 폐렴 환자:",
    length(unique(case_cohort$subject_id)), "명 /",
    nrow(case_cohort), "장(CXR 인스턴스)\n")
cat("    CXR 를 가진 비폐렴 환자:",
    length(unique(control_cohort$subject_id)), "명 /",
    nrow(control_cohort), "장(CXR 인스턴스)\n")

# case / control 이 겹치면 안 된다. 방어적으로 확인한다.
overlap <- intersect(case_cohort$subject_id, control_cohort$subject_id)
if (length(overlap) > 0) {
  stop("case 와 control 에 동시에 속한 환자가 있다: ", overlap[1])
}

# label 을 붙인 통합본도 같이 만든다.
combined <- bind_rows(
  case_cohort    %>% mutate(label = 1L),
  control_cohort %>% mutate(label = 0L)
) %>% arrange(subject_id, study_id)

# --- 5. 브릿지 파일 저장 --------------------------------------------
case_csv     <- file.path(OUT_DIR, "pneumonia_cohort.csv")
control_csv  <- file.path(OUT_DIR, "control_cohort.csv")
combined_csv <- file.path(OUT_DIR, "cxr_cohort_labeled.csv")

write.csv(case_cohort,    case_csv,     row.names = FALSE)
write.csv(control_cohort, control_csv,  row.names = FALSE)
write.csv(combined,       combined_csv, row.names = FALSE)

cat("\n[완료] 코호트 저장\n")
cat("  case    =>", case_csv, "\n")
cat("  control =>", control_csv, "\n")
cat("  labeled =>", combined_csv, "\n")
cat("컬럼: subject_id, study_id, local_path (CXR DICOM 의 GCS 경로)\n")
cat("labeled 는 여기에 label(1=폐렴, 0=비폐렴) 이 추가된다.\n")
cat("이 파일을 Jupyter(03_load_cxr_images.ipynb)에서 읽어\n")
cat("폐렴/비폐렴 환자의 흉부 X선 이미지를 로드한다.\n\n")
cat("case 미리보기:\n");    print(head(case_cohort, 5))
cat("\ncontrol 미리보기:\n"); print(head(control_cohort, 5))
