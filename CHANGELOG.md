# Changelog

## [Unreleased]

### Added
- Producto form: tipo-aware sections (crédito/inversión se muestran según tipo seleccionado)
- Summernote WYSIWYG reemplaza a Quill.js en formulario de productos

### Changed
- **Base de datos**: migración completa a clean ASCII (~65 columnas, 3 tablas, 6 ENUMs)
  - Tablas: `créditos`→`creditos`, `parámetros`→`parametros`, `catastro_entidades_públicas`→`catastro_entidades_publicas`
  - Columnas: `cédula`→`cedula`, `contraseña`→`contrasena`, `correo_electrónico`→`correo_electronico`, etc.
  - ENUMs: `'francés'`→`'frances'`, `'desembolso_crédito'`→`'desembolso_credito'`, `'unión_libre'`→`'union_libre'`, etc.
- Todos los archivos PHP actualizados con los nuevos nombres de columna/tabla
- `database/schema.sql` y `database/seeds.sql` sincronizados con la migración
- Formulario de producto refactorizado: campos organizados por secciones con separadores visuales
- `Penalidad retiro anticipado` movido a sección de inversión (solo aplica a inversiones)
- Controlador `ProductoController`: sanitización y validación tipo-aware

### Fixed
- Mojibake en `app/views/asistencias/listar.php` (`Ã‚¿`→`¿`)
- Quill.js causaba superposición de campos; reemplazado por Summernote (compatible con Bootstrap 5)
