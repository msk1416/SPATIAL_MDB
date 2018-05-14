ALTER TABLE AREA ADD LOCATION SDO_GEOMETRY;

INSERT INTO AREA VALUES(
  'Raval',
  'Barcelona',
  SDO_GEOMETRY(
    2003,
    NULL,
    NULL,
    SDO_ELEM_INFO_ARRAY(1,1003,3),
    SDO_ORDINATE_ARRAY(3,3, 9,6) 
  )
);

INSERT INTO AREA VALUES(
  'Eixample',
  'Barcelona',
  SDO_GEOMETRY(
    2003,  
    NULL,
    NULL,
    SDO_ELEM_INFO_ARRAY(1,1003,4),
    SDO_ORDINATE_ARRAY(12,6, 15,8, 12,11)
  )
);

INSERT INTO AREA VALUES(
  'Clot',
  'Barcelona',
  SDO_GEOMETRY(
    2003,
    NULL,
    NULL,
    SDO_ELEM_INFO_ARRAY(1,1003,3),
    SDO_ORDINATE_ARRAY(15,8, 22,4) 
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
              NULL,
              MDSYS.SDO_POINT_TYPE(5,7,NULL),
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
              NULL,
              MDSYS.SDO_POINT_TYPE(5,4,NULL),
              NULL,
              NULL
          ));     

INSERT INTO user_sdo_geom_metadata
    (TABLE_NAME,
     COLUMN_NAME,
     DIMINFO,
     SRID)
  VALUES (
  'area',
  'a_loc',
  SDO_DIM_ARRAY(
    SDO_DIM_ELEMENT('X', 0, 50, 0.005),
    SDO_DIM_ELEMENT('Y', 0, 50, 0.005)
     ),
  NULL
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
    SDO_DIM_ELEMENT('X', 0, 50, 0.005),
    SDO_DIM_ELEMENT('Y', 0, 50, 0.005)
     ),
  NULL
);

CREATE INDEX AREA_SPATIAL_IDX
   ON AREA(A_LOC)
   INDEXTYPE IS MDSYS.SPATIAL_INDEX;
   
CREATE INDEX STATIONS_SPATIAL_IDX
   ON STATIONS(S_LOC)
   INDEXTYPE IS MDSYS.SPATIAL_INDEX;
   
SELECT S.NAME, S.LINE_ID
  FROM STATIONS S
  WHERE SDO_CONTAINS(
            MDSYS.SDO_GEOMETRY(2003,NULL,NULL,MDSYS.SDO_ELEM_INFO_ARRAY(1,1003,3),MDSYS.SDO_ORDINATE_ARRAY(0,0,30,30)), S.S_LOC
            ) = 'TRUE';