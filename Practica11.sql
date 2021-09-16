CREATE OR REPLACE FUNCTION 
modificar_fecha_cita(
		id_cliente1 INTEGER,
 		id_cita1 INTEGER, 
		nueva_fecha DATE,
		nueva_hora TIME
)

RETURNS VARCHAR(20)
AS
$$
BEGIN 

	IF((SELECT id_cita
	    FROM cita
	    WHERE id_cita = id_cita1) IS NOT NULL)
		
	THEN IF((SELECT id_cliente
	 	     FROM cita
	         WHERE id_cita = id_cita1)=id_cliente1)
	
		 THEN UPDATE cita SET fecha = nueva_fecha
			   WHERE id_cita = id_cita1;
		  
			   UPDATE cita SET hora = nueva_hora
			   WHERE id_cita = id_cita1;
		  
	 		   RETURN 'Modificación exitosa';
	
	 	 ELSE
			RETURN 'Error, no coincide la cita con el cliente';
		 END IF;
	ELSE
		RETURN 'Error, la cita no existe';
	END IF;  
END;
$$
LANGUAGE 'plpgsql';



CREATE OR REPLACE FUNCTION 
insertar_cotizacion(
	 	num_sesion1 INTEGER,
		precio_sesion1 INTEGER,
		id_tatuaje1 INTEGER,
		id_tatuador1 INTEGER,
		tamano1 DOUBLE PRECISION,
		color1 BOOLEAN,
		id_estilo1 INTEGER
)

RETURNS VARCHAR(20)
AS
$$
DECLARE id_cotizacion_nuevo INTEGER;
DECLARE id_tatuaje_nuevo INTEGER;
BEGIN 
	
	id_cotizacion_nuevo = (SELECT COALESCE(MAX (id_cotizacion),0)
	 	    			   FROM cotizacion)+1;
	IF(id_tatuaje1 = 0)
		
	THEN
		IF((SELECT id_estilo
	    FROM estilo
	    WHERE id_estilo = id_estilo1) IS NOT NULL)
		THEN
				id_tatuaje_nuevo = (SELECT COALESCE(MAX (id_tatuaje),0)
	 	    					 FROM tatuaje)+1;
			 
				INSERT INTO tatuaje(id_tatuaje, tamano, color, id_estilo) 
				VALUES (id_tatuaje_nuevo, tamano1, color1, id_estilo1);

				INSERT INTO cotizacion(id_cotizacion, num_sesion, precio_sesion,
							  		id_tatuaje, id_tatuador)
				VALUES(id_cotizacion_nuevo, num_sesion1, precio_sesion1,
			 			 id_tatuaje_nuevo, id_tatuador1);
					 
				RETURN 'Inserción exitosa';
		ELSE
				RETURN 'id_estilo no existe';
		END IF;
	ELSE 
	    IF((SELECT id_tatuaje
	    FROM tatuaje
	    WHERE id_tatuaje = id_tatuaje1) IS NOT NULL)
		THEN
			INSERT INTO cotizacion(id_cotizacion, num_sesion, precio_sesion,
								  id_tatuaje, id_tatuador)
			VALUES(id_cotizacion_nuevo, num_sesion1, precio_sesion1,
				  id_tatuaje1, id_tatuador1);
			RETURN 'Inserción exitosa';
		ELSE
			RETURN 'El id_tatuaje ingresado no existe';
		END IF;
	END IF;
END;
$$
LANGUAGE 'plpgsql';
