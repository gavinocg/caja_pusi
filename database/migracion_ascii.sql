-- =========================================================
-- Migración: Renombrar nombres con acentos/ñ a clean ASCII
-- =========================================================

START TRANSACTION;

SET FOREIGN_KEY_CHECKS = 0;

-- =========================================================
-- FASE 1: Actualizar datos ENUM (valores con acentos)
-- =========================================================

-- 1a) historial_operaciones.tipo_operación
UPDATE historial_operaciones SET tipo_operación = 'inversion_apertura' WHERE tipo_operación = 'inversión_apertura';
UPDATE historial_operaciones SET tipo_operación = 'inversion_retiro' WHERE tipo_operación = 'inversión_retiro';
UPDATE historial_operaciones SET tipo_operación = 'interes_ganado' WHERE tipo_operación = 'interés_ganado';
UPDATE historial_operaciones SET tipo_operación = 'interes_pagado' WHERE tipo_operación = 'interés_pagado';
UPDATE historial_operaciones SET tipo_operación = 'anulacion' WHERE tipo_operación = 'anulación';
UPDATE historial_operaciones SET tipo_operación = 'cierre_sesion' WHERE tipo_operación = 'cierre_sesión';
UPDATE historial_operaciones SET tipo_operación = 'desembolso_credito' WHERE tipo_operación = 'desembolso_crédito';

-- 1b) créditos.método_interés
UPDATE créditos SET método_interés = 'frances' WHERE método_interés = 'francés';
UPDATE créditos SET método_interés = 'aleman' WHERE método_interés = 'alemán';

-- 1c) productos_financieros.método_interés
UPDATE productos_financieros SET método_interés = 'frances' WHERE método_interés = 'francés';
UPDATE productos_financieros SET método_interés = 'aleman' WHERE método_interés = 'alemán';

-- 1d) parámetros.tipo
UPDATE parámetros SET tipo = 'numero' WHERE tipo = 'número';

-- =========================================================
-- FASE 2: Eliminar FKs que referencian tablas a renombrar
-- =========================================================

ALTER TABLE amortizaciones DROP FOREIGN KEY amortizaciones_ibfk_1;
ALTER TABLE garantes DROP FOREIGN KEY garantes_ibfk_1;

-- =========================================================
-- FASE 3: Renombrar TABLAS
-- =========================================================

RENAME TABLE créditos TO creditos;
RENAME TABLE parámetros TO parametros;
RENAME TABLE catastro_entidades_públicas TO catastro_entidades_publicas;

-- =========================================================
-- FASE 4: Renombrar COLUMNAS
-- =========================================================

-- amortizaciones
ALTER TABLE amortizaciones RENAME COLUMN id_amortización TO id_amortizacion;
ALTER TABLE amortizaciones RENAME COLUMN id_crédito TO id_credito;
ALTER TABLE amortizaciones RENAME COLUMN número_cuota TO numero_cuota;
ALTER TABLE amortizaciones RENAME COLUMN interés TO interes;

-- archivos
ALTER TABLE archivos RENAME COLUMN tamaño TO tamano;
ALTER TABLE archivos RENAME COLUMN extensión TO extension;

-- asistencias
ALTER TABLE asistencias RENAME COLUMN id_sesión TO id_sesion;
ALTER TABLE asistencias RENAME COLUMN justificación TO justificacion;
ALTER TABLE asistencias RENAME COLUMN justificación_pdf TO justificacion_pdf;
ALTER TABLE asistencias RENAME COLUMN justificación_aprobada TO justificacion_aprobada;

-- cantones
ALTER TABLE cantones RENAME COLUMN id_cantón TO id_canton;

-- catastro_entidades_publicas
ALTER TABLE catastro_entidades_publicas RENAME COLUMN razón_social TO razon_social;

-- cobros
ALTER TABLE cobros RENAME COLUMN id_sesión TO id_sesion;
ALTER TABLE cobros RENAME COLUMN motivo_anulación TO motivo_anulacion;
ALTER TABLE cobros RENAME COLUMN fecha_anulación TO fecha_anulacion;

-- creditos
ALTER TABLE creditos RENAME COLUMN id_crédito TO id_credito;
ALTER TABLE creditos RENAME COLUMN id_sesión_aprobación TO id_sesion_aprobacion;
ALTER TABLE creditos RENAME COLUMN tasa_interés TO tasa_interes;
ALTER TABLE creditos RENAME COLUMN método_interés TO metodo_interes;
ALTER TABLE creditos RENAME COLUMN acta_aprobación_pdf TO acta_aprobacion_pdf;
ALTER TABLE creditos RENAME COLUMN fecha_aprobación TO fecha_aprobacion;

-- cuentas_ahorro
ALTER TABLE cuentas_ahorro RENAME COLUMN fecha_último_movimiento TO fecha_ultimo_movimiento;

-- historial_operaciones
ALTER TABLE historial_operaciones RENAME COLUMN id_operación TO id_operacion;
ALTER TABLE historial_operaciones RENAME COLUMN tipo_operación TO tipo_operacion;
ALTER TABLE historial_operaciones RENAME COLUMN id_sesión TO id_sesion;

-- inversiones
ALTER TABLE inversiones RENAME COLUMN id_inversión TO id_inversion;
ALTER TABLE inversiones RENAME COLUMN tasa_interés TO tasa_interes;
ALTER TABLE inversiones RENAME COLUMN notificado_devolución TO notificado_devolucion;

-- multas
ALTER TABLE multas RENAME COLUMN id_sesión TO id_sesion;
ALTER TABLE multas RENAME COLUMN justificación TO justificacion;
ALTER TABLE multas RENAME COLUMN justificación_aprobada TO justificacion_aprobada;
ALTER TABLE multas RENAME COLUMN justificación_pdf TO justificacion_pdf;
ALTER TABLE multas RENAME COLUMN fecha_generación TO fecha_generacion;

-- notificaciones
ALTER TABLE notificaciones RENAME COLUMN id_notificación TO id_notificacion;
ALTER TABLE notificaciones RENAME COLUMN título TO titulo;
ALTER TABLE notificaciones RENAME COLUMN leída TO leida;
ALTER TABLE notificaciones RENAME COLUMN fecha_creación TO fecha_creacion;

-- parametros
ALTER TABLE parametros RENAME COLUMN id_parámetro TO id_parametro;
ALTER TABLE parametros RENAME COLUMN código TO codigo;
ALTER TABLE parametros RENAME COLUMN módulo TO modulo;

-- permisos
ALTER TABLE permisos RENAME COLUMN código TO codigo;
ALTER TABLE permisos RENAME COLUMN descripción TO descripcion;

-- productos_financieros
ALTER TABLE productos_financieros RENAME COLUMN tasa_interés_anual TO tasa_interes_anual;
ALTER TABLE productos_financieros RENAME COLUMN método_interés TO metodo_interes;
ALTER TABLE productos_financieros RENAME COLUMN plazo_mín_meses TO plazo_min_meses;
ALTER TABLE productos_financieros RENAME COLUMN plazo_máx_meses TO plazo_max_meses;
ALTER TABLE productos_financieros RENAME COLUMN monto_mín TO monto_min;
ALTER TABLE productos_financieros RENAME COLUMN monto_máx TO monto_max;
ALTER TABLE productos_financieros RENAME COLUMN fecha_creación TO fecha_creacion;

-- roles
ALTER TABLE roles RENAME COLUMN descripción TO descripcion;

-- sesiones_mensuales
ALTER TABLE sesiones_mensuales RENAME COLUMN id_sesión TO id_sesion;
ALTER TABLE sesiones_mensuales RENAME COLUMN número_sesión TO numero_sesion;
ALTER TABLE sesiones_mensuales RENAME COLUMN título TO titulo;

-- socios
ALTER TABLE socios RENAME COLUMN cédula TO cedula;
ALTER TABLE socios RENAME COLUMN género TO genero;
ALTER TABLE socios RENAME COLUMN dirección TO direccion;
ALTER TABLE socios RENAME COLUMN teléfono TO telefono;
ALTER TABLE socios RENAME COLUMN correo_electrónico TO correo_electronico;
ALTER TABLE socios RENAME COLUMN profesión TO profesion;
ALTER TABLE socios RENAME COLUMN fecha_aprobación TO fecha_aprobacion;
ALTER TABLE socios RENAME COLUMN número_acta_aprobación TO numero_acta_aprobacion;
ALTER TABLE socios RENAME COLUMN acta_aprobación_pdf TO acta_aprobacion_pdf;
ALTER TABLE socios RENAME COLUMN fecha_exclusión TO fecha_exclusion;
ALTER TABLE socios RENAME COLUMN motivo_exclusión TO motivo_exclusion;
ALTER TABLE socios RENAME COLUMN representante_cédula TO representante_cedula;
ALTER TABLE socios RENAME COLUMN representante_teléfono TO representante_telefono;
ALTER TABLE socios RENAME COLUMN fecha_creación TO fecha_creacion;

-- usuarios
ALTER TABLE usuarios RENAME COLUMN cédula TO cedula;
ALTER TABLE usuarios RENAME COLUMN correo_electrónico TO correo_electronico;
ALTER TABLE usuarios RENAME COLUMN teléfono TO telefono;
ALTER TABLE usuarios RENAME COLUMN contraseña TO contrasena;
ALTER TABLE usuarios RENAME COLUMN fecha_creación TO fecha_creacion;
ALTER TABLE usuarios RENAME COLUMN fecha_último_acceso TO fecha_ultimo_acceso;

-- =========================================================
-- FASE 5: Actualizar definiciones ENUM
-- =========================================================

ALTER TABLE historial_operaciones MODIFY COLUMN tipo_operacion ENUM(
    'aporte_obligatorio','aporte_excedente','retiro_ahorro',
    'desembolso_credito','pago_cuota','pago_multa',
    'inversion_apertura','inversion_retiro',
    'interes_ganado','interes_pagado',
    'cierre_sesion','anulacion'
) NOT NULL COMMENT 'Tipo de operacion financiera';

ALTER TABLE creditos MODIFY COLUMN metodo_interes ENUM('simple','frances','aleman') NOT NULL COMMENT 'Metodo de interes aplicado a este credito';

ALTER TABLE productos_financieros MODIFY COLUMN metodo_interes ENUM('simple','frances','aleman') DEFAULT 'simple' COMMENT 'Metodo de calculo de intereses';

ALTER TABLE parametros MODIFY COLUMN tipo ENUM('texto','numero','decimal','booleano','color') DEFAULT 'texto' COMMENT 'Tipo de dato del valor';

-- =========================================================
-- FASE 6: Recrear FKs con nombres limpios
-- =========================================================

ALTER TABLE amortizaciones ADD CONSTRAINT amortizaciones_ibfk_1 FOREIGN KEY (id_credito) REFERENCES creditos(id_credito);
ALTER TABLE garantes ADD CONSTRAINT garantes_ibfk_1 FOREIGN KEY (id_credito) REFERENCES creditos(id_credito);

-- =========================================================
-- FASE 7: Reactivar FK checks
-- =========================================================
SET FOREIGN_KEY_CHECKS = 1;

COMMIT;
