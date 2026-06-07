# AGENTS.md — Contexto del proyecto

## Proyecto
**Caja de Ahorro y Crédito Solidaria Familiar Pujota-Simbaña**
Sistema web MVC PHP 8.4 + MySQL 8 para gestión integral de una caja de ahorro.

## Stack
- PHP 8.4 MVC puro (Front Controller + Route Map)
- MySQL 8.4 InnoDB utf8mb4_unicode_ci
- Bootstrap 5.3.3 + icons
- PHPMailer v6.12 (SMTP)
- HTML print (`@media print`) para PDF/comprobantes
- Pusher vía HTTP API cURL (configurado app_id 2133656, key e61ecc32567775804dcc, cluster us2)
- Chart.js en dashboard

## Entorno
- Servidor: Laragon (Apache 2.4.62, PHP 8.4.12, MySQL 8.4.3)
- URL base: `http://localhost/caja/`
- Ruta raíz: `C:\laragon\www\caja\`
- Windows 11

## Estructura
```
caja/
├── index.php          # Front Controller + Route Map (~120 rutas)
├── .htaccess          # RewriteRule todo a index.php
├── basedatos/         # Dump MySQL (caja_ahorro_pujota.sql)
├── config/
│   ├── app.php        # Constantes globales
│   ├── database.php   # PDO singleton
│   ├── email.php      # SMTP (mail.titanix-ec.com:587)
│   └── pusher.php     # Credenciales Pusher
├── database/
│   ├── schema.sql     # 25 tablas (incl. archivos)
│   ├── seeds.sql      # 6 roles, 28 permisos, matriz, 20 parámetros
│   └── seed_admin.php # Admin user creator
├── app/
│   ├── controllers/   # 23 (BaseController + ArchivoController + 21 módulos)
│   ├── helpers/       # 12 helpers (+FileManager)
│   ├── models/        # 3 (BaseModel, Socio, Usuario)
│   └── views/         # ~60 vistas en 18 subdirectorios
│       └── layouts/   # header.php (sidebar bifurcado Socio/Admin) + footer.php
├── public/
│   └── assets/
│       ├── css/style.css
│       ├── js/app.js
│       └── images/
├── storage/
│   ├── archivos/      # Almacenamiento seguro FileManager (fuera de public/)
│   ├── documentos/    # HTML generados (comprobantes, actas, contratos)
│   ├── fotos/         # Fotos de socios
│   └── logs/
├── vendor/            # PHPMailer v6.12
├── composer.json
├── AGENTS.md
└── CHANGELOG.md
```

## Base de datos — 25 tablas (nombres clean ASCII)
archivos, usuarios, roles, permisos, roles_usuarios, roles_permisos, socios, sesiones_mensuales, asistencias, cuentas_ahorro, productos_financieros, creditos, amortizaciones, inversiones, cobros, multas, historial_operaciones, notificaciones, parametros, provincias, cantones, catastro_entidades_publicas, garantes, solicitudes_retiro

## RBAC
- **28 permisos** en 7 módulos
- **6 roles**: Administrador Técnico (solo técnico), Presidente, Analista Financiero (endosable=TRUE → hereda TODOS los permisos), Tesorero, Asistente Tesorería, Socio
- Roles endosables: si usuario tiene rol con endosable=TRUE, obtiene todos los permisos
- Sidebar bifurcado: usuarios con solo rol "Socio" ven menú simplificado (Inicio, Pagar, Solicitar, Inversión)

## Controladores (23)
Auth, Socio, Parametro, Usuario, Rol, Catalogo, Imagen, Producto, Sesion, Cobro, Calculo (CalculadoraInteres: Simple, Frances, Aleman), Credito, Inversion, Reporte, Dashboard, Documento, Notificacion, Portal, Multa, Retiro, Asistencia, Archivo

## Ayudantes (12)
UUIDGenerator, CedulaEcuador, Validator, Auth, RBAC, CSRFMiddleware, PDFGenerator, PusherHelper, NotificacionHelper, EmailHelper, CalculadoraInteres, **FileManager**

## Seguridad
- CSRF por sesión
- 2FA PIN 6 dígitos vía SMTP (PHPMailer)
- bcrypt en contraseñas
- Prepared statements (PDO)
- Bloqueo 3 intentos, timeout 30 min
- SHA-256 en historial_operaciones (inmodificable)
- Middleware requireAuth() en BaseController
- Archivos almacenados fuera de `public/` (storage/archivos/), servidos solo vía controlador autenticado

## Módulos implementados
- **Auth**: Login, 2FA PIN SMTP, logout, timeout, cambio contraseña (admin + portal)
- **Socios**: CRUD, búsqueda + paginación, cambio estado AJAX + acta PDF, subir foto/documentos, estado de cuenta PDF
- **Parámetros**: Listar + editar (inputs tipo-aware)
- **Usuarios**: CRUD con checkboxes roles, 2FA toggle, protege auto-eliminación
- **Roles**: CRUD + matriz permisos por módulo + endosable
- **Catálogos**: Provincias, cantones, entidades públicas
- **Imagen corporativa**: Logo + color picker, carga vía FileManager (logo_sidebar, logo_sd)
- **Productos financieros**: CRUD + toggle estado, formulario tipo-aware (crédito/inversión) con Summernote WYSIWYG
- **Sesiones y Cobros**: Abrir sesión, check-in, registro cobro AJAX, cierre con acta + multas automáticas + historial, anular cobro, pago cuota crédito
- **Cálculos**: Simulador 3 métodos, tabla amortización, excedentes + aprobar, intereses de ahorro mensuales
- **Créditos**: Solicitar (con garantes), ver, aprobar, desembolsar, rechazar, mora automática
- **Inversiones**: Apertura con contrato PDF, listar, retiro anticipado, cierre automático vencidas
- **Multas**: CRUD, justificar portal, aprobar/rechazar, marcar pagada
- **Asistencias**: Listar, justificar portal, aprobar/rechazar admin
- **Retiros de ahorro**: Solicitud portal → admin aprueba/rechaza/desembolsa (id_sesión nullable)
- **Garantes**: Tabla propia, selección multi-checkbox, validaciones
- **Dashboard**: Tarjetas, últimos cobros, Chart.js
- **Portal socio**: Inicio con cards resumen + Pagar (cards pendientes) + Solicitar (Crédito/Certificado) + Inversión
- **Certificados**: Página dedicada con cards (Estado cuenta, Constancia, Libre deuda) con botón Imprimir
- **Reportes**: Socios + CSV, financiero, cobros + CSV, morosidad, historial operaciones
- **Notificaciones**: Helper inserts, listar + marcar leídas, vista portal, polling 30s + Pusher
- **PDF/HTML**: Comprobantes cobro, actas cierre, constancias, libre deuda, estado cuenta, contrato inversión
- **FileManager**: Gestión centralizada de archivos con metadatos en BD y almacenamiento seguro
- **Notificaciones push**: Pusher HTTP API con HMAC-SHA256 + polling 30s fallback

## Sidebar
- **Admin**: Dashboard, Socios, Sesiones, Cobros, Asistencias, Retiros, Créditos, Inversiones, Productos, Cálculos, Reportes, Configuración (Parámetros/Imagen corporativa), Usuarios, Roles, Catálogos, Multas, Inicio, Contraseña, Salir
- **Socio** (solo rol Socio): Inicio, Pagar, Solicitar (Crédito/Certificado), Inversión — sin títulos, sin Dashboard/Contraseña/Salir. Toggle light-dark en footer del sidebar

## Responsive
- Sidebar colapsable con hamburguesa (transform translateX + overlay)
- 31 tablas con `table-responsive`
- Portal con `table-responsive-stack` (cards apiladas en móvil)
- Media queries en style.css

## Convenciones
- Nombres columnas en clean ASCII (sin acentos/ñ): cedula, correo_electronico, contrasena, etc.
- UUIDs como PK (`UUIDGenerator::generate()`)
- CONCAT_WS para nombres completos
- Ruteo híbrido: mapa explícito + fallback por convención
- Historial operaciones: `historialInsert()` en BaseController
- Roles endosables heredan todos los permisos
- Interés moratorio: `total * tasa * (días/30)` desde parámetro `multa_mora_credito`
- Interés ahorro: `saldo * tasa / 100 / 12`, acredita a `saldo_excedente`
- PHPMailer vía Composer
- Archivos siempre por FileManager (upload/serve/delete), nunca acceso directo
- Form POST controllers redirigen con flash; JSON solo para AJAX explícito

## Usuarios de prueba
- **admin** / admin123 — Admin Técnico (sin 2FA, sin permisos financieros)
- **1002606083** / Admin123 — Admin Técnico (sin 2FA, sin permisos financieros)
- **1002003000** / admin123 — Tesorero + Asistente Tesorería (para probar cobros y portal)
- Para probar todo el sistema: Analista Financiero (rol endosable) hereda todos los permisos

## Estado actual
- ~110 archivos PHP propios, 75 vendor (PHPMailer) = ~185 total
- 0 errores de sintaxis
- Todas las rutas HTTP funcionales (200/302/403 según permisos)
- Base de datos migrada a clean ASCII: ~65 columnas, 3 tablas, 6 ENUMs renombrados
- Productos financieros: formulario tipo-aware con Summernote WYSIWYG, secciones por tipo
- SMTP funcional con PHPMailer
- Pusher configurado con credenciales reales
- FileManager operativo con tabla archivos en BD
- Sidebar bifurcado: sidebar completo para admin, simplificado para Socio
- Portal socio con Inicio (cards resumen), Pagar, Solicitar (Crédito funcional / Certificado funcional), Inversión (placeholder)
- Dump MySQL en `basedatos/caja_ahorro_pujota.sql`

## Próximos pasos
- Población de datos de prueba (socios, sesiones, cobros, créditos, inversiones)
- Implementar página Inversión en portal socio
- Pruebas de integración end-to-end
- Despliegue a producción
