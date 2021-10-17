create table buildings(building_id serial primary key, geometry geometry, building_name name);
create table roads(road_id serial primary key, geometry geometry, road_name name);
create table poi(point_id serial primary key, geometry geometry, point_name name);


insert into poi(geometry, point_name) values(st_geomfromtext('POINT(1 3.5)', -1), 'G');
insert into poi(geometry, point_name) values(st_geomfromtext('POINT(5.5 1.5)', -1), 'H');
insert into poi(geometry, point_name) values(st_geomfromtext('POINT(9.5 6)', -1), 'I');
insert into poi(geometry, point_name) values(st_geomfromtext('POINT(6.5 6)', -1), 'J');
insert into poi(geometry, point_name) values(st_geomfromtext('POINT(6 9.5)', -1), 'K');


insert into roads(geometry, road_name) values(st_geomfromtext('LINESTRING(0 4.5, 12 4.5)', -1), 'RoadX');
insert into roads(geometry, road_name) values(st_geomfromtext('LINESTRING(7.5 0, 7.5 10.5)', -1), 'RoadY');

insert into buildings(geometry, building_name) values(st_geomfromtext('POLYGON((8 4, 10.5 4, 10.5 1.5, 8 1.5, 8 4))', -1), 'BuildingA');
insert into buildings(geometry, building_name) values(st_geomfromtext('POLYGON((4 7, 6 7, 6 5, 4 5, 4 7))', -1), 'BuildingB');
insert into buildings(geometry, building_name) values(st_geomfromtext('POLYGON((3 8, 5 8, 5 6, 3 6, 3 8))', -1), 'BuildingC');
insert into buildings(geometry, building_name) values(st_geomfromtext('POLYGON((9 9, 10 9, 10 8, 9 8, 9 9))', -1), 'BuildingD');
insert into buildings(geometry, building_name) values(st_geomfromtext('POLYGON((1 2, 2 2, 2 1, 1 1, 1 2))', -1), 'BuildingF');

-- a
select sum(st_length(geometry)) from roads;

--b
select ST_GeometryType(geometry) as geom, st_area(geometry) as area, st_perimeter(geometry) as perimeter from buildings where building_name = 'BuildingA';

--c
select building_name as building, ST_Area(geometry) as area from buildings order by building_name;

--d
select building_name as building, st_perimeter(geometry) as perimeter from buildings order by building_name limit 2;

--e
select st_length(st_shortestline(buildings.geometry, poi.geometry)) from buildings, poi
where buildings.building_name = 'BuildingC' and poi.point_name = 'G';

--f
select st_area(st_difference(m.geometry, st_buffer(t.geometry, 0.5) )) from buildings t, buildings m
where t.building_name = 'BuildingB' and m.building_name = 'BuildingC'

--g 
select building_name from buildings
where ST_Y(ST_Centroid(buildings.geometry)) > ST_Y(ST_PointN((select geometry from roads where road_name = 'RoadX'), 1));


--h
select ST_Area(ST_SymDifference(buildings.geometry, ST_GeomFromText('POLYGON((4 7, 6 7, 6 8, 4 8, 4 7))', 0))) from buildings
where building_name = 'BuildingC'