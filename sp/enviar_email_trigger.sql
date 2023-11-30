create trigger enviar_email_trigger
after update on pedido
for each row
execute function enviar_email();