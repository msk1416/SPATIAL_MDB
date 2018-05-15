
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
    MDSYS.SDO_GEOMETRY(2001, NULL, MDSYS.SDO_POINT_TYPE(S_X,S_Y,NULL), NULL, NULL)
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


CREATE OR REPLACE PROCEDURE INSERTNEWAREA (
  A_NAME area.NAME%TYPE,
  A_CITY area.city%TYPE,
  fp_X NUMBER,
  FP_Y NUMBER,
  SP_X NUMBER,
  SP_Y NUMBER
  ) IS
BEGIN
  INSERT INTO AREA VALUES (
    A_NAME,
    a_city,
    SDO_GEOMETRY(2003, NULL, NULL, SDO_ELEM_INFO_ARRAY(1,1003,3), SDO_ORDINATE_ARRAY(FP_X,FP_Y, SP_X,SP_Y))
  );
  
  EXCEPTION 
  WHEN DUP_VAL_ON_INDEX THEN
    DBMS_OUTPUT.PUT_LINE('There is already an area in this city with the same name.');

END;

execute INSERTNEWAREA('La mina', 'Sant Adrià del Besòs', 22, 0, 27, 3);

CREATE OR REPLACE PROCEDURE INSERTNEWROUNDAREA (
  A_NAME area.NAME%TYPE,
  A_CITY AREA.CITY%TYPE,
  a_X NUMBER,
  A_Y NUMBER,
  a_radius number
  ) IS
BEGIN
  INSERT INTO AREA VALUES (
    A_NAME,
    A_CITY,
    SDO_GEOMETRY (2003, NULL, NULL, sdo_elem_info_array(1, 1003, 4), SDO_ORDINATE_ARRAY (a_X-a_RADIUS, a_Y, a_x, a_y+a_radius, a_x+a_radius, a_y))
  );
  
  EXCEPTION 
  WHEN DUP_VAL_ON_INDEX THEN
    DBMS_OUTPUT.PUT_LINE('There is already an area in this city with the same name.');

END;

execute INSERTNEWroundAREA('Sant Martí', 'Barcelona', 23, 4, 3);

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
              SDO_GEOMETRY(2003, NULL, NULL, SDO_ELEM_INFO_ARRAY(1,1003,3), SDO_ORDINATE_ARRAY(FP_X,FP_Y, SP_X,SP_Y))
            ) = 'TRUE' order by line_id asc) 
  LOOP
    DBMS_OUTPUT.PUT_LINE(station.name || ' (' || station.line ||')');
  END LOOP;
END;

execute findstationsbyarealoc(0,0 , 20,20);


CREATE OR REPLACE PROCEDURE FINDSTATIONSBYAREANAME (
  A_NAME AREA.NAME%TYPE,
  a_city area.city%type
  ) IS

  area_loc area.a_loc%type;
BEGIN
  select a_loc into area_loc from area where name = a_name and city = a_city;
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

execute FINDSTATIONSBYAREANAME('Eixample', 'Barcelona');

CREATE OR REPLACE PROCEDURE MYCLOSESTSTATIONS(
  MY_X NUMBER,
  MY_Y NUMBER,
  MAX_DIST NUMBER
  ) IS
    MY_LOC SDO_GEOMETRY;
  BEGIN
    MY_LOC := MDSYS.SDO_GEOMETRY(2001, NULL, MDSYS.SDO_POINT_TYPE(MY_X,MY_Y,NULL), NULL, NULL);
    FOR CS IN (
      SELECT * FROM (SELECT S.NAME AS NAME, S.LINE_ID AS LINE, SDO_GEOM.SDO_DISTANCE(MY_LOC, S.S_LOC, 0.005) * 100 AS DIST
      FROM STATIONS S) where dist <= MAX_DIST
    ) LOOP
        dbms_output.put_line(cs.name || ' (' || cs.line || '): ' || round(cs.dist, 1) || ' m');
      end loop;
  END;
  
/* -- usage -- */
/* params: my x coord, my y coord, max distance in meters */
EXECUTE MYCLOSESTSTATIONS(3, 4, 1000);
EXECUTE MYCLOSESTSTATIONS(11, 7, 700);


