create or replace function enviar_email_encuesta_de_satisfaccion() returns void as $$

declare

    fecha_recibimiento_pedido date := current_date - 1;
    asunto_text text := 'Encuesta de satisfacción';
    cuerpo_email text :=' esperamos que este disfrutando su pedido. Lo invitamos a completar una breve encuesta en https:www.changoonline.com/encuestas. Gracias!';
    usuarios_a_notificar cliente;
    usuario record;

begin

    --Obtener todos los usuarios que recibieron correctamente su pedido el dia anterior

    select * into usuarios_a_notificar
    from cliente 
    where id_usuarie in (select id_usuarie from pedido where f_pedido::date=fecha_recibimiento_pedido and estado='entregado');

    --Enviar el mail a cada uno de los usuarios

    for usuario in (select * from usuarios_a_notificar)
    loop
    insert into envio_email(email_cliente,asunto,cuerpo,f_envio,estado)
    values(usuario.email,asunto_text,
    'Estimade: ' || usuario.nombre || '' || usuario.apellido || cuerpo_email,current_timestamp,'enviado');
    end loop;

end;
$$language plpgsql;