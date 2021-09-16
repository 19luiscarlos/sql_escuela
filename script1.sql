/*
Función que devuelve los datos generales de las
pólizas de auto dado un año específico
*/
CREATE OR REPLACE FUNCTION sp_recuperaPolizasAuto(
pnano	INTEGER
)
RETURNS TABLE (oidpoliza INTEGER, ofechai DATE, ofechaf DATE)
AS
$$
BEGIN	
	RETURN QUERY SELECT id_poliza,fecha_inicio,fecha_fin
				 FROM poliza NATURAL JOIN poliza_vehiculo 
				 WHERE EXTRACT(YEAR FROM fecha_emision) = pnano;
END;
$$
LANGUAGE 'plpgsql' VOLATILE;

SELECT * FROM sp_recuperaPolizasAuto(2006);
SELECT * FROM sp_recuperaPolizasAuto(2011);
SELECT * FROM sp_recuperaPolizasAuto(1900);
/*
Función que permite registrar una póliza y al
cliente que la adquirió
*/
CREATE OR REPLACE FUNCTION sp_registraPolizaCliente(
papp	VARCHAR(32),
papm	VARCHAR(32),
pnombre	VARCHAR(64)
)
RETURNS INTEGER
AS 
$$
DECLARE vidpersona 	INTEGER;
		vidpoliza	INTEGER;
BEGIN
	
	vidpersona = ((SELECT MAX(id_persona) FROM persona) + 1);
	
	vidpoliza = ((SELECT MAX(id_poliza) FROM poliza) + 1);
	
	INSERT INTO persona (id_persona,app,apm,nombre,rfc) 
	VALUES (vidpersona,papp,papm,pnombre,'123311121');
	
	INSERT INTO poliza(id_poliza,id_persona,fecha_emision) 
	VALUES (vidpoliza,vidpersona,CURRENT_DATE);

	RETURN 1;
END;
$$
LANGUAGE 'plpgsql' VOLATILE;

-- 22654
SELECT *
FROM persona  
ORDER BY id_persona DESC;

-- 30000
SELECT * 
FROM poliza 
ORDER BY id_poliza DESC;

SELECT * FROM sp_registraPolizaCliente('matla','cruz','erick');

ALTER TABLE poliza ALTER COLUMN status DROP NOT NULL;

/*
SQL Dinámico
*/
CREATE OR REPLACE FUNCTION sp_actualizaValorTabla(
ptabla		VARCHAR(32),
patributo	VARCHAR(32),
pvalor		VARCHAR(32),
pid			INTEGER
)
RETURNS INTEGER
AS
$$
BEGIN
	EXECUTE 
	'UPDATE ' || ptabla || ' SET (' || patributo 
	|| ') = (''' || pvalor || ''') WHERE id_' || 
	ptabla || ' = ' || pid || ';';
	
	RETURN 1;
END;
$$
LANGUAGE 'plpgsql' VOLATILE;

SELECT * 
FROM sp_actualizaValorTabla('persona','apm','ruiz',22655);

--Clase viernes 7nov

CREATE OR REPLACE FUNCTION inserta_cliente(
	nombre_cliente VARCHAR(70),
	app_cliente VARCHAR(50),
	apm_cliente VARHCAR(50)
)
RETURNS VARCHAR(20)
AS
$$
BEGIN
	INSERT INTO Cliente(nombre, a_paterno, a_materno)
	VALUES(nombre_cliente, app_cliente, apm_cliente);
RETURN 'Insercion exitosa';
END;
$$
LANGUAGE 'plpgsql';


CREATE OR REPLACE FUNCTION inserta_cliente2(
	nombre_cliente VARCHAR(70),
	app_cliente VARCHAR(50),
	apm_cliente VARHCAR(50)
)
RETURNS VARCHAR(20)
AS
$$
DECLARE id_cliente_calc INTEGER
DECLARE estatus_insercion VARCHAR(25) --si existe o no existe
BEGIN
	IF((SELECT COUNT(*) FROM Cliente
	    WHERE nombre = nombre_cliente AND a_paterno = app_Cliente
	    AND a_materno = apm_cliente) = 0)
	THEN 
	    id_cliente_calc =
		CASE
			WHEN((SELECT MAX(id_cliente) FROM Cliente)
				IS NOT NULL)
			THEN(SELECT MAX(id_cliente) FROM Cliente) +1
			ELSE 1
		END;
	
		INSERT INTO Cliente(id_cliente, nombre, a_paterno, a_materno)
		VALUES(id_cliente_calc, nombre_cliente, app_cliente, apm_cliente);
		RETURN 'Insercion exitosa';
	
	ELSE 
		estatus_insercion = 'El cliente ya existe';
	END IF;
	RETURN estatus_insercion;
	
END
$$
LANGUAGE 'plpgsql';