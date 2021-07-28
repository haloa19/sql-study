/*
 * WHERE 조건절
 * - 주의: 여러 조건일때 우선순위 고려해서 조건 걸기
 * */
-- 1) 비교 연산자
-- 조건: 팀 KO2 또는 K07, 포지션 MF, 키 170 이상 180 이하
SELECT *
FROM PLAYER
WHERE (TEAM_ID = 'K02' OR TEAM_ID = 'K07') 
	AND POSITION = 'MF'
	AND (HEIGHT >= 170 AND HEIGHT <= 180);
-- 조건: 팀 K02 또는 팀 K07, 포지션 MF, 키 170 이상 180 이하
SELECT *
FROM PLAYER
WHERE TEAM_ID = 'K02' OR TEAM_ID = 'K07'
	AND POSITION = 'MF'
	AND (HEIGHT >= 170 AND HEIGHT <= 180);

-- 2) SQL 연산자: 모든 데이터 타입에 대해서 연산 가능 (조건 위와 동일)
SELECT *
FROM PLAYER
WHERE TEAM_ID IN ('K02', 'K07')
	AND POSITION LIKE 'MF'
	AND HEIGHT BETWEEN 170 AND 180;
-- 2-1) IN 연산자
-- 조건: 팀 KO2 이면서 포지션 MF, 팀 K07 이면서 포지션 DF
SELECT *
FROM PLAYER
WHERE (TEAM_ID, POSITION) IN (('K02', 'MF'), ('K07', 'DF'));
-- 조건: 팀 K02 이거나 K07 이면서 포지션 MF 이거나 DF
SELECT *
FROM PLAYER
WHERE TEAM_ID IN ('K02', 'K07')
	AND POSITION IN ('MF', 'DF');

-- 2-2) LIKE 연산자 
-- WILDCARD 사용이 편리
-- 조건: '정'씨 성을 가진 선수
SELECT *
FROM PLAYER
WHERE PLAYER_NAME LIKE '정%';
-- 조건: '정'씨 성인데 외자인 선수
SELECT *
FROM PLAYER
WHERE PLAYER_NAME LIKE '정_';

-- 2-3) BETWEEN a AND b
-- 조건: 키가 170 이상 180 이하인 선수
SELECT *
FROM PLAYER 
WHERE HEIGHT BETWEEN 170 AND 180;

-- 2-4) IS NULL 연산자
-- ㄴ 널 값은 비교 자체가 불가능, 비교 연산 X, 널과 비교하면 무조건 RETURN FALSE
-- ㄴ INSERT 할 때, NULL 값으로 넣는 것과 빈문자열로 넣는 것은 다름 => 오라클은 둘다 NULL로 조회 가능, SQLite는 다르게 조회
-- 조건: 포지션이 없는 선수 구하기
SELECT *
FROM PLAYER 
WHERE POSITION IS NULL;
-- 조건: 닉네임이 있는 선수 구하기
SELECT *
FROM PLAYER 
WHERE NICKNAME IS NOT NULL AND NICKNAME != '';

-- 3. 논리 연산자
-- ㄴ 우선순위: (), NOT, AND, OR
-- 조건: 포지션이 MF도 아니고 DF도 아닌 선수
SELECT *
FROM PLAYER 
WHERE POSITION NOT IN ('MF', 'DF');

-- 4. 부정 연산자
-- 4-1) 부정 논리 연산자
-- ㄴ NOT, <>. !=, ^=
-- 조건: 삼성블루윙즈 소속 중, 포지션이 미드필드가 아니고 키가 175이상이 아닌 선수 
-- 방법1
SELECT *
FROM PLAYER 
WHERE TEAM_ID = 'K02'
	AND NOT POSITION = 'MF'
	AND NOT HEIGHT >= 175;
-- 방법2
SELECT *
FROM PLAYER
WHERE TEAM_ID = 'K02'
	AND POSITION <> 'MF'
	AND NOT HEIGHT >= 175;

-- 4-2) 부정 SQL 연산자
-- ㄴ NOT IN, IS NOT NULL, NOT BETWEEN a AND b
-- 조건: 삼성블루윙즈 소속이 아니면서 포지션이 존재하고 키가 175이상 185 이하가 아닌 선수
SELECT *
FROM PLAYER 
WHERE TEAM_ID NOT IN ('K02')
	AND POSITION IS NOT NULL 
	AND POSITION != ''
	AND NOT HEIGHT BETWEEN 175 AND 185;

-- 5. ROWNUM, TOP 사용
-- 원하는 만큼의 행만 가져올 때 사용
-- 1) ORACLE
-- 1건 가져오기
SELECT *
FROM PLAYER
WHERE ROWNUM = 1;
-- 3건 가져오기
SELECT *
FROM PLAYER
WHERE ROWNUM <= 3; -- ROWNUM = 3 불가능 

-- 2) SQL Server
-- 1건 가져오기
SELECT TOP(1)
FROM PLAYER;
-- 3건 가져오기
SELECT TOP(3) 
FROM PLAYER;