# Caja de Ahorro y Crédito Solidaria Familiar Pujota-Simbaña

> Sistema web MVC PHP 8.4 + MySQL 8 para gestión integral de una caja de ahorro comunitaria.

---

## 1. Condiciones de créditos (Estatuto + Reglamento Interno)

### 1.1 Requisitos para solicitar un crédito
El socio debe cumplir **al menos una** de las siguientes condiciones:

1. **Mínimo 6 meses** de permanencia en la Caja.
2. **Ahorro mínimo de USD 100,00** en su cuenta.

### 1.2 Aprobación
- Los créditos son aprobados por la **Asamblea General** mediante votación por **mayoría simple** de los socios presentes (Art. 10 Reglamento).
- Están sujetos a la **disponibilidad económica** generada en cada sesión mensual (Art. 11 Reglamento).

### 1.3 Condiciones financieras

| Concepto | Valor |
|---|---|
| Tasa de interés ordinaria | **6% anual** |
| Método de interés | **Simple** |
| Cálculo de cuotas | **Fijas**: capital / N meses + interés |
| Crédito emergente | Hasta **USD 300,00** (fuera del turno ordinario) |

### 1.4 Desembolso
- Se realiza durante la **sesión mensual**.
- Se generan los siguientes documentos:
  - Formulario de solicitud
  - Registro de aprobación
  - Comprobante de desembolso
  - Historial de pagos
  - Tabla de amortización

### 1.5 Mora y atrasos
- **Multa de USD 5,00** por cuota no pagada en la sesión correspondiente.
- El valor pendiente se suma a la cuota del siguiente mes.
- El atraso puede **limitar temporalmente** el acceso a nuevos créditos.

---

## 2. Flujo de solicitud de crédito (autoservicio portal socio)

### 2.1 Estados del crédito

| Estado | Significado |
|---|---|
| **ingresado** | Socio envió solicitud desde el portal (3-step wizard) |
| **pendiente** | Presidente marcó "En espera" (falta liquidez o problema puntual). Se notifica al socio |
| **aprobado** | Comité aprueba. Se genera tabla de amortización. Pasa a legalización |
| **legalizado** | Secretaría subió PDF firmado (solicitud + tabla de amortización) vía FileManager |
| **desembolsado** | Tesorero ejecutó el desembolso |
| **rechazado** | Negado con justificación. Se notifica al socio |
| **cancelado** | Anulado posteriormente |

### 2.2 Diagrama de flujo

```
ingresado ──→ pendiente ──→ aprobado ──→ legalizado ──→ desembolsado
    │             │             │                              
    └──→ rechazado ←───────────┘
```

### 2.3 Transiciones

| Desde | Hacia | Acción | Rol |
|---|---|---|---|
| `ingresado` | `pendiente` | Poner en espera + motivo | Presidente / delegate |
| `ingresado` | `aprobado` | Aprobar (con o sin monto modificado) | Presidente / delegate |
| `ingresado` | `rechazado` | Rechazar + justificación | Presidente / delegate |
| `pendiente` | `aprobado` | Aprobar | Presidente / delegate |
| `pendiente` | `rechazado` | Rechazar | Presidente / delegate |
| `aprobado` | `legalizado` | Subir PDF firmado (solo si `requiere_documento_firmado=TRUE`) | Secretaría |
| `aprobado` | `desembolsado` | Desembolso directo (si `requiere_documento_firmado=FALSE`) | Tesorero |
| `legalizado` | `desembolsado` | Ejecutar desembolso | Tesorero |

### 2.4 Wizard portal (tres pasos)

1. **Simular**: Socio selecciona producto, monto y plazo → `CalculadoraInteres::simular()` genera tabla de amortización en vivo
2. **Condiciones**: Muestra `condiciones_html` del producto + verifica elegibilidad (permanencia mínima, ahorro mínimo)
3. **Confirmar**: Resumen + checkbox "Acepto condiciones" → INSERT con estado `ingresado`

### 2.5 Bandeja de aprobación (Presidente / delegate)

- Ruta: `/credito/bandejaAprobados`
- Permiso requerido: `credito.aprobar` (asignado a Presidente y Tesorero; Analista Financiero hereda por endosable)
- Acciones disponibles según estado:
  - `ingresado`: Aprobar | Poner en espera | Rechazar
  - `pendiente`: Aprobar | Rechazar
  - `aprobado`: Generar PDF Solicitud | Subir acta firmada | Desembolsar
  - `legalizado`: Desembolsar

### 2.6 Legalización

1. Presidente/delegate aprueba → estado `aprobado`, se genera tabla de amortización
2. Se imprime **Solicitud de crédito PDF** (formato según template Excel "SOLICITUD DE CRÉDITO")
3. Comité de crédito + socio firman el documento
4. Secretaría **sube el PDF firmado** vía FileManager (`entidad_tipo='credito'`)
5. Estado cambia a `legalizado`

### 2.7 Desembolso

- Solo disponible si:
  - `requiere_documento_firmado=FALSE`: desde estado `aprobado`
  - `requiere_documento_firmado=TRUE`: desde estado `legalizado`
- Genera cobro tipo `desembolso` + historial de operación

### 2.8 Nuevas columnas en `productos_financieros`

| Columna | Tipo | Default | Descripción |
|---|---|---|---|---|
| `condiciones_html` | TEXT | NULL | Condiciones en HTML (WYSIWYG Summernote) |
| `min_permanencia_meses` | INT | 0 | Antigüedad mínima como socio activo |
| `min_ahorro` | DECIMAL(10,2) | 0 | Ahorro acumulado mínimo requerido |
| `es_emergente` | BOOLEAN | FALSE | Crédito emergente (sin sesión) |
| `monto_max_emergente` | DECIMAL(10,2) | 0 | Tope para emergente |
| `requiere_documento_firmado` | BOOLEAN | TRUE | Exige PDF firmado antes del desembolso |

### 2.9 Nuevos permisos

| Código | Nombre | Asignado a |
|---|---|---|
| `credito.aprobar` | Aprobar/rechazar créditos | Presidente (2), Tesorero (4) |

---

## 3. Migración a clean ASCII (base de datos)

### 3.1 Tablas renombradas

| Original | Nuevo |
|---|---|
| `créditos` | `creditos` |
| `parámetros` | `parametros` |
| `catastro_entidades_públicas` | `catastro_entidades_publicas` |

### 3.2 Columnas renombradas (~65)

Todas las columnas con acentos/ñ fueron migradas a clean ASCII:

| Patrón | Ejemplos |
|---|---|
| `é`→`e` | `cédula`→`cedula`, `interés`→`interes`, `método`→`metodo` |
| `ó`→`o` | `dirección`→`direccion`, `sesión`→`sesion` |
| `í`→`i` | `plazo_mín`→`plazo_min`, `título`→`titulo` |
| `ú`→`u` | `fecha_último`→`fecha_ultimo` |
| `á`→`a` | `tamaño`→`tamano`, `código`→`codigo` |
| `ñ`→`n` | `contraseña`→`contrasena`, `año` (no aplica) |
| `ü`→`u` | `fecha_último_acceso`→`fecha_ultimo_acceso` |

### 3.3 ENUMs actualizados

| Tabla | Columna | Valor antiguo | Valor nuevo |
|---|---|---|---|
| `historial_operaciones` | `tipo_operacion` | `'desembolso_crédito'` | `'desembolso_credito'` |
| `historial_operaciones` | `tipo_operacion` | `'inversión_apertura'` | `'inversion_apertura'` |
| `historial_operaciones` | `tipo_operacion` | `'interés_ganado'` | `'interes_ganado'` |
| `historial_operaciones` | `tipo_operacion` | `'anulación'` | `'anulacion'` |
| `historial_operaciones` | `tipo_operacion` | `'cierre_sesión'` | `'cierre_sesion'` |
| `creditos` | `metodo_interes` | `'francés'` | `'frances'` |
| `creditos` | `metodo_interes` | `'alemán'` | `'aleman'` |
| `productos_financieros` | `metodo_interes` | `'francés'` | `'frances'` |
| `productos_financieros` | `metodo_interes` | `'alemán'` | `'aleman'` |
| `parametros` | `tipo` | `'número'` | `'numero'` |
| `cobros` | `medio_pago` | `'compensación'` | `'compensacion'` |
| `cobros` | `tipo` | `'cuota_crédito'` | `'cuota_credito'` |
| `cobros` | `tipo` | `'inversión'` | `'inversion'` |
| `multas` | `tipo` | `'mora_crédito'` | `'mora_credito'` |
| `socios` | `estado_civil` | `'unión_libre'` | `'union_libre'` |
| `productos_financieros` | `tipo` | `'crédito'` | `'credito'` |
| `notificaciones` | `tipo` | `'crédito'` | `'credito'` |

---

## 4. Formulario de productos financieros

### 4.1 Estructura del formulario

El formulario de registro/edición de productos (`/producto/registrar` y `/producto/editar/:id`) se organiza en secciones que se muestran según el tipo seleccionado:

1. **Datos generales**: Nombre, Tipo (crédito/inversión), Activo
2. **Configuración financiera** (compartido): tasa interés, plazos, montos
3. **Opciones de crédito** (solo si tipo=crédito): método de interés, requiere garante, requiere documento firmado, crédito emergente
4. **Opciones de inversión** (solo si tipo=inversión): permanencia mínima, ahorro mínimo, penalidad retiro anticipado
5. **Condiciones**: Editor WYSIWYG (Summernote) para el texto descriptivo

### 4.2 Campos específicos por tipo

**Crédito:**
- `metodo_interes`: Simple, Francés, Alemán
- `requiere_garante`: BOOLEAN
- `es_emergente`: BOOLEAN (despliega `monto_max_emergente`)
- `requiere_documento_firmado`: BOOLEAN (default TRUE)

**Inversión:**
- `min_permanencia_meses`: meses mínimos de permanencia
- `min_ahorro`: ahorro mínimo requerido
- `penalidad_retiro_anticipado`: porcentaje de penalización por retiro anticipado

---

*Documento incremental — secciones 1 y 2 preservadas, secciones 3 y 4 añadidas*
