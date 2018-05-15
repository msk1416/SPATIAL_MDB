ALTER TABLE AREAS ADD LOCATION SDO_GEOMETRY;
DROP INDEX AREA_SPATIAL_IDX;
DROP INDEX STATIONS_SPATIAL_IDX;
DELETE FROM AREAS;
delete from stations;

INSERT INTO AREAS VALUES(
  'Raval',
  'Barcelona',
  SDO_GEOMETRY(
    2003,
    8307,
    NULL,
    SDO_ELEM_INFO_ARRAY(1,1003,3),
    SDO_ORDINATE_ARRAY(COORD(3), COORD(3), COORD(9), COORD(6) )
  )
);
COORD(
INSERT INTO AREAS VALUES(
  'Eixample',
  'Barcelona',
  SDO_GEOMETRY(2003, 8307, NULL, 
          MDSYS.SDO_ELEM_INFO_ARRAY(1,1003,1), 
          MDSYS.SDO_ORDINATE_ARRAY(COORD(12), COORD(4), COORD(15), COORD(8), COORD(15), COORD(10), COORD(12), COORD(10), COORD(10), COORD(9), COORD(10), COORD(6), COORD(12), COORD(4))
        )
);

INSERT INTO AREAS VALUES(
  'Clot',
  'Barcelona',
  SDO_GEOMETRY(
    2003,
    8307,
    NULL,
    SDO_ELEM_INFO_ARRAY(1,1003,3),
    SDO_ORDINATE_ARRAY(COORD(15), COORD(4), COORD(22), COORD(8) )
  )
);

INSERT INTO AREAS VALUES(
  'Pedralbes',
  'Barcelona',
  SDO_GEOMETRY(
    2003,
    8307,
    NULL,
    SDO_ELEM_INFO_ARRAY(1,1003,3),
    SDO_ORDINATE_ARRAY(COORD(0), COORD(6), COORD(9), COORD(13)) 
  )
);


INSERT INTO AREAS VALUES(
  'Collblanc',
  'L''Hospitalet de Llobregat',
  SDO_GEOMETRY(
    2003,
    8307,
    NULL,
    SDO_ELEM_INFO_ARRAY(1,1003,3),
    SDO_ORDINATE_ARRAY(COORD(0), COORD(3), COORD(3), COORD(6) )
  )
);


INSERT INTO STATIONS(
          NAME, 
          LINE_ID, 
          S_LOC
  ) VALUES (
          'Drassanes',
          'L3',
          MDSYS.SDO_GEOMETRY(
              2001,
              8307,
              MDSYS.SDO_POINT_TYPE(COORD(5), COORD(7),NULL),
              NULL,
              NULL
          ));
          
INSERT INTO STATIONS(
          NAME, 
          LINE_ID, 
          S_LOC
  ) VALUES (
          'Liceu',
          'L3',
          MDSYS.SDO_GEOMETRY(
              2001,
              8307,
              MDSYS.SDO_POINT_TYPE(COORD(5), COORD(4),NULL),
              NULL,
              NULL
          ));     

DELETE FROM USER_SDO_GEOM_METADATA WHERE COLUMN_NAME = 'S_LOC';
INSERT INTO user_sdo_geom_metadata
    (TABLE_NAME,
     COLUMN_NAME,
     DIMINFO,
     SRID)
  VALUES (
  'AREAS',
  'a_loc',
  SDO_DIM_ARRAY(
    SDO_DIM_ELEMENT('X', COORD(0), COORD(50), 0.005),
    SDO_DIM_ELEMENT('Y', COORD(0), COORD(50), 0.005)
     ),
  8307
);
INSERT INTO user_sdo_geom_metadata
    (TABLE_NAME,
     COLUMN_NAME,
     DIMINFO,
     SRID)
  VALUES (
  'stations',
  's_loc',
  SDO_DIM_ARRAY(
    SDO_DIM_ELEMENT('X', COORD(0), COORD(50), 0.005),
    SDO_DIM_ELEMENT('Y', COORD(0), COORD(50), 0.005)
     ),
  8307
);

CREATE INDEX AREA_SPATIAL_IDX
   ON AREAS(A_LOC)
   INDEXTYPE IS MDSYS.SPATIAL_INDEX;
   
CREATE INDEX STATIONS_SPATIAL_IDX
   ON STATIONS(S_LOC)
   INDEXTYPE IS MDSYS.SPATIAL_INDEX;

