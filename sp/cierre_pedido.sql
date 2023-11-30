create or replace function cerrar_pedido(id_pedido int, fecha_entrega date, hora_entrega time) 
returns boolean as $$
declare
    v_cantidad_productos int;
    v_hora_hasta time;
begin
    
--Que el id del pedido exista.En caso de que no cumpla,se debe cargar un
--error con el mensaje ?id de pedido no valido

    if id_pedido not in (select id_pedido from pedido) then
		insert into error(id_pedido,operacion,f_error, motivo)
         values (id_pedido,'cierre',current_timestamp, 'id de pedido no válido');

	    return false;

	end if;


--Que el pedido tenga al menos un producto agregado. En caso de que no cumpla,
--se debe cargar un error con el mensaje ?pedido vacío.

    select count(*) into v_cantidad_productos
    from pedido_detalle
    where id_pedido = id_pedido;

    if v_cantidad_productos = 0 then
        insert into error (id_pedido,operacion,f_error, motivo)
        values (id_pedido,'cierre',current_timestamp, '?pedido vacío');

        return false;

    end if;

--Que la fecha y hora de entrega sea posterior a la fecha y hora actual. En caso de
--que no cumpla, se debe cargar un error con el mensaje ?fecha de entrega no valida

    if fecha_entrega < current_date or (fecha_entrega = current_date and hora_entrega <= current_time) then
        insert into error (id_pedido, motivo)
        values (id_pedido, 'fecha de entrega no válida');

        return false;

    end if;

--Si se aprueba el cierre, se deberá actualizar la fila correspondiente en la tabla pedido
--con la fecha de entrega, y las horas de entrega desde y hasta, dejando su estado como
--completado. Calcular la ‘hora hasta’ como dos horas posterior a la ‘hora desde’.
	
    v_hora_hasta := hora_entrega + interval '2 hours';
    begin
    set transaction isolation level serializable;
		update pedido
		set fecha_entrega = fecha_entrega,
			hora_entrega_desde = hora_entrega,
			hora_entrega_hasta = v_hora_hasta,
			estado = 'completado'
		where id_pedido = id_pedido;
	
    return true;
    commit;
    exception when others then
    rollback;
    return false;
    end;
    
commit;
end;
$$ language plpgsql;

