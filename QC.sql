--El número de partidos en los que ganó un equipo visitante que tenía record de juegos ganados mayor que 9.

SELECT COUNT(DISTINCT(id_partido))
FROM(
	SELECT *
	FROM partido JOIN(
			SELECT id_equipo
			FROM equipo
			WHERE record_g > 9) AS T1
		ON partido.id_equipo_l = T1.id_equipo
	WHERE marcador_v > marcador_l
	UNION
	SELECT *
	FROM partido JOIN(
			SELECT id_equipo
			FROM equipo
			WHERE record_g > 9) AS T2
		ON partido.id_equipo_v = T2.id_equipo
	WHERE marcador_v > marcador_l
	ORDER BY id_partido) AS T3;
	
--El nombre y apellido de los jugadores que: sean linea_ofensiva y el identificador de su equipo 
--comience con la letra 'P' pero su posición no sea 'OT' ,
--o que sean defensiva y hayan logrado al menos 2 fumbles (ff) y al menos 2 intercepciones (ints).
SELECT nombre_jugador, apellido_jugador
FROM jugador
WHERE id_jugador IN(
	SELECT id_jugador
	FROM linea_ofensiva NATURAL JOIN jugador_equipo
	WHERE posicion NOT LIKE 'OT' AND id_equipo LIKE 'P%'  
	UNION  
	SELECT id_jugador
	FROM defensiva
	WHERE ff > 1 AND ints > 1
	ORDER BY id_jugador);

--Los nombres distintos de las universidades, ordenados de manera ascendente, 
--a las que pertenecen los kicker que registran más intentos de goles de campo (fga) 
--que el promedio de fga de todos los kickers y su año de nacimiento es menor a 1970.

SELECT universidad
FROM jugador
WHERE EXTRACT(YEAR FROM fecha_nacimiento) < 1970
AND id_jugador IN(
				SELECT id_jugador
				FROM kicker
				WHERE fga >
					(SELECT AVG(fga)
					FROM kicker)) 
ORDER BY universidad;

--Identificador y nombre de la ciudad con el número total de receptores 
--agrupados por la ciudad donde juega su equipo y ordenados por el nombre de la ciudad 
--de manera ascendente. Los equipos considerados deben tener record 
--de más de tres perdidos (record_p) y ser de la conferencia 'Nacional'.
SELECT id_ciudad, nombre_ciudad, COALESCE(T1.count,0) AS count
FROM equipo_ciudad LEFT JOIN 
					(SELECT id_equipo, COUNT(id_jugador)
					FROM jugador_equipo
					WHERE id_jugador IN (SELECT id_jugador
										 FROM receiver)
					AND id_equipo IN (SELECT id_equipo
									 FROM equipo
									 WHERE record_p > 3 AND conferencia LIKE 'Nacional')
					GROUP BY id_equipo) AS T1
ON equipo_ciudad.id_equipo = T1.id_equipo
NATURAL JOIN ciudad
ORDER BY nombre_ciudad;

--Nombre de los nuevos proyectos (distintos), ordenados por nombre de manera ascendente, 
--de estadio de los equipos que juegan en estadios cuya capacidad es mayor que el promedio 
--de las capacidades de los estadios. No deben incluirse aquellos proyectos nuevos con valor "none".

SELECT DISTINCT(proyecto_nuevo) AS distinct
FROM equipo_estadio
WHERE id_estadio IN (SELECT id_estadio
					FROM estadio
					WHERE capacidad > (SELECT AVG(capacidad)
				   					   FROM estadio))
AND proyecto_nuevo NOT LIKE 'none'
ORDER BY proyecto_nuevo;

--De las 5 ciudades con mayor número de habitantes 
--¿Cuál es la que tiene la menor cantidad de equipos? 
--En caso de obtener como resultado más de una ciudad, ordenalas por nombre de manera ascendente.
SELECT nombre_ciudad
FROM ciudad
WHERE id_ciudad IN(
				SELECT T3.id_ciudad 
				FROM(
					SELECT T1.id_ciudad, COUNT(id_equipo) as total
					FROM equipo_ciudad RIGHT JOIN (SELECT id_ciudad
												  FROM ciudad
												  ORDER BY habitantes DESC
												  LIMIT 5) AS T1
									   ON equipo_ciudad.id_ciudad = T1.id_ciudad
					GROUP BY T1.id_ciudad) AS T3
				WHERE T3.total =
								(SELECT MIN(T2.total)
								FROM(
								SELECT T1.id_ciudad, COUNT(id_equipo) as total
								FROM equipo_ciudad RIGHT JOIN (SELECT id_ciudad
															  FROM ciudad
															  ORDER BY habitantes DESC
															  LIMIT 5) AS T1
												   ON equipo_ciudad.id_ciudad = T1.id_ciudad
								GROUP BY T1.id_ciudad) AS T2))
ORDER BY nombre_ciudad;




