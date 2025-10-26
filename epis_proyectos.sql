-- --------------------------------------------------------
-- Host:                         161.132.55.248
-- Versión del servidor:         8.0.43 - MySQL Community Server - GPL
-- SO del servidor:              Win64
-- HeidiSQL Versión:             12.10.0.7000
-- --------------------------------------------------------

/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET NAMES utf8 */;
/*!50503 SET NAMES utf8mb4 */;
/*!40103 SET @OLD_TIME_ZONE=@@TIME_ZONE */;
/*!40103 SET TIME_ZONE='+00:00' */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;
/*!40111 SET @OLD_SQL_NOTES=@@SQL_NOTES, SQL_NOTES=0 */;


-- Volcando estructura de base de datos para epis_proyectos
CREATE DATABASE IF NOT EXISTS `epis_proyectos` /*!40100 DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci */ /*!80016 DEFAULT ENCRYPTION='N' */;
USE `epis_proyectos`;

-- Volcando estructura para tabla epis_proyectos.administradores
CREATE TABLE IF NOT EXISTS `administradores` (
  `id` int NOT NULL AUTO_INCREMENT,
  `nombres` varchar(100) NOT NULL,
  `apellidos` varchar(100) NOT NULL,
  `correo` varchar(150) NOT NULL,
  `numero_telefono` varchar(20) NOT NULL,
  `contrasena_hash` char(64) NOT NULL,
  `fecha_creacion` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `correo` (`correo`)
) ENGINE=InnoDB AUTO_INCREMENT=3 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- Volcando datos para la tabla epis_proyectos.administradores: ~2 rows (aproximadamente)
INSERT INTO `administradores` (`id`, `nombres`, `apellidos`, `correo`, `numero_telefono`, `contrasena_hash`, `fecha_creacion`) VALUES
	(1, 'Admin', 'Principal', 'admin@upt.pe', '999999999', '8c6976e5b5410415bde908bd4dee15dfb167a9c873fc4bb8a81f6f2ab448a918', '2025-10-25 11:45:47'),
	(2, 'Admin Prueba', 'EPIS', 'admin.prueba@example.com', '999999999', '54de7f606f2523cba8efac173fab42fb7f59d56ceff974c8fdb7342cf2cfe345', '2025-10-25 14:38:25');

-- Volcando estructura para tabla epis_proyectos.categorias
CREATE TABLE IF NOT EXISTS `categorias` (
  `id` int NOT NULL AUTO_INCREMENT,
  `concurso_id` int NOT NULL,
  `nombre` varchar(100) NOT NULL,
  `rango_ciclos` varchar(100) DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `uq_categoria_por_concurso` (`concurso_id`,`nombre`),
  KEY `idx_categorias_concurso` (`concurso_id`),
  CONSTRAINT `fk_categorias_concurso` FOREIGN KEY (`concurso_id`) REFERENCES `concursos` (`id`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=4 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- Volcando datos para la tabla epis_proyectos.categorias: ~3 rows (aproximadamente)
INSERT INTO `categorias` (`id`, `concurso_id`, `nombre`, `rango_ciclos`) VALUES
	(1, 1, 'Categoria Junior', 'I a III ciclo'),
	(2, 1, 'Categoria Intermedio', 'IV a VI ciclo'),
	(3, 1, 'Categoria Senior', 'VII a X ciclo');

-- Volcando estructura para tabla epis_proyectos.concursos
CREATE TABLE IF NOT EXISTS `concursos` (
  `id` int NOT NULL AUTO_INCREMENT,
  `nombre` varchar(200) NOT NULL,
  `administrador_id` int NOT NULL,
  `fecha_limite_inscripcion` datetime NOT NULL,
  `fecha_revision` datetime NOT NULL,
  `fecha_confirmacion_aceptados` datetime NOT NULL,
  `fecha_creacion` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `idx_concursos_admin` (`administrador_id`),
  CONSTRAINT `fk_concursos_admin` FOREIGN KEY (`administrador_id`) REFERENCES `administradores` (`id`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=2 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- Volcando datos para la tabla epis_proyectos.concursos: ~1 rows (aproximadamente)
INSERT INTO `concursos` (`id`, `nombre`, `administrador_id`, `fecha_limite_inscripcion`, `fecha_revision`, `fecha_confirmacion_aceptados`, `fecha_creacion`) VALUES
	(1, 'Concurso de Proyectos EPIS', 1, '2025-11-24 11:45:55', '2025-12-09 11:45:55', '2025-12-24 11:45:55', '2025-10-25 11:45:55');

-- Volcando estructura para tabla epis_proyectos.estudiantes
CREATE TABLE IF NOT EXISTS `estudiantes` (
  `id` int NOT NULL AUTO_INCREMENT,
  `nombres` varchar(100) NOT NULL,
  `apellidos` varchar(100) NOT NULL,
  `codigo_universitario` varchar(20) NOT NULL,
  `correo` varchar(150) NOT NULL,
  `numero_telefono` varchar(20) NOT NULL,
  `ciclo` int NOT NULL,
  `contrasena_hash` char(64) NOT NULL,
  `fecha_creacion` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `codigo_universitario` (`codigo_universitario`),
  UNIQUE KEY `correo` (`correo`)
) ENGINE=InnoDB AUTO_INCREMENT=6 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- Volcando datos para la tabla epis_proyectos.estudiantes: ~5 rows (aproximadamente)
INSERT INTO `estudiantes` (`id`, `nombres`, `apellidos`, `codigo_universitario`, `correo`, `numero_telefono`, `ciclo`, `contrasena_hash`, `fecha_creacion`) VALUES
	(1, 'Juan Carlos', 'Pérez', '20200001', 'juan.perez@estudiante.edu.pe', '999111111', 7, '8d969eef6ecad3c29a3a629280e686cf0c3f5d5a86aff3ca12020c923adc6c92', '2025-10-25 11:58:54'),
	(2, 'María Elena', 'García', '20200002', 'maria.garcia@estudiante.edu.pe', '999222222', 5, '8d969eef6ecad3c29a3a629280e686cf0c3f5d5a86aff3ca12020c923adc6c92', '2025-10-25 11:58:54'),
	(3, 'Carlos Alberto', 'Ruiz', '20200003', 'carlos.ruiz@estudiante.edu.pe', '999333333', 9, '8d969eef6ecad3c29a3a629280e686cf0c3f5d5a86aff3ca12020c923adc6c92', '2025-10-25 11:58:54'),
	(4, 'Ana Sofía', 'López', '20200004', 'ana.lopez@estudiante.edu.pe', '999444444', 2, '8d969eef6ecad3c29a3a629280e686cf0c3f5d5a86aff3ca12020c923adc6c92', '2025-10-25 11:58:54'),
	(5, 'Estudiante Prueba', 'EPIS', '20250001', 'estudiante.prueba@example.com', '888888888', 5, '54de7f606f2523cba8efac173fab42fb7f59d56ceff974c8fdb7342cf2cfe345', '2025-10-25 14:40:51');

-- Volcando estructura para tabla epis_proyectos.proyectos
CREATE TABLE IF NOT EXISTS `proyectos` (
  `id` int NOT NULL AUTO_INCREMENT,
  `titulo` varchar(200) NOT NULL,
  `github_url` varchar(255) DEFAULT NULL,
  `zip_url` varchar(255) DEFAULT NULL,
  `estudiante_id` int NOT NULL,
  `concurso_id` int NOT NULL,
  `categoria_id` int NOT NULL,
  `fecha_envio` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `estado` enum('enviado','en_revision','aprobado','rechazado','ganador') NOT NULL DEFAULT 'enviado',
  `comentarios` text,
  `puntuacion` decimal(5,2) DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `fk_proyectos_concurso` (`concurso_id`),
  KEY `idx_proyectos_categoria` (`categoria_id`),
  KEY `idx_proyectos_estudiante` (`estudiante_id`),
  KEY `idx_proyectos_estado` (`estado`),
  CONSTRAINT `fk_proyectos_categoria` FOREIGN KEY (`categoria_id`) REFERENCES `categorias` (`id`) ON DELETE RESTRICT ON UPDATE CASCADE,
  CONSTRAINT `fk_proyectos_concurso` FOREIGN KEY (`concurso_id`) REFERENCES `concursos` (`id`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `fk_proyectos_estudiante` FOREIGN KEY (`estudiante_id`) REFERENCES `estudiantes` (`id`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=5 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- Volcando datos para la tabla epis_proyectos.proyectos: ~4 rows (aproximadamente)
INSERT INTO `proyectos` (`id`, `titulo`, `github_url`, `zip_url`, `estudiante_id`, `concurso_id`, `categoria_id`, `fecha_envio`, `estado`, `comentarios`, `puntuacion`) VALUES
	(1, 'Sistema de Gestión Académica', 'https://github.com/estudiante1/sistema-academico', 'sistema-academico.zip', 1, 1, 3, '2025-10-25 11:59:13', 'enviado', NULL, NULL),
	(2, 'App de Reservas Móvil', 'https://github.com/estudiante2/app-reservas', 'app-reservas.zip', 2, 1, 2, '2025-10-25 11:59:13', 'en_revision', NULL, NULL),
	(3, 'Plataforma de E-learning', 'https://github.com/estudiante3/e-learning', 'e-learning-platform.zip', 3, 1, 3, '2025-10-25 11:59:13', 'aprobado', NULL, NULL),
	(4, 'Sistema de Inventario', 'https://github.com/estudiante4/inventario', 'sistema-inventario.zip', 4, 1, 1, '2025-10-25 11:59:13', 'ganador', NULL, NULL);

/*!40103 SET TIME_ZONE=IFNULL(@OLD_TIME_ZONE, 'system') */;
/*!40101 SET SQL_MODE=IFNULL(@OLD_SQL_MODE, '') */;
/*!40014 SET FOREIGN_KEY_CHECKS=IFNULL(@OLD_FOREIGN_KEY_CHECKS, 1) */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40111 SET SQL_NOTES=IFNULL(@OLD_SQL_NOTES, 1) */;
