# Flujo básico de facturación e inventario

## Facturación
1. Un usuario crea una factura desde el módulo de ventas.
2. Cada línea de la factura se guarda y reduce la existencia del producto correspondiente.
3. Al finalizar se puede generar un PDF de la factura usando `pdfmake`.

## Inventario
1. El servicio de inventario mantiene la cantidad disponible de cada producto.
2. Cuando una factura se registra, el servicio descuenta la cantidad vendida.
3. Otros módulos pueden llamar a `adjustStock` para ingresar o retirar unidades.
