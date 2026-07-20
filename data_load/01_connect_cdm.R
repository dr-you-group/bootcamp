# --- 0. 패키지 (없으면 설치) -----------------------------------------
# 아무 패키지도 깔려 있지 않은 R 환경을 가정한 후 미설치 시 패키지 설치 후 진행되도록 코드 구성.
#   DatabaseConnector: OHDSI 표준 DB 커넥터 (JDBC 로 DB에 접속)
#   dplyr: 결과를 파이프(%>%)로 처리
ensure <- function(pkg) {
  if (!requireNamespace(pkg, quietly = TRUE)) {
    install.packages(pkg, repos = "https://cloud.r-project.org")
  }
  library(pkg, character.only = TRUE)
}
for (p in c("DatabaseConnector", "dplyr")) ensure(p)

# --- 1. CDM 접속 정보 ------------------------------------------------
# 병원 CDM 은 DB 안에 존재 → "CDM 연결" = DB 커넥션
# 비밀번호는 환경변수로 관리
#   터미널: export CDM_DB_PASSWORD='...'
#   R: Sys.setenv(CDM_DB_PASSWORD = "...")
dbPassword <- Sys.getenv("CDM_DB_PASSWORD")
if (!nzchar(dbPassword)) stop("CDM_DB_PASSWORD 를 먼저 설정할 것.")

connectionDetails <- createConnectionDetails(
  dbms         = "postgresql",
  server       = "10.60.0.2/mimiciv_cdm",
  port         = 15432,
  user         = "cdm_user",
  password     = dbPassword,
  pathToDriver = Sys.getenv("DATABASECONNECTOR_JAR_FOLDER", "/opt/ohdsi/jdbc/postgresql")
)

CDM_SCHEMA <- "cdm"

conn <- connect(connectionDetails)
cat("CDM 스키마:", CDM_SCHEMA, "\n\n")

# --- 2. 연결확인: 테이블 확인 ------------------------------------------
# CDM 표준 테이블 이름: person, condition_occurrence, concept ...
# image_occurrence: 영상을 CDM 에 얹는 확장 테이블
cat("사용 가능한 CDM 테이블:\n")
querySql(conn, sprintf(
  "SELECT table_name FROM information_schema.tables
    WHERE table_schema = '%s' ORDER BY table_name", CDM_SCHEMA)) %>%
  pull(1) %>%
  print()

# --- 3. 연결 확인 (sanity check) ------------------------------------
cat("\n[연결 확인]\n")
cat("\nperson 테이블 미리보기 (5행):\n")
querySql(conn, sprintf(
  "SELECT CAST(person_id AS VARCHAR) AS person_id,
          person_source_value, year_of_birth, gender_source_value
     FROM %s.person LIMIT 5", CDM_SCHEMA)) %>%
  print()

# 핵심 포인트:
# - person_source_value 컬럼 = MIMIC 의 subject_id (환자 식별자)
#   의료 영상과 코호트를 잇는 열쇠

cat("\n연결 완료. 다음 단계(02_build_tb_cohort.R)에서 결핵 코호트를 만들 예정.\n")