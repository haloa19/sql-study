/*
 * SUBQUERY 서브쿼리
 * 서브..? 쿼리 안의 쿼리, 메인쿼리와 서브쿼리는 종속 관계
 * 사용절: select, from, where, having, order by, insert values, update set
 * */
-- 1. 단일행 서브쿼리
-- 설명: 조건절에서 '=', '<', '>' 등을 사용하는 경우고 서브 결과가 반드시 1건
-- 조건: 정남일 선수가 포함된 팀의 선수 정보를 출력
SELECT *
FROM PLAYER P 
WHERE P.TEAM_ID = (SELECT TEAM_ID
				   FROM PLAYER P2
				   WHERE P2.PLAYER_NAME = '정남일')
ORDER BY PLAYER_NAME;

-- 그룹함수를 이용한 서브쿼리
-- 조건: 키가 평균 이하인 선수들을 출력
SELECT *
FROM PLAYER 
WHERE HEIGHT <= (SELECT AVG(HEIGHT)
				 FROM PLAYER);

				
-- 2. 다중행 서브쿼리	
-- 설명: 다중행 비교 연산자 IN, ALL, SOME과 함께 사용하며 서브쿼리 결과가 2건 이상		
-- 조건: 정현수가 포함된 팀의 정보를 출력하라
SELECT *
FROM TEAM
WHERE TEAM_ID IN (SELECT TEAM_ID  -- 정현수가 2명이므로 '=' 사용시 에러
				  FROM PLAYER 
				  WHERE PLAYER_NAME = '정현수');
				  
				 
-- 3. 다중 컬럼 서브쿼리
-- 설명: 서브쿼리 결과를 여러 개의 칼럼이 반환				
-- 조건: 소속팀별 키가 가장 작은 사람들의 정보를 출력
SELECT *
FROM PLAYER
WHERE (TEAM_ID, HEIGHT) IN (SELECT TEAM_ID, MIN(HEIGHT)
							FROM PLAYER
							GROUP BY TEAM_ID)
ORDER BY TEAM_ID, PLAYER_NAME;


-- 4. 연관 서브쿼리
-- 설명: 서브쿼리 내에 메인쿼리 칼럼을 사용하는 쿼리
-- 조건: 선수 자신이 속한 팀의 평균 키보다 작은 선수들의 정보 출력
SELECT *
FROM PLAYER P1, TEAM T
WHERE P1.TEAM_ID  = T.TEAM_ID 
	  AND P1.HEIGHT < (SELECT AVG(HEIGHT)
					   FROM PLAYER P2
					   WHERE P1.TEAM_ID = P2.TEAM_ID 
							AND P2.HEIGHT != '' 
							AND P2.HEIGHT IS NOT NULL
					   GROUP BY P2.TEAM_ID);
					   
-- 조건: 경기일정이 20120501~20120502 사이에 있는 경기장 조회
SELECT ST.STADIUM_ID, ST.STADIUM_NAME, SD.SCHE_DATE
FROM STADIUM ST
	INNER JOIN SCHEDULE SD ON ST.STADIUM_ID = SD.STADIUM_ID
WHERE SD.SCHE_DATE BETWEEN '20120501' AND '20120502';

-- EXISTS사용
-- 서브쿼리의 WHERE 조건절을 만족하는 데이터가 있으면 출력 아니면 패스
-- 1건이라도 만족하는 데이터가 있으면 검색 중단
SELECT  ST.STADIUM_ID, ST.STADIUM_NAME
FROM STADIUM ST
WHERE EXISTS(SELECT 1 
			 FROM SCHEDULE SC 
			 WHERE SC.STADIUM_ID = ST.STADIUM_ID
			 	AND SC.SCHE_DATE BETWEEN '20120501' AND '20120502');

			 
-- 5. SELECT 절에서 서브쿼리 사용
-- 설명: 스칼라 서브쿼리라고 하며, 1행 1컬럼을 반환
-- 조건: 선수 정보와 해당 선수가 속한 팀의 평균키를 한번에 출력하기
SELECT P.PLAYER_ID, 
	   P.PLAYER_NAME, 
	   P.BACK_NO,
	   P.HEIGHT,
	   P.TEAM_ID,
	   (SELECT AVG(HEIGHT)
	    FROM PLAYER P2
	    WHERE P.TEAM_ID = P2.TEAM_ID
	    )
FROM PLAYER P;


-- 6. FROM 절에서 서브쿼리 사용
-- 설명: 인라인 뷰라고 하며, 임시로 만들어진 동적 뷰의 개념
-- 조건: 포지션이 MF인 선수들의 소속팀명, 선수 정보 출력
SELECT T.TEAM_NAME, P.PLAYER_NAME, P.POSITION
FROM (SELECT PLAYER_ID, PLAYER_NAME, POSITION, TEAM_ID 
	  FROM PLAYER
	  WHERE POSITION = 'MF'
	  ORDER BY PLAYER_NAME
	  ) P 
INNER JOIN TEAM T ON P.TEAM_ID = T.TEAM_ID

-- 인라인뷰는 ORDER BY 절을 사용할 수 있으므로 TOP-N쿼리 작성이 가능하다
-- 조건: MF인 선수중 키가 큰 5명을 출력
-- ROWNUM <= 5 또는 TOP(5)
SELECT T.TEAM_NAME, P.PLAYER_NAME, P.POSITION, P.HEIGHT
FROM (SELECT PLAYER_ID, PLAYER_NAME, POSITION, TEAM_ID, HEIGHT
	  FROM PLAYER
	  WHERE POSITION = 'MF'
	  ORDER BY HEIGHT DESC 
	  ) P 
INNER JOIN TEAM T ON P.TEAM_ID = T.TEAM_ID
WHERE ROWNUM <= 5;


-- 7. HAVING 절에서 서브쿼리 사용
-- 설명: 그룹핑된 결과에 대해 부가적인 조건을 주기위해 사용
-- 조건: 평균키가 KO2 팀의 평균키보다 작은 팀의 이름과 해당 팀의 평균키를 출력
SELECT P.TEAM_ID, T.TEAM_NAME, AVG(P.HEIGHT)
FROM PLAYER P, TEAM T
WHERE P.TEAM_ID = T.TEAM_ID 
GROUP BY P.TEAM_ID, T.TEAM_NAME 
HAVING AVG(HEIGHT) < (SELECT AVG(HEIGHT)
					  FROM PLAYER
					  WHERE TEAM_ID = 'K02');

					 
-- 8. UPDATE문의 SET 절에서 사용
UPDATE TEAM T SET T.STADIUM_NAME = (SELECT S.STADIUM_NAME 
									FROM STADIUM S
									WHERE T.STADIUM_ID = S.STADIUM_ID);
								
-- 9. INSERT문의 VALUES 절에서 사용					
INSERT INTO PLAYER(PLAYER_ID, PLAYER_NAME, TEAM_ID) VALUES (SELECT TO_CHAR(MAX(TO_NUMBER(PLAYER_ID) + 1)), '홍길동', 'K06');


-- 10. 뷰(View)
-- 설명: 실제 데이터를 가지고 있지 않으며 재작성하여 질의 수행
-- 1) 뷰 생성
CREATE VIEW V_PLAYER_TEAM AS SELECT P.PLAYER_ID, P.PLAYER_NAME, P.BACK_NO, P."POSITION", P.TEAM_ID, T.TEAM_NAME
							  FROM PLAYER P, TEAM T
							  WHERE P.TEAM_ID = T.TEAM_ID AND P."POSITION" IN ('GK', 'MF');
		
-- 2) 기존의 뷰를 참조하는 뷰
CREATE VIEW V_PLAYER_TEAM_FILTER AS SELECT PLAYER_ID, PLAYER_NAME, BACK_NO, TEAM_ID, TEAM_NAME
									FROM V_PLAYER_TEAM
									WHERE POSITION IN ('MF');
								
-- 3) 뷰 사용하기
SELECT *
FROM V_PLAYER_TEAM_FILTER -- 뷰를 만들때 AS 이후의 쿼리를 사용
WHERE PLAYER_NAME LIKE '황%';


-- 4) 뷰 삭제
DROP VIEW V_PLAYER_TEAM;
DROP VIEW V_PLAYER_TEAM_FILTER;