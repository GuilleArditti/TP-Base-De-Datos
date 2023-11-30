create or replace function entregar_pedido(id_pedido_aux int) returns boolean as $$
declare
    operacion text; 
    productos_involucrados record;
    producto_record record;
begin

    operacion = 'entrega';

    --que el id de pedido exista. en caso de que no cumpla, se debe cargar un error con
    --el mensaje ?id de pedido no válido

    if id_pedido_aux not in (select id_pedido from pedido) then
        insert into error(f_pedido, id_pedido, operacion, f_error, motivo) 
        values (current_timestamp, id_pedido_aux, operacion, current_timestamp, '?id de pedido no válido');
        return false;
    end if;

    --que el pedido se encuentre en estado completado. en caso de que no cumpla, se
    --debe cargar un error con el mensaje ?pedido sin cerrar o ya entregado.

    if (select estado from pedido where id_pedido = id_pedido_aux) == 'completado' then
        insert into error(f_pedido, id_pedido, operacion, f_error, motivo) 
        values (current_timestamp, id_pedido_aux, operacion, current_timestamp, '?pedido sin cerrar o ya entregado');
        return false;
    end if;

    --si va todo ok, se deberá marcar el estado del pedido como entregado.
    --además, deberá restarse del stock reservado de cada producto la cantidad
    --incluida en el pedido entregado.
    
    select id_producto, cantidad into productos_involucrados from pedido_detalle where id_pedido = id_pedido_aux;
    begin
    set transaction isolation level serializable;
		update pedido
		set
			estado = 'entregado'
		where
			id_pedido = id_pedido_aux;

		for producto_record in select * from productos_involucrados
		loop
			update producto
			set stock_reservado = stock_reservado - producto_record.cantidad
			where id_producto = producto_record.id_producto;
		end loop;
		return true;
		commit;
		exception when others then
		rollback;
		return false;
	end;
end;
$$ language plpgsql;
