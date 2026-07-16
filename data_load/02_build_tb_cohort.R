# =====================================================================
# 목표: ATLAS 에서 정의한 결핵 concept set 으로 condition_occurrence 에서
#       결핵 환자를 찾아 코호트를 만든다. 그 환자들의 흉부 X선(CXR)
#       인스턴스 경로(local_path)를 붙여 tb_cohort.csv (subject_id, study_id,
#       local_path) 로 저장한다.
#       => 이 CSV 가 RStudio 실습을 Jupyter 실습으로 잇는 "다리" 이다.
#
# 진단 판정 원칙(MI-CDM 규칙): 진단은 오직 condition_occurrence 로만 한다.
#
# concept 정의 방식: ATLAS(OHDSI) 에서 개념을 검색·확정한다.
#   1) ATLAS 의 Search 에서 'Tuberculosis' 검색
#   2) SNOMED standard concept 'Tuberculosis'(concept_id = 434557) 선택
#   3) Concept Set 에 넣고 'include descendants' 체크 -> 하위개념까지 resolve
#   4) resolved concept 목록을 tb_concepts.csv 로 내보내 이 스크립트에 동봉
#   => 그래서 R 에서 concept_ancestor 로 다시 펼치지 않고, 이 목록을 그대로 쓴다.
#      (afib 실습의 afib_concepts.csv 와 동일한 패턴)
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
# 공통인 '/Datasets/...' 뒤쪽만 살리고 앞을 우리 GCS 버킷으로 갈아끼운다.
GCS_PREFIX <- "gs://zarathu-edu-mimic-data-ethereal-mind-460209-e0"

to_gcs <- function(path) {
  out <- sub("^.*?(/Datasets/.*)$", paste0(GCS_PREFIX, "\\1"), path)
  bad <- !startsWith(out, GCS_PREFIX)
  if (any(bad)) stop("'/Datasets/' 를 못 찾은 경로가 있다: ", out[which(bad)[1]])
  out
}

lower_names <- function(df) { names(df) <- tolower(names(df)); df }

# --- 1. ATLAS 에서 확정한 결핵 concept set 불러오기 --------------------
# ATLAS 에서 'Tuberculosis'(SNOMED 434557) 를 include-descendants 로 resolve 해
# 내보낸 목록. (Athena 로 개념 확인: https://athena.ohdsi.org/search-terms/terms/434557)
# concept_ancestor 를 R 에서 다시 펼치지 않는다 - 이미 ATLAS 가 펼쳐 확정했다.
tb_concepts <- read.csv(file.path(getwd(), "tb_concepts.csv"))
tb_ids <- unique(tb_concepts$concept_id)
if (length(tb_ids) == 0) stop("tb_concepts.csv 가 비어있다. ATLAS 에서 내보낸 목록을 확인할 것.")
id_list <- paste(tb_ids, collapse = ",")
cat(sprintf("[1] ATLAS resolved 결핵 concept: %d 개 (SNOMED, include descendants)\n",
            length(tb_ids)))
cat("    예:", paste(head(tb_concepts$concept_name, 3), collapse = " / "), "...\n")

# --- 2. 결핵 환자의 영상 modality 구성 --------------------------------
# image_occurrence 에는 ECG 와 CXR 이 섞여 있다. 경로로 갈라낸다.
#   ECG : .../Datasets/ECG/...
#   CXR : .../Datasets/MIMIC-CXR/...
cat("[2] 결핵 환자의 영상 modality 구성:\n")
querySql(conn, sprintf(
  "WITH tb_person AS (
     SELECT DISTINCT co.person_id
       FROM %1$s.condition_occurrence co
      WHERE co.condition_concept_id IN (%2$s))
   SELECT c.concept_name AS modality, COUNT(*) AS n
     FROM %1$s.image_occurrence io
     JOIN tb_person tp ON io.person_id = tp.person_id
     LEFT JOIN %1$s.concept c ON c.concept_id = io.modality_concept_id
    GROUP BY c.concept_name ORDER BY n DESC", CDM_SCHEMA, id_list)) %>%
  lower_names() %>%
  print()

# --- 3. 결핵 환자의 CXR 인스턴스만 뽑기 -------------------------------
# subject_id 는 person.person_source_value 에서 붙인다.
cohort_raw <- querySql(conn, sprintf(
  "WITH tb_person AS (
     SELECT DISTINCT co.person_id
       FROM %1$s.condition_occurrence co
      WHERE co.condition_concept_id IN (%2$s))
   SELECT p.person_source_value AS subject_id, io.local_path
     FROM %1$s.image_occurrence io
     JOIN tb_person tp ON io.person_id = tp.person_id
     JOIN %1$s.person p ON p.person_id = io.person_id
    WHERE io.local_path LIKE '%%/MIMIC-CXR/%%'", CDM_SCHEMA, id_list)) %>%
  lower_names()

if (nrow(cohort_raw) == 0) {
  stop("결핵 환자의 CXR 인스턴스가 없다. 위 modality 표를 보고 ",
       "image_occurrence 에 CXR 이 실려 있는지 확인할 것.")
}

# --- 4. 경로 변환 & study_id 추출 -----------------------------------
# local_path 예:
#   s3://dryou-workspace/Datasets/MIMIC-CXR/files/p15/p15689523/s54023788/<uid>.dcm
# 여기서 s########  부분이 study_id 이다.
cohort <- cohort_raw %>%
  mutate(
    subject_id = as.character(subject_id),
    study_id   = sub(".*/s([0-9]+)/.*", "\\1", local_path),
    local_path = to_gcs(local_path)                # s3:// 등 -> gs:// 로 통일
  ) %>%
  select(subject_id, study_id, local_path) %>%
  arrange(subject_id, study_id)

cat("[3] CXR 를 가진 결핵 환자:",
    length(unique(cohort$subject_id)), "명 /",
    nrow(cohort), "장(CXR 인스턴스)\n")

# --- 5. 브릿지 파일 저장 --------------------------------------------
out_csv <- file.path(OUT_DIR, "tb_cohort.csv")
write.csv(cohort, out_csv, row.names = FALSE)

cat("\n[완료] 코호트 저장 =>", out_csv, "\n")
cat("컬럼: subject_id, study_id, local_path (CXR DICOM 의 GCS 경로)\n")
cat("이 파일을 Jupyter(03_load_cxr_images.ipynb)에서 읽어\n")
cat("결핵 환자의 흉부 X선 이미지를 로드한다.\n\n")
cat("코호트 미리보기:\n")
print(head(cohort, 5))
