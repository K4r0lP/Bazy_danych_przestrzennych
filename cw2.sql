--4) Wyznacz liczbę budynków (tabela: popp, atrybut: f_codedesc, reprezentowane, jako punkty) 
--położonych w odległości mniejszej niż 1000 m od głównych rzek. 
--Budynki spełniające to kryterium zapisz do osobnej tabeli tableB.
select p.gid,p.cat,p.f_codedesc,p.f_code,p.type,p.geom
into tableb
from majrivers r, popp p
where  ST_DWithin(p.geom, r.geom, 1000) and p.f_codedesc = 'Building';

select count(gid)
from tableb
--drop table tableB;

--5)Utwórz tabelę o nazwie airportsNew. Z tabeli airports do zaimportuj nazwy lotnisk, 
--ich geometrię, a także atrybut elev, reprezentujący wysokość n.p.m.
select name, geom, elev
into airportsNew
from airports;

--a)Znajdź lotnisko, które położone jest najbardziej na zachód i najbardziej na wschód.

--zachód
SELECT name
  FROM airportsNew
  ORDER BY ST_X(geom)
  LIMIT 1;
  
--wschód
SELECT name
  FROM airportsNew
  ORDER BY ST_X(geom) desc
  LIMIT 1;

--b)Do tabeli airportsNew dodaj nowy obiekt - lotnisko, które położone jest w punkcie środkowym 
--drogi pomiędzy lotniskami znalezionymi w punkcie a. Lotnisko nazwij airportB. 
--Wysokość n.p.m. przyjmij dowolną.

insert into airportsNew 
values ('airportB', (select st_centroid (st_makeline(
    (select geom from airportsNew where name = 'ATKA'),
    (select geom from airportsNew where name = 'ANNETTE ISLAND')))),1111);

--delete from airportsNew where name = 'airportB';

--6)Wyznacz pole powierzchni obszaru, który oddalony jest mniej niż 1000 jednostek od 
--najkrótszej linii łączącej jezioro o nazwie ‘Iliamna Lake’ i lotnisko o nazwie „AMBLER”
--select st_area(st_buffer(st_shortestline(d.geom,b.geom),1000))

select st_area(st_buffer(st_shortestline(l.geom,a.geom),1000)) as area
from lakes l, airports a
where l.names = 'Iliamna Lake' and a.name = 'AMBLER';

--7)Napisz zapytanie, które zwróci sumaryczne pole powierzchni poligonów reprezentujących 
--poszczególne typy drzew znajdujących się na obszarze tundry i bagien (swamps).


select sum(ST_Area(t.geom))as "Pole Powierzchni", t.vegdesc as "Typ Drzewa"
from trees t, swamp s, tundra tu
where ST_Contains(t.geom, tu.geom) or ST_Contains(t.geom, s.geom)
group by t.vegdesc;