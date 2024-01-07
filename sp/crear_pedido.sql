create or replace function crear_pedido(id_usuarie_aux int, id_direccion int) returns boolean as $$
declare

resultado direccion_entrega;
resultado2 tarifa_entrega;
costo_envio_aux decimal(12,2);

begin

--Que el id de le usuarie exista. En caso de que no cumpla, se debe cargar un error con el mensaje ?id de usuarie no valido.
if id_usuarie_aux not in (select id_usuarie from cliente) then
	insert into error (id_usuarie,operacion,f_error,motivo)
	values(id_usuarie_aux,'creación',current_timestamp,'?id de usuarie no válido');
	return false;
end if;

--Que el id de la direccion de entrega exista para le cliente.En caso de que no cumpla se debe cargar un error con el mensaje ?id de direccion no valido.


select * into resultado from direccion_entrega where id_usuarie_aux=id_usuarie and id_direccion=id_direccion_entrega;

if resultado is null then
	insert into error (id_usuarie,id_direccion_entrega,operacion,f_error,motivo)
	values(id_usuarie_aux,id_direccion,'creación',current_timestamp,'?id de dirección no válido');
	return false;
end if;

--Que el codigo postal de la direccion de entrega tenga una tarifa establecida.
--En caso de que no cumpla,se debe cargar un error con el mensaje
--?direccion de entrega fuera del area de atencion.

select * into resultado2 from tarifa_entrega t, direccion_entrega d
where d.codigo_postal=t.codigo_postal_corto and id_direccion=id_direccion_entrega;

if resultado2 is null then
	insert into error(id_usuarie,id_direccion_entrega,codigo_postal,operacion,f_error,motivo)
	values(id_usuarie_aux,id_direccion,resultado2.codigo_postal,'creación',current_timestamp,'?dirección de entrega fuera del area de atención');
	return false;
end if;

--Si se aprueba la creación del pedido, se deberá insertar una fila en la tabla pedido con
--los datos de le cliente, la fecha y hora del pedido, y el costo de envío correspondiente
--al código postal, dejando su estado como ingresado.

costo_envio_aux:=(select costo from tarifa_entrega where codigo_postal_corto in
 (select codigo_postal from direccion_entrega where id_usuarie=id_usuarie_aux
  and id_direccion=id_direccion_entrega));

insert into pedido (f_pedido,id_usuarie,id_direccion_entrega,costo_envio,estado)
values(current_timestamp,id_usuarie_aux,id_direccion,costo_envio_aux,'ingresado');

return true;

end;
$$ language plpgsql;
