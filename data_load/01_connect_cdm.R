# --- 0. 패키지 -------------------------------------------------------
# DatabaseConnector: OHDSI 표준 DB 커넥터 (JDBC 로 PostgreSQL 등에 붙는다)
# dplyr: 가져온 결과를 파이프(%>%)로 다루기 위함
library(DatabaseConnector)
library(dplyr)

# --- 1. CDM 접속 정보 ------------------------------------------------
# 실제 병원 CDM 은 이렇게 DB 안에 있다. 여기서 "CDM 연결" 은 곧 DB 커넥션이다.
# 비밀번호는 코드에 적지 않고 환경변수로 받는다.
#   터미널:  export CDM_DB_PASSWORD='...'
#   R:       Sys.setenv(CDM_DB_PASSWORD = "...")
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

# --- 2. 어떤 테이블이 있는지 ------------------------------------------
# CDM 은 표준 테이블 이름을 쓴다. person, condition_occurrence, concept ...
# image_occurrence 는 영상을 CDM 에 얹기 위한 확장 테이블이다.
cat("사용 가능한 CDM 테이블:\n")
querySql(conn, sprintf(
  "SELECT table_name FROM information_schema.tables
    WHERE table_schema = '%s' ORDER BY table_name", CDM_SCHEMA)) %>%
  pull(1) %>%
  print()

# --- 3. 연결 확인 (sanity check) ------------------------------------
# person_id 는 int64 라 R 의 numeric 으로 받으면 정밀도가 깨진다.
# 미리보기라도 문자열로 캐스팅해서 가져온다.
cat("\n[연결 확인]\n")
cat("\nperson 테이블 미리보기 (5행):\n")
querySql(conn, sprintf(
  "SELECT CAST(person_id AS VARCHAR) AS person_id,
          person_source_value, year_of_birth, gender_source_value
     FROM %s.person LIMIT 5", CDM_SCHEMA)) %>%
  print()

# 핵심 포인트:
# - person_source_value 컬럼 = MIMIC 의 subject_id (환자 식별자).
#   이 컬럼이 나중에 영상(Jupyter)과 코호트를 이어주는 열쇠가 된다.

cat("\n연결 완료. 다음 단계(02_build_tb_cohort.R)에서 결핵 코호트를 만든다.\n")

# 커넥션(conn)은 02 에서 이어 쓴다. 실습이 끝나면 disconnect(conn).
