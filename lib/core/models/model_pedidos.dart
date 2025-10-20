
//Resumen de los pagos 
class ResumenPagos{
  final int? idTransaccion;
  final double monto;
  final String metodo;
  final String fecha;
  final String? detalles;

  ResumenPagos({
    this.idTransaccion,
    required this.monto,
    required this.metodo,
    required this.fecha,
    this.detalles,
  });

  factory ResumenPagos.fromJson(Map<String, dynamic> json) {
    return ResumenPagos(
      idTransaccion: json['id'] as int?,
      monto: double.tryParse(json['monto']?.toString() ?? '') ?? 0.0,
      metodo: json['metodo'] ?? 'Efectivo',
      fecha: json['fecha'] ?? 'N/A', 
      detalles: json['detalles'],
    );
  }
}


class PedidosAsignadosResponse {
  final String fechaConsulta;
  final int idRepartidor;
  final int totalPedidos;
  final List<Pedido> pedidos;

  PedidosAsignadosResponse({
    required this.fechaConsulta,
    required this.idRepartidor,
    required this.totalPedidos,
    required this.pedidos,
  });

  factory PedidosAsignadosResponse.fromJson(Map<String, dynamic> json) {
 
    var pedidosList = json['pedidos'] as List? ?? [];
    
    return PedidosAsignadosResponse(
      fechaConsulta: json['fechaConsulta'] ?? '',
      idRepartidor: json['repartidor'] ?? 0,
      totalPedidos: json['totalPedidos'] ?? 0,
    
      pedidos: pedidosList.map((p) => Pedido.fromJson(p)).toList(),
    );
  }
}



class Pedido{
  final int id;
  final int diasAlquiler;
  final String tipoPedido;
  final String estadoPedido;
  final String descripcion;
  final String telefonoCliente;
  final String nombreCliente;
  final String localidad;
  final String municipio;
  final String estado;
  final DateTime fechaEntrega;
  final String direccion;
  final double totalAPagar;
  final double totalPagado;
  final bool isUrgente;
  final String? observaciones;
  final List<Producto> productos;
  final List<ResumenPagos> historialPagos;

  Pedido({
    required this.id,
    required this.diasAlquiler,
    required this.tipoPedido,
    required this.estadoPedido,
    required this.descripcion,
    required this.nombreCliente,
    required this.telefonoCliente,
    required this.localidad,
    required this.municipio,
    required this.estado,
    required this.fechaEntrega,
    required this.direccion,
    required this.totalAPagar,
    required this.totalPagado,
    required this.isUrgente,
    this.observaciones, 
    required this.productos,
    required this.historialPagos,

  });

 factory Pedido.fromJson(Map<String, dynamic> json) {
    String capitalizeStatus(String? status) {
      if (status == null || status.isEmpty) return "Pendiente";
      return status[0].toUpperCase() + status.substring(1).toLowerCase();
    }

    var productosList = json['productos'] as List? ?? [];
    List<Producto> productos = productosList.map((p) => Producto.fromJson(p)).toList();
    var pagosList = json['pagos'] as List? ?? json['resumen_pagos'] as List? ?? [];
    List<ResumenPagos> historialPagos =
        pagosList.map((p) => ResumenPagos.fromJson(p as Map<String, dynamic>)).toList(); // Asegura Map


  return Pedido(
      id: json['id'] ?? 0,
      diasAlquiler: json['diasAlquiler'] ?? 0,
      tipoPedido: json['tipo_pedido'] ?? 'entrega',
      estadoPedido: capitalizeStatus(json['estado_pedido']),
      descripcion: json['descripcion'] ?? 'Sin descripción',
      nombreCliente: json['cliente'] ?? 'Desconocido', // Mapeo cliente
      telefonoCliente: json['telefono_cliente'] ?? 'N/A', // Mapeo telefono_cliente
      localidad: json['localidad'] ?? 'Desconocido',
      municipio: json['municipio'] ?? 'Desconocido',
      estado: json['estado'] ?? 'Desconocido',
      // Usa DateTime.tryParse y maneja el valor nulo con el operador ??
      fechaEntrega: DateTime.tryParse(json['fecha_entrega'] ?? '') ?? DateTime.now(),
      direccion: json['direccion'] ?? 'Sin dirección',
      // Convierte de String (si viene como tal) a double de forma segura
      totalAPagar: double.tryParse(json['total_a_pagar']?.toString() ?? '') ?? 0.0,
      totalPagado: double.tryParse(json['total_pagado']?.toString() ?? '') ?? 0.0,
      isUrgente: (json['urgente'] is int) ? (json['urgente'] == 1) : (json['urgente'] ?? false), // Manejo seguro de 0/1 o bool
      observaciones: json['observaciones'], // Ya es String?
      productos: productos,
      historialPagos: historialPagos,
    );
  }

Pedido copyWith({
    String? estadoPedido,
    double? totalPagado,
    String? observaciones,
    List<Producto>? productos,
    List<ResumenPagos>? historialPagos,
  
  }) {
    return Pedido(
      id: this.id,
      diasAlquiler: this.diasAlquiler,
      tipoPedido: this.tipoPedido,
      estadoPedido: estadoPedido ?? this.estadoPedido,
      descripcion: this.descripcion,
      nombreCliente: this.nombreCliente,
      telefonoCliente: this.telefonoCliente,
      localidad: this.localidad,
      municipio: this.municipio,
      estado: this.estado,
      fechaEntrega: this.fechaEntrega,
      direccion: this.direccion,
      totalAPagar: this.totalAPagar,
      totalPagado: totalPagado ?? this.totalPagado,
      isUrgente: this.isUrgente,
      observaciones: observaciones ?? this.observaciones,
      productos: productos ?? this.productos,
      historialPagos: historialPagos ?? this.historialPagos,
    );
  }
}




class Producto {
  final int id;
  final String nombre;
  final int cantidad;
  final double precio;
  final double subtotal;
  final String? color;
  final String estado;
  final String? nota;
  final String? foto;

  Producto({
    required this.id,
    required this.nombre,
    required this.cantidad,
    required this.precio,
    required this.subtotal,
    this.color,
    required this.estado,
    this.nota,
    this.foto,
  });

  factory Producto.fromJson(Map<String, dynamic> json) {
    String capitalizeStatus(String? status) {
      if (status == null || status.isEmpty) return "Disponible";
      return status[0].toUpperCase() + status.substring(1).toLowerCase();
    }
    
    return Producto(
      id: json['id'] ?? 0,
      nombre: json['nombre'] ?? 'Sin nombre',
      cantidad: json['cantidad'] ?? 0,

      precio: double.tryParse(json['precio']?.toString() ?? '') ?? 0.0,
      subtotal: double.tryParse(json['subtotal']?.toString() ?? '') ?? 0.0,
      color: json['color'],
      estado: capitalizeStatus(json['estado']),
      nota: json['nota'],
      foto: json['foto'],
    );
  }
  
 
  Producto copyWith({
    String? estado,
    String? nota,
  }) {
    return Producto(
      id: this.id,
      nombre: this.nombre,
      cantidad: this.cantidad,
      precio: this.precio,
      subtotal: this.subtotal,
      color: this.color,
      estado: estado ?? this.estado,
      nota: nota ?? this.nota,
      foto: this.foto,
    );
  }
}

