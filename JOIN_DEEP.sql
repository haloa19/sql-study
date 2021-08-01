/*
 * JOIN 심화과정
 * */
-- 1. INNER JOIN
-- 설명: 동일한 값만 반환하며 JOIN 절의 기본으로 INNER 생략 가능
-- 조건: 사원의 이름과 소속 부서코드, 부서명을 출력
SELECT E.ENAME, D.DEPTNO, D.DNAME
FROM EMP E
	INNER JOIN DEPT D ON E.DEPTNO = D.DEPTNO;
	

-- 2. NATURAL INNER JOIN (ORACLE만 지원)
-- 설명: 두 테이블이 동일하게 갖는 모든 컬럼들에 대해 EQUI JOIN 수행
-- 주의: 1) 별칭 X 
--      2) USING, ON, WHERE에서의 JOIN을 추가로 사용 불가
--      3) 같은 컬럼으로 잡힌 값들이 모두 서로 일치해야 결과에 출력 
--      4) 같은 컬럼은 한번만 표시
-- 조건: 사원 테이블과 부서 테이블을 연결
-- 결과: DEPTNO가 자동으로 공통 컬럼(데이터 타입까지 같아야 함)으로 잡히고 그 기준으로 조인 수행 => 별칭사용 할 수 없는 이유
SELECT *
FROM EMP 
	NATURAL JOIN DEPT;

SELECT *
FROM DEPT 
	NATURAL INNER JOIN DEPT_DEPT; -- DNAME이 다르기 때문에 2건만 출력
	

-- 3. USING 조건절 (ORACLE만 지원)
-- 설명: 원하는 컬럼만 선택적으로 조인 가능
-- 주의: 기준되는 컬럼은 별칭 사용 불가, 나머지는 가능
SELECT *
FROM DEPT 
	NATURAL INNER JOIN DEPT_DEPT USING(DEPTNO); -- DEPTNO에 대해서만 조인하므로 4건 출력
	
SELECT *
FROM DEPT 
	NATURAL INNER JOIN DEPT_DEPT USING(DEPTNO, DNAME);
	

-- 4. ON 조건절
-- 설명: USING과 동일한 기능이지만 컬럼명이 달라도 가능
-- 조건: 팀이름, 스타디움 ID, 스타디움 이름 찾기
SELECT T.TEAM_NAME, S.STADIUM_ID, S.STADIUM_NAME
FROM TEAM T 
	JOIN STADIUM S ON T.STADIUM_ID = S.STADIUM_ID;

-- 조건: 사원 이름과, 소속 부서명, 바뀐 부서명을 출력하기
SELECT E.ENAME, D.DNAME, DD.DNAME AS NEW_DNAME
FROM EMP E 
	JOIN DEPT D ON E.DEPTNO = D.DEPTNO
	JOIN DEPT_DEPT DD ON E.DEPTNO = DD.DEPTNO

-- 조건: 홈팀이 3점 차이로 이긴 경기의 경기장 이름, 일정, 홈팀 이름, 원정팀 이름 출력
SELECT STD.STADIUM_NAME, SCD.STADIUM_ID, SCD.SCHE_DATE, HT.TEAM_NAME 홈팀이름, AT.TEAM_NAME 원정팀이름, SCD.HOME_SCORE, SCD.AWAY_SCORE 
FROM STADIUM STD 
	JOIN SCHEDULE SCD ON STD.STADIUM_ID = SCD.STADIUM_ID
	JOIN TEAM HT ON SCD.HOMETEAM_ID = HT.TEAM_ID
	JOIN TEAM AT ON SCD.AWAYTEAM_ID = AT.TEAM_ID
WHERE SCD.HOME_SCORE >= SCD.AWAY_SCORE + 3;


-- 5. CROSS 조인
-- 설명: JOIN 조건이 없는 경우 발생할 수 있는 모든 조합을 출력
-- EMP 14건과 DEPT 4건의 조합 => 56건
SELECT *
FROM EMP CROSS JOIN DEPT;


-- 6. OUTER JOIN
-- 설명: JOIN 조건에 만족하는 값이 없는 행도 반환 가능, 기준이 되는 테이블이 조인 수행시 무조건 드라이빙

-- 1) LEFT OUTER JOIN (좌측 테이블 기준)
-- 조건: 스타디움과 팀이름을 출력하되, 스타디움의 홈팀이 없는 운동장도 포함
SELECT S.STADIUM_ID, S.SEAT_COUNT, S.STADIUM_NAME, T.TEAM_NAME
FROM STADIUM S
	LEFT OUTER JOIN TEAM T ON S.HOMETEAM_ID = T.TEAM_ID; 

-- 2) RIGHT OUTER JOIN (우측 테이블 기준)
-- 조건: 사원과 부서 정보를 출력하되 사원이 없는 부서도 출력
SELECT E.EMPNO, E.ENAME, D.DEPTNO, D.DNMAE
FROM EMP E
	RIGHT OUTER JOIN DEPT D E.DEPTNO = D.DEPTNO;


-- 3) FULL OUTER JOIN (양쪽 테이블을 읽어 모든 데이터를 출력, 중복은 삭제)
SELECT *
FROM DEPT D 
	FULL OUTER JOIN DEPT_DEPT DD ON D.DEPTNO = DD.DEPTNO;

-- FULL OUTER JOIN = LEFT OUTER JOIN + RIGHT OUTER JOIN
SELECT *
 FROM DEPT D
	LEFT OUTER JOIN DEPT_DEPT DD ON D.DEPTNO = DD.DEPTNO
UNION
SELECT *
 FROM DEPT D
	RIGHT OUTER JOIN DEPT_DEPT DD ON D.DEPTNO = DD.DEPTNO;


-- 7. 계층형 질의
-- 설명: 동일 테이블에 계층적으로 상/하위 데이터가 포함된 데이터
-- 1) ORACLE
SELECT CONNECT_BY_ROOT E.EMPNO AS '루트사원', -- 현재 전개할 데이터의 루트 데이터 표시
	   SYS_CONNECT_BY_PATH(E.EMPNO, '/') AS '경로', -- 루트 ~ 현재 전개할 데이터까지의 경로 표시
	   E.ENAME, 
	   E.MGR
FROM EMP E
	START WITH E.MGR IS NULL -- 시작 데이터 지정
	CONNECT BY PRIOR E.EMPNO = E.MGR -- 다음 전계될 자식 데이터 (자식 -> 부모: 순방향 / 부모 -> 자식: 역방향)
	
	
-- 2) SQL Server
-- WITH절의 CTE 쿼리 사용 -> CTE쿼리는 엥커 멤버 + 재귀 멤버 구성
WITH T_EMP_ANCHOR AS (-- 첫번째 호출, 입력용 TI
					  SELECT E.EMPNO, E.MGR, 0 AS LEVEL, CONVERT(VARCHAR(1000), E.EMPNO) AS SORT
					  FROM EMP E
					  WHERE MGR IS NULL
					  UNION ALL 
					  -- TI+1 출력용
					  SELECT R.EMPNO, R.MGR, A.LEVEL + 1, CONVERT(VARCHAR(1000), A.SORT + '/' + R.EMPNO) AS SORT
					  FROM T_EMP_ANCHOR A, EMP R
					  WHERE A.EMPNO = R.MGR)
SELECT LEVEL, REPLICATE('', LEVEL) + EMPNO AS EMPNO, MGR, SORT
FROM T_EMP_ANCHOR 
ORDER BY SORT GO;


-- 8. 셀프 조인
-- 설명: 동일 테이블 사이의 조인
-- 조건: 사원의 상위, 차상위 관리자를 한줄에 출력하라
SELECT E1.EMPNO AS '사원번호',    E1.ENAME AS '사원이름', 
	   E1.MGR AS '상위관리자 번호', E2.ENAME AS '상위관리자 이름',
	   E2.MGR AS '차상위관리자 번호'
FROM EMP E1
	LEFT OUTER JOIN EMP E2
		ON E1.MGR = E2.EMPNO
ORDER BY E1.EMPNO;