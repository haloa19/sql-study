/*
 * GROUP FUNCTION
 * 설명: 간단한 COUNT, SUM, MAX 등을 넘어 소계, 중계, 합계 등을 구할 수 있는 함수
 * 종류: 1) AGGREGATE FUNC -> COUNT, SUM, AVG, MAX, MIN 등
 *      2) GROUP FUNC -> 소계, 중계, 합계 등 여러 레벨의 집계
 *      3) WINDOW FUNC -> 분석 함수, 순위 함수 등
 * */
-- 1. ROLLUP 함수
-- 설명: 선택한 컬럼을 기준으로 소계와 집계 수행
-- 조건: 부서명과 업무명으로 사원수와 급여의 합 구하기
-- STEP1. GROUP BY를 사용하기
SELECT D.DNAME, E.JOB, COUNT(*) '사원수', SUM(E.SAL) AS '급여합'
FROM EMP E, DEPT D
WHERE E.DEPTNO = D.DEPTNO
GROUP BY D.DNAME, E.JOB 
ORDER BY D.DNAME, E.JOB;

-- STEP2. ROLLUP 사용해서 같은 결과 출력하기
-- 결과: GROUP BY와 동일, 추가로 맨 끝에 총 합이 출력
SELECT D.DNAME, 
	   GROUPING(D.DNAME), -- 전체 데이터 총합을 나타내는 라인은 1, 아니면 0
	   E.JOB, 
	   GROUPING(E.JOB), -- 부서별 총합(소계)을 나타내는 라인은 1, 아니면 0
	   COUNT(*) '사원수', 
	   SUM(E.SAL) AS '급여합'
FROM EMP E, DEPT D
WHERE E.DEPTNO = D.DEPTNO
GROUP BY ROLLUP(D.DNAME, E.JOB)
ORDER BY D.DNAME, E.JOB; 

-- STEP3. ROLLUP 함수 일부만 사용하기
-- 결과: 위 결과에서 마지막 총합 라인만 삭제됨 -> D.DNAME에 ROLLUP함수를 적용하지 않았기 때문
SELECT D.DNAME, 
	   GROUPING(D.DNAME), -- 전체 데이터 총합을 나타내는 라인은 1, 아니면 0
	   E.JOB, 
	   GROUPING(E.JOB), -- 부서별 총합(소계)을 나타내는 라인은 1, 아니면 0
	   COUNT(*) '사원수', 
	   SUM(E.SAL) AS '급여합'
FROM EMP E, DEPT D
WHERE E.DEPTNO = D.DEPTNO
GROUP BY D.DNAME, ROLLUP(E.JOB) -- 업무명에만 적용
ORDER BY D.DNAME, E.JOB; 


-- 2. CUBE 함수
-- 설명: 결합 가능한 모든 값에 대해 다차원 집계 생성, UNION ALL 사용보다 테이블 엑세스가 적음
-- 조건: 부서명과 업무명으로 사원수와 급여의 합 구하기
-- 결과: ROLLUP 함수 결과 + 'ALL DEPT + JOB별 총합' 추가
SELECT CASE GROUPING(D.DNAME) WHEN 1 THEN 'All Dept' ELSE D.DNAME END AS DNAME, 
	   CASE GROUPING(E.JOB) WHEN 1 THEN 'All Jobs' ELSE E.JOB END AS JOB,
	   COUNT(*) '사원수', 
	   SUM(E.SAL) AS '급여합'
FROM EMP E, DEPT D
WHERE E.DEPTNO = D.DEPTNO
GROUP BY CUBE(D.DNAME, E.JOB)
ORDER BY D.DNAME, E.JOB; 


-- 3. GROUPING SETS 함수
-- 설명: 원하는 소계 집합을 한번에 여러개 구할 수 있음
-- 조건: 부서별, JOB별 인원수와 급여 합 구하기
-- STEP1. 일반 그룹함수 사용
SELECT D.DNAME, 'ALL JOBS' JOB, COUNT(*) 'TOTAL EMP', SUM(E.SAL) 'TOTAL SAL'
FROM EMP E, DEPT D
WHERE D.DEPTNO = E.DEPTNO 
GROUP BY D.DNAME 
UNION ALL 
SELECT 'ALL DEPT' DNAME, E.JOB, COUNT(*) 'TOTAL EMP', SUM(E.SAL) 'TOTAL SAL'
FROM EMP E, DEPT D
WHERE D.DEPTNO = E.DEPTNO 
GROUP BY E.JOB; 

-- STEP2. GROUPING SETS 사용
SELECT DECODE(GROUPING(D.DNAME), 1, 'ALL DEPT', D.DNAME) AS DNAME,
	   DECODE(GROUPING(E.JOB), 1, 'ALL JOBS', E.JOB) AS JOB,
	   COUNT(*) 'TOTAL EMP',
	   SUM(E.SAL) 'TOTAL SAL'
FROM EMP E, DEPT D
WHERE E.DEPTNO = D.DEPTNO 
GROUP BY GROUPING SETS(D.DNAME, E.JOB);

-- STEP3. GROUPING SETS 여러 인자 사용 (부서-JOB-매니저 별 집계, 부서-JOB 별 집계, JOB-매니저 별 집계)
-- 결과: 인자에 따라 해당 컬럼에 매핑되어 결과 출력
SELECT D.DNAME, E.JOB, E.MGR, SUM(E.SAL) 'TOTAL SAL'
FROM EMP E, DEPT D
WHERE E.DEPTNO = D.DEPTNO 
GROUP BY GROUPING SETS((D.DNAME, E.JOB, E.MGR), (D.DNAME, E.JOB), (E.JOB, E.MGR));