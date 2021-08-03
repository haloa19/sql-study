/*
 * WINDOW FUNCTION
 * 설명: 행과 행간의 관계 정리를 위한 함수
 * W_FUNC() OVER (PARTITION BY [그룹기준] ORDER BY [순위대상] ROWS | RANGE [대상이되는 행 기준의 범위(물리|논리)])
 * */
-- 1. 순위 함수
-- 1) RANK 함수
-- 설명: 동일 값에 같은 순위를 부여하고 각 건수로 취급
-- 조건: 연봉에 대한 전체 순위와 직업별 연봉 순위를 출력
SELECT JOB, 
	   ENAME, 
	   SAL, 
	   RANK() OVER (ORDER BY SAL DESC) ALL_RANK, -- 전체 순위
	   RANK() OVER (PARTITION BY JOB ORDER BY SAL DESC) JOB_RANK -- 직업내에서의 순위, 두개 정렬이 충돌되어 SAL 정렬만 적용
FROM EMP;

-- 조건: 직업별 순위를 출력하고 정렬하기
SELECT JOB,
	   ENAME,
	   SAL,
	   RANK() OVER (PARTITION BY JOB ORDER BY SAL) JOB_RANK -- 직업별, 연봉별 정렬
FROM EMP;


-- 2) DENSE_RANK 함수
-- 설명: 동일 값에 같은 순위를 부여하고 해당 순위를 1건으로 취급
-- 조건: 급여가 높은 순서와 동일한 순위를 하나의 건수로 간주한 결과 출력
SELECT JOB,
	   ENAME,
	   SAL,
	   RANK() OVER (ORDER BY SAL DESC) RANK,
	   DENSE_RANK() OVER (ORDER BY SAL DESC) DENSE_RANK 
FROM EMP;


-- 3) ROW_NUMBER 함수
-- 설명: 동일 값에 대해서 고유 순위를 매겨 순위 부여
-- 조건: 급여가 높은 순서와 동일한 순위를 인정하지 않는 등수 출력
SELECT JOB,
	   ENAME,
	   SAL,
	   RANK() OVER (ORDER BY SAL DESC) RANK,
	   ROW_NUMBER() OVER (ORDER BY SAL DESC) DENSE_RANK 
FROM EMP;


-- 2. 일반집계함수
-- 1) SUM 함수
-- 조건: 사원들의 급여와 같은 매니저를 두고있는 사원들의 연봉 합
SELECT MGR,
	   ENAME,
	   SAL,
	   SUM(SAL) OVER (PARTITION BY MGR) MGR_SUM
FROM EMP;

-- 조건: 파티션 내에서 현재 행까지의 누적값 (동일 순위는 같은 ORDER로 취급)
SELECT MGR,
	   ENAME,
	   SAL,
	   SUM(SAL) OVER (PARTITION BY MGR) MGR_SUM,
	   SUM(SAL) OVER (PARTITION BY MGR ORDER BY SAL) MGR_SUMS,
	   SUM(SAL) OVER (PARTITION BY MGR ORDER BY SAL RANGE UNBOUNDED PRECEDING) AS MGR_SUM
FROM EMP;

-- 2) MAX 함수
-- 조건: 개인별 연봉과 파티션별 윈도우의 최대값 출력
SELECT MGR,
	   ENAME,
	   SAL,
	   MAX(SAL) OVER (PARTITION BY MGR) MGR_MAX_SAL
FROM EMP;

-- 조건: 파티션별 윈도우의 최대값만 출력
SELECT MGR, 
       ENAME,
       SAL
FROM (SELECT MGR, 
	         ENAME,
	         SAL,
	         MAX(SAL) OVER (PARTITION BY MGR) AS MGR_MAX_SAL
	   FROM EMP)
WHERE SAL = MGR_MAX_SAL;

-- 3) MIN 함수
-- 조건: 개인별 연봉과 파티션별 윈도우의 최소값 출력
SELECT MGR,
	   ENAME,
	   SAL,
	   MIN(SAL) OVER (PARTITION BY MGR) AS MGR_MIN_SAL
FROM EMP;

-- 4) AVG 함수
-- 조건: 같은 매니저를 두고있는 사원들의 평균 연봉을 구한다. 단, 자기 바로 앞과 뒤의 사원 대상
-- 주의: 앞, 뒤에 데이터가 없는 경우 제외하고 계산
SELECT MGR,
	   ENAME, 
	   HIREDATE,
	   SAL,
	   /* 현재 행을 기준으로 1행 앞과 1행 뒤를 계산 */
	   ROUND(AVG(SAL) OVER (PARTITION BY MGR ORDER BY HIREDATE ROWS BETWEEN 1 PRECEDING AND 1 FOLLOWING)) AS MGR_AVG
FROM EMP;

-- 5) COUNT 함수
-- 조건: 사원들을 급여 기준으로 정렬하고 본인의 급여보다 50이하고 적거나 150 이하로 많은 급여를 받는 인원수를 구하랄
SELECT ENAME,
       SAL,
       /* 현재 행의 값에서 연봉이 -50 ~ +150 사이를 만족하는 행 모두 카운트 */
       COUNT(*) OVER (ORDER BY SAL RANGE BETWEEN 50 PRECEDING AND 150 FOLLOWING) AS SAL_CNT
FROM EMP;


-- 3. 그룹 내 행 순서 함수
-- 1) FIRST_VALUE 함수
-- 조건: 부서별 직원들을 연봉 높은 순으로 정렬하고, 파티션 내에서 가장 먼저 나온 값을 출력
-- 주의: 공동 등수를 인정하지 않고 처음 나온 행으로 처리
SELECT DEPTNO,
  	   ENAME,
  	   SAL,
  	   FIRST_VALUE(ENAME) OVER (PARTITION BY DEPTNO ORDER BY SAL DESC ROWS UNBOUNDED PRECEDING) AS DEPT_RICH
FROM EMP;

-- 2) LAST_VALUE 함수
-- 조건: 부서별 직원들을 연봉 높은 순으로 정렬하고, 파티션 내에서 가장 마지막에 나온 값을 출력
-- 주의: 공동 등수를 인정하지 않고 마지막 행으로 처리
SELECT DEPTNO,
  	   ENAME,
  	   SAL,
  	   LAST_VALUE(ENAME) OVER (PARTITION BY DEPTNO ORDER BY SAL DESC ROWS BETWEEN CURRENT ROW AND UNBOUNDED FOLLOWING) AS DEPT_RICH
FROM EMP;

-- 3) LAG 함수
-- 설명: 자신 기준 이전 N번째 행의 값을 가져올 수 있음 (2번째 인자: 몇번째 앞의 행을 가져올지 결정, 3번째 인자: 없을 경우 대체 값)
-- 조건: 직원들을 입사일자 빠른순으로 정렬하고, 본인보다 입사일자가 1명 앞선 사원의 급여를 본인의 급여와 같이 출력
SELECT ENAME,
       HIREDATE,
       SAL,
       LAG(SAL, 2, 0) OVER (ORDER BY HIREDATE ASC) AS NEXT_SAL
FROM EMP;

-- 4) LEAD 함수
-- 설명: 자신 기준 이후 N번째 행의 값을 가져올 수 있음 (2번째 인자: 몇번째 뒤의 행을 가져올지 결정, 3번째 인자: 없을 경우 대체 값)
-- 조건: 직원들을 입사일자 빠른순으로 정렬하고, 바로 다음에 입사한 인력의 입사일자를 같이 출력
SELECT ENAME,
       HIREDATE,
       SAL,
       LEAD(HIREDATE, 1) OVER (ORDER BY HIREDATE ASC) AS NEXT_HIRED
FROM EMP;


-- 4. 그룹 내 비율 함수
-- 1) RATIO_TO_REPORT 함수
-- 설명: 파티션 내 전체 합에 대한 행별 컬럼 값의 백분율
-- 조건: JOB이 SALESMAN인 사원들을 대상으로 전체 급여에서 본인이 차지하는 비율 출력 
SELECT ENAME,
	   SAL,
	   ROUND(RATIO_TO_REPORT(SAL) OVER (), 2) AS R_R
FROM EMP
WHERE JOB = 'SALESMAN';

-- 2) PERCENT_RANK 함수
-- 설명: 파티션별 제일 먼저 나오는 것을 0, 제일 늦게 나오는 것을 1로 하여 행의 순서별 백분율 구하기
-- 조건: 같은 부서 소속 사람들 중 자신의 급여가 순서상 몇 번째 위치에 있는지 0~1 사이의 값으로 출력
SELECT DEPTNO,
       ENAME,
       SAL,
       PERCENT_RANK() OVER (PARTITION BY DEPTNO ORDER BY SAL DESC) AS P_R
FROM EMP;

-- 3) CUME_DIST 함수
-- 설명: 파티션별 윈도우의 전체건수에서 현재 행보다 작거나 같은 건수에 대한 누적백분율 구하기
-- 조건: 같은 부서 소속 사람들 중 자신의 급여가 누적 순서상 몇 번째 위치에 있는지 0~1 사이의 값으로 출력
SELECT DEPTNO,
       ENAME,
       SAL,
       CUME_DIST() OVER (PARTITION BY DEPTNO ORDER BY SAL DESC) AS C_D
FROM EMP;

-- 4) NTILE 함수
-- 설명: 파티션별 전체 건수를 인자값으로 N 등분한 결과 구하기
-- 조건: 전체 사원을 급여가 높은 순서로 정렬하고, 급여를 기준으로 4개의 그룹으로 분류하기
SELECT ENAME,
       SAL,
       NTILE(4) OVER (ORDER BY SAL) AS QUAR_TILE
FROM EMP;