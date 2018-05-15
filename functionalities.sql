
CREATE OR REPLACE PROCEDURE INSERTNEWSTATION (
  S_NAME STATIONS.NAME%TYPE,
  S_LINEID STATIONS.LINE_ID%TYPE,
  S_X NUMBER,
  S_Y NUMBER
  ) IS
BEGIN
  INSERT INTO STATIONS VALUES (
    S_NAME,
    S_LINEID,
    MDSYS.SDO_GEOMETRY(2001, 8307, MDSYS.SDO_POINT_TYPE(COORD(S_X), COORD(S_Y),NULL), NULL, NULL)
  );
  
  EXCEPTION 
  WHEN DUP_VAL_ON_INDEX THEN
    DBMS_OUTPUT.PUT_LINE('There is already a station in this line with the same name.');

END;

EXECUTE INSERTNEWSTATION('Diagonal', 'L5', 11, 7);
EXECUTE INSERTNEWSTATION('Sagrada Família', 'L5', 14, 8);
EXECUTE INSERTNEWSTATION('Sagrada Família', 'L2', 14, 8);
EXECUTE INSERTNEWSTATION('Camp Nou', 'L3', 2, 5);
EXECUTE INSERTNEWSTATION('Palau reial', 'L3', 2, 7);
EXECUTE INSERTNEWSTATION('Zona universitària', 'L3', 1, 7);


CREATE OR REPLACE PROCEDURE INSERTNEWAREA (
  A_NAME AREAS.NAME%TYPE,
  A_CITY AREAS.city%TYPE,
  fp_X NUMBER,
  FP_Y NUMBER,
  SP_X NUMBER,
  SP_Y NUMBER
  ) IS
BEGIN
  INSERT INTO AREAS VALUES (
    A_NAME,
    A_CITY,
    SDO_GEOMETRY(2003, 8307, NULL, SDO_ELEM_INFO_ARRAY(1,1003,3), SDO_ORDINATE_ARRAY(COORD(FP_X), COORD(FP_Y), COORD(SP_X), COORD(SP_Y)))
  );
  
  EXCEPTION 
  WHEN DUP_VAL_ON_INDEX THEN
    DBMS_OUTPUT.PUT_LINE('There is already an area in this city with the same name.');

END;

execute INSERTNEWAREA('La mina', 'Sant Adrià del Besòs', 22, 0, 27, 3);


CREATE OR REPLACE PROCEDURE FINDSTATIONSBYAREALOC (
  fp_X NUMBER,
  FP_Y NUMBER,
  SP_X NUMBER,
  SP_Y NUMBER
  ) is
BEGIN
  FOR STATION IN (
    SELECT S.NAME as name, S.LINE_ID as line, S.S_LOC as location
    FROM STATIONS S
    WHERE SDO_INSIDE(S.S_LOC,
              SDO_GEOMETRY(2003, 8307, NULL, SDO_ELEM_INFO_ARRAY(1,1003,3), SDO_ORDINATE_ARRAY(COORD(FP_X), COORD(FP_Y), COORD(SP_X), COORD(SP_Y)))
            ) = 'TRUE' order by line_id asc) 
  LOOP
    DBMS_OUTPUT.PUT_LINE(station.name || ' (' || station.line ||')');
  END LOOP;
END;

execute findstationsbyarealoc(0,0 , 9,6);


CREATE OR REPLACE PROCEDURE FINDSTATIONSBYAREANAME (
  A_NAME AREAS.NAME%TYPE,
  a_city AREAS.city%type
  ) IS

  area_loc AREAS.a_loc%type;
BEGIN
  SELECT A_LOC INTO AREA_LOC FROM AREAS WHERE NAME = A_NAME AND CITY = A_CITY;
  DBMS_OUTPUT.PUT_LINE('Stations in '|| A_NAME || ' ('|| A_CITY || ')');
  dbms_output.put_line('------------------------------------------------');
  FOR STATION IN (
    SELECT S.NAME as name, S.LINE_ID as line, S.S_LOC as location
    FROM STATIONS S
    WHERE SDO_INSIDE(S.S_LOC,area_loc) = 'TRUE') 
  LOOP
    DBMS_OUTPUT.PUT_LINE(station.name || ' (' || station.line ||')');
  END LOOP;
  
  EXCEPTION 
    WHEN NO_DATA_FOUND THEN
      dbms_output.put_line('There is no area with this name in this city.');
END;

EXECUTE FINDSTATIONSBYAREANAME('Eixample', 'Barcelona');
execute FINDSTATIONSBYAREANAME('Pedralbes', 'Barcelona');

CREATE OR REPLACE PROCEDURE MYCLOSESTSTATIONS(
  MY_X NUMBER,
  MY_Y NUMBER,
  MAX_DIST NUMBER
  ) IS
    MY_LOC SDO_GEOMETRY;
  BEGIN
    MY_LOC := MDSYS.SDO_GEOMETRY(2001, 8307, MDSYS.SDO_POINT_TYPE(COORD(MY_X), COORD(MY_Y),NULL), NULL, NULL);
    FOR CS IN (
      SELECT * FROM (SELECT S.NAME AS NAME, S.LINE_ID AS LINE, SDO_GEOM.SDO_DISTANCE(MY_LOC, S.S_LOC, 0.005)  AS DIST
      FROM STATIONS S) where dist <= MAX_DIST
    ) LOOP
        dbms_output.put_line(cs.name || ' (' || cs.line || '): ' || round(cs.dist/1000, 2) || ' km');
      end loop;
  END;
  
/* -- usage -- */
/* params: my x coord, my y coord, max distance in meters */
EXECUTE MYCLOSESTSTATIONS(11, 7, 5000);
EXECUTE MYCLOSESTSTATIONS(2, 7, 2500);


CREATE OR REPLACE PROCEDURE VALIDATEGEOMETRIES IS
COUNTVALID NUMBER := 0;
COUNTTOTAL NUMBER := 0;
isgeovalid varchar2(4000);
BEGIN
  FOR G IN (SELECT name as name, city as city, A_LOC AS SHAPE FROM AREAS) 
    LOOP 
      COUNTTOTAL := COUNTTOTAL + 1;
      IF (SDO_GEOM.VALIDATE_GEOMETRY_WITH_CONTEXT(G.SHAPE, 0.005) = 'TRUE') THEN
        COUNTVALID := COUNTVALID + 1;
      end if;
    END LOOP;
  FOR G IN (SELECT name as name, line_id as line, S_LOC AS SHAPE from STATIONS)
    LOOP
      counttotal := counttotal + 1;
      IF(SDO_GEOM.VALIDATE_GEOMETRY_WITH_CONTEXT(G.SHAPE, 0.005) = 'TRUE') THEN
        COUNTVALID := COUNTVALID + 1;
      end if;
    END LOOP;
  IF (COUNTVALID <> COUNTTOTAL) THEN
    DBMS_OUTPUT.PUT_LINE('There are ' || (counttotal - countvalid) || ' invalid geometries in the database. Total count is ' || counttotal);
  ELSE
    DBMS_OUTPUT.PUT_LINE('All geometries in the database are valid.');
  END IF;
END;

EXECUTE CREATEINVALIDGEOMETRIES(15);
EXECUTE VALIDATEGEOMETRIES;
EXECUTE CLEANINVALIDGEOMETRIES;

CREATE OR REPLACE PROCEDURE CREATEINVALIDGEOMETRIES (
  N NUMBER
  ) IS
    COUNT NUMBER;
    NAME_TEMPLATE VARCHAR2(12) := 'invalidgeo_';
    RAND INTEGER;
    max_val integer := 2147483648;
  BEGIN
    RAND := ROUND(DBMS_RANDOM.VALUE() * MAX_VAL - N - 1) + 1;
    FOR I IN rand..rand+N-1 LOOP
      INSERT INTO AREAS VALUES(
        name_template || i, 
        NAME_TEMPLATE || I, 
        MDSYS.SDO_GEOMETRY(2003, 8307, NULL, 
          MDSYS.SDO_ELEM_INFO_ARRAY(1,1003,1), 
          MDSYS.SDO_ORDINATE_ARRAY(COORD(10), COORD(10), COORD(15), COORD(20), COORD(20), COORD(10), COORD(20), COORD(15), COORD(15), COORD(10), COORD(10), COORD(10), COORD(0), COORD(0))
        )
      );
    end loop;
  END;
  
CREATE OR REPLACE PROCEDURE CLEANINVALIDGEOMETRIES IS
  NAME_TEMPLATE VARCHAR2(12) := 'invalidgeo_';
  BEGIN
    delete from AREAS where name like name_template||'%';
  end;
  
create or replace procedure showareasbysize is

BEGIN
  FOR r IN (SELECT A.NAME AS area_NAME, SDO_GEOM.SDO_AREA(A.A_LOC, 0.005) AS AREA_size FROM AREAS A ORDER BY AREA_size DESC)
    LOOP
      dbms_output.put_line(r.area_name || ' - ' || round(r.area_size / 100000, 3) || ' km2');    
    end loop;
end;

execute showareasbysize;

CREATE OR REPLACE FUNCTION COORD (
  C NUMBER
) RETURN float
  is
BEGIN
RETURN round(C / 110.495204536789, 8);
END;

