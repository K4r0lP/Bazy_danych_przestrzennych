drop table obiekty;
--tworze tabele

create table obiekty(id INT primary key,geometry GEOMETRY,name varchar not null);

--dodawanie obiektów

insert into obiekty values
(1, st_geomFromText('compoundcurve( (0 1, 1 1), circularstring(1 1, 2 0, 3 1), circularstring(3 1, 4 2, 5 1), (5 1, 6 1) )'), 'obiekt1'),
(2, st_geomFromText('curvepolygon(compoundcurve( (10 6, 14 6), circularstring(14 6, 16 4, 14 2),
			 circularstring(14 2, 12 0, 10 2), (10 2, 10 6)), circularstring(11 2, 12 3, 13 2, 12 1, 11 2))'), 'obiekt2'),
(3, st_geomFromText('multicurve( (7 15, 10 17), (10 17, 12 13), (12 13, 7 15) )' ), 'obiekt3'),
(4, st_geomFromText('multicurve((20 20, 25 25), (25 25, 27 24), (27 24, 25 22), (25 22, 26 21), (26 21, 22 19), (22 19, 20.5 19.5))'), 'obiekt4'),
(5, st_geomFromText('multipoint(30 30 59, 38 32 234)'), 'obiekt5'),
(6, st_geomFromText('geometrycollection(point(4 2), linestring(1 1, 3 2))'), 'obiekt6');


--zapytania
--1
select ST_Area(ST_Buffer(ST_ShortestLine(a.geometry,b.geometry),5))
	from obiekty a, obiekty b
		where a.name = 'obiekt3' and b.name = 'obiekt4';
		
--2
update obiekty
	set geometry = ST_GeomFromText('polygon((20 20, 25 25, 27 24, 25 22, 26 21, 22 19, 20.5 19.5, 20 20))',-1)
		where name = 'obiekt4';


--3
insert into obiekty(id,name,geometry) values(
	7,
	'obiekt8',
	--select St_Collect(a.geometry, b.geometry)
	(select St_Union(a.geometry, b.geometry) from obiekty a, obiekty b
		where a.name = 'obiekt3' and b.name = 'obiekt4')
	);

select st_asText(geometry) from obiekty 
where name = 'obiekt7'


--4
select name,ST_Area(ST_Buffer(geometry,5))
	from obiekty
		where not ST_HasArc(geometry)
