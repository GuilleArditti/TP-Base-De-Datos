create or replace function cancelar_pedido(id_pedido_aux int) returns boolean as $$
declare

estado_pedido text;
productos_a_actualizar record;
producto_record record;

begin

--Que el id de pedido exista. En caso de que no cumpla, se debe cargar un error con
--el mensaje ?id de pedido no válido.

if id_pedido_aux not in (select id_pedido from pedido) then
		insert into error(id_pedido,f_pedido,operacion,f_error,motivo)
        values (id_pedido_aux,current_timestamp,'cancelación', current_timestamp, '?id de pedido no válido');
	return false;
end if;

--Que el pedido se encuentre en estado ingresado o completado. En caso de que
--no cumpla, se debe cargar un error con el mensaje ?pedido ya entregado o
--cancelado.

estado_pedido:= (select estado from pedido where id_pedido=id_pedido_aux);

if(estado_pedido!= 'ingresado' or estado_pedido!='completado') then
        insert into error(f_pedido,id_pedido,operacion,f_error,motivo)
        values (current_timestamp,id_pedido_aux,'cancelación',current_timestamp,'?pedido ya entregado o cancelado');
    return false;
end if;

--Si las validaciones pasan correctamente, se deberá marcar el estado del pedido como
--cancelado. Además, deberá sumarse al stock disponible de cada producto la cantidad
--incluida en el pedido cancelado, y descontarla del stock reservado.
begin
set transaction isolation level serializable;

update pedido
    set
        estado = 'cancelado'
    where
        id_pedido = id_pedido_aux;

select id_producto,cantidad into productos_a_actualizar from pedido_detalle where id_pedido_aux=id_pedido;

for producto_record in select * from productos_a_actualizar
    loop
      update producto
        set
            stock_disponible = stock_disponible + producto_record.cantidad,
            stock_reservado = stock_reservado - producto_record.cantidad

        where id_producto = producto_record.id_producto;
    end loop;

return true;
commit;
exception when others then
rollback;
return false;
end;

commit;

end;

$$language plpgsql;
