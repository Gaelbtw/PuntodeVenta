import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseHelper {
  static Database?_database;

  // Singleton una sola instancia, significa que solo habra una conexion a la base de datos para todo.
  
  Future<Database> get database async {
    if(_database != null) return _database!;
    _database = await _initDB();
    return _database!;
  }

  // Inicializar la base de datos 

  Future<Database> _initDB() async {
    String path = join(await getDatabasesPath(), 'pos.db');

    return await openDatabase(
      path,
      version: 4,
      onCreate: _onCreate,
    );
  }


  // Crear todas las tablas 

  Future<void> _onCreate(Database db, int version) async {

    await db.execute('''
      CREATE TABLE Proveedores (
        id_proveedor INTEGER PRIMARY KEY AUTOINCREMENT,
        nombre TEXT NOT NULL,
        direccion TEXT,
        telefono INTEGER
      );
    ''');

    await db.execute ('''
      CREATE TABLE Usuarios (
        id_usuario INTEGER PRIMARY KEY AUTOINCREMENT,
        nombre TEXT NOT NULL,
        contra TEXT NOT NULL,
        rol TEXT CHECK(rol IN ('Cajero','Admin')) NOT NULL
      );
    ''');

    await db.execute('''
      CREATE TABLE Compras (
        id_compra INTEGER PRIMARY KEY AUTOINCREMENT,
        fecha DATE,
        total REAL,
        id_proveedor INTEGER,
        id_usuario INTEGER,
        FOREIGN KEY (id_proveedor) REFERENCES Proveedores(id_proveedor),
        FOREIGN KEY (id_usuario) REFERENCES Usuarios(id_usuario)
      );
    ''');

    await db.execute('''
    CREATE TABLE Categorias (
      id_categoria INTEGER PRIMARY KEY AUTOINCREMENT,
      nombre TEXT NOT NULL
    );
    ''');

    await db.execute('''
      CREATE TABLE Detalle_Compra (
        id_detalle INTEGER PRIMARY KEY AUTOINCREMENT,
        id_compra INTEGER,
        id_producto INTEGER,
        precio REAL,
        FOREIGN KEY (id_compra) REFERENCES Compras(id_compra),
        FOREIGN KEY (id_producto) REFERENCES Producto(id_producto)
      );
    ''');

    await db.execute('''
      CREATE TABLE Clientes (
        id_cliente INTEGER PRIMARY KEY AUTOINCREMENT,
        nombre TEXT NOT NULL,
        direccion TEXT,
        telefono INTEGER,
        correo TEXT,
        fecha_registro DATE
      );
    ''');

    await db.execute('''
      CREATE TABLE Pedidos (
        id_pedido INTEGER PRIMARY KEY AUTOINCREMENT,
        id_cliente INTEGER,
        fecha DATE,
        estado TEXT,
        FOREIGN KEY (id_cliente) REFERENCES Clientes(id_cliente)
      );  
    ''');


    await db.execute('''
      CREATE TABLE Ventas (
        id_venta INTEGER PRIMARY KEY AUTOINCREMENT,
        id_cliente INTEGER,
        id_usuario INTEGER,
        id_pedido INTEGER,
        fecha DATE,
        total REAL,
        metodo_pago TEXT DEFAULT 'efectivo',
        FOREIGN KEY (id_cliente) REFERENCES Clientes(id_cliente),
        FOREIGN KEY (id_usuario) REFERENCES Usuarios(id_usuario)
      );
    ''');

    await db.execute('''
      CREATE TABLE Detalle_Venta (
        id_detalleV INTEGER PRIMARY KEY AUTOINCREMENT,
        id_venta INTEGER,
        id_producto INTEGER,
        cantidad INTEGER,
        precio REAL,
        FOREIGN KEY (id_venta) REFERENCES Ventas(id_venta),
        FOREIGN KEY (id_producto) REFERENCES Producto(id_producto)
      );
    ''');

    await db.execute('''
      CREATE TABLE Producto (
        id_producto INTEGER PRIMARY KEY AUTOINCREMENT,
        nombre TEXT NOT NULL,
        descripcion TEXT,
        precio REAL NOT NULL,
        id_categoria INTEGER,
        FOREIGN KEY (id_categoria) REFERENCES Categorias(id_categoria)
      );
    ''');

    await db.execute('''
      CREATE TABLE Inventario (
        id_inventario INTEGER PRIMARY KEY AUTOINCREMENT,
        id_producto INTEGER UNIQUE,
        cantidad INTEGER,
        FOREIGN KEY (id_producto) REFERENCES Producto(id_producto)
      );
    ''');

    await db.execute('''
      CREATE TABLE Reporte (
        id_reporte INTEGER PRIMARY KEY AUTOINCREMENT,
        tipo TEXT,
        descripcion TEXT,
        fecha DATE,
        id_usuario INTEGER,
        FOREIGN KEY (id_usuario) REFERENCES Usuarios(id_usuario)
      );
    ''');

    // Insertar un usuario para probar 

    await db.execute ('''
      INSERT INTO Usuarios (
        nombre,
        contra,
        rol
      ) VALUES ("Admin", "1234", "Admin");
    ''');
  }
}