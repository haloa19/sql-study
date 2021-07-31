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