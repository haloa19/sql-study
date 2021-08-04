/*
 * DCL (Data Control Language)
 * 설명: 유저 생성 및 권한 부여
 * */
-- 1. 유저 생성과 시스템 권한 부여 
-- 1-1. ORACLE
-- 1) SCOTT 유저에게 유저 생성 권한 부여하기 (DBA권한이 있는 SYSTEM으로 접속)
-- [SYSTEM]
GRANT CREATE USER TO SCOTT;
-- 2) SCOTT 유저로 접속 후, PJS 유저 생성하기 (PWD: LUCKY)
-- [SCOTT]
CREATE USER PJS IDENTIFIED BY LUCKY;
-- 3) PJS에게 로그인 권한 부여하기 (로그인 부여 권한이 있는 SCOTT로 접속)
-- [SCOTT]
GRANT CREATE SESSION TO PJS;
-- 4) PJS에게 테이블 생성 권한 부여하기 (테이블 생성 권한이 있는 SYSTEM으로 접속)
-- [SYSTEM]
GRANT CREATE TABLE TO PJS;
-- => PJS 계정으로 로그인 및 테이블 생성 성공


-- 1-2. SQL Server
-- 1) PJS의 로그인 생성하는데 최초 접속 DB는 AdventureWorks (로그인 생성 권한이 있는 sa로 접속)
-- [sa]
CREATE LOGIN PJS WITH PASSWORD = 'LUCKY', DEFAULT_DATABASE=AdventureWorks
-- 2) 유저 생성을 위해 유저가 속한 DB로 이동
USE ADVENTUREWORKS;
CREATE USER PJS FOR LOGIN PJS WITH DEFAULT_SCHEMA = dbo;
-- 3) PJS에게 테이블 생성 권한 부여하기 (테이블 생성 권한이 있는 SYSTEM으로 접속)
-- [SYSTEM]
GRANT CREATE TABLE TO PJS;
-- 4) PJS에게 스키마 권한 부여하기
GRANT Control ON SCHEMA::dbo TO PJS;
-- => PJS 계정으로 로그인 및 테이블 생성 성공


-- 2. Object 권한 부여
-- 설명: 특정 유저가 소유한 테이블에 접근하기 위해서 필요한 권한 (SELECT, INSERT, DELETE, UPDATE 각 개별로 관리)
-- 2-1. ORACLE
-- 1) SCOTT에게 PJS가 생성한 MENU 테이블 SELECT 권한 부여하기
-- [PJS]
GRANT SELECT ON MENU TO SCOTT;
-- 2) SCOTT으로 접속하여 MENU 테이블 조회
-- [SCOTT]
SELECT * FROM PJS.MENU;

-- 2-2. SQL Server
-- 1) SCOTT에게 PJS가 생성한 MENU 테이블 SELECT 권한 부여하기
-- [PJS]
GRANT SELECT ON MENU TO SCOTT;
-- 2) SCOTT으로 접속하여 MENU 테이블 조회
-- [SCOTT]
SELECT * FROM dbo.MENU;


-- 3. Role을 이용한 권한 부여
-- 설명: DB관리자가 각 유저에게 매번 권한을 부여해야하는 번거로움을 줄이고자 권한 부여를 대신 수행
-- 3-1. ORACLE
-- ㄴ 오라클에서 기본으로 제공하는 권한: CONNECT, RESOURCE
-- 1) CREATE SESSION, CREATE TABLE 권한을 가진 ROLE 생성 (이름: LOGIN_TABLE)
-- [SYSTEM]
CREATE ROLE LOGIN_TABLE;
GRANT CREATE SESSION, CREATE TABLE TO LOGIN_TABLE;
-- 2) JISUNG 유저에게 LOGIN_TABLE 롤 부여
-- [JISUNG]
GRANT LOGIN_TABLE TO JISUNG;
-- 3) JISUNG 유저를 삭제 후, 다시 생성하고 CONNECT, RESOURCE 권한 부여
-- ㄴ CONNECT: 로그인 관련 권한, RESOURCE: 오브젝트 생성 권한
-- [SYSTEM]
DROP USER JISUNG;
CREATE USER JISUNG IDENTIFIED BY 'LUCKY';
GRANT CONNECT, RESOURCE TO JISUNG;


-- 3-2. SQL Server
-- ㄴ ROLE 생성이 아닌 기본 제공 ROLE에 멤버로 참여하는 방식
-- ㄴ 서버수준역할: 인스턴스 수준을 요구하는 로그인에 사용
-- ㄴ 데이터베이스 수준 역할: DB 수준을 요구하는 경우 사용
