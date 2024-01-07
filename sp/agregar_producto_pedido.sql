create or replace function agregar_producto_pedido(id_pedido_aux int, id_producto_aux int, cantidad_solicitada int) returns boolean as $$
declare
    operacion text;
    cantidad_aux int;
    is_producto_en_pedido boolean;
    stock_disponible_en_producto int;
    estado_pedido text;
    pedido_detalle_aux pedido_detalle;
    monto_a_agregar float;
    
begin
    
    operacion = 'producto';
    
    --- que el id de pedido exista. en caso de que no cumpla, se debe cargar un error con
    --el mensaje ?id de pedido no válido.
    if id_pedido_aux not in (select id_pedido from pedido) then
    insert into error(f_pedido, id_pedido, id_producto, operacion, f_error, motivo) 
	values (current_timestamp, id_pedido_aux, id_producto_aux, operacion, current_date, '?id de pedido no válido');
    return false;
    end if;
    
    --- que el pedido se encuentre en estado ingresado. en caso de que no cumpla, se debe
    --cargar un error con el mensaje ?pedido cerrado.
    estado_pedido = (select estado from pedido where id_pedido = id_pedido_aux);
    if estado_pedido != 'ingresado' then
    insert into error(f_pedido, id_pedido, id_producto, operacion, f_error, motivo) 
	values (current_timestamp, id_pedido_aux, id_producto_aux, operacion, current_date, '?pedido cerrado');
    return false;
    end if;
    
    --- que el id de producto exista. en caso de que no cumpla, se debe cargar un error
    --con el mensaje ?id de producto no válido.
    if id_producto_aux not in (select id_producto from producto) then
    insert into error(f_pedido, id_pedido, id_producto, operacion, f_error, motivo) 
	values (current_timestamp, id_pedido_aux, id_producto_aux, operacion, current_date, '?id producto no valido');
    return false;
    end if;
    
    --- que el producto tenga stock disponible para satisfacer la cantidad solicitada al momento de realizar el pedido. en caso de que no se cumpla, se debe cargar un nuevo
    --error con el mensaje ?stock no disponible para el producto [id_producto],
    --reemplazando en el mensaje [id_producto] por el valor correspondiente que generó el error
   
    stock_disponible_en_producto = (select stock_disponible from producto);
    if stock_disponible_en_producto < cantidad_solicitada then
    insert into error(f_pedido, id_pedido, id_producto, operacion, f_error, motivo) 
	values (current_timestamp, id_pedido_aux, id_producto_aux, operacion, current_date, '?stock no disponible para el producto ' || id_pedido_aux);
    return false;
    end if;

/* si se aprueba la incorporación, se deberá insertar una fila en la tabla pedido_detalle
    con los datos del producto. si el pedido ya contiene al producto, se deberá actualizar
    la fila correspondiente, sumando la nueva cantidad. en cualquiera de los dos casos,
    se deberá descontar dicha cantidad del stock disponible y sumarla al stock reservado.
    también deberá mantenerse actualizado el monto total del pedido de forma coherente
    con el detalle de productos solicitados.*/

   -- guardo el monto agregar cuanto debo sumar luego
    monto_a_agregar = cantidad_solicitada * (select precio_unitario from producto where id_producto = id_producto_aux);
    
    select * into pedido_detalle_aux from pedido_detalle
        where id_pedido = id_pedido_aux and id_producto = id_producto_aux;
    
    begin
    set transaction isolation level serializable;

    if pedido_detalle_aux is null then

        insert into pedido_detalle (id_pedido, id_producto, cantidad, precio_unitario)
        values (id_pedido_aux, id_producto_aux, cantidad_solicitada, monto_a_agregar);

        update producto
            set
                stock_disponible = stock_disponible - cantidad_solicitada,
                stock_reservado = stock_reservado + cantidad_solicitada
            where
                id_producto = id_producto_aux;

        update pedido
            set
                monto_total = monto_total + monto_a_agregar
            where
                id_pedido = id_pedido_aux;       
        return true;
    
    --existe, entonces actualizo
    else
        update pedido_detalle
            set
                cantidad = cantidad + cantidad_solicitada
            where
                id_pedido = id_pedido_aux and id_producto = id_producto_aux;

        update producto
            set
                stock_disponible = stock_disponible - cantidad_solicitada,
                stock_reservado = stock_reservado + cantidad_solicitada
            where
                id_producto = id_producto_aux;
            
        update pedido
            set
                monto_total = monto_total + monto_a_agregar
            where
                id_pedido = id_pedido_aux;
            
        return true;
    end if;
    commit;
    exception when others then
		rollback;
		return false;
    end;

commit;
end;
$$ language plpgsql;
