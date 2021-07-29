/*
 * 함수 (Function)
 * 종류: 내장함수, 사용자정의함수
 * 내장함수 종류: 단일행 함수, 다중행 함수(집계함수, 그룹함수, 윈도우함수)
 * ㄴ 함수의 출력은 무조건 단일!!
 * */
/* 내장 함수 */
-- 사용처: select, where, order by
-- 1. 문자형 함수
SELECT LOWER(TEAM_ID), UPPER(TEAM_ID) -- k06, K06
FROM PLAYER;

SELECT ASCII('A'), CHAR(65); -- 65, A

SELECT 'MY' || ' SQL', 'MY' + ' SQL', CONCAT('MY', 'SQL'); -- MY SQL

SELECT SUBSTR('MY SQL', 1, 3), SUBSTRING('MY SQL', 3, 3) -- 'MY ', ' SQ', IDX는 1부터고 맨 마지막 인자는 현시점에서 부터 자를 크기

SELECT LENGTH('MY SQL'), LEN('MY SQL'); -- 6

SELECT LTRIM('aaaBBBaC', 'a'); -- BBBaC, 왼쪽기준으로 'a'와 동일한 값이 나오면 계속 삭제
SELECT RTRIM('aaaBBBaC', 'C'); -- aaaBBBa
SELECT TRIM('X' FROM 'XXABCDXABX'); -- ABCDXAB, 양쪽에서 삭제
SELECT RTRIM('AA   '); -- AA, 공백제거에 유용


-- 2. 숫자형 함수
SELECT ABS(-15); -- 15
SELECT SIGN(-20), SIGN(0), SIGN(20); -- -1, 0, 1
SELECT MOD(7, 3), 7%3; -- 1, 나머지

SELECT CEIL(56.658), CEIL(-56.658); -- 57, -56, 해당 수보다 크거나 같은 정수
SELECT FLOOR(56.658), FLOOR(-56.658) -- 56, -57, 해당 수보다 작거나 같은 정수

SELECT ROUND(38.5238, 3), ROUND(38.5238); -- 38.524, 39, 소수점 아래 N+1 자리에서 반올림하여 N번째 자리가지 표현
SELECT TRUNC(38.5235, 3), ROUND(38.5235); -- 38.523, 38, 소수점 아래 N자리까지 표현


-- 3. 날짜형 함수
-- ㄴ 날짜는 숫자형으로 저장하기 때문에 산술연산 가능
-- 조건: 생일의 년, 월, 일 추출
-- 1) ORACLE
SELECT EXTRACT(YEAR FROM BIRTH_DATE), EXTRACT(MONTH FROM BIRTH_DATE), EXTRACT(DAY FROM BIRTH_DATE)
FROM PLAYER;
SELECT TO_NUMBER(TO_CHAR(BIRTH_DATE, 'YYYY')), TO_NUMBER(TO_CHAR(BIRTH_DATE, 'MM')), TO_NUMBER(TO_CHAR(BIRTH_DATE, 'DD'))
FROM PLAYER;
-- 2) SQL Server
SELECT DATEPART(YEAR, BIRTH_DATE), DEPART(MONTH, BIRTH_DATE), DEPART(DAY, BIRTH_DATE)
FROM PLAYER;
SELECT YEAR(BIRTH_DATE), MONTH(BIRTH_DATE), DAY(BIRTH_DATE)
FROM PLAYER;


-- 4. 변환형 함수
-- 1) ORACLE: TO_NUMBER(), TO_CHAR(), TO_DATE()
SELECT TO_CHAR(12345/12000, '$999,999,99.99'); -- 달러로 표시
SELECT TO_CHAR(123456789, 'L999,999,999'); -- 원화로 표시
-- 2) SQL Server: CAST(), CONVERT()
SELECT CONVERT(VARCHAR(10), DATETIME(), 111);


-- 5. CASE 표현
-- IF-THEN-ELSE-END 와 동일한 기능
-- 1) SIMPLE CASE: CASE 다음에 사용하는 컬럼의 값이 WHEN절의 값과 같은지 비교
SELECT TEAM_ID, 
	   CASE TEAM_ID 
		   WHEN 'K07' THEN '블루'
		   WHEN 'K05' THEN '레드'
		   WHEN 'K02' THEN '핑크'
		   ELSE '기타'
	   END AS '소속팀'
FROM PLAYER;
-- 2) SEARCHED CASE: CASE 다음에 컬럼을 사용하지 않고 비교 연산을 통해 비교
SELECT PLAYER_NAME, HEIGHT,
	   CASE 
	   	WHEN HEIGHT >= 180 THEN 'BIG'
	   	WHEN HEIGHT < 170  THEN 'LOW'
	   	ELSE 'MID'
	   END AS HEIGHT_GRADE
FROM PLAYER;
-- 3) 중첩사용 가능
SELECT PLAYER_NAME, HEIGHT, WEIGHT,
	   CASE 
	   	WHEN HEIGHT >= 180 THEN 'BIG'
	   	ELSE 
	   		CASE 
	   		WHEN WEIGHT > 80 THEN 'VERY FAT'
	   		ELSE 'NORMAL'
	   		END 
	   	END AS 'GRADE'
FROM PLAYER;


-- 6. NULL 관련 함수
-- 1) NVL / ISNULL 함수
-- 위 함수는 수치 계산에 꼭 필요하다 (다중행은 제외 -> 다중행 함수는 알아서 NULL 제외 후 계산)
-- 조건: NICKNAME이 없는 경우 '닉네임 없음'으로 출력
-- 1-1) ORACLE
SELECT PLAYER_NAME, NVL(NICKNAME, '닉네임 없음')
FROM PLAYER;
-- 1-2) SQL Server
SELECT PLAYER_NAME, ISNULL(NICKNAME, '닉네임 없음')
FROM PLAYER;
-- CASE 문으로 표현
SELECT PLAYER_NAME,
	   CASE 
	   WHEN POSITION IS NULL OR POSITION = '' THEN '포지션 없음'
	   ELSE POSITION
	   END AS '포지션'
FROM PLAYER;

-- 2) 공집합과 NULL의 구분
-- 공집합이 발생 -> 조회 결과 자체가 없을 경우
SELECT PLAYER_NAME, NICKNAME 
FROM PLAYER
WHERE PLAYER_NAME = '라이언';
-- 결과 자체가 공집합이면 NVL을 사용해도 공집합이다 => NVL은 인수가 NULL인 것만 대상으로!!
SELECT ISNULL(PLAYER_NAME, '이름없음'), ISNULL(NICKNAME, '별명없음')
FROM PLAYER
WHERE PLAYER_NAME = '라이언';
-- 집계함수를 통해 NULL을 발생시킬 수 있음
SELECT NVL(MAX(NICKNAME), '별명없음')
FROM PLAYER 
WHERE PLAYER_NAME = '라이언';

-- 3) NULLIF
-- NULLIF(EX1, EX2): EX1과 EX2값이 같으면 EX1을 출력하고 다르면 NULL 출력
SELECT NULLIF(TEAM_ID, 'K07') AS 'K07은 널로 표현'
FROM PLAYER;

-- 4) COALESCE
-- COALESCE(EX1, EX2, EX3, ...): NULL이 아닌 최초의 값을 반환, 모두 널이면 널 반환, 인수가 한정되어 있지 않음
SELECT PLAYER_NAME, COALESCE(NICKNAME, E_PLAYER_NAME, PLAYER_NAME) AS '별명'
FROM PLAYER
WHERE PLAYER_NAME LIKE '손흥민';