drop table obiekty;
--tworze tabele

create table obiekty(id INT primary key,name varchar(255),geometry GEOMETRY);

--dodawanie obiektów

--obiekt 1
insert into obiekty(id,name,geometry) values(
	1,'obiekt1',ST_GeomFromText('MULTICURVE(LINESTRING(0 1, 1 1),CIRCULARSTRING(1 1, 2 0, 3 1),
								 CIRCULARSTRING(3 1, 4 2, 5 1),LINESTRING(5 1, 6 1))',-1));
								 
--obiekt 2
insert into obiekty(id,name,geometry) values(
	2,'obiekt2',ST_GeomFromText('CURVEPOLYGON(COMPOUNDCURVE(LINESTRING(10 6, 14 6),CIRCULARSTRING(14 6, 16 4, 14 2),
 CIRCULARSTRING(14 2, 12 0, 10 2),LINESTRING(10 2, 10 6)),CIRCULARSTRING(11 2, 13 2, 11 2))',-1));

--obiekt 3							
insert into obiekty(id,name,geometry) values(3,'obiekt3',ST_GeomFromText('POLYGON((10 17, 12 13, 7 15, 10 17))',-1));

--obiekt 4	
insert into obiekty(id,name,geometry) values(
	4,'obiekt4',ST_GeomFromText('MULTILINESTRING((20 20, 25 25),(25 25, 27 24),(27 24, 25 22),(25 22, 26 21),(26 21, 22 19),(22 19, 20.5 19.5))',-1));

--obiekt 5	
insert into obiekty(id,name,geometry) values(5,'obiekt5',ST_GeomFromText('MULTIPOINT((30 30 59),(38 32 234))',-1));
	
--obiekt 6	
insert into obiekty(id,name,geometry) values(6,'obiekt6',ST_GeomFromText('GEOMETRYCOLLECTION(LINESTRING(1 1, 3 2),POINT(4 2))',-1));

--zapytania
--1
select ST_Area(ST_Buffer(ST_ShortestLine(a.geometry,b.geometry),5))
	from obiekty a, obiekty b
		where a.name = 'obiekt3' and b.name = 'obiekt4';
		
--2
update obiekty
	set geometry = ST_GeomFromText('POLYGON((20 20, 25 25, 27 24, 25 22, 26 21, 22 19, 20.5 19.5, 20 20))',-1)
		where name = 'obiekt4';

--3
insert into obiekty(id,name,geometry) values(
	7,
	'obiekt7',
	(select ST_Union(a.geometry, b.geometry) from obiekty a, obiekty b
		where a.name = 'obiekt3' and b.name = 'obiekt4')
	);
	
--4
select name,ST_Area(ST_Buffer(geometry,5))
	from obiekty
		where not ST_HasArc(geometry)
