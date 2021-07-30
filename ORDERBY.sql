/*
 * ORDER BY 절
 * 설명: 
 * 가장 마지막에 SELECT 절에서 선택한 컬럼에 대해 정렬
 * 그러나, 반드시 SELECT절의 열만 선택할 필요는 없음
 * 관계형 DB는 데이터를 메모리에 올릴 때, 행 단위로 모든 컬럼을 가져오기 때문 
 * 단, 서브쿼리는 그 범위를 벗어나면 더 이상 사용 불가
 * */
-- 1. 대표적인 사용 예
-- 조건: 선수 테이블에서 선수들의 팀을 내림차순으로, 선수들의 이름을 올림차순으로 정렬하라
-- ORACLE은 NULL을 가장 큰 값 취급, SQL Server은 반대
SELECT TEAM_ID, PLAYER_NAME AS '선수명'
FROM PLAYER
ORDER BY TEAM_ID, 선수명 DESC;

-- 2. SELECT 절의 컬럼 순으로도 정렬 가능
SELECT TEAM_ID, PLAYER_NAME
FROM PLAYER 
ORDER BY 1 ASC, 2 DESC;

-- 3. SELECT 절에 없는 컬럼으로도 정렬 가능
SELECT TEAM_ID, PLAYER_NAME
FROM PLAYER 
ORDER BY BACK_NO;

-- 4. 서브쿼리에서 불러온 값만 선택 가능
SELECT PLAYER_NAME
FROM (SELECT PLAYER_NAME, BACK_NO, HEIGHT, WEIGHT 
	  FROM PLAYER
	  WHERE HEIGHT > 180);
	 
-- 5. GROUP BY 절과 정렬
-- GROUP BY 사용 시, 집계된 새로운 그룹 외 개별 데이터는 메모리에서 삭제됨 -> SELECT, ORDER BY 절에서 사용불가
SELECT TEAM_ID, SUM(HEIGHT)
FROM PLAYER
GROUP BY TEAM_ID
ORDER BY AVG(HEIGHT) DESC

-- 6. TOP N 쿼리
-- 1) ORACLE
-- 상위 N개의 데이터를 추출하려면 서브쿼리 수행을 통해 오름차순으로 정렬시킨 데이터를 만들고 그 데이터에서 선택
SELECT ENAME, SAL
FROM (
	SELECT ENAME, SAL
	FROM EMP 
	ORDER BY SAL DESC
	)
WHERE ROWNUM < 4;

-- 2) TOP()
-- 오라클과 달리 ORDER BY를 통해 바로 상위 N개 데이터 추출 가능
SELECT TOP(2) WITH TIES, ENAME, SAL -- WITH TIES는 동일 결과 시, 모두 추출
FROM EMP
ORDER BY SAL DESC;