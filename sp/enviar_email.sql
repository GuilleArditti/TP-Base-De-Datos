create or replace function enviar_email() returns trigger as $$
begin

--Envio de email cuando un pedido es aceptado
if new.estado='completado' then

declare

    pedido_datos text;
    productos_detalles text;
    email_cliente text;

    direccion text := (select direccion from direccion_entrega d
    where new.id_usuarie=d.id_usuarie and new.id_direccion_entrega=d.direccion_entrega);

    productos producto;
    cadaProducto record;
    
begin
	
	select * into productos from producto where id_producto in (select id_producto from pedido_detalle where new.id_pedido=id_pedido);
	
    --carga de los datos del pedido
    select 'Fecha de pedido: ' || new.f_pedido || E'\n' ||
            'Fecha de entrega: ' || new.fecha_entrega || E'\n' ||
            'Hora de entrega: ' || new.hora_entrega_desde || E' a ' || new.hora_entrega_hasta || E'\n' ||
            'Monto total: ' || new.monto_total || E'\n' ||
            'Dirección:' || direccion
    into pedido_datos
    from pedido
    where id_pedido=new.id_pedido;

    --carga del detalle de los productos del pedido
    for cadaProducto in (select * from productos)
    loop
        productos_detalles := productos_detalles || 'nombre: ' || cadaProducto.nombre || ', precio: ' || cadaProducto.precio_unitario || E'\n';
    end loop;

    --obtener el email del cliente que realizo el pedido
    select email into email_cliente from cliente cl, pedido p where new.id_pedido=p.id_pedido and p.id_usuarie=cl.id_usuarie;

    insert into envio_email(f_generacion,email_cliente,asunto,cuerpo,f_envio,estado)
    values((select f_pedido from pedido where id_pedido=new.id_pedido),email_cliente,'Pedido aceptado'
    ,pedido_datos || E'\n' || productos_detalles,current_timestamp,'pendiente');

end;
end if;


--Envio de email cuando un pedido es cancelado
if new.estado='cancelado' then

declare

    pedido_datos text;
    productos_detalles text;
    email_cliente text;

    direccion text:=(select direccion from direccion_entrega d
    where new.id_usuarie=d.id_usuarie and new.id_direccion_entrega=d.direccion_entrega);

    productos producto;
    cadaProducto record;
    

begin
	
	select * into productos from producto where id_producto in (select id_producto from pedido_detalle where new.id_pedido=id_pedido);

    --carga de los datos del pedido
    select 'Fecha de pedido: ' || new.f_pedido || E'\n' ||
            'Fecha de entrega: ' || new.fecha_entrega || E'\n' ||
            'Hora de entrega: ' || new.hora_entrega_desde || E' a ' || new.hora_entrega_hasta || E'\n' ||
            'Monto total: ' || new.monto_total || E'\n' ||
            'Dirección:' || direccion
    into pedido_datos
    from pedido
    where id_pedido=new.id_pedido;

    --carga del detalle de los productos del pedido
    for cadaProducto in (select * from productos)
    loop
        productos_detalles := productos_detalles || 'nombre: ' || cadaProducto.nombre || ', precio: ' || cadaProducto.precio_unitario || E'\n';
    end loop;

    --obtener el email del cliente que realizo el pedido
    select email into email_cliente from cliente cl, pedido p where new.id_pedido=p.id_pedido and p.id_usuarie=cl.id_usuarie;

    insert into envio_email(f_generacion,email_cliente,asunto,cuerpo,f_envio,estado)
    values((select f_pedido from pedido where id_pedido=new.id_pedido),email_cliente,'Pedido cancelado'
    ,pedido_datos || E'\n' || productos_detalles,current_timestamp,'pendiente');

end;
end if;

--Envio de email cuando un pedido es entregado
if new.estado='entregado' then

declare

    pedido_datos text;
    productos_detalles text;
    email_cliente text;

    direccion text:=(select direccion from direccion_entrega d
    where new.id_usuarie=d.id_usuarie and new.id_direccion_entrega=d.direccion_entrega);

    productos producto;
    cadaProducto record;
    

begin

	select * into productos from producto where id_producto in (select id_producto from pedido_detalle where new.id_pedido=id_pedido);

    --carga de los datos del pedido
    select 'Fecha de pedido: ' || new.f_pedido || E'\n' ||
            'Fecha de entrega: ' || new.fecha_entrega || E'\n' ||
            'Hora de entrega: ' || new.hora_entrega_desde || E' a ' || new.hora_entrega_hasta || E'\n' ||
            'Monto total: ' || new.monto_total || E'\n' ||
            'Dirección:' || direccion
    into pedido_datos
    from pedido
    where id_pedido=new.id_pedido;

    --carga del detalle de los productos del pedido
    for cadaProducto in (select * from productos)
    loop
        productos_detalles := productos_detalles || 'nombre: ' || cadaProducto.nombre || ', precio: ' || cadaProducto.precio_unitario || E'\n';
    end loop;

    --obtener el email del cliente que realizo el pedido
    select email into email_cliente from cliente cl, pedido p where new.id_pedido=p.id_pedido and p.id_usuarie=cl.id_usuarie;

    insert into envio_email(f_generacion,email_cliente,asunto,cuerpo,f_envio,estado)
    values((select f_pedido from pedido where id_pedido=new.id_pedido),email_cliente,'Pedido entregado'
    ,pedido_datos || E'\n' || productos_detalles,current_timestamp,'enviado');
    
end;
end if;

return new;
end;
$$language plpgsql;
