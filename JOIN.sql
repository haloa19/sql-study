/*
 * JOIN
 * 설명: 2개 이상의 테이블을 연결하여 더욱 다양한 결과를 만들기
 * 데이터의 정합성을 위해 분리해놓은 데이터들의 논리적인 연결
 * */
-- 1. EQUI JOIN
-- 조건: 선수 이름과 소속 팀 이름 출력
-- 1) WHERE 조건절 사용
SELECT PLAYER.PLAYER_ID, PLAYER.PLAYER_NAME, PLAYER.TEAM_ID, TEAM.TEAM_ID, TEAM.TEAM_NAME, TEAM.REGION_NAME
FROM PLAYER, TEAM
WHERE PLAYER.TEAM_ID = TEAM.TEAM_ID;
-- 2) JOIN 조건절 사용
SELECT PLAYER.PLAYER_ID, PLAYER.PLAYER_NAME, PLAYER.TEAM_ID, TEAM.TEAM_ID, TEAM.TEAM_NAME, TEAM.REGION_NAME
FROM PLAYER 
	INNER JOIN TEAM ON PLAYER.TEAM_ID = TEAM.TEAM_ID;


-- 2. EQUI JOIN + 부가조건
-- 1) WHERE 조건 사용
SELECT *
FROM PLAYER P, TEAM T 
WHERE P.TEAM_ID = T.TEAM_ID 
	AND P."POSITION" = 'GK'
ORDER BY P.BACK_NO DESC;
-- 2) JOIN 조건절 사용
SELECT *
FROM PLAYER P 
	JOIN TEAM T ON P.TEAM_ID = T.TEAM_ID 
WHERE P."POSITION" = 'GK'
ORDER BY P.BACK_NO DESC;


-- 3. Non EQUI JOIN
-- '='이 아닌 조인
-- 조건: 사원이 받는 급여가 어는 등급에 속하는 등급인지 구하기
SELECT E.EMPNO, E.ENAME, E.SAL, S.GRADE
FROM EMP E, SALGRADE S
WHERE E.SAL BETWEEN S.LOW_SAL AND S.HI_SAL;


-- 4. 3개 이상 TABLE JOIN
-- 1) WHERE 조건 사용
SELECT P.PLAYER_ID, P.PLAYER_NAME, P.POSITION, T.REGION_NAME, T.TEAM_NAME, S.STADIUM_NAME
FROM PLAYER P, TEAM T, STADIUM S
WHERE P.TEAM_ID = T.TEAM_ID AND T.STADIUM_ID = S.STADIUM_ID
ORDER BY P.PLAYER_NAME;
-- 2) JOIN 조건절 사용
SELECT P.PLAYER_NAME, T.TEAM_ID, T.TEAM_NAME, T.REGION_NAME, S.STADIUM_ID, S.STADIUM_NAME 
FROM PLAYER P
	INNER JOIN TEAM T ON P.TEAM_ID = T.TEAM_ID 
	INNER JOIN STADIUM S ON T.STADIUM_ID = S.STADIUM_ID;