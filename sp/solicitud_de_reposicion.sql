--Diariamente se deberán generar las solicitudes de reposición de los productos que tengan un stock bajo.
create or replace function solicitar_reposicion() returns boolean as $$
declare  
    
    productos_reponer producto;
    p_record record;
    ret boolean;
    no_existe boolean;
    cantidad_a_reponer_aux int;
	solicitud_table reposicion;
    solicitud_record record;

begin
    ret = true;

--productos que necesitan reposicion
select * into productos_reponer from producto where 
    (stock_disponible + stock_reservado) <= punto_reposicion;

begin
set transaction isolation level serializable;
	for p_record in (select * from productos_reponer)
	loop
		--no existe solicitud con el producto
		no_existe = p_record.id_producto not in (select id_producto from reposicion);

		if(no_existe) then
			cantidad_a_reponer_aux = (p_record.stock_maximo - (p_record.stock_disponible + p_record.stock_reservado));
			insert into reposicion(id_producto, fecha_solicitud, cantidad_a_reponer, estado)
			values (p_record.id_producto, current_date, cantidad_a_reponer_aux, 'pendiente');

		--existe, me fijo si tiene la fecha de hoy
		else
			solicitud_table = (select * from reposicion where id_producto = p_record.id_producto);
			for solicitud_record in (select * from solicitud_table)
			loop
			if((solicitud_record.fecha_solicitud == current_date) and (solicitud_record.estado == 'pendiente')) then
				ret = false;
			end if;
			end loop;
		end if;
	end loop;
	commit;
	exception when others then
	rollback;
	return false;
	end;

return ret;
end;
$$ language plpgsql;
