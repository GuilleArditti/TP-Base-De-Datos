package main

import (
	"database/sql"
	"fmt"
	"log"
	"os"

	_ "github.com/lib/pq"
)

func main() {

	var mostrarMenu = true
	var input string
	db := conectarDb("postgres")

	menuOptions := `
		Bienvenido a Chango Online, ingrese un número para continuar:
		1 - Crear la base de datos con sus tablas
		2 - Agregar tablas
    	3 - Agregar PKs y FKs
    	4 - Quitar PKs y FKs
     	5 - Instanciar datos
    	6 - Ejecutar los store procedures y triggers
    	0 - Salir`

	for mostrarMenu {

		fmt.Println(menuOptions)
		fmt.Print("Ingrese su opción aqui: ")
		fmt.Scanf("%s", &input)

		if input == "1" {
			ejecutarSql(db, "./sql/eliminar_db.sql")
			ejecutarSql(db, "./sql/crear_db.sql")
			db = conectarDb("aguirre_arditti_villalba_db1")
			fmt.Println("Usted ha creado con exito la base de datos.")
		}
		if input == "2" {
			ejecutarSql(db, "./sql/tablas.sql")
			fmt.Println("Usted ha creado con exito las tablas.")
		}
		if input == "3" {
			ejecutarSql(db, "./sql/crear_pks_fks.sql")
			fmt.Println("Usted ha insertado PKs y FKs con exito.")
		}
		if input == "4" {
			ejecutarSql(db, "./sql/eliminar_pks_fks.sql")
			fmt.Println("Usted ha eliminado PKs y FKs con exito.")
		}
		if input == "5" {
			ejecutarSql(db, "./sql/insertar_datos.sql")
			fmt.Println("Usted ha instanciado con exito los datos.")
		}
		if input == "6" {
			cargarStoresProcedures(db)
			fmt.Println("Usted ejecuto los SP y Triggers con exito.")
		}
		if input == "0" {
			db.Close()
			mostrarMenu = false
			fmt.Println("Hasta la próxima!")
		}
	}
}

func conectarDb(nombreDb string) (db *sql.DB) {
	db, err := sql.Open("postgres", "user=postgres host=localhost dbname="+nombreDb+" sslmode=disable")
	if err != nil {
		log.Fatal(err)
	}
	return db
}

func ejecutarSql(db *sql.DB, path string) {
	query, osErr := os.ReadFile(path)
	if osErr != nil {
		log.Fatal(osErr)
	}
	sql := string(query)
	fmt.Println(sql)
	_, err := db.Exec(sql)
	if err != nil {
		log.Fatal(err)
	}
}

func cargarStoresProcedures(db *sql.DB) {
	files, err := os.ReadDir("./sp")
	if err != nil {
		log.Fatal(err)
	}
	for _, file := range files {
		sp, err := os.ReadFile("./sp/" + file.Name())
		if err != nil {
			log.Fatal(err)
		}
		_, err = db.Exec(string(sp))
		if err != nil {
			log.Fatal(err)
		}
	}
}
