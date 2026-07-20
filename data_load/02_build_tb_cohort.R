# =====================================================================
# 목표: ATLAS에서 정의한 결핵 concept set으로 condition_occurrence 에서 결핵 환자 추출,
#       흉부 X선(CXR) 인스턴스 경로(local_path)를 붙여
#       tb_cohort.csv (person_id, image_occurrence_id, local_path) 로 저장
#       => 코호트 키는 CDM 네이티브 id (환자=person_id, 영상=image_occurrence_id)
#
# concept 정의 방식: ATLAS(OHDSI) 에서 개념 검색·확정
#   1) ATLAS Search 에서 'Tuberculosis' 검색
#   2) SNOMED standard concept 'Tuberculosis'(concept_id = 434557) 선택
#   3) 데모이므로 하위개념 확장 없이 434557 만 그대로 사용 (별도 CSV 불필요)
# =====================================================================
# --- 0. 패키지 (없으면 설치) -----------------------------------------
# 아무 패키지도 깔려 있지 않은 R 환경을 가정한 후 미설치 시 패키지 설치 후 진행되도록 코드 구성.
ensure <- function(pkg) {
  if (!requireNamespace(pkg, quietly = TRUE)) {
    install.packages(pkg, repos = "https://cloud.r-project.org")
  }
  library(pkg, character.only = TRUE)
}
for (p in c("DatabaseConnector", "dplyr")) ensure(p)

# --- 이 스크립트가 있는 폴더 찾기 (getwd() 아님) ---------------------
# CSV 를 코드 파일과 같은 폴더에 만들기 위함.
# RStudio: Source 실행(sys.frame$ofile) / 줄단위 실행(rstudioapi) 모두 대응.
get_script_dir <- function() {
  for (i in seq_len(sys.nframe())) {                 # 1) source() 실행
    of <- sys.frame(i)$ofile
    if (!is.null(of)) return(dirname(normalizePath(of)))
  }
  fa <- grep("^--file=", commandArgs(FALSE), value = TRUE)  # 2) Rscript --file=
  if (length(fa)) return(dirname(normalizePath(sub("^--file=", "", fa[1]))))
  if (requireNamespace("rstudioapi", quietly = TRUE) &&      # 3) RStudio 줄단위 실행
      rstudioapi::isAvailable()) {
    p <- rstudioapi::getSourceEditorContext()$path
    if (nzchar(p)) return(dirname(normalizePath(p)))
  }
  getwd()                                            # 4) 폴백
}
SCRIPT_DIR <- get_script_dir()

# 01_connect_cdm.R 선행 실행으로 conn / CDM_SCHEMA 준비 (같은 폴더 기준)
if (!exists("conn")) source(file.path(SCRIPT_DIR, "01_connect_cdm.R"))

lower_names <- function(df) { names(df) <- tolower(names(df)); df }

# --- 1. 결핵 concept id 조회 --------------------
# ATLAS 또는 Concept table에서 'Tuberculosis' 검색 후 standard_concept_id '434557' 사용
# (Athena로 개념 확인: https://athena.ohdsi.org/search-terms/terms/434557)
TB_CONCEPT_ID <- 434557
id_list <- as.character(TB_CONCEPT_ID)
cat(sprintf("[1] 결핵 concept: %d (Tuberculosis)\n", TB_CONCEPT_ID))

# --- 2. 결핵 환자의 영상 modality 구성 --------------------------------
# image_occurrence 에 ECG 와 CXR 혼재 → modality_concept_id 로 구분 (경로 X)
#   ECG : 4217142  (12 lead ECG, SNOMED)
#   CXR : 2128009197 (Digital radiography, DX) / 2128009189 (Computed Radiography, CR)
CXR_MODALITY_IDS <- c(2128009197, 2128009189)
cxr_id_list <- paste(CXR_MODALITY_IDS, collapse = ",")
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

# --- 3. 결핵 환자의 CXR 인스턴스만 추출 -------------------------------
# 코호트 키(person_id, image_occurrence_id)는 image_occurrence 에 직접 있어
# person 조인 없이 바로 뽑는다 (CDM 네이티브 id 그대로 사용).
# CXR 판별은 local_path 문자열이 아니라 modality_concept_id 로 한다 (표준 방식).
cohort_raw <- querySql(conn, sprintf(
  "WITH tb_person AS (
     SELECT DISTINCT co.person_id
       FROM %1$s.condition_occurrence co
      WHERE co.condition_concept_id IN (%2$s))
   SELECT CAST(io.person_id           AS VARCHAR) AS person_id,
          CAST(io.image_occurrence_id AS VARCHAR) AS image_occurrence_id,
          io.local_path
     FROM %1$s.image_occurrence io
     JOIN tb_person tp ON io.person_id = tp.person_id
    WHERE io.modality_concept_id IN (%3$s)
    ORDER BY io.person_id, io.image_occurrence_id", CDM_SCHEMA, id_list, cxr_id_list)) %>%
  lower_names()

if (nrow(cohort_raw) == 0) {
  stop("결핵 환자의 CXR(modality_concept_id ", cxr_id_list, ") 인스턴스가 없다. ",
       "위 modality 표를 보고 image_occurrence 에 CXR 이 실려 있는지 확인할 것.")
}

# --- 4. 컬럼 정리 (CDM 네이티브 키) ----------------------------------
# person_id / image_occurrence_id 는 bigint 라 SQL 에서 VARCHAR 로 캐스팅해
# 가져왔다 (R numeric 정밀도 손실 방지). 정렬도 DB(ORDER BY)에서 끝냈으므로
# 여기선 컬럼 순서만 맞춘다.
cohort <- cohort_raw %>%
  select(person_id, image_occurrence_id, local_path)

cat("[3] CXR 를 가진 결핵 환자:",
    length(unique(cohort$person_id)), "명 /",
    nrow(cohort), "장(CXR 인스턴스)\n")

# --- 5. 파일 저장 (코드 파일과 같은 폴더) ----------------------------
out_csv <- file.path(SCRIPT_DIR, "tb_cohort.csv")
write.csv(cohort, out_csv, row.names = FALSE)

cat("\n[완료] 코호트 저장 =>", out_csv, "\n")
cat("컬럼: person_id, image_occurrence_id, local_path (CXR DICOM 의 GCS 경로)\n")
cat("이 파일을 Jupyter(03_load_cxr_images.ipynb)에서 읽어\n")
cat("결핵 환자의 흉부 X선 이미지를 로드한다.\n\n")
cat("코호트 미리보기:\n")
print(head(cohort, 5))
