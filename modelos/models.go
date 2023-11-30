package modelos

import "time"

type Cliente struct {
	IdUsuarie       int `json:"id_usuarie"`
	Nombre          string
	Apellido        string
	Dni             int
	FechaNacimiento time.Time
	Telefono        string
	Email           string
}

type Tarifa_entrega struct {
	CodigoPostal string `json:"codigo_postal_corto"`
	Costo        float32
}

type Producto struct {
	IdProducto      int `json:"id_producto"`
	Nombre          string
	PrecioUnitario  float32 `json:"precio_unitario"`
	StockDisponible int     `json:"stock_disponible"`
	StockReservado  int     `json:"stock_reservado"`
	PuntoReposicion int     `json:"punto_reposicion"`
	StockMaximo     int     `json:"stock_maximo"`
}

type Direccion_entrega struct {
	IdUsuarie          int `json:"id_usuarie"`
	IdDireccionEntrega int `json:"id_direccion_entrega"`
	Direccion          string
	Localidad          string
	CodigoPostal       string `json:"codigo_postal"`
}

type Trx_pedido struct {
	IdOrden              int `json:"id_orden"`
	Operacion            string
	IdUsuarie            int `json:"id_usuarie"`
	Id_direccion_entrega int `json:"id_direccion_entrega"`
	Id_pedido            int `json:"id_pedido"`
	Id_producto          int `json:"id_producto"`
	Cantidad             int
	Fecha_hora_entrega   time.Time `json:"fecha_hora_entrega"`
}
