/* 1. 테이블 생성 */
/* 1-1. PLAYER 테이블 생성 */
CREATE TABLE PLAYER (
	PLAYER_ID CHAR(7) NOT NULL,
	PLAYER_NAME VARCHAR(20) NOT NULL,
	TEAM_ID CHAR(3) NOT NULL,
	E_PLAYER_NAME VARCHAR(40),
	NICKNAME VARCHAR(30),
	JOIN_YYYY CHAR(4),
	POSITION VARCHAR(10),
	BACK_NO TINYINT, -- NUMBER(2) / ORACLE
	NATION VARCHAR(20),
	BIRTH_DATE DATE,
	SOLAR CHAR(1),
	HEIGHT SMALLINT, -- NUMBER(3)
	WEIGHT SMALLINT, -- NUMBER(3)
	CONSTRAINT PLAYER_PK PRIMARY KEY(PLAYER_ID), -- not null 은 여기서 생성 불가
	CONSTRAINT PLAYER_FK FOREIGN KEY(TEAM_ID) REFERENCES TEAM(TEAM_ID)
);

/* 1-2. TEAM 테이블 생성 */
CREATE TABLE TEAM (
	TEAM_ID CHAR(3) NOT NULL,
	REGION_NAME VARCHAR(8) NOT NULL,
	TEAM_NAME VARCHAR(40) NOT NULL,
	E_TEAM_NAME VARCHAR(50),
	ORIG_YYYY CHAR(4),
	STADIUM_ID CHAR(4) NOT NULL,
	ZIP_CODE1 CHAR(3),
	ZIP_CODE2 CHAR(3),
	ADDRESS VARCHAR(80),
	DDD VARCHAR(3),
	TEL VARCHAR(10),
	FAX VARCHAR(10),
	HOMEPAGE VARCHAR(50),
	OWNER VARCHAR(10),
	CONSTRAINT TEAM_PK PRIMARY KEY(TEAM_ID),
	CONSTRAINT TEAM_FK FOREIGN KEY(STADIUM_ID) REFERENCES STADIUM(STADIUM_ID)
);


/* 2. 생성된 테이블 구조 확인 */
-- ORACLE
DESCRIBE PLAYER;
DESC PLAYER;
-- SQL SERVER
EXEC sp_help 'dbo.PLAYER';
-- SQLite
pragma table_info(PLAYER);
pragma table_info(TEAM);


/* 3. CTAS: CREATE TABLE AS SELECT 기법으로 테이블 생성 */
/* 주의: 제약조건은 not null, identity 만 복사됨, 나머지 제약조건과 데이터 타입 등 복사x */
-- ORACLE
CREATE TABLE TEAM_TEMP AS SELECT * FROM TEAM;
-- SQL Server
SELECT * INTO TEAM_TEMP FROM TEAM;


/* 4. 테이블 변경 */
/* 4-1. ADD COLUMN - 무조건 맨 뒤에 추가 */
-- Oracle
ALTER TABLE PLAYER ADD (ADDRESS VARCHAR2(80));
-- SQL Server
ALTER TABLE PLAYER ADD ADDRESS VARCHAR(80);


/* 4-2. DROP COLUMN */
/* 주의: 데이터 유무 관계없이 삭제, 1회1컬럼, 삭제 후 최소 1개 컬럼 존재, 복구 불가능 */
ALTER TABLE PLAYER DROP COLUMN ADDRESS;

/* 4-3. MODIFY COLUMN */
-- Oracle
ALTER TABLE TEAM_TEMP MODIFY(ORIG_YYYY VARCHAR2(80) DEFAULT '20210726' NOT NULL);
-- SQL Server
ALTER TABLE TEAM_TEMP ALTER (ORIG_YYYY VARCHAR(80) DEFAULT '20210726' NOT NULL);
ALTER TABLE TEAM_TEMP ALTER COLUMN ORIG_YYYY VARCHAR(80) NOT NULL;
ALTER TABLE TEAM_TEMP ADD CONSTRAINT DF_ORIG_YYYY DEFAULT '20210726' FOR ORIG_YYYY;

/* 4-4. RENAME COLUMN */
-- Oracle
ALTER TABLE PLAYER RENAME COLUMN PLAYER_ID TO TEMP_ID;
-- SQL Server
sp_rename 'dbo.TEAM_TEMP.TEAM_ID', 'TEAM_TEMP_ID', 'COLUMN';

/* 4-5. DROP CONSTRAINT */
ALTER TABLE PLAYER DROP CONSTRAINT PLAYER_FK;

/* 4-6. ADD CONSTRAINT */
ALTER TABLE PLAYER ADD CONSTRAINT PLAYER_FK FOREIGN KEY(TEAM_ID) REFERENCES TEAM(TEAM_ID);

/* 4-7. RENAME TABLE */
-- Oracle
RENAME TEAM TO TEAM_BACKUP;
-- SQL Server
sp_rename 'dbo.TEAM', 'TEAM_BACKUP';

/* 4-8. DROP TABLE */
-- Oracle
-- ㄴ TEAM 테이블은 PLAYER 테이블이 참조하고있어 삭제 불가능
-- ㄴ CASECADE 옵션을 추가하여 참조 조건 먼저 삭제 후, 테이블 삭제
DROP TABLE TEAM; 
DROP TABLE TEAM CASCADE CONSTRAINT;
-- SQL Server
-- ㄴ CASCADE 옵션 없음, 차례로 삭제
ALTER TABLE PLAYER DROP CONSTRAINT PLAYER_FK;
DROP TABLE TEAM;

/* 4-9. TRUNCATE TABLE */
/* 테이블 구조는 그대로, 모든 행만 제거, DELETE보다 부하가 적음 */
TRUNCATE TABLE TEAM;