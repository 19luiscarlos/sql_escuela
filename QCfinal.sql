SELECT *
FROM entrenador

--Todos los datos de los partidos jugados en la semana 17 
--y a las '4:05PM' (hora_partido).
SELECT *
FROM partido
WHERE semana = 17 AND hora_partido LIKE '4:05PM';

--Número total de jugadores agrupados por apellido.
SELECT apellido_jugador, COUNT(id_jugador)
FROM jugador
GROUP BY apellido_jugador;

--El nombre, apellido y cargo de los entrenadores que 
--entrenan a un equipo fundado (anyo_fund) en 1960 
--o cuya segunda letra del nombre del equipo es 'i'.

SELECT nombre_entrenador, apellido_entrenador, cargo
FROM entrenador
WHERE id_entrenador IN(
					SELECT id_entrenador
					FROM equipo_entrenador 
					WHERE id_equipo IN(
									SELECT id_equipo
									FROM equipo
									WHERE anyo_fund = 1960
									AND SUBSTRING(nombre_equipo, 2, 1) = 'i'));

--Nombre, apellido, universidad y fecha de nacimiento 
--del runner que menos carries tiene.
SELECT nombre_jugador, apellido_jugador, universidad, fecha_nacimiento
FROM jugador
WHERE id_jugador IN(
SELECT id_jugador 
FROM runner
WHERE carries = (SELECT MIN(carries)
				FROM runner));

--El nombre y apellido de los jugadores que: 
--sean receivers con más de 100 recepciones (rec) 
--y pertenzcan a un equipo fundado después de 1960 
--o que sean runners con al menos 220 acarreos (carries) 
--y con exactamente 3 fumbles.
SELECT nombre_jugador, apellido_jugador 
FROM jugador
WHERE id_jugador IN(
			SELECT id_jugador
			FROM receiver NATURAL JOIN jugador_equipo
			WHERE rec > 100
			AND id_equipo IN(
							SELECT id_equipo 
							FROM equipo
							WHERE anyo_fund > 1960)
			UNION
			SELECT id_jugador 
			FROM runner
			WHERE carries > 219 AND fumbles = 3);

--El total de pancakes que suman los jugadores de línea ofensiva 
--que nacieron después de 1980 agrupados por posición 
--y ordenados por número total de pancakes de manera descendente.
SELECT posicion, SUM(pancakes)
FROM linea_ofensiva NATURAL JOIN jugador
WHERE EXTRACT (YEAR FROM fecha_nacimiento) > 1980
GROUP BY posicion
ORDER BY sum DESC;

--El nombre y apellido de los Runners que han jugado 
--en dos equipos diferentes y 
--cuyo año de adquisición sea a partir de 1990.
SELECT nombre_jugador, apellido_jugador
FROM jugador
WHERE id_jugador IN(
				SELECT T1.id_jugador
				FROM(
					SELECT id_jugador, COUNT(id_equipo) as equipos
					FROM jugador_equipo
					WHERE id_jugador IN (SELECT id_jugador 
										 FROM runner)
						  AND anyo_adquirido > 1989
					GROUP BY id_jugador) AS T1
				WHERE T1.equipos = 2);
				
--El nombre del equipo que ha ganado más partidos de local.
SELECT nombre_equipo
FROM equipo
WHERE id_equipo IN(
	SELECT T1.id_equipo_l
	FROM (SELECT id_equipo_l, COUNT(id_partido) AS partidos
		FROM partido
		WHERE marcador_l > marcador_v
		GROUP BY id_equipo_l) AS T1
	WHERE T1.partidos = (
						SELECT MAX(T1.partidos)
						FROM(
							SELECT COUNT(id_partido) AS partidos
							FROM partido
							WHERE marcador_l > marcador_v
							GROUP BY id_equipo_l) as T1));













