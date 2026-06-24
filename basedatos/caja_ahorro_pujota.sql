-- phpMyAdmin SQL Dump
-- version 5.2.2
-- https://www.phpmyadmin.net/
--
-- Host: localhost:3306
-- Generation Time: Jun 24, 2026 at 10:00 PM
-- Server version: 8.4.3
-- PHP Version: 8.3.16

SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
START TRANSACTION;
SET time_zone = "+00:00";


/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8mb4 */;

--
-- Database: `caja_ahorro_pujota`
--

-- --------------------------------------------------------

--
-- Table structure for table `amortizaciones`
--

CREATE TABLE `amortizaciones` (
  `id_amortizacion` char(36) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL COMMENT 'Identificador único de la amortización (UUID)',
  `id_credito` char(36) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL COMMENT 'FK al crédito asociado',
  `numero_cuota` int NOT NULL COMMENT 'Número de cuota (1, 2, 3...)',
  `fecha_vencimiento` date NOT NULL COMMENT 'Fecha de vencimiento de la cuota',
  `capital` decimal(12,2) NOT NULL COMMENT 'Porción de capital de la cuota',
  `interes` decimal(12,2) NOT NULL COMMENT 'Porción de interés de la cuota',
  `total` decimal(12,2) NOT NULL COMMENT 'Total de la cuota (capital + interés)',
  `saldo_restante` decimal(12,2) NOT NULL COMMENT 'Saldo de capital pendiente después de esta cuota',
  `estado` enum('pendiente','pagada','vencida') CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT 'pendiente' COMMENT 'Estado de la cuota',
  `id_cobro` char(36) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL COMMENT 'FK al cobro cuando la cuota es pagada'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='Tabla de amortización de créditos — cuotas generadas según método de interés';

-- --------------------------------------------------------

--
-- Table structure for table `archivos`
--

CREATE TABLE `archivos` (
  `id_archivo` char(36) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL COMMENT 'Identificador único del archivo (UUID)',
  `nombre_original` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL COMMENT 'Nombre original del archivo subido',
  `nombre_archivo` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL COMMENT 'Nombre interno en disco (UUID + extensión)',
  `mime_type` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL COMMENT 'Tipo MIME del archivo',
  `tamano` bigint NOT NULL COMMENT 'Tamaño en bytes',
  `extension` varchar(10) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL COMMENT 'Extensión del archivo (pdf, jpg, png, etc)',
  `ruta` varchar(500) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL COMMENT 'Ruta relativa desde storage/archivos/',
  `hash_sha256` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL COMMENT 'SHA-256 del contenido del archivo',
  `entidad_tipo` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL COMMENT 'Nombre de la tabla o módulo asociado (socio, credito, multa, etc)',
  `entidad_id` char(36) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL COMMENT 'UUID del registro asociado en la entidad',
  `subdirectorio` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT 'general' COMMENT 'Subdirectorio dentro de storage/archivos/',
  `id_usuario_subio` char(36) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL COMMENT 'Usuario que subió el archivo',
  `fecha_subida` datetime DEFAULT CURRENT_TIMESTAMP COMMENT 'Fecha de subida del archivo'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='Gestión centralizada de archivos ? metadatos en BD, archivos fuera del public root';

-- --------------------------------------------------------

--
-- Table structure for table `asistencias`
--

CREATE TABLE `asistencias` (
  `id_asistencia` char(36) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL COMMENT 'Identificador único del registro de asistencia (UUID)',
  `id_socio` char(36) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL COMMENT 'FK al socio que asiste',
  `id_sesion` char(36) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL COMMENT 'FK a la sesión mensual',
  `tipo` enum('a_tiempo','retraso_10min','retraso_30min','falta') CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL COMMENT 'Tipo de asistencia registrada',
  `justificacion` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci COMMENT 'Justificación presentada por el socio (opcional)',
  `justificacion_pdf` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL COMMENT 'Archivo PDF de la justificación',
  `justificacion_aprobada` tinyint(1) DEFAULT '0' COMMENT 'Indica si la justificación fue aprobada',
  `usuario_registra` char(36) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL COMMENT 'Usuario que registró la asistencia',
  `fecha_registro` datetime DEFAULT CURRENT_TIMESTAMP COMMENT 'Fecha y hora del registro'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='Registro de asistencia a sesiones mensuales con tipo y justificación';

--
-- Dumping data for table `asistencias`
--

INSERT INTO `asistencias` (`id_asistencia`, `id_socio`, `id_sesion`, `tipo`, `justificacion`, `justificacion_pdf`, `justificacion_aprobada`, `usuario_registra`, `fecha_registro`) VALUES
('2da46248-7770-47f1-9f99-a5cf14beea34', '6819f961-b144-4c96-bbbd-8a0c0055cce1', '5c4f2b3f-1f3e-43f7-aacc-1ab8faa23ff6', 'a_tiempo', NULL, NULL, 0, '516363c5-c79a-4491-83b4-b8303ce1f286', '2026-06-24 16:10:42'),
('3747740b-a84e-4cad-9e87-6290fca387a7', '6819f961-b144-4c96-bbbd-8a0c0055cce1', 'a0c8e34d-3724-4b59-83a0-ea9a4daf3e54', 'retraso_10min', NULL, NULL, 0, '516363c5-c79a-4491-83b4-b8303ce1f286', '2026-06-24 16:15:01'),
('94bd12e8-e29a-4da3-b5e4-b87e66986b32', '6819f961-b144-4c96-bbbd-8a0c0055cce1', '3ae0cc43-1d87-4fb0-b281-023a38fca310', 'retraso_10min', NULL, NULL, 0, '516363c5-c79a-4491-83b4-b8303ce1f286', '2026-06-24 16:12:01');

-- --------------------------------------------------------

--
-- Table structure for table `caja_movimientos`
--

CREATE TABLE `caja_movimientos` (
  `id_movimiento` char(36) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL COMMENT 'Identificador unico del movimiento (UUID)',
  `id_sesion` char(36) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL COMMENT 'FK a la sesion donde ocurrio',
  `id_socio` char(36) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL COMMENT 'FK al socio relacionado',
  `id_referencia` char(36) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL COMMENT 'FK al cobro, credito, inversion, etc',
  `tipo_movimiento` enum('ingreso','egreso') CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL COMMENT 'Ingreso o egreso',
  `concepto` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL COMMENT 'Concepto descriptivo de la operacion',
  `categoria` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL COMMENT 'Categoria: aporte_obligatorio, multa, desembolso, etc',
  `monto` decimal(12,2) NOT NULL COMMENT 'Monto del movimiento',
  `saldo_anterior` decimal(12,2) NOT NULL COMMENT 'Saldo antes del movimiento',
  `saldo_posterior` decimal(12,2) NOT NULL COMMENT 'Saldo despues del movimiento',
  `fecha_registro` datetime DEFAULT CURRENT_TIMESTAMP COMMENT 'Fecha y hora del registro'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='Libro mayor de la Caja - estado de cuenta centralizado';

--
-- Dumping data for table `caja_movimientos`
--

INSERT INTO `caja_movimientos` (`id_movimiento`, `id_sesion`, `id_socio`, `id_referencia`, `tipo_movimiento`, `concepto`, `categoria`, `monto`, `saldo_anterior`, `saldo_posterior`, `fecha_registro`) VALUES
('44767387-e5ef-4042-b290-5cc3cb1924b3', 'a0c8e34d-3724-4b59-83a0-ea9a4daf3e54', '6819f961-b144-4c96-bbbd-8a0c0055cce1', '4e5070c3-8723-438f-ab38-d4c76f1e15b8', 'ingreso', 'Cuota mensual - 1002003000 - Sesion #3', 'aporte_obligatorio', 10.00, 0.00, 10.00, '2026-06-24 16:15:09'),
('6514bf56-a68d-4ac3-be2a-f39d19d73998', 'a0c8e34d-3724-4b59-83a0-ea9a4daf3e54', '6819f961-b144-4c96-bbbd-8a0c0055cce1', '69c5da7e-61f7-4d92-8287-c609e70ff925', 'ingreso', 'Cuota mensual - 1002003000 - Sesion #3', 'aporte_obligatorio', 10.00, 10.00, 20.00, '2026-06-24 16:15:10'),
('6ce5b7af-aa2b-4985-a8c8-628f3fd09de4', 'a0c8e34d-3724-4b59-83a0-ea9a4daf3e54', '6819f961-b144-4c96-bbbd-8a0c0055cce1', '52dd7c53-8144-4eeb-bf60-675e4ebd1de4', 'ingreso', 'Multa por cuota impaga - Sesion #2 del 31/07/2026 - pagada en Sesion #3', 'multa', 5.00, 36.00, 41.00, '2026-06-24 16:15:13'),
('85a92256-57ad-4180-b86a-902cc39f63f3', 'a0c8e34d-3724-4b59-83a0-ea9a4daf3e54', '6819f961-b144-4c96-bbbd-8a0c0055cce1', '0b87e295-782a-4087-ad50-8d92120bd7a3', 'ingreso', 'Multa por Retraso 10min - Sesion #2 del 31/07/2026 - pagada en Sesion #3', 'multa', 1.00, 35.00, 36.00, '2026-06-24 16:15:13'),
('a829cddd-939a-48de-a500-ba8ed09b6b3f', 'a0c8e34d-3724-4b59-83a0-ea9a4daf3e54', '6819f961-b144-4c96-bbbd-8a0c0055cce1', '23144773-d709-434a-b9e8-2a987fbdb6e0', 'ingreso', 'Multa por cuota impaga - Sesion #1 del 28/06/2026 - pagada en Sesion #3', 'multa', 5.00, 30.00, 35.00, '2026-06-24 16:15:12'),
('c94045ba-daa2-44fa-858e-aacd0ce608eb', NULL, '6819f961-b144-4c96-bbbd-8a0c0055cce1', 'dc33b964-aca3-4199-871c-0bfef901fda5', 'ingreso', 'Deposito capital inversion - PUJOTA  ELVIA ', 'deposito_capital_inversion', 500.00, 36.00, 536.00, '2026-06-24 16:21:43'),
('ccaa28d0-757c-4e16-af54-5143cd12bc87', 'a0c8e34d-3724-4b59-83a0-ea9a4daf3e54', '6819f961-b144-4c96-bbbd-8a0c0055cce1', '6493535f-c937-4d80-bbec-c537e7575770', 'ingreso', 'Cuota mensual - 1002003000 - Sesion #3', 'aporte_obligatorio', 10.00, 20.00, 30.00, '2026-06-24 16:15:11'),
('ef60d1df-ef1f-4478-9ffd-eef5774078f2', NULL, '6819f961-b144-4c96-bbbd-8a0c0055cce1', '68a0018a-20bb-4be9-9243-343791d4fc01', 'egreso', 'Retiro anticipado inversion portal', 'inversion_retiro', 500.00, 536.00, 36.00, '2026-06-24 16:55:12');

-- --------------------------------------------------------

--
-- Table structure for table `cantones`
--

CREATE TABLE `cantones` (
  `id_canton` int NOT NULL COMMENT 'Identificador numérico del cantón',
  `id_provincia` int NOT NULL COMMENT 'FK a la provincia',
  `nombre` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL COMMENT 'Nombre del cantón'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='Catálogo de cantones por provincia';

--
-- Dumping data for table `cantones`
--

INSERT INTO `cantones` (`id_canton`, `id_provincia`, `nombre`) VALUES
(1, 1, 'Pedro Moncayo');

-- --------------------------------------------------------

--
-- Table structure for table `capital_inversion`
--

CREATE TABLE `capital_inversion` (
  `id_capital_inversion` char(36) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL COMMENT 'Identificador unico del registro de capital de inversion (UUID)',
  `id_socio` char(36) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL COMMENT 'FK al socio',
  `saldo` decimal(12,2) DEFAULT '0.00' COMMENT 'Saldo disponible para invertir',
  `fecha_ultimo_movimiento` datetime DEFAULT NULL COMMENT 'Fecha del ultimo movimiento'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='Capital de inversion del socio - independiente de la cuenta de ahorro';

--
-- Dumping data for table `capital_inversion`
--

INSERT INTO `capital_inversion` (`id_capital_inversion`, `id_socio`, `saldo`, `fecha_ultimo_movimiento`) VALUES
('edacf383-d5ad-4fc9-856a-9474d6182bd5', '6819f961-b144-4c96-bbbd-8a0c0055cce1', 0.00, '2026-06-24 16:22:43');

-- --------------------------------------------------------

--
-- Table structure for table `catastro_entidades_publicas`
--

CREATE TABLE `catastro_entidades_publicas` (
  `id_entidad` int NOT NULL COMMENT 'Identificador numérico de la entidad',
  `ruc` varchar(13) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL COMMENT 'RUC de la entidad pública',
  `razon_social` varchar(200) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL COMMENT 'Razón social de la entidad'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='Catastro de entidades públicas para registro de socios';

-- --------------------------------------------------------

--
-- Table structure for table `cobros`
--

CREATE TABLE `cobros` (
  `id_cobro` char(36) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL COMMENT 'Identificador único del cobro (UUID)',
  `id_socio` char(36) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL COMMENT 'FK al socio que realiza el pago',
  `id_sesion` char(36) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL COMMENT 'FK a la sesión mensual donde se registra el cobro',
  `tipo` enum('aporte_obligatorio','aporte_excedente','cuota_credito','multa','inversion','interes','desembolso','otro','deposito_capital_inversion','retiro_inversion') CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `id_referencia` char(36) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL COMMENT 'ID de referencia según el tipo (id_amortización, id_multa, etc.)',
  `monto` decimal(12,2) NOT NULL COMMENT 'Monto cobrado',
  `medio_pago` enum('efectivo','transferencia','compensacion','digital') CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `comprobante_pdf` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL COMMENT 'Archivo PDF del comprobante de pago',
  `hash_integridad` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL COMMENT 'SHA-256 de integridad del registro',
  `usuario_registra` char(36) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL COMMENT 'Usuario que registró el cobro',
  `anulado` tinyint(1) DEFAULT '0' COMMENT 'Indica si el cobro fue anulado',
  `motivo_anulacion` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL COMMENT 'Motivo de la anulación',
  `fecha_anulacion` datetime DEFAULT NULL COMMENT 'Fecha de anulación',
  `usuario_anula` char(36) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL COMMENT 'Usuario que anuló el cobro',
  `fecha_registro` datetime DEFAULT CURRENT_TIMESTAMP COMMENT 'Fecha de registro del cobro'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='Registro de cobros — transacciones financieras diarias';

--
-- Dumping data for table `cobros`
--

INSERT INTO `cobros` (`id_cobro`, `id_socio`, `id_sesion`, `tipo`, `id_referencia`, `monto`, `medio_pago`, `comprobante_pdf`, `hash_integridad`, `usuario_registra`, `anulado`, `motivo_anulacion`, `fecha_anulacion`, `usuario_anula`, `fecha_registro`) VALUES
('0b87e295-782a-4087-ad50-8d92120bd7a3', '6819f961-b144-4c96-bbbd-8a0c0055cce1', 'a0c8e34d-3724-4b59-83a0-ea9a4daf3e54', 'multa', 'c0919a91-8f15-45e0-a1e5-51ef6f8f45db', 1.00, 'efectivo', NULL, '78fc9bb7d4ffb4624390e1d80aab3f93ad2f95a45655c6de3877a18ef04cb27b', '516363c5-c79a-4491-83b4-b8303ce1f286', 0, NULL, NULL, NULL, '2026-06-24 16:15:12'),
('23144773-d709-434a-b9e8-2a987fbdb6e0', '6819f961-b144-4c96-bbbd-8a0c0055cce1', 'a0c8e34d-3724-4b59-83a0-ea9a4daf3e54', 'multa', '4deb16df-f5ec-41d0-b8c5-fe59100d75a1', 5.00, 'efectivo', NULL, 'dbdb545d79163bec6e574ef6c3e03699a4be874254e31ab68e2400e3047ad1bf', '516363c5-c79a-4491-83b4-b8303ce1f286', 0, NULL, NULL, NULL, '2026-06-24 16:15:11'),
('4e5070c3-8723-438f-ab38-d4c76f1e15b8', '6819f961-b144-4c96-bbbd-8a0c0055cce1', 'a0c8e34d-3724-4b59-83a0-ea9a4daf3e54', 'aporte_obligatorio', NULL, 10.00, 'efectivo', NULL, '579773c7407568df717354fc8864f7cdeadefc58fc28cbac917f71ff44c3a3ab', '516363c5-c79a-4491-83b4-b8303ce1f286', 0, NULL, NULL, NULL, '2026-06-24 16:15:08'),
('52dd7c53-8144-4eeb-bf60-675e4ebd1de4', '6819f961-b144-4c96-bbbd-8a0c0055cce1', 'a0c8e34d-3724-4b59-83a0-ea9a4daf3e54', 'multa', 'b9dcdeef-0441-45b9-9fc6-8ca01408d9a0', 5.00, 'efectivo', NULL, '3c0ccc59b0506f94c1df76018f97bb904148c050eb0e20459e4dce580a0dfab2', '516363c5-c79a-4491-83b4-b8303ce1f286', 0, NULL, NULL, NULL, '2026-06-24 16:15:13'),
('6493535f-c937-4d80-bbec-c537e7575770', '6819f961-b144-4c96-bbbd-8a0c0055cce1', 'a0c8e34d-3724-4b59-83a0-ea9a4daf3e54', 'aporte_obligatorio', NULL, 10.00, 'efectivo', NULL, '22aafa515423d4932120a30ffb6e5f58147535b5dfce2d93dd2d9fc4613d03fa', '516363c5-c79a-4491-83b4-b8303ce1f286', 0, NULL, NULL, NULL, '2026-06-24 16:15:10'),
('69c5da7e-61f7-4d92-8287-c609e70ff925', '6819f961-b144-4c96-bbbd-8a0c0055cce1', 'a0c8e34d-3724-4b59-83a0-ea9a4daf3e54', 'aporte_obligatorio', NULL, 10.00, 'efectivo', NULL, 'c51a23d16ab7b24562442540640215bae2e032eb5ac7c482c1517774d86a1842', '516363c5-c79a-4491-83b4-b8303ce1f286', 0, NULL, NULL, NULL, '2026-06-24 16:15:09'),
('6c598538-65f6-4cff-9b2a-62b0970596d4', '6819f961-b144-4c96-bbbd-8a0c0055cce1', 'a0c8e34d-3724-4b59-83a0-ea9a4daf3e54', 'retiro_inversion', '68a0018a-20bb-4be9-9243-343791d4fc01', 500.00, 'efectivo', NULL, '56252301a21f641b7c4b5f2af45df607d5282efacebe4279635131f902fbb590', '1673019a-c66d-4bb8-9158-1729fa6b064a', 0, NULL, NULL, NULL, '2026-06-24 16:55:10'),
('dc33b964-aca3-4199-871c-0bfef901fda5', '6819f961-b144-4c96-bbbd-8a0c0055cce1', 'a0c8e34d-3724-4b59-83a0-ea9a4daf3e54', 'deposito_capital_inversion', NULL, 500.00, 'efectivo', NULL, '1307ff97207b17413525d07b0b20832e02228f8842c548608946cc886638a234', '516363c5-c79a-4491-83b4-b8303ce1f286', 0, NULL, NULL, NULL, '2026-06-24 16:21:42');

-- --------------------------------------------------------

--
-- Table structure for table `creditos`
--

CREATE TABLE `creditos` (
  `id_credito` char(36) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL COMMENT 'Identificador único del crédito (UUID)',
  `id_socio` char(36) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL COMMENT 'FK al socio solicitante',
  `id_producto` char(36) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL COMMENT 'FK al producto financiero asociado',
  `id_sesion_aprobacion` char(36) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL COMMENT 'FK a la sesión donde se aprobó el crédito',
  `monto_solicitado` decimal(12,2) NOT NULL COMMENT 'Monto solicitado por el socio',
  `monto_aprobado` decimal(12,2) DEFAULT NULL COMMENT 'Monto aprobado por la Asamblea',
  `plazo_meses` int NOT NULL COMMENT 'Plazo del crédito en meses',
  `tasa_interes` decimal(5,2) NOT NULL COMMENT 'Tasa de interés anual aplicada',
  `metodo_interes` enum('simple','frances','aleman') CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL COMMENT 'Metodo de interes aplicado a este credito',
  `destino` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci COMMENT 'Destino o propósito del crédito',
  `estado` enum('ingresado','pendiente','aprobado','legalizado','desembolsado','rechazado','cancelado') CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'ingresado' COMMENT 'Estado actual de la solicitud de credito',
  `acta_aprobacion_pdf` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL COMMENT 'Archivo PDF del acta de aprobación',
  `fecha_solicitud` datetime DEFAULT CURRENT_TIMESTAMP COMMENT 'Fecha de solicitud del crédito',
  `fecha_aprobacion` datetime DEFAULT NULL COMMENT 'Fecha de aprobación',
  `fecha_desembolso` datetime DEFAULT NULL COMMENT 'Fecha de desembolso del crédito',
  `usuario_aprueba` char(36) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL COMMENT 'Usuario que aprobó el crédito',
  `justificacion` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci COMMENT 'Justificacion de rechazo o puesta en espera'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='Solicitudes y desembolsos de créditos de los socios';

-- --------------------------------------------------------

--
-- Table structure for table `cuentas_ahorro`
--

CREATE TABLE `cuentas_ahorro` (
  `id_cuenta_ahorro` char(36) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL COMMENT 'Identificador único de la cuenta de ahorro (UUID)',
  `id_socio` char(36) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL COMMENT 'FK al socio propietario de la cuenta',
  `saldo_obligatorio` decimal(12,2) DEFAULT '0.00' COMMENT 'Saldo del aporte obligatorio (USD 10/mes)',
  `saldo_excedente` decimal(12,2) DEFAULT '0.00' COMMENT 'Saldo de aportes voluntarios/excedentes',
  `saldo_disponible` decimal(12,2) DEFAULT '0.00' COMMENT 'Saldo total disponible para retiro según reglas',
  `fecha_ultimo_movimiento` datetime DEFAULT NULL COMMENT 'Fecha del último movimiento registrado'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='Cuentas de ahorro de los socios — capital separado de inversiones';

--
-- Dumping data for table `cuentas_ahorro`
--

INSERT INTO `cuentas_ahorro` (`id_cuenta_ahorro`, `id_socio`, `saldo_obligatorio`, `saldo_excedente`, `saldo_disponible`, `fecha_ultimo_movimiento`) VALUES
('d3496eee-37e8-46b2-8bbf-c4180a07f54d', '6819f961-b144-4c96-bbbd-8a0c0055cce1', 30.00, 0.00, 30.00, '2026-06-24 16:15:10');

-- --------------------------------------------------------

--
-- Table structure for table `garantes`
--

CREATE TABLE `garantes` (
  `id_garante` char(36) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL COMMENT 'UUID del garante',
  `id_credito` char(36) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL COMMENT 'FK al crédito',
  `id_socio` char(36) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL COMMENT 'FK al socio garante',
  `tipo_garante` enum('fiador_solidario','prendario','hipotecario') CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT 'fiador_solidario' COMMENT 'Tipo de garantía',
  `monto_garantizado` decimal(12,2) NOT NULL DEFAULT '0.00' COMMENT 'Monto garantizado',
  `fecha_registro` datetime DEFAULT CURRENT_TIMESTAMP COMMENT 'Fecha de registro'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='Garantes de créditos';

-- --------------------------------------------------------

--
-- Table structure for table `historial_operaciones`
--

CREATE TABLE `historial_operaciones` (
  `id_operacion` char(36) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL COMMENT 'Identificador único de la operación (UUID)',
  `id_socio` char(36) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL COMMENT 'FK al socio asociado a la operación',
  `tipo_operacion` enum('aporte_obligatorio','aporte_excedente','retiro_ahorro','desembolso_credito','pago_cuota','pago_multa','inversion_apertura','inversion_retiro','interes_ganado','interes_pagado','cierre_sesion','anulacion','deposito_capital_inversion') CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `monto` decimal(12,2) NOT NULL COMMENT 'Monto de la operación',
  `saldo_anterior` decimal(12,2) DEFAULT NULL COMMENT 'Saldo anterior a la operación',
  `saldo_posterior` decimal(12,2) DEFAULT NULL COMMENT 'Saldo posterior a la operación',
  `id_referencia` char(36) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL COMMENT 'ID de referencia a la entidad origen',
  `id_sesion` char(36) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL COMMENT 'FK a la sesión mensual',
  `id_usuario_registra` char(36) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL COMMENT 'Usuario que registró la operación',
  `comprobante_pdf` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL COMMENT 'Archivo PDF del comprobante',
  `hash_integridad` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL COMMENT 'SHA-256 de integridad del registro (inmodificable)',
  `ip_registro` varchar(45) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL COMMENT 'Dirección IP desde donde se registró la operación',
  `fecha_registro` datetime DEFAULT CURRENT_TIMESTAMP COMMENT 'Fecha y hora del registro'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='Historial inmodificable de operaciones financieras — solo inserción, sin DELETE/UPDATE';

--
-- Dumping data for table `historial_operaciones`
--

INSERT INTO `historial_operaciones` (`id_operacion`, `id_socio`, `tipo_operacion`, `monto`, `saldo_anterior`, `saldo_posterior`, `id_referencia`, `id_sesion`, `id_usuario_registra`, `comprobante_pdf`, `hash_integridad`, `ip_registro`, `fecha_registro`) VALUES
('01972f7a-6b0d-4537-9124-b7ae2f8737e1', '6819f961-b144-4c96-bbbd-8a0c0055cce1', 'aporte_obligatorio', 10.00, NULL, NULL, '69c5da7e-61f7-4d92-8287-c609e70ff925', 'a0c8e34d-3724-4b59-83a0-ea9a4daf3e54', '516363c5-c79a-4491-83b4-b8303ce1f286', NULL, NULL, '::1', '2026-06-24 16:15:09'),
('276cbba1-4182-445e-ab29-2bfaeb95b835', '6819f961-b144-4c96-bbbd-8a0c0055cce1', 'aporte_obligatorio', 10.00, NULL, NULL, '4e5070c3-8723-438f-ab38-d4c76f1e15b8', 'a0c8e34d-3724-4b59-83a0-ea9a4daf3e54', '516363c5-c79a-4491-83b4-b8303ce1f286', NULL, NULL, '::1', '2026-06-24 16:15:08'),
('2deb93f0-05d7-429f-a570-a9f473d2e3fb', '6819f961-b144-4c96-bbbd-8a0c0055cce1', 'inversion_retiro', 500.00, NULL, NULL, '68a0018a-20bb-4be9-9243-343791d4fc01', NULL, '1673019a-c66d-4bb8-9158-1729fa6b064a', NULL, NULL, '::1', '2026-06-24 16:55:11'),
('45c00f8d-500b-4536-9994-ede356b2979d', '6819f961-b144-4c96-bbbd-8a0c0055cce1', 'pago_multa', 5.00, NULL, NULL, '52dd7c53-8144-4eeb-bf60-675e4ebd1de4', 'a0c8e34d-3724-4b59-83a0-ea9a4daf3e54', '516363c5-c79a-4491-83b4-b8303ce1f286', NULL, NULL, '::1', '2026-06-24 16:15:13'),
('86aac4b2-2288-4a8a-b9af-f165c80bfe23', '6819f961-b144-4c96-bbbd-8a0c0055cce1', 'pago_multa', 1.00, NULL, NULL, '0b87e295-782a-4087-ad50-8d92120bd7a3', 'a0c8e34d-3724-4b59-83a0-ea9a4daf3e54', '516363c5-c79a-4491-83b4-b8303ce1f286', NULL, NULL, '::1', '2026-06-24 16:15:12'),
('8c99d469-9a56-4e3b-94d7-83ba33ad589e', '6819f961-b144-4c96-bbbd-8a0c0055cce1', 'inversion_apertura', 500.00, NULL, NULL, '68a0018a-20bb-4be9-9243-343791d4fc01', NULL, '516363c5-c79a-4491-83b4-b8303ce1f286', NULL, NULL, '::1', '2026-06-24 16:22:43'),
('9d229eb2-678f-414d-8cfc-e76057c3e19e', '6819f961-b144-4c96-bbbd-8a0c0055cce1', 'deposito_capital_inversion', 500.00, NULL, NULL, 'dc33b964-aca3-4199-871c-0bfef901fda5', 'a0c8e34d-3724-4b59-83a0-ea9a4daf3e54', '516363c5-c79a-4491-83b4-b8303ce1f286', NULL, NULL, '::1', '2026-06-24 16:21:42'),
('c34cfa04-4e0c-4bb3-91da-018cf9e3c1a3', '6819f961-b144-4c96-bbbd-8a0c0055cce1', 'pago_multa', 5.00, NULL, NULL, '23144773-d709-434a-b9e8-2a987fbdb6e0', 'a0c8e34d-3724-4b59-83a0-ea9a4daf3e54', '516363c5-c79a-4491-83b4-b8303ce1f286', NULL, NULL, '::1', '2026-06-24 16:15:11'),
('c53e9b02-89ed-4116-8d6e-bf987e5c46de', '6819f961-b144-4c96-bbbd-8a0c0055cce1', 'aporte_obligatorio', 10.00, NULL, NULL, '6493535f-c937-4d80-bbec-c537e7575770', 'a0c8e34d-3724-4b59-83a0-ea9a4daf3e54', '516363c5-c79a-4491-83b4-b8303ce1f286', NULL, NULL, '::1', '2026-06-24 16:15:10');

-- --------------------------------------------------------

--
-- Table structure for table `inversiones`
--

CREATE TABLE `inversiones` (
  `id_inversion` char(36) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL COMMENT 'Identificador único de la inversión (UUID)',
  `id_socio` char(36) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL COMMENT 'FK al socio inversionista',
  `id_producto` char(36) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL COMMENT 'FK al producto de inversión',
  `monto` decimal(12,2) NOT NULL COMMENT 'Monto invertido',
  `plazo_meses` int NOT NULL COMMENT 'Plazo de la inversión en meses',
  `tasa_interes` decimal(5,2) NOT NULL COMMENT 'Tasa de interés anual aplicada',
  `fecha_inicio` date NOT NULL COMMENT 'Fecha de inicio de la inversión',
  `fecha_vencimiento` date NOT NULL COMMENT 'Fecha de vencimiento',
  `rendimiento_proyectado` decimal(12,2) DEFAULT NULL COMMENT 'Rendimiento proyectado al vencimiento',
  `destino_final` enum('capital_inversion','efectivo','transferencia') CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'capital_inversion',
  `estado` enum('pendiente','activa','vencida','retiro_anticipado','cancelada','rechazada') CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'pendiente',
  `notificado_devolucion` tinyint(1) DEFAULT '0' COMMENT 'Indica si se notificó la próxima devolución',
  `contrato_pdf` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL COMMENT 'Archivo PDF del contrato de inversión',
  `fecha_registro` datetime DEFAULT CURRENT_TIMESTAMP COMMENT 'Fecha de registro de la inversión'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='Inversiones a plazo fijo de los socios — capital separado de cuenta de ahorro';

--
-- Dumping data for table `inversiones`
--

INSERT INTO `inversiones` (`id_inversion`, `id_socio`, `id_producto`, `monto`, `plazo_meses`, `tasa_interes`, `fecha_inicio`, `fecha_vencimiento`, `rendimiento_proyectado`, `destino_final`, `estado`, `notificado_devolucion`, `contrato_pdf`, `fecha_registro`) VALUES
('68a0018a-20bb-4be9-9243-343791d4fc01', '6819f961-b144-4c96-bbbd-8a0c0055cce1', '2e4c5dbd-afa8-424e-9367-6687ad3c4490', 500.00, 3, 6.00, '2026-06-24', '2026-09-24', 7.50, 'efectivo', 'retiro_anticipado', 0, NULL, '2026-06-24 16:22:14');

-- --------------------------------------------------------

--
-- Table structure for table `multas`
--

CREATE TABLE `multas` (
  `id_multa` char(36) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL COMMENT 'Identificador único de la multa (UUID)',
  `id_socio` char(36) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL COMMENT 'FK al socio multado',
  `id_sesion` char(36) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL COMMENT 'FK a la sesión donde se generó la multa',
  `tipo` enum('retraso_10min','retraso_30min','inasistencia','mora_credito','cuota_impaga','otro') COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'otro',
  `monto` decimal(10,2) NOT NULL COMMENT 'Monto de la multa en USD',
  `justificacion` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci COMMENT 'Justificación presentada por el socio',
  `justificacion_aprobada` tinyint(1) DEFAULT '0' COMMENT 'Indica si la justificación fue aprobada',
  `justificacion_pdf` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL COMMENT 'Archivo PDF de la justificación',
  `observacion` text COLLATE utf8mb4_unicode_ci,
  `pagada` tinyint(1) DEFAULT '0' COMMENT 'Indica si la multa fue pagada',
  `estado` enum('activa','en_impugnacion','impugnada','anulada') COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'activa',
  `fecha_pago` datetime DEFAULT NULL COMMENT 'Fecha de pago de la multa',
  `id_cobro` char(36) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL COMMENT 'FK al cobro cuando la multa es pagada',
  `fecha_generacion` datetime DEFAULT CURRENT_TIMESTAMP COMMENT 'Fecha de generación de la multa'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='Multas generadas por inasistencia, retraso o mora — base legal Art.11 Estatuto';

--
-- Dumping data for table `multas`
--

INSERT INTO `multas` (`id_multa`, `id_socio`, `id_sesion`, `tipo`, `monto`, `justificacion`, `justificacion_aprobada`, `justificacion_pdf`, `observacion`, `pagada`, `estado`, `fecha_pago`, `id_cobro`, `fecha_generacion`) VALUES
('2d547cb7-2692-41f6-863c-a8cb8ab96992', '6819f961-b144-4c96-bbbd-8a0c0055cce1', 'a0c8e34d-3724-4b59-83a0-ea9a4daf3e54', 'retraso_10min', 1.00, 'No me atrasé pendejo.', 1, NULL, 'Ok bestia.', 0, 'impugnada', NULL, NULL, '2026-06-24 16:15:50'),
('4deb16df-f5ec-41d0-b8c5-fe59100d75a1', '6819f961-b144-4c96-bbbd-8a0c0055cce1', '5c4f2b3f-1f3e-43f7-aacc-1ab8faa23ff6', 'cuota_impaga', 5.00, NULL, 0, NULL, NULL, 0, 'activa', NULL, NULL, '2026-06-24 16:10:46'),
('b9dcdeef-0441-45b9-9fc6-8ca01408d9a0', '6819f961-b144-4c96-bbbd-8a0c0055cce1', '3ae0cc43-1d87-4fb0-b281-023a38fca310', 'cuota_impaga', 5.00, NULL, 0, NULL, NULL, 0, 'activa', NULL, NULL, '2026-06-24 16:14:18'),
('c0919a91-8f15-45e0-a1e5-51ef6f8f45db', '6819f961-b144-4c96-bbbd-8a0c0055cce1', '3ae0cc43-1d87-4fb0-b281-023a38fca310', 'retraso_10min', 1.00, NULL, 0, NULL, NULL, 0, 'activa', NULL, NULL, '2026-06-24 16:12:01');

-- --------------------------------------------------------

--
-- Table structure for table `notificaciones`
--

CREATE TABLE `notificaciones` (
  `id_notificacion` char(36) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL COMMENT 'Identificador único de la notificación (UUID)',
  `id_usuario` char(36) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL COMMENT 'FK al usuario destinatario (si es administrativo)',
  `id_socio` char(36) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL COMMENT 'FK al socio destinatario (si es socio)',
  `tipo` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL COMMENT 'Tipo de notificación (ej: cobro, crédito, multa)',
  `titulo` varchar(200) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL COMMENT 'Título de la notificación',
  `mensaje` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL COMMENT 'Cuerpo del mensaje',
  `leida` tinyint(1) DEFAULT '0' COMMENT 'Indica si el destinatario leyó la notificación',
  `buzon` enum('entrada','archivadas','papelera') CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT 'entrada' COMMENT 'Buzon donde se encuentra la notificacion',
  `enviada_pusher` tinyint(1) DEFAULT '0' COMMENT 'Indica si ya se envió por Pusher',
  `fecha_creacion` datetime DEFAULT CURRENT_TIMESTAMP COMMENT 'Fecha de creación de la notificación',
  `fecha_lectura` datetime DEFAULT NULL COMMENT 'Fecha en que se leyó la notificación',
  `fecha_eliminacion` datetime DEFAULT NULL COMMENT 'Fecha de eliminacion (movida a papelera)'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='Buzón de notificaciones persistido en BD + envío en tiempo real por Pusher';

--
-- Dumping data for table `notificaciones`
--

INSERT INTO `notificaciones` (`id_notificacion`, `id_usuario`, `id_socio`, `tipo`, `titulo`, `mensaje`, `leida`, `buzon`, `enviada_pusher`, `fecha_creacion`, `fecha_lectura`, `fecha_eliminacion`) VALUES
('14219543-7f74-4925-b3fc-cb33660c7a53', 'ce86e169-fa0a-468d-bb04-ca7b8c7a5291', NULL, 'sesion', 'Sesion #2 cerrada', 'La sesion #2 ha sido cerrada. Total recaudado: $0.00', 0, 'entrada', 1, '2026-06-24 16:14:19', NULL, NULL),
('3e222ff0-a7a1-4b02-b3a2-f8d0dd184e56', NULL, '6819f961-b144-4c96-bbbd-8a0c0055cce1', 'multa', 'Impugnacion aprobada', 'Su impugnacion ha sido aprobada. La multa queda sin efecto. Observacion: Ok bestia.', 1, 'entrada', 1, '2026-06-24 16:16:26', '2026-06-24 16:24:00', NULL),
('56b415b7-63e7-4d86-b7b2-0846e0188632', NULL, '6819f961-b144-4c96-bbbd-8a0c0055cce1', 'inversion', 'Inversion retiro anticipado', 'Inversion de $500 para PUJOTA  ELVIA  ha sido retiro anticipado', 1, 'entrada', 1, '2026-06-24 16:55:11', '2026-06-24 16:56:16', NULL),
('6d08674c-957c-43eb-8cf6-99f0bd21112d', NULL, '6819f961-b144-4c96-bbbd-8a0c0055cce1', 'multa', 'Multa generada', 'Se ha generado una multa por Retraso 10min de $1 en la sesion #3 para el socio 1002003000', 1, 'entrada', 1, '2026-06-24 16:15:50', '2026-06-24 16:16:51', NULL),
('b2867bf2-4186-4b77-8f09-b7e6f23a5d8a', NULL, '6819f961-b144-4c96-bbbd-8a0c0055cce1', 'inversion', 'Deposito a capital de inversion', 'Deposito de $500 a capital de inversion de PUJOTA  ELVIA ', 1, 'entrada', 1, '2026-06-24 16:21:42', '2026-06-24 16:21:49', NULL),
('c170975d-36e5-4d09-ad5d-58be1147196b', 'ce86e169-fa0a-468d-bb04-ca7b8c7a5291', NULL, 'sesion', 'INVITACION', 'Sesión Ordinaria Julio 2026 (ordinaria), a realizarse el 31/07/2026 a las 19:00.', 0, 'entrada', 0, '2026-06-24 16:11:09', NULL, NULL),
('e2c57898-b0e0-43b4-92d9-66862842229f', NULL, '6819f961-b144-4c96-bbbd-8a0c0055cce1', 'inversion', 'Inversion solicitada', 'Inversion de $500 para PUJOTA  ELVIA  ha sido solicitada', 1, 'entrada', 1, '2026-06-24 16:22:14', '2026-06-24 16:23:58', NULL),
('e670153b-5f81-4719-9597-d228e1c88b66', 'ce86e169-fa0a-468d-bb04-ca7b8c7a5291', NULL, 'sesion', 'Sesion #1 cerrada', 'La sesion #1 ha sido cerrada. Total recaudado: $0.00', 0, 'entrada', 1, '2026-06-24 16:10:47', NULL, NULL),
('e98302f9-3e3e-47f0-a82e-4a388c86ce6b', NULL, '6819f961-b144-4c96-bbbd-8a0c0055cce1', 'inversion', 'Inversion aprobada', 'Inversion de $500.00 para PUJOTA  ELVIA  ha sido aprobada', 1, 'entrada', 1, '2026-06-24 16:22:43', '2026-06-24 16:24:01', NULL),
('ff48c6fc-5285-4dcf-8f0f-41028e7a5214', 'ce86e169-fa0a-468d-bb04-ca7b8c7a5291', NULL, 'sesion', 'INVITACION', 'Sesión Ordinaria Agosto 2026 (ordinaria), a realizarse el 31/08/2026 a las 19:00.', 0, 'entrada', 0, '2026-06-24 16:14:41', NULL, NULL);

-- --------------------------------------------------------

--
-- Table structure for table `obligaciones_sesion`
--

CREATE TABLE `obligaciones_sesion` (
  `id_obligacion` char(36) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL COMMENT 'Identificador unico de la obligacion (UUID)',
  `id_sesion` char(36) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL COMMENT 'FK a la sesion donde se genero',
  `id_socio` char(36) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL COMMENT 'FK al socio',
  `tipo` enum('cuota_mensual','cuota_credito','multa','otro') CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL COMMENT 'Tipo de obligacion',
  `concepto` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL COMMENT 'Descripcion detallada de la obligacion',
  `monto` decimal(12,2) NOT NULL COMMENT 'Monto a pagar',
  `id_referencia` char(36) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL COMMENT 'FK a amortizacion, multa, etc',
  `pagada` tinyint(1) DEFAULT '0' COMMENT 'Indica si ya fue pagada',
  `id_cobro` char(36) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL COMMENT 'FK al cobro cuando se paga',
  `fecha_registro` datetime DEFAULT CURRENT_TIMESTAMP COMMENT 'Fecha de creacion'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='Obligaciones de pago generadas al abrir una sesion - calculadas segun fecha de reunion';

--
-- Dumping data for table `obligaciones_sesion`
--

INSERT INTO `obligaciones_sesion` (`id_obligacion`, `id_sesion`, `id_socio`, `tipo`, `concepto`, `monto`, `id_referencia`, `pagada`, `id_cobro`, `fecha_registro`) VALUES
('0511b14b-ed5c-4fc5-b4c0-50d54720bd51', 'a0c8e34d-3724-4b59-83a0-ea9a4daf3e54', '6819f961-b144-4c96-bbbd-8a0c0055cce1', 'multa', 'Multa por Cuota impaga - Sesion #1 del 28/06/2026', 5.00, '4deb16df-f5ec-41d0-b8c5-fe59100d75a1', 1, '23144773-d709-434a-b9e8-2a987fbdb6e0', '2026-06-24 16:14:43'),
('0acaae9a-3509-4ce0-95db-bfc279e97b5e', '5c4f2b3f-1f3e-43f7-aacc-1ab8faa23ff6', '6819f961-b144-4c96-bbbd-8a0c0055cce1', 'cuota_mensual', 'Cuota mensual - Sesion #1 del 28/06/2026', 10.00, NULL, 1, '4e5070c3-8723-438f-ab38-d4c76f1e15b8', '2026-06-24 16:08:03'),
('4d147009-4a5b-4d5f-8e07-561ef3050655', 'a0c8e34d-3724-4b59-83a0-ea9a4daf3e54', '6819f961-b144-4c96-bbbd-8a0c0055cce1', 'multa', 'Multa por Retraso 10min - Sesion #3 del 31/08/2026', 1.00, '2d547cb7-2692-41f6-863c-a8cb8ab96992', 1, NULL, '2026-06-24 16:15:50'),
('644a4826-dd47-4dec-8be8-c78c9102dd65', 'a0c8e34d-3724-4b59-83a0-ea9a4daf3e54', '6819f961-b144-4c96-bbbd-8a0c0055cce1', 'multa', 'Multa por Cuota impaga - Sesion #2 del 31/07/2026', 5.00, 'b9dcdeef-0441-45b9-9fc6-8ca01408d9a0', 1, '52dd7c53-8144-4eeb-bf60-675e4ebd1de4', '2026-06-24 16:14:43'),
('7da5c079-31da-4dbd-85a7-c73b6bf497ad', '3ae0cc43-1d87-4fb0-b281-023a38fca310', '6819f961-b144-4c96-bbbd-8a0c0055cce1', 'cuota_mensual', 'Cuota mensual - Sesion #2 del 31/07/2026', 10.00, NULL, 1, '69c5da7e-61f7-4d92-8287-c609e70ff925', '2026-06-24 16:11:10'),
('a42d0306-a29f-4f07-9ff1-8f63c7fe0767', '5c4f2b3f-1f3e-43f7-aacc-1ab8faa23ff6', '6819f961-b144-4c96-bbbd-8a0c0055cce1', 'multa', 'Multa por cuota impaga - Sesion #1 del 28/06/2026', 5.00, '4deb16df-f5ec-41d0-b8c5-fe59100d75a1', 1, '23144773-d709-434a-b9e8-2a987fbdb6e0', '2026-06-24 16:10:46'),
('af82ba13-5993-4085-bd49-e12bd0d62931', '3ae0cc43-1d87-4fb0-b281-023a38fca310', '6819f961-b144-4c96-bbbd-8a0c0055cce1', 'multa', 'Multa por cuota impaga - Sesion #2 del 31/07/2026', 5.00, 'b9dcdeef-0441-45b9-9fc6-8ca01408d9a0', 1, '52dd7c53-8144-4eeb-bf60-675e4ebd1de4', '2026-06-24 16:14:18'),
('b4ba0e90-2a8f-4c87-b2c6-467663e262fd', '3ae0cc43-1d87-4fb0-b281-023a38fca310', '6819f961-b144-4c96-bbbd-8a0c0055cce1', 'multa', 'Multa por Retraso 10min - Sesion #2 del 31/07/2026', 1.00, 'c0919a91-8f15-45e0-a1e5-51ef6f8f45db', 1, '0b87e295-782a-4087-ad50-8d92120bd7a3', '2026-06-24 16:12:01'),
('bba07add-9299-44c5-aa5f-a76b63014a8b', 'a0c8e34d-3724-4b59-83a0-ea9a4daf3e54', '6819f961-b144-4c96-bbbd-8a0c0055cce1', 'cuota_mensual', 'Cuota mensual - Sesion #3 del 31/08/2026', 10.00, NULL, 1, '6493535f-c937-4d80-bbec-c537e7575770', '2026-06-24 16:14:43'),
('db3128dc-c4a1-419c-80b9-d5e7d847d50c', '3ae0cc43-1d87-4fb0-b281-023a38fca310', '6819f961-b144-4c96-bbbd-8a0c0055cce1', 'multa', 'Multa por Cuota impaga - Sesion #1 del 28/06/2026', 5.00, '4deb16df-f5ec-41d0-b8c5-fe59100d75a1', 1, '23144773-d709-434a-b9e8-2a987fbdb6e0', '2026-06-24 16:11:10'),
('e4bc0b86-3000-47e6-ac22-fec0f8ec0bf6', 'a0c8e34d-3724-4b59-83a0-ea9a4daf3e54', '6819f961-b144-4c96-bbbd-8a0c0055cce1', 'multa', 'Multa por Retraso 10min - Sesion #2 del 31/07/2026', 1.00, 'c0919a91-8f15-45e0-a1e5-51ef6f8f45db', 1, '0b87e295-782a-4087-ad50-8d92120bd7a3', '2026-06-24 16:14:43');

-- --------------------------------------------------------

--
-- Table structure for table `parametros`
--

CREATE TABLE `parametros` (
  `id_parametro` int NOT NULL COMMENT 'Identificador numérico del parámetro',
  `codigo` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL COMMENT 'Código único del parámetro (ej: tasa_interés_crédito)',
  `nombre` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL COMMENT 'Nombre descriptivo del parámetro',
  `valor` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL COMMENT 'Valor del parámetro',
  `tipo` enum('texto','numero','decimal','booleano','color') CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT 'texto' COMMENT 'Tipo de dato del valor',
  `modulo` enum('general','financiero','seguridad','imagen') CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT 'general' COMMENT 'Módulo al que pertenece el parámetro',
  `editable` tinyint(1) DEFAULT '1' COMMENT 'Indica si el parámetro puede ser editado desde el panel'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='Parámetros configurables del sistema';

--
-- Dumping data for table `parametros`
--

INSERT INTO `parametros` (`id_parametro`, `codigo`, `nombre`, `valor`, `tipo`, `modulo`, `editable`) VALUES
(1, 'tasa_interés_crédito', 'Tasa de interés para créditos', '6.00', 'decimal', 'financiero', 1),
(2, 'método_interés_default', 'Método de interés por defecto', 'simple', 'texto', 'financiero', 1),
(3, 'tasa_interés_ahorro', 'Tasa de interés sobre ahorros', '0.00', 'decimal', 'financiero', 1),
(4, 'tasa_interés_inversión', 'Tasa de interés para inversiones', '6.00', 'decimal', 'financiero', 1),
(5, 'aporte_obligatorio_mensual', 'Aporte obligatorio mensual', '10.00', 'decimal', 'financiero', 1),
(6, 'cuota_ingreso', 'Cuota única de ingreso', '20.00', 'decimal', 'financiero', 1),
(7, 'multa_retraso_10min', 'Multa retraso 10-30 minutos', '1.00', 'decimal', 'financiero', 1),
(8, 'multa_retraso_30min', 'Multa retraso >=30 minutos', '5.00', 'decimal', 'financiero', 1),
(9, 'multa_inasistencia', 'Multa por inasistencia', '5.00', 'decimal', 'financiero', 1),
(10, 'multa_mora_crédito', 'Multa por mora de crédito', '5.00', 'decimal', 'financiero', 1),
(11, 'límite_crédito_emergente', 'Límite crédito emergente', '300.00', 'decimal', 'financiero', 1),
(12, 'plazo_mínimo_inversión', 'Plazo mínimo inversión (meses)', '6', 'numero', 'financiero', 1),
(13, 'intentos_máx_login', 'Intentos máximo de login', '3', 'numero', 'seguridad', 1),
(14, 'bloqueo_minutos', 'Minutos de bloqueo', '15', 'numero', 'seguridad', 1),
(15, 'session_timeout_minutos', 'Timeout de sesión (minutos)', '30', 'numero', 'seguridad', 1),
(16, 'pin_2fa_dígitos', 'Dígitos del PIN 2FA', '6', 'numero', 'seguridad', 1),
(17, 'pin_2fa_expiracion_min', 'Expiración PIN 2FA (minutos)', '5', 'numero', 'seguridad', 1),
(18, 'máx_reenvío_pin_hora', 'Máximo reenvíos PIN por hora', '3', 'numero', 'seguridad', 1),
(19, 'logo_sidebar', 'Logo del sidebar', 'ca62b9e0-de01-42cc-9bb6-0826f49dce00', 'texto', 'imagen', 1),
(20, 'logo_sd', 'Logo sin fondo', 'd9433f2e-ffa1-48c9-bf86-b338e6796ff2', 'texto', 'imagen', 1),
(21, 'multa_cuota_impaga', 'Multa por cuota mensual impaga', '5.00', 'decimal', 'financiero', 1);

-- --------------------------------------------------------

--
-- Table structure for table `permisos`
--

CREATE TABLE `permisos` (
  `id_permiso` int NOT NULL COMMENT 'Identificador numérico del permiso',
  `codigo` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL COMMENT 'Código único del permiso (ej: socio.registrar)',
  `nombre` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL COMMENT 'Nombre descriptivo del permiso',
  `descripcion` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL COMMENT 'Descripción detallada del alcance del permiso',
  `modulo` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT '' COMMENT 'Modulo/categoria para agrupar permisos'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='Catálogo de permisos disponibles en el sistema';

--
-- Dumping data for table `permisos`
--

INSERT INTO `permisos` (`id_permiso`, `codigo`, `nombre`, `descripcion`, `modulo`) VALUES
(1, 'auth.login', 'Ingresar al sistema', 'Permite iniciar sesión en el sistema', 'Autenticacion'),
(2, 'auth.ver_2fa', 'Acceder con 2FA', 'Permite acceder con autenticación de dos factores', 'Autenticacion'),
(3, 'socio.registrar', 'Registrar nuevo socio', 'Permite registrar un nuevo socio en el sistema', 'Socios'),
(4, 'socio.editar', 'Editar datos de socio', 'Permite modificar los datos de un socio existente', 'Socios'),
(5, 'socio.cambiar_estado', 'Cambiar estado del socio', 'Permite cambiar el estado de un socio en su ciclo de vida', 'Socios'),
(6, 'socio.consultar', 'Consultar lista de socios', 'Permite consultar el listado de socios registrados', 'Socios'),
(7, 'socio.ver_financiero', 'Ver datos financieros del socio', 'Permite visualizar la información financiera del socio', 'Socios'),
(8, 'param.usuarios', 'Gestionar usuarios del sistema', 'CRUD completo de usuarios del sistema', 'Parametros del Sistema'),
(9, 'param.roles', 'Gestionar roles y permisos', 'Crear, editar y eliminar roles con permisos personalizados', 'Parametros del Sistema'),
(10, 'param.imagen', 'Configurar imagen corporativa', 'Gestionar logo, colores, membrete y razón social', 'Parametros del Sistema'),
(11, 'param.catalogos', 'Editar catálogos', 'Gestionar provincias, cantones y entidades públicas', 'Parametros del Sistema'),
(12, 'param.financiero', 'Configurar parámetros financieros', 'Configurar tasas, montos, plazos y métodos de interés', 'Parametros del Sistema'),
(13, 'producto.crear', 'Crear productos financieros', 'Crear nuevos productos de crédito e inversión', 'Productos Financieros'),
(14, 'producto.editar', 'Editar productos', 'Modificar productos financieros existentes', 'Productos Financieros'),
(15, 'producto.activar', 'Activar/desactivar productos', 'Activar o desactivar productos financieros', 'Productos Financieros'),
(16, 'cobro.aporte', 'Registrar cobro de aporte', 'Registrar cobro de aporte obligatorio y voluntario', 'Cobros'),
(17, 'cobro.cuota_credito', 'Registrar cobro de cuota de crédito', 'Registrar cobro de cuotas de crédito', 'Cobros'),
(18, 'cobro.multa', 'Registrar cobro de multa', 'Registrar cobro de multas generadas', 'Cobros'),
(19, 'cobro.inversion', 'Registrar inversión voluntaria', 'Registrar apertura de inversión a plazo fijo', 'Cobros'),
(20, 'cobro.desembolso', 'Realizar desembolso de crédito', 'Ejecutar el desembolso de un crédito aprobado', 'Cobros'),
(21, 'cobro.anular', 'Anular cobro registrado', 'Anular un cobro previamente registrado', 'Cobros'),
(22, 'cobro.cierre_sesion', 'Ejecutar cierre de sesión mensual', 'Cerrar la sesión mensual con generación de acta', 'Cobros'),
(23, 'calculo.intereses', 'Ejecutar cálculo de intereses', 'Calcular intereses de créditos, ahorros e inversiones', 'Calculos Financieros'),
(24, 'calculo.excedentes', 'Calcular distribución de excedentes', 'Calcular la distribución de excedentes entre los socios', 'Calculos Financieros'),
(25, 'calculo.aprobar_excedentes', 'Aprobar distribución de excedentes', 'Aprobar la distribución de excedentes calculada', 'Calculos Financieros'),
(26, 'reporte.socios', 'Generar reportes de socios', 'Generar reportes del módulo de socios', 'Reportes'),
(27, 'reporte.financiero', 'Generar reportes financieros', 'Generar reportes del módulo financiero', 'Reportes'),
(28, 'reporte.cobros', 'Generar reportes de cobros', 'Generar reportes del módulo de cobros', 'Reportes'),
(29, 'credito.aprobar', 'Aprobar/rechazar creditos', 'Permite aprobar o rechazar solicitudes de credito en la bandeja de aprobacion', 'Creditos'),
(30, 'notificacion.configurar', 'Configurar reglas de notificacion', 'Gestionar las reglas de notificacion del sistema (canal y destinatarios)', 'Notificaciones'),
(32, 'multa.impugnar', 'Impugnar multas', 'Permite autorizar la impugnacion de multas presentadas por los socios', 'Multas'),
(33, 'multa.autorizar_impugnacion', 'Autorizar impugnacion', 'Permite autorizar o rechazar impugnaciones de multas presentadas por los socios', 'Multas'),
(34, 'inversion.aprobar', 'Aprobar/rechazar inversiones', 'Permite aprobar o rechazar solicitudes de inversion en la bandeja de aprobacion', 'Inversiones'),
(35, 'socio.eliminar', 'Eliminar socio', 'Permite eliminar un socio del sistema de forma permanente', 'Socios');

-- --------------------------------------------------------

--
-- Table structure for table `productos_financieros`
--

CREATE TABLE `productos_financieros` (
  `id_producto` char(36) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL COMMENT 'Identificador único del producto financiero (UUID)',
  `nombre` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL COMMENT 'Nombre del producto (ej: Crédito Ordinario, Inversión 6 Meses)',
  `tipo` enum('credito','inversion') CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `tasa_interes_anual` decimal(5,2) NOT NULL DEFAULT '6.00' COMMENT 'Tasa de interés anual en porcentaje',
  `metodo_interes` enum('simple','frances','aleman') CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT 'simple' COMMENT 'Metodo de calculo de intereses',
  `plazo_min_meses` int NOT NULL COMMENT 'Plazo mínimo en meses',
  `plazo_max_meses` int NOT NULL COMMENT 'Plazo máximo en meses',
  `monto_min` decimal(10,2) NOT NULL COMMENT 'Monto mínimo del producto',
  `monto_max` decimal(10,2) NOT NULL COMMENT 'Monto máximo del producto',
  `requiere_garante` tinyint(1) DEFAULT '0' COMMENT 'Indica si el producto requiere garante',
  `penalidad_retiro_anticipado` decimal(5,2) DEFAULT '0.00' COMMENT 'Penalidad por retiro anticipado (%)',
  `activo` tinyint(1) DEFAULT '1' COMMENT 'Indica si el producto está activo para nuevas solicitudes',
  `fecha_creacion` datetime DEFAULT CURRENT_TIMESTAMP COMMENT 'Fecha de creación del producto',
  `condiciones_html` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci COMMENT 'Condiciones generales del credito en HTML (WYSIWYG)',
  `min_permanencia_meses` int DEFAULT '0' COMMENT 'Minimo de permanencia como socio activo (meses)',
  `min_ahorro` decimal(10,2) DEFAULT '0.00' COMMENT 'Minimo de ahorro acumulado requerido',
  `es_emergente` tinyint(1) DEFAULT '0' COMMENT 'Si es credito emergente (no requiere sesion de aprobacion)',
  `monto_max_emergente` decimal(10,2) DEFAULT '0.00' COMMENT 'Monto maximo para credito emergente',
  `requiere_documento_firmado` tinyint(1) DEFAULT '1' COMMENT 'Si requiere documento firmado escaneado antes del desembolso',
  `dias_gracia` int DEFAULT '0' COMMENT 'Dias de gracia antes de primera cuota',
  `min_ahorro_unidad` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT 'dolares' COMMENT 'Unidad del monto minimo de ahorro: dolares o porcentaje',
  `min_destino_caracteres` int DEFAULT '0' COMMENT 'Minimo de caracteres para destino del credito',
  `min_permanencia_valor` int DEFAULT '0' COMMENT 'Valor minimo de permanencia',
  `min_permanencia_unidad` varchar(10) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT 'meses' COMMENT 'Unidad de permanencia: dias, meses, anios'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='Catálogo de productos financieros parametrizables por el Analista Financiero';

--
-- Dumping data for table `productos_financieros`
--

INSERT INTO `productos_financieros` (`id_producto`, `nombre`, `tipo`, `tasa_interes_anual`, `metodo_interes`, `plazo_min_meses`, `plazo_max_meses`, `monto_min`, `monto_max`, `requiere_garante`, `penalidad_retiro_anticipado`, `activo`, `fecha_creacion`, `condiciones_html`, `min_permanencia_meses`, `min_ahorro`, `es_emergente`, `monto_max_emergente`, `requiere_documento_firmado`, `dias_gracia`, `min_ahorro_unidad`, `min_destino_caracteres`, `min_permanencia_valor`, `min_permanencia_unidad`) VALUES
('2e4c5dbd-afa8-424e-9367-6687ad3c4490', 'Inversión ordinaria', 'inversion', 6.00, 'simple', 3, 12, 500.00, 10000.00, 0, 45.00, 1, '2026-06-20 15:42:04', '<p>Condiciones de Inversión</p><p>Estas son condiciones de inversión.</p><p>-Saludos</p>', 0, 0.00, 0, 0.00, 1, 0, 'dolares', 0, 0, 'meses'),
('c3dd23b3-5eff-45f3-97c6-8343c340bfcc', 'Crédito Ordinario', 'credito', 6.00, 'simple', 1, 12, 1.00, 10000.00, 0, 0.00, 1, '2026-06-07 18:03:07', '<p>Condiciones del crédito</p><p>Estas son las condiciones que debe aceptar el socio para acceder al crédito.</p><p>-La Directiva</p>', 0, 20.00, 0, 0.00, 0, 0, 'dolares', 10, 0, 'meses');

-- --------------------------------------------------------

--
-- Table structure for table `provincias`
--

CREATE TABLE `provincias` (
  `id_provincia` int NOT NULL COMMENT 'Identificador numérico de la provincia',
  `nombre` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL COMMENT 'Nombre de la provincia'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='Catálogo de provincias del Ecuador';

--
-- Dumping data for table `provincias`
--

INSERT INTO `provincias` (`id_provincia`, `nombre`) VALUES
(1, 'Pichincha');

-- --------------------------------------------------------

--
-- Table structure for table `reglas_notificacion`
--

CREATE TABLE `reglas_notificacion` (
  `id_regla` int NOT NULL,
  `codigo` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `nombre` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `tipo_evento` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `titulo_evento` varchar(200) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `canal` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'push',
  `para_todos` tinyint(1) DEFAULT '0',
  `activo` tinyint(1) DEFAULT '1'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `reglas_notificacion`
--

INSERT INTO `reglas_notificacion` (`id_regla`, `codigo`, `nombre`, `tipo_evento`, `titulo_evento`, `canal`, `para_todos`, `activo`) VALUES
(1, 'solicitud_credito', 'Solicitud de credito', 'credito', 'Nueva solicitud de credito', 'push', 0, 1),
(2, 'credito_aprobado', 'Credito aprobado', 'credito', 'Credito aprobado', 'push', 0, 1),
(3, 'credito_rechazado', 'Credito rechazado', 'credito', 'Credito rechazado', 'push', 0, 1),
(4, 'credito_desembolsado', 'Credito desembolsado', 'credito', 'Credito desembolsado', 'push', 0, 1),
(5, 'credito_mora', 'Credito en mora', 'credito', NULL, 'ambos', 1, 1),
(6, 'solicitud_retiro', 'Solicitud de retiro', 'cobro', 'Solicitud de retiro', 'push', 0, 1),
(7, 'sesion_cerrada', 'Sesion cerrada', 'sesion', 'Sesion cerrada', 'ambos', 1, 1);

-- --------------------------------------------------------

--
-- Table structure for table `reglas_notificacion_destinatarios`
--

CREATE TABLE `reglas_notificacion_destinatarios` (
  `id_regla` int NOT NULL,
  `id_rol` int NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `reglas_notificacion_destinatarios`
--

INSERT INTO `reglas_notificacion_destinatarios` (`id_regla`, `id_rol`) VALUES
(1, 2),
(6, 2),
(2, 4),
(6, 4);

-- --------------------------------------------------------

--
-- Table structure for table `roles`
--

CREATE TABLE `roles` (
  `id_rol` int NOT NULL COMMENT 'Identificador numérico del rol',
  `nombre` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL COMMENT 'Nombre personalizable del rol (ej: Presidente, Tesorero)',
  `descripcion` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL COMMENT 'Descripción de las funciones del rol',
  `endosable` tinyint(1) DEFAULT '0' COMMENT 'Si es TRUE, este rol puede acumular permisos de otros roles'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='Roles del sistema — 100% personalizables desde el panel de administración';

--
-- Dumping data for table `roles`
--

INSERT INTO `roles` (`id_rol`, `nombre`, `descripcion`, `endosable`) VALUES
(1, 'Administrador Técnico', 'Gobierna usuarios, roles, permisos e imagen corporativa. Sin acceso financiero', 0),
(2, 'Presidente', 'Representante legal, convocatorias, supervisión, firma de certificados', 0),
(3, 'Analista Financiero', 'Configura productos financieros, parámetros, cálculos y distribución de excedentes', 0),
(4, 'Tesorero', 'Ejecución financiera diaria: cobros, desembolsos, cierre de sesión', 0),
(5, 'Asistente de Tesorería', 'Apoyo en cobros de aportes, cuotas y multas', 0),
(6, 'Socio', 'Acceso al portal personal: consultas, solicitudes, comprobantes', 0),
(7, 'Secretario/a', 'Gestión documental, registro de socios, certificados, actas y convocatorias', 0);

-- --------------------------------------------------------

--
-- Table structure for table `roles_permisos`
--

CREATE TABLE `roles_permisos` (
  `id_rol` int NOT NULL COMMENT 'FK al ID del rol',
  `id_permiso` int NOT NULL COMMENT 'FK al ID del permiso',
  `permitir` tinyint(1) DEFAULT '1' COMMENT 'TRUE = concedido, FALSE = denegado explícitamente'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='Matriz de permisos asignados a cada rol (gestión por checkboxes)';

--
-- Dumping data for table `roles_permisos`
--

INSERT INTO `roles_permisos` (`id_rol`, `id_permiso`, `permitir`) VALUES
(1, 1, 1),
(1, 2, 1),
(1, 3, 1),
(1, 4, 1),
(1, 6, 1),
(1, 8, 1),
(1, 9, 1),
(1, 10, 1),
(1, 11, 1),
(1, 30, 1),
(1, 35, 1),
(2, 1, 1),
(2, 2, 1),
(2, 29, 1),
(2, 30, 1),
(2, 32, 1),
(2, 33, 1),
(2, 34, 1),
(3, 1, 1),
(3, 2, 1),
(3, 4, 1),
(3, 6, 1),
(3, 7, 1),
(3, 12, 1),
(3, 13, 1),
(3, 14, 1),
(3, 15, 1),
(3, 21, 1),
(3, 22, 1),
(3, 23, 1),
(3, 24, 1),
(3, 26, 1),
(3, 27, 1),
(3, 28, 1),
(3, 30, 1),
(4, 1, 1),
(4, 2, 1),
(4, 16, 1),
(4, 17, 1),
(4, 18, 1),
(4, 19, 1),
(4, 20, 1),
(4, 21, 1),
(4, 22, 1),
(4, 23, 1),
(4, 24, 1),
(4, 25, 1),
(4, 26, 1),
(4, 27, 1),
(4, 28, 1),
(4, 29, 1),
(4, 32, 1),
(4, 33, 1),
(4, 34, 1),
(5, 1, 1),
(5, 16, 1),
(5, 17, 1),
(5, 18, 1),
(5, 19, 1),
(5, 26, 1),
(5, 28, 1),
(6, 1, 1),
(7, 1, 1),
(7, 2, 1),
(7, 3, 1),
(7, 4, 1),
(7, 5, 1),
(7, 6, 1),
(7, 7, 1),
(7, 16, 1),
(7, 21, 1),
(7, 26, 1),
(7, 30, 1);

-- --------------------------------------------------------

--
-- Table structure for table `roles_usuarios`
--

CREATE TABLE `roles_usuarios` (
  `id_usuario` char(36) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL COMMENT 'FK al UUID del usuario',
  `id_rol` int NOT NULL COMMENT 'FK al ID del rol'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='Asignación de roles a usuarios (relación muchos-a-muchos)';

--
-- Dumping data for table `roles_usuarios`
--

INSERT INTO `roles_usuarios` (`id_usuario`, `id_rol`) VALUES
('ce86e169-fa0a-468d-bb04-ca7b8c7a5291', 1),
('ce86e169-fa0a-468d-bb04-ca7b8c7a5291', 2),
('ce86e169-fa0a-468d-bb04-ca7b8c7a5291', 3),
('516363c5-c79a-4491-83b4-b8303ce1f286', 4),
('ce86e169-fa0a-468d-bb04-ca7b8c7a5291', 4),
('516363c5-c79a-4491-83b4-b8303ce1f286', 5),
('ce86e169-fa0a-468d-bb04-ca7b8c7a5291', 5),
('1673019a-c66d-4bb8-9158-1729fa6b064a', 6),
('ce86e169-fa0a-468d-bb04-ca7b8c7a5291', 7);

-- --------------------------------------------------------

--
-- Table structure for table `sesiones_mensuales`
--

CREATE TABLE `sesiones_mensuales` (
  `id_sesion` char(36) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL COMMENT 'Identificador único de la sesión mensual (UUID)',
  `numero_sesion` int NOT NULL COMMENT 'Número correlativo de la sesión mensual',
  `fecha_sesion` datetime NOT NULL,
  `titulo` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL COMMENT 'Título o nombre de la sesión',
  `tipo` enum('ordinaria','extraordinaria','informativa') COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'ordinaria' COMMENT 'Tipo de sesion: ordinaria (max 1/mes), extraordinaria, informativa',
  `estado` enum('abierta','cerrada') CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT 'abierta' COMMENT 'Estado de la sesión: abierta (en curso) o cerrada (finalizada)',
  `fecha_apertura` datetime DEFAULT CURRENT_TIMESTAMP COMMENT 'Fecha y hora de apertura de la sesión',
  `fecha_cierre` datetime DEFAULT NULL COMMENT 'Fecha y hora de cierre de la sesión',
  `usuario_cierre` char(36) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL COMMENT 'Usuario que ejecutó el cierre de sesión',
  `acta_cierre_pdf` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL COMMENT 'Archivo PDF del acta de cierre',
  `total_recaudado` decimal(12,2) DEFAULT '0.00' COMMENT 'Total recaudado en la sesión',
  `total_desembolsado` decimal(12,2) DEFAULT '0.00' COMMENT 'Total desembolsado en la sesión',
  `saldo_caja` decimal(12,2) DEFAULT '0.00' COMMENT 'Saldo final de caja (recaudado - desembolsado)'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='Sesiones mensuales de cobro y check-in — núcleo operativo del sistema';

--
-- Dumping data for table `sesiones_mensuales`
--

INSERT INTO `sesiones_mensuales` (`id_sesion`, `numero_sesion`, `fecha_sesion`, `titulo`, `tipo`, `estado`, `fecha_apertura`, `fecha_cierre`, `usuario_cierre`, `acta_cierre_pdf`, `total_recaudado`, `total_desembolsado`, `saldo_caja`) VALUES
('3ae0cc43-1d87-4fb0-b281-023a38fca310', 2, '2026-07-31 19:00:00', 'Sesión Ordinaria Julio 2026', 'ordinaria', 'cerrada', '2026-06-24 16:11:04', '2026-06-24 16:14:18', '516363c5-c79a-4491-83b4-b8303ce1f286', 'acta_sesion_2_20260624.html', 0.00, 0.00, 0.00),
('5c4f2b3f-1f3e-43f7-aacc-1ab8faa23ff6', 1, '2026-06-28 19:00:00', 'Sesión Ordinaria Junio 2026', 'ordinaria', 'cerrada', '2026-06-24 16:07:56', '2026-06-24 16:10:46', '516363c5-c79a-4491-83b4-b8303ce1f286', 'acta_sesion_1_20260624.html', 0.00, 0.00, 0.00),
('a0c8e34d-3724-4b59-83a0-ea9a4daf3e54', 3, '2026-08-31 19:00:00', 'Sesión Ordinaria Agosto 2026', 'ordinaria', 'abierta', '2026-06-24 16:14:36', NULL, NULL, NULL, 0.00, 0.00, 0.00);

-- --------------------------------------------------------

--
-- Table structure for table `socios`
--

CREATE TABLE `socios` (
  `id_socio` char(36) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL COMMENT 'Identificador único del socio (UUID)',
  `cedula` varchar(10) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL COMMENT 'Cédula de identidad ecuatoriana (10 dígitos, dígito verificador)',
  `apellido1` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL COMMENT 'Primer apellido (mayúsculas)',
  `apellido2` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL COMMENT 'Segundo apellido (mayúsculas)',
  `nombre1` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL COMMENT 'Primer nombre (mayúsculas)',
  `nombre2` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL COMMENT 'Segundo nombre (mayúsculas)',
  `fecha_nacimiento` date NOT NULL COMMENT 'Fecha de nacimiento',
  `genero` enum('masculino','femenino') CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL COMMENT 'Género del socio',
  `estado_civil` enum('soltero','casado','divorciado','viudo','union_libre') CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `direccion` varchar(200) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL COMMENT 'Dirección de residencia',
  `telefono` varchar(15) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL COMMENT 'Número de teléfono fijo',
  `celular` varchar(15) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL COMMENT 'Número de celular',
  `correo_electronico` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL COMMENT 'Correo electrónico (validado con PIN 6 dígitos)',
  `profesion` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL COMMENT 'Profesión u ocupación',
  `foto_url` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL COMMENT 'URL de la fotografía del socio',
  `documento_identidad_anverso` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL COMMENT 'Archivo PDF/JPG del anverso de la cédula',
  `documento_identidad_reverso` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL COMMENT 'Archivo PDF/JPG del reverso de la cédula',
  `estado` enum('pendiente','pre_activo','activo','suspendido','retiro_voluntario','excluido','fallecido') CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT 'pendiente' COMMENT 'Estado actual del socio en el ciclo de vida',
  `fecha_ingreso` date NOT NULL COMMENT 'Fecha de solicitud de ingreso',
  `fecha_aprobacion` date DEFAULT NULL COMMENT 'Fecha de aprobación por la Asamblea',
  `numero_acta_aprobacion` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL COMMENT 'Número de acta de la Asamblea que aprobó el ingreso',
  `acta_aprobacion_pdf` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL COMMENT 'Archivo PDF del acta de aprobación',
  `observaciones` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci COMMENT 'Observaciones generales del socio',
  `fecha_retiro` date DEFAULT NULL COMMENT 'Fecha de retiro voluntario',
  `motivo_retiro` varchar(300) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL COMMENT 'Motivo del retiro voluntario',
  `fecha_exclusion` date DEFAULT NULL COMMENT 'Fecha de exclusión (Art.14 Estatuto)',
  `motivo_exclusion` varchar(300) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL COMMENT 'Motivo de la exclusión',
  `menor_edad` tinyint(1) DEFAULT '0' COMMENT 'Indica si el socio es menor de edad',
  `representante_nombres` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL COMMENT 'Nombres del representante legal (menores de edad)',
  `representante_cedula` varchar(10) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL COMMENT 'Cédula del representante legal',
  `representante_telefono` varchar(15) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL COMMENT 'Teléfono del representante legal',
  `representante_correo` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL COMMENT 'Correo del representante legal',
  `representante_documento_pdf` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL COMMENT 'Documento legal del representante (PDF)',
  `hash_integridad` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL COMMENT 'SHA-256 de integridad del registro',
  `fecha_creacion` datetime DEFAULT CURRENT_TIMESTAMP COMMENT 'Fecha de creación del registro'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='Registro de socios de la Caja de Ahorro con datos personales, estado y representación';

--
-- Dumping data for table `socios`
--

INSERT INTO `socios` (`id_socio`, `cedula`, `apellido1`, `apellido2`, `nombre1`, `nombre2`, `fecha_nacimiento`, `genero`, `estado_civil`, `direccion`, `telefono`, `celular`, `correo_electronico`, `profesion`, `foto_url`, `documento_identidad_anverso`, `documento_identidad_reverso`, `estado`, `fecha_ingreso`, `fecha_aprobacion`, `numero_acta_aprobacion`, `acta_aprobacion_pdf`, `observaciones`, `fecha_retiro`, `motivo_retiro`, `fecha_exclusion`, `motivo_exclusion`, `menor_edad`, `representante_nombres`, `representante_cedula`, `representante_telefono`, `representante_correo`, `representante_documento_pdf`, `hash_integridad`, `fecha_creacion`) VALUES
('6819f961-b144-4c96-bbbd-8a0c0055cce1', '1002003000', 'PUJOTA', '', 'ELVIA', '', '1983-01-19', 'masculino', NULL, 'IBARRA', '', '0995756654', 'gavinocg@gmail.com', 'Econ.', NULL, NULL, NULL, 'activo', '2026-06-20', '2026-06-20', '', 'acta_aprobacion_6819f961.pdf', NULL, NULL, NULL, NULL, NULL, 0, '', '', '', '', NULL, 'd00c2852329529ad4164cc651368518f7700e34e14a34a377ff7e4775f60fac9', '2026-06-20 14:20:38');

-- --------------------------------------------------------

--
-- Table structure for table `solicitudes_retiro`
--

CREATE TABLE `solicitudes_retiro` (
  `id_solicitud` char(36) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL COMMENT 'UUID de la solicitud',
  `id_socio` char(36) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL COMMENT 'FK al socio solicitante',
  `monto` decimal(12,2) NOT NULL COMMENT 'Monto solicitado',
  `motivo` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci COMMENT 'Motivo del retiro',
  `estado` enum('pendiente','aprobado','rechazado') CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT 'pendiente' COMMENT 'Estado de la solicitud',
  `fecha_solicitud` datetime DEFAULT CURRENT_TIMESTAMP COMMENT 'Fecha de solicitud',
  `fecha_respuesta` datetime DEFAULT NULL COMMENT 'Fecha de aprobación/rechazo',
  `usuario_respuesta` char(36) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL COMMENT 'Usuario que aprobó/rechazó',
  `id_cobro` char(36) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL COMMENT 'Cobro generado al aprobar'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='Solicitudes de retiro de ahorro';

-- --------------------------------------------------------

--
-- Table structure for table `usuarios`
--

CREATE TABLE `usuarios` (
  `id_usuario` char(36) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL COMMENT 'Identificador único del usuario (UUID)',
  `nombres` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL COMMENT 'Nombres del usuario',
  `apellidos` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL COMMENT 'Apellidos del usuario',
  `cedula` varchar(10) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL COMMENT 'Cédula de identidad ecuatoriana',
  `correo_electronico` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL COMMENT 'Correo electrónico del usuario',
  `telefono` varchar(15) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL COMMENT 'Número de teléfono',
  `nombre_usuario` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL COMMENT 'Nombre de usuario para inicio de sesión',
  `contrasena` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL COMMENT 'Hash bcrypt de la contraseña',
  `activo` tinyint(1) DEFAULT '1' COMMENT 'Indica si el usuario está activo en el sistema',
  `_2fa_obligatorio` tinyint(1) DEFAULT '0' COMMENT 'Indica si el 2FA es obligatorio para este usuario',
  `_2fa_activo` tinyint(1) DEFAULT '0' COMMENT 'Indica si el 2FA está actualmente activo',
  `bloqueado_hasta` datetime DEFAULT NULL COMMENT 'Fecha/hasta cuándo está bloqueado (3 intentos fallidos)',
  `intentos_fallidos` int DEFAULT '0' COMMENT 'Contador de intentos fallidos de inicio de sesión',
  `fecha_creacion` datetime DEFAULT CURRENT_TIMESTAMP COMMENT 'Fecha de creación del registro',
  `fecha_ultimo_acceso` datetime DEFAULT NULL COMMENT 'Fecha y hora del último inicio de sesión exitoso',
  `token_activacion` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL COMMENT 'SHA-256 del token de activacion de cuenta',
  `token_activacion_expira` datetime DEFAULT NULL COMMENT 'Expiracion del token de activacion',
  `fecha_contrasena` datetime DEFAULT NULL COMMENT 'Fecha del ultimo cambio de contrasena',
  `reset_token_hash` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL COMMENT 'SHA-256 del token de restablecimiento de contrasena',
  `reset_token_expira` datetime DEFAULT NULL COMMENT 'Expiracion del token de restablecimiento',
  `reset_token_usos` int DEFAULT '0' COMMENT 'Contador de usos del token de restablecimiento'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='Usuarios del sistema con credenciales de acceso y control 2FA';

--
-- Dumping data for table `usuarios`
--

INSERT INTO `usuarios` (`id_usuario`, `nombres`, `apellidos`, `cedula`, `correo_electronico`, `telefono`, `nombre_usuario`, `contrasena`, `activo`, `_2fa_obligatorio`, `_2fa_activo`, `bloqueado_hasta`, `intentos_fallidos`, `fecha_creacion`, `fecha_ultimo_acceso`, `token_activacion`, `token_activacion_expira`, `fecha_contrasena`, `reset_token_hash`, `reset_token_expira`, `reset_token_usos`) VALUES
('1673019a-c66d-4bb8-9158-1729fa6b064a', 'Elvia', 'Pujota', '1002003000', 'epujota@gmail.com', '0996755645', 'gcarranco', '$2y$12$he9h3v/EHzKV/O.6c4kt4uYsYGPt2aHoHjAOzhoqzrMKhUNfdz2KG', 1, 0, 0, NULL, 0, '2026-06-06 16:38:03', '2026-06-24 14:43:47', NULL, NULL, '2026-06-06 16:38:03', NULL, NULL, 0),
('516363c5-c79a-4491-83b4-b8303ce1f286', 'Tesorero', 'Caja', '1003560438', 'gcarranco@hotmail.com', '', 'tesorero', '$2y$12$/gRI9LwajMIzc8e/NYxO6.hCsUvfbH3c.yxuEKpkpRT7AXoL2ojxe', 1, 0, 0, NULL, 0, '2026-06-06 18:23:36', '2026-06-24 14:49:53', NULL, NULL, '2026-06-06 18:23:36', NULL, NULL, 0),
('ce86e169-fa0a-468d-bb04-ca7b8c7a5291', 'Admin', 'Sistema', '1002606083', 'admin@caja.test', '0999999999', 'admin', '$2y$12$he9h3v/EHzKV/O.6c4kt4uYsYGPt2aHoHjAOzhoqzrMKhUNfdz2KG', 1, 0, 0, NULL, 0, '2026-06-06 14:16:51', '2026-06-24 15:06:27', NULL, NULL, '2026-06-20 14:39:19', '$2y$12$Zv9DvqMKa/BSRVhgfSWxROh9zu75TawpzezMGBqt6EVYICZ3.aAvS', '2026-06-24 00:03:57', 0);

--
-- Indexes for dumped tables
--

--
-- Indexes for table `amortizaciones`
--
ALTER TABLE `amortizaciones`
  ADD PRIMARY KEY (`id_amortizacion`),
  ADD KEY `idx_amortizaciones_crédito` (`id_credito`),
  ADD KEY `idx_amortizaciones_estado` (`estado`);

--
-- Indexes for table `archivos`
--
ALTER TABLE `archivos`
  ADD PRIMARY KEY (`id_archivo`),
  ADD KEY `id_usuario_subio` (`id_usuario_subio`),
  ADD KEY `idx_archivos_entidad` (`entidad_tipo`,`entidad_id`),
  ADD KEY `idx_archivos_hash` (`hash_sha256`);

--
-- Indexes for table `asistencias`
--
ALTER TABLE `asistencias`
  ADD PRIMARY KEY (`id_asistencia`),
  ADD UNIQUE KEY `id_socio` (`id_socio`,`id_sesion`),
  ADD KEY `id_sesión` (`id_sesion`),
  ADD KEY `usuario_registra` (`usuario_registra`);

--
-- Indexes for table `caja_movimientos`
--
ALTER TABLE `caja_movimientos`
  ADD PRIMARY KEY (`id_movimiento`),
  ADD KEY `idx_fecha` (`fecha_registro`),
  ADD KEY `idx_categoria` (`categoria`),
  ADD KEY `idx_sesion` (`id_sesion`),
  ADD KEY `idx_referencia` (`id_referencia`);

--
-- Indexes for table `cantones`
--
ALTER TABLE `cantones`
  ADD PRIMARY KEY (`id_canton`),
  ADD KEY `id_provincia` (`id_provincia`);

--
-- Indexes for table `capital_inversion`
--
ALTER TABLE `capital_inversion`
  ADD PRIMARY KEY (`id_capital_inversion`),
  ADD UNIQUE KEY `id_socio` (`id_socio`);

--
-- Indexes for table `catastro_entidades_publicas`
--
ALTER TABLE `catastro_entidades_publicas`
  ADD PRIMARY KEY (`id_entidad`);

--
-- Indexes for table `cobros`
--
ALTER TABLE `cobros`
  ADD PRIMARY KEY (`id_cobro`),
  ADD KEY `usuario_registra` (`usuario_registra`),
  ADD KEY `idx_cobros_socio` (`id_socio`),
  ADD KEY `idx_cobros_tipo` (`tipo`),
  ADD KEY `idx_cobros_sesión` (`id_sesion`),
  ADD KEY `idx_cobros_fecha` (`fecha_registro`);

--
-- Indexes for table `creditos`
--
ALTER TABLE `creditos`
  ADD PRIMARY KEY (`id_credito`),
  ADD KEY `id_producto` (`id_producto`),
  ADD KEY `id_sesión_aprobación` (`id_sesion_aprobacion`),
  ADD KEY `usuario_aprueba` (`usuario_aprueba`),
  ADD KEY `idx_créditos_estado` (`estado`),
  ADD KEY `idx_créditos_socio` (`id_socio`);

--
-- Indexes for table `cuentas_ahorro`
--
ALTER TABLE `cuentas_ahorro`
  ADD PRIMARY KEY (`id_cuenta_ahorro`),
  ADD UNIQUE KEY `id_socio` (`id_socio`);

--
-- Indexes for table `garantes`
--
ALTER TABLE `garantes`
  ADD PRIMARY KEY (`id_garante`),
  ADD KEY `id_socio` (`id_socio`),
  ADD KEY `garantes_ibfk_1` (`id_credito`);

--
-- Indexes for table `historial_operaciones`
--
ALTER TABLE `historial_operaciones`
  ADD PRIMARY KEY (`id_operacion`),
  ADD KEY `id_sesión` (`id_sesion`),
  ADD KEY `id_usuario_registra` (`id_usuario_registra`),
  ADD KEY `idx_historial_socio` (`id_socio`),
  ADD KEY `idx_historial_tipo` (`tipo_operacion`),
  ADD KEY `idx_historial_fecha` (`fecha_registro`);

--
-- Indexes for table `inversiones`
--
ALTER TABLE `inversiones`
  ADD PRIMARY KEY (`id_inversion`),
  ADD KEY `id_producto` (`id_producto`),
  ADD KEY `idx_inversiones_estado` (`estado`),
  ADD KEY `idx_inversiones_socio` (`id_socio`);

--
-- Indexes for table `multas`
--
ALTER TABLE `multas`
  ADD PRIMARY KEY (`id_multa`),
  ADD KEY `id_sesión` (`id_sesion`),
  ADD KEY `id_cobro` (`id_cobro`),
  ADD KEY `idx_multas_socio` (`id_socio`),
  ADD KEY `idx_multas_pagada` (`pagada`);

--
-- Indexes for table `notificaciones`
--
ALTER TABLE `notificaciones`
  ADD PRIMARY KEY (`id_notificacion`),
  ADD KEY `idx_notificaciones_usuario` (`id_usuario`),
  ADD KEY `idx_notificaciones_socio` (`id_socio`),
  ADD KEY `idx_notificaciones_leída` (`leida`);

--
-- Indexes for table `obligaciones_sesion`
--
ALTER TABLE `obligaciones_sesion`
  ADD PRIMARY KEY (`id_obligacion`),
  ADD UNIQUE KEY `uk_sesion_socio_tipo_ref` (`id_sesion`,`id_socio`,`tipo`,`id_referencia`),
  ADD KEY `id_sesion` (`id_sesion`),
  ADD KEY `id_socio` (`id_socio`);

--
-- Indexes for table `parametros`
--
ALTER TABLE `parametros`
  ADD PRIMARY KEY (`id_parametro`),
  ADD UNIQUE KEY `código` (`codigo`);

--
-- Indexes for table `permisos`
--
ALTER TABLE `permisos`
  ADD PRIMARY KEY (`id_permiso`),
  ADD UNIQUE KEY `código` (`codigo`);

--
-- Indexes for table `productos_financieros`
--
ALTER TABLE `productos_financieros`
  ADD PRIMARY KEY (`id_producto`),
  ADD KEY `idx_productos_tipo` (`tipo`),
  ADD KEY `idx_productos_activo` (`activo`);

--
-- Indexes for table `provincias`
--
ALTER TABLE `provincias`
  ADD PRIMARY KEY (`id_provincia`);

--
-- Indexes for table `reglas_notificacion`
--
ALTER TABLE `reglas_notificacion`
  ADD PRIMARY KEY (`id_regla`),
  ADD UNIQUE KEY `codigo` (`codigo`),
  ADD KEY `idx_reglas_evento` (`tipo_evento`,`activo`);

--
-- Indexes for table `reglas_notificacion_destinatarios`
--
ALTER TABLE `reglas_notificacion_destinatarios`
  ADD PRIMARY KEY (`id_regla`,`id_rol`),
  ADD KEY `id_rol` (`id_rol`);

--
-- Indexes for table `roles`
--
ALTER TABLE `roles`
  ADD PRIMARY KEY (`id_rol`),
  ADD UNIQUE KEY `nombre` (`nombre`);

--
-- Indexes for table `roles_permisos`
--
ALTER TABLE `roles_permisos`
  ADD PRIMARY KEY (`id_rol`,`id_permiso`),
  ADD KEY `id_permiso` (`id_permiso`);

--
-- Indexes for table `roles_usuarios`
--
ALTER TABLE `roles_usuarios`
  ADD PRIMARY KEY (`id_usuario`,`id_rol`),
  ADD KEY `id_rol` (`id_rol`);

--
-- Indexes for table `sesiones_mensuales`
--
ALTER TABLE `sesiones_mensuales`
  ADD PRIMARY KEY (`id_sesion`),
  ADD KEY `usuario_cierre` (`usuario_cierre`);

--
-- Indexes for table `socios`
--
ALTER TABLE `socios`
  ADD PRIMARY KEY (`id_socio`),
  ADD UNIQUE KEY `cédula` (`cedula`),
  ADD UNIQUE KEY `correo_electrónico` (`correo_electronico`),
  ADD KEY `idx_socios_cédula` (`cedula`),
  ADD KEY `idx_socios_correo` (`correo_electronico`),
  ADD KEY `idx_socios_estado` (`estado`),
  ADD KEY `idx_socios_apellidos` (`apellido1`,`apellido2`),
  ADD KEY `idx_socios_nombres` (`nombre1`,`nombre2`);

--
-- Indexes for table `solicitudes_retiro`
--
ALTER TABLE `solicitudes_retiro`
  ADD PRIMARY KEY (`id_solicitud`),
  ADD KEY `id_socio` (`id_socio`);

--
-- Indexes for table `usuarios`
--
ALTER TABLE `usuarios`
  ADD PRIMARY KEY (`id_usuario`),
  ADD UNIQUE KEY `cédula` (`cedula`),
  ADD UNIQUE KEY `correo_electrónico` (`correo_electronico`),
  ADD UNIQUE KEY `nombre_usuario` (`nombre_usuario`),
  ADD KEY `idx_usuarios_cédula` (`cedula`),
  ADD KEY `idx_usuarios_correo` (`correo_electronico`),
  ADD KEY `idx_usuarios_activo` (`activo`);

--
-- AUTO_INCREMENT for dumped tables
--

--
-- AUTO_INCREMENT for table `cantones`
--
ALTER TABLE `cantones`
  MODIFY `id_canton` int NOT NULL AUTO_INCREMENT COMMENT 'Identificador numérico del cantón', AUTO_INCREMENT=2;

--
-- AUTO_INCREMENT for table `catastro_entidades_publicas`
--
ALTER TABLE `catastro_entidades_publicas`
  MODIFY `id_entidad` int NOT NULL AUTO_INCREMENT COMMENT 'Identificador numérico de la entidad';

--
-- AUTO_INCREMENT for table `parametros`
--
ALTER TABLE `parametros`
  MODIFY `id_parametro` int NOT NULL AUTO_INCREMENT COMMENT 'Identificador numérico del parámetro', AUTO_INCREMENT=22;

--
-- AUTO_INCREMENT for table `permisos`
--
ALTER TABLE `permisos`
  MODIFY `id_permiso` int NOT NULL AUTO_INCREMENT COMMENT 'Identificador numérico del permiso', AUTO_INCREMENT=36;

--
-- AUTO_INCREMENT for table `provincias`
--
ALTER TABLE `provincias`
  MODIFY `id_provincia` int NOT NULL AUTO_INCREMENT COMMENT 'Identificador numérico de la provincia', AUTO_INCREMENT=2;

--
-- AUTO_INCREMENT for table `reglas_notificacion`
--
ALTER TABLE `reglas_notificacion`
  MODIFY `id_regla` int NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=16;

--
-- AUTO_INCREMENT for table `roles`
--
ALTER TABLE `roles`
  MODIFY `id_rol` int NOT NULL AUTO_INCREMENT COMMENT 'Identificador numérico del rol', AUTO_INCREMENT=9;

--
-- Constraints for dumped tables
--

--
-- Constraints for table `amortizaciones`
--
ALTER TABLE `amortizaciones`
  ADD CONSTRAINT `amortizaciones_ibfk_1` FOREIGN KEY (`id_credito`) REFERENCES `creditos` (`id_credito`);

--
-- Constraints for table `archivos`
--
ALTER TABLE `archivos`
  ADD CONSTRAINT `archivos_ibfk_1` FOREIGN KEY (`id_usuario_subio`) REFERENCES `usuarios` (`id_usuario`);

--
-- Constraints for table `asistencias`
--
ALTER TABLE `asistencias`
  ADD CONSTRAINT `asistencias_ibfk_1` FOREIGN KEY (`id_socio`) REFERENCES `socios` (`id_socio`),
  ADD CONSTRAINT `asistencias_ibfk_2` FOREIGN KEY (`id_sesion`) REFERENCES `sesiones_mensuales` (`id_sesion`),
  ADD CONSTRAINT `asistencias_ibfk_3` FOREIGN KEY (`usuario_registra`) REFERENCES `usuarios` (`id_usuario`);

--
-- Constraints for table `cantones`
--
ALTER TABLE `cantones`
  ADD CONSTRAINT `cantones_ibfk_1` FOREIGN KEY (`id_provincia`) REFERENCES `provincias` (`id_provincia`);

--
-- Constraints for table `capital_inversion`
--
ALTER TABLE `capital_inversion`
  ADD CONSTRAINT `capital_inversion_ibfk_1` FOREIGN KEY (`id_socio`) REFERENCES `socios` (`id_socio`);

--
-- Constraints for table `cobros`
--
ALTER TABLE `cobros`
  ADD CONSTRAINT `cobros_ibfk_1` FOREIGN KEY (`id_socio`) REFERENCES `socios` (`id_socio`),
  ADD CONSTRAINT `cobros_ibfk_2` FOREIGN KEY (`id_sesion`) REFERENCES `sesiones_mensuales` (`id_sesion`),
  ADD CONSTRAINT `cobros_ibfk_3` FOREIGN KEY (`usuario_registra`) REFERENCES `usuarios` (`id_usuario`);

--
-- Constraints for table `creditos`
--
ALTER TABLE `creditos`
  ADD CONSTRAINT `creditos_ibfk_1` FOREIGN KEY (`id_socio`) REFERENCES `socios` (`id_socio`),
  ADD CONSTRAINT `creditos_ibfk_2` FOREIGN KEY (`id_producto`) REFERENCES `productos_financieros` (`id_producto`),
  ADD CONSTRAINT `creditos_ibfk_3` FOREIGN KEY (`id_sesion_aprobacion`) REFERENCES `sesiones_mensuales` (`id_sesion`),
  ADD CONSTRAINT `creditos_ibfk_4` FOREIGN KEY (`usuario_aprueba`) REFERENCES `usuarios` (`id_usuario`);

--
-- Constraints for table `cuentas_ahorro`
--
ALTER TABLE `cuentas_ahorro`
  ADD CONSTRAINT `cuentas_ahorro_ibfk_1` FOREIGN KEY (`id_socio`) REFERENCES `socios` (`id_socio`);

--
-- Constraints for table `garantes`
--
ALTER TABLE `garantes`
  ADD CONSTRAINT `garantes_ibfk_1` FOREIGN KEY (`id_credito`) REFERENCES `creditos` (`id_credito`),
  ADD CONSTRAINT `garantes_ibfk_2` FOREIGN KEY (`id_socio`) REFERENCES `socios` (`id_socio`);

--
-- Constraints for table `historial_operaciones`
--
ALTER TABLE `historial_operaciones`
  ADD CONSTRAINT `historial_operaciones_ibfk_1` FOREIGN KEY (`id_socio`) REFERENCES `socios` (`id_socio`),
  ADD CONSTRAINT `historial_operaciones_ibfk_2` FOREIGN KEY (`id_sesion`) REFERENCES `sesiones_mensuales` (`id_sesion`),
  ADD CONSTRAINT `historial_operaciones_ibfk_3` FOREIGN KEY (`id_usuario_registra`) REFERENCES `usuarios` (`id_usuario`);

--
-- Constraints for table `inversiones`
--
ALTER TABLE `inversiones`
  ADD CONSTRAINT `inversiones_ibfk_1` FOREIGN KEY (`id_socio`) REFERENCES `socios` (`id_socio`),
  ADD CONSTRAINT `inversiones_ibfk_2` FOREIGN KEY (`id_producto`) REFERENCES `productos_financieros` (`id_producto`);

--
-- Constraints for table `multas`
--
ALTER TABLE `multas`
  ADD CONSTRAINT `multas_ibfk_1` FOREIGN KEY (`id_socio`) REFERENCES `socios` (`id_socio`),
  ADD CONSTRAINT `multas_ibfk_2` FOREIGN KEY (`id_sesion`) REFERENCES `sesiones_mensuales` (`id_sesion`),
  ADD CONSTRAINT `multas_ibfk_3` FOREIGN KEY (`id_cobro`) REFERENCES `cobros` (`id_cobro`);

--
-- Constraints for table `notificaciones`
--
ALTER TABLE `notificaciones`
  ADD CONSTRAINT `notificaciones_ibfk_1` FOREIGN KEY (`id_usuario`) REFERENCES `usuarios` (`id_usuario`),
  ADD CONSTRAINT `notificaciones_ibfk_2` FOREIGN KEY (`id_socio`) REFERENCES `socios` (`id_socio`);

--
-- Constraints for table `obligaciones_sesion`
--
ALTER TABLE `obligaciones_sesion`
  ADD CONSTRAINT `obligaciones_sesion_ibfk_1` FOREIGN KEY (`id_sesion`) REFERENCES `sesiones_mensuales` (`id_sesion`),
  ADD CONSTRAINT `obligaciones_sesion_ibfk_2` FOREIGN KEY (`id_socio`) REFERENCES `socios` (`id_socio`);

--
-- Constraints for table `reglas_notificacion_destinatarios`
--
ALTER TABLE `reglas_notificacion_destinatarios`
  ADD CONSTRAINT `reglas_notificacion_destinatarios_ibfk_1` FOREIGN KEY (`id_regla`) REFERENCES `reglas_notificacion` (`id_regla`) ON DELETE CASCADE,
  ADD CONSTRAINT `reglas_notificacion_destinatarios_ibfk_2` FOREIGN KEY (`id_rol`) REFERENCES `roles` (`id_rol`);

--
-- Constraints for table `roles_permisos`
--
ALTER TABLE `roles_permisos`
  ADD CONSTRAINT `roles_permisos_ibfk_1` FOREIGN KEY (`id_rol`) REFERENCES `roles` (`id_rol`) ON DELETE CASCADE,
  ADD CONSTRAINT `roles_permisos_ibfk_2` FOREIGN KEY (`id_permiso`) REFERENCES `permisos` (`id_permiso`) ON DELETE CASCADE;

--
-- Constraints for table `roles_usuarios`
--
ALTER TABLE `roles_usuarios`
  ADD CONSTRAINT `roles_usuarios_ibfk_1` FOREIGN KEY (`id_usuario`) REFERENCES `usuarios` (`id_usuario`) ON DELETE CASCADE,
  ADD CONSTRAINT `roles_usuarios_ibfk_2` FOREIGN KEY (`id_rol`) REFERENCES `roles` (`id_rol`) ON DELETE CASCADE;

--
-- Constraints for table `sesiones_mensuales`
--
ALTER TABLE `sesiones_mensuales`
  ADD CONSTRAINT `sesiones_mensuales_ibfk_1` FOREIGN KEY (`usuario_cierre`) REFERENCES `usuarios` (`id_usuario`);

--
-- Constraints for table `solicitudes_retiro`
--
ALTER TABLE `solicitudes_retiro`
  ADD CONSTRAINT `solicitudes_retiro_ibfk_1` FOREIGN KEY (`id_socio`) REFERENCES `socios` (`id_socio`);
COMMIT;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
