/*
 * PROCEDURE LANGUAGE (절차형 SQL)
 * 설명: 절차 지향적인 프로그램이 가능하도록 제공
 * */
-- 1. PL/SQL 
-- 설명: 오라클에서 아용, BLOCK으로 모듈화하여 DB서버에 저장, 한 블럭 전부를 서버로 보냄으로써 통신량 줄일 수 있음
-- 특이점: 대입연산자 ':=' 
-- 1) 생성
CREATE OR REPLACE PROCEDURE TEST_PC (
	ARG1 IN VARCHAR, ARG2 OUT NUMBER, ARG3 INOUT DATE
) IS AS .. BEGIN ... EXCEPTION ... END; /
	
-- 2) 삭제
DROP PROCEDURE TEST_PC;


-- 2. T-SQL
-- 설명: SQL Server에서 사용, 저장 모듈 개발
-- 1) 생성
CREATE Procedure dbo.TEST_PC @param1 VARCHAR, @param2 NUMBER,
...WITH AS ... BEGIN ... ERROR 처리 ... END;
-- 2) 변경
ALTER Procedure TEST_PC ... 
-- 3) 삭제
DROP Procedure dbo.TEST_PC;


-- 3. 프로시져 생성 예제
-- 조건: DEPT 테이블에 새로운 부서 등록
-- 1) PL/SQL (ORACLE)
CREATE OR REPLACE Procedure p_DEPT_insert ( -- DEPT 테이블에 들어갈 컬럼 입력 부
	v_DEPTNO in number,
	v_dname in varchar2,
	v_loc in varchar2,
	v_result out varchar2
) IS cnt number := 0; -- cnt는 scalar변수, 임시 데이터를 1건만 저장하도록 해주는 기능
BEGIN
	SELECT COUNT(*) INTO CNT -- 등록한 부서번호가 존재하는지 확인, PL/SQL은 결과가 반드시 1건!!
	FROM DEPT 
	WHERE DEPTNO = v_DEPTNO AND ROWNUM = 1;
	/* 부서 존재여부 분기문 시작 */
	if cnt > 0 then v_result := '이미 등록된 부서입니다.'; -- 부서가 존재한다면
	else INSERT INTO DEPT(DEPTNO, DNAME, LOC) VALUES (v_DEPTNO, v_dname, v_loc); -- 부서가 존재하지 않으면 입력받은 값 삽입
	COMMIT;
	v_result := '입력완료!';
	end if;
	/* 분기문 끝 */
EXCEPTION
	WHEN OTHERS THEN ROLLBACK;
	v_result := '오류발생';
END;/

-- 2) T-SQL (SQL Server)
CREATE Procedure dbo.p_DEPT_insert
	@v_DEPTNO in number,
	@v_dname varchar(30),
	@v_loc varchar(30),
	@v_result varchar(100)
	OUTPUT AS DECLARE @cnt int SET @cnt = 0
BEGIN 
	SELECT @cnt = COUNT(*)
	FROM DEPT
	WHERE DEPTNO = @v_DEPTNO
	IF @cnt > 0
		BEGIN SET @v_result='이미 등록된 부서' RETURN END
	ELSE
		BEGIN 
			BEGIN TRAN INSERT INTO DEPT(DEPTNO, DNAME, LOC) VALUES(@v_DEPTNO, @v_dname, @v_loc)
			IF @@ERROR<>()
				BEGIN ROLLBACK SET @v_result='ERROR발생' RETURN END 
			ELSE 
				BEGIN COMMIT SET @v_result='입력완료' RETURN END 
		END
END  


-- 4. 프로시져 실행
-- 1) PL/SQL (ORACLE)
variable rslt varchar2(30); -- 결과 받을 변수 선언
EXECUTE p_DEPT_insert(10, 'dev', 'seoul', :rslt); -- 실행
print rslt; -- 결과 보기
	
-- 2) T-SQL (SQL Server)
DECLARE @v_result VARCHAR(100); -- 결과 받을 변수 선언
EXECUTE dbo.p_DEPT_insert 10, 'dev', 'seoul', @v_result=@v_result OUTPUT -- 실행 및 결과 받기
SELECT @v_result AS RSLT -- 결과 보기


-- 5. User Defined Function의 생성과 활용
-- 설명: 사용자가 직접 만든 함수, 프로시져와 다른 점은 return을 이용하여 반드시 1건을 돌려줘야 함
-- 문제: ABS함수 만들기
-- 1) ORACLE
CREATE  OR REPLACE Function UTIL_ABS (v_input in number) -- 숫자값 입력부
return NUMBER IS v_return number := 0; -- 리턴 변수 선언
BEGIN 
	if v_input < 0 then v_return := v_input * -1;
	else v_return := v_input;
	end if;
RETURN v_return;
END;/

/* 실행 */
SELECT SCHE_DATE, UTIL_ABS(HOME_SCORE - AWAY_SCORE) AS '점수차'
FROM SCHEDULE;

-- 2) SQL Server
CREATE Function dbo.UTIL_ABS (@v_input int) -- 숫자값 입력부
RETURNS int AS BEGIN
	DECLARE @v_return int  SET @v_return = 0 -- 리턴 변수 선언
	IF @v_input < 0 SET @v_return = @v_input * -1;
	ELSE SET @v_return = @v_input
	RETURN @v_return;
END

/* 실행  */
SELECT SCHE_DATE, dbo.UTIL_ABS(HOME_SCORE - AWAY_SCORE) AS '점수차'
FROM SCHEDULE;


-- 6. Trigger 생성과 활용
-- 설명: DML 문이 수행될 때, DB에서 자동으로 동작하도록 작성된 프로그램, 커밋과 롤백 실행 불가
-- 대상: 테이블, 뷰, DB 작업
-- 문제: ORDER_LIST에 주문 정보 입력 시, 
--      주문 정보의 주문 일자와 주문 상품을 기준으로 판매 집계 테이블에 해당 주문 일자의 주문 상품 레코드가 존재하면 판매 수량 + 판매 금액, 아니면 새로운 레코드 입력
-- 1) ORACLE
CREATE OR REPLACE Trigger SUMMARY_SALES -- 트리거 선언
AFTER INSERT ON ORDER_LIST FOR EACH ROW DECLARE -- 레코드 입력 후, 각 행마다 트리거 적용
o_date ORDER_LIST.order_date%TYPE;
o_prod ORDER_LIST.product%TYPE;
BEGIN
	o_date := :NEW.order_date; -- ':NEW' 는 신규로 입력한 정보를 가지고 있는 구조체
	o_prod := :NEW.product;
	UPDATE SALES_PER_DATE SET qty = qty + :NEW.qty, amount = amount + :NEW.amount
	WHERE sale_date = o_date AND product = o_prod;
	if SQL%NOTFOUND then INSERT INTO SALES_PER_DATE VALUES(o_date, o_proda, :NEW.qty, :NEW.amount);
	end if;
END;/

/* 실행 */
INSERT INTO ORDER_LIST VALUES('20200101', 'MONOPACK', 10, 30000);
SELECT * FROM ORDER_LIST; -- 전체 데이터
SELECT * FROM SALES_PER_DATE; -- 마지막에 트리거를 통해 넣은 데이터

-- 2) SQL Server
CREATE Trigger dbo.SUMMARY_SALES -- 트리거 선언
ON ORDER_LIST AFTER INSERT AS DECLARE -- 레코드 입력 후, 트리거 발생
	@o_date DATETIME,
	@o_prod INT,
	@qty int,
	@amount int
BEGIN 
	SELECT @o_date = order_date, @o_prod = product, @qty = qty, @amount = amount
	FROM inserted -- 신규 입력된 레코드 정보 존재하는 구조체
	UPDATE SALES_PER_DATE SET qty = qty + @qty, amount = amount + @amount
	WHERE sale_date = @o_date AND product = @o_prod;
		IF @@ROOWCOUNT = 0
		INSERT INTO SALES_PER_DATE VALUES(@o_date, @o_prod, @qty, @amount)
END

/* 실행 */
INSERT INTO ORDER_LIST VALUES('20200101', 'MONOPACK', 10, 30000);