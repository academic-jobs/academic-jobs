# ************************************************************
# Sequel Pro SQL dump
# Version 4499
#
# http://www.sequelpro.com/
# https://github.com/sequelpro/sequelpro
#
# Host: 127.0.0.1 (MySQL 5.5.46-0ubuntu0.14.04.2)
# Database: academic
# Generation Time: 2015-12-03 11:10:06 +0000
# ************************************************************


/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8 */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;
/*!40111 SET @OLD_SQL_NOTES=@@SQL_NOTES, SQL_NOTES=0 */;


# Dump of table department
# ------------------------------------------------------------

DROP TABLE IF EXISTS `department`;

CREATE TABLE `department` (
  `id` int(11) unsigned NOT NULL AUTO_INCREMENT,
  `uni_id` int(11) unsigned DEFAULT NULL,
  `sub_ref_id` int(11) unsigned DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `uni_id` (`uni_id`),
  KEY `sub_ref_id` (`sub_ref_id`),
  CONSTRAINT `department_ibfk_2` FOREIGN KEY (`sub_ref_id`) REFERENCES `subject-ref` (`id`),
  CONSTRAINT `department_ibfk_1` FOREIGN KEY (`uni_id`) REFERENCES `university` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;



# Dump of table jobs
# ------------------------------------------------------------

DROP TABLE IF EXISTS `jobs`;

CREATE TABLE `jobs` (
  `id` int(11) unsigned NOT NULL AUTO_INCREMENT,
  `title` varchar(255) NOT NULL DEFAULT '',
  `uni_id` int(11) unsigned NOT NULL,
  `closes` date NOT NULL,
  `main_sub_id` int(11) unsigned NOT NULL,
  `sub_list` mediumtext,
  `text` mediumtext,
  `job_type` varchar(255) NOT NULL DEFAULT '',
  `location` varchar(255) DEFAULT NULL,
  `salary` varchar(255) DEFAULT NULL,
  `job_hours` varchar(255) DEFAULT NULL,
  `contract_type` varchar(255) DEFAULT NULL,
  `placed_on` date DEFAULT NULL,
  `job_ref` varchar(255) DEFAULT NULL,
  `funding_amount` varchar(255) DEFAULT NULL,
  `funding_for` varchar(255) DEFAULT NULL,
  `url` varchar(255) NOT NULL DEFAULT '',
  `qualification_type` varchar(255) DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `uni_id` (`uni_id`),
  KEY `main_sub_id` (`main_sub_id`),
  CONSTRAINT `jobs_ibfk_2` FOREIGN KEY (`main_sub_id`) REFERENCES `subject` (`id`),
  CONSTRAINT `jobs_ibfk_1` FOREIGN KEY (`uni_id`) REFERENCES `university` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;



# Dump of table ref
# ------------------------------------------------------------

DROP TABLE IF EXISTS `ref`;

CREATE TABLE `ref` (
  `id` int(11) unsigned NOT NULL AUTO_INCREMENT,
  `uni_id` int(11) unsigned NOT NULL,
  `ref_dept_id` int(11) unsigned DEFAULT NULL,
  `fourstar` float DEFAULT NULL,
  `threestar` float DEFAULT NULL,
  `twostar` float DEFAULT NULL,
  `onestar` float DEFAULT NULL,
  `fte_sub` float DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `uni_id` (`uni_id`),
  KEY `ref_dept_id` (`ref_dept_id`),
  CONSTRAINT `ref_ibfk_2` FOREIGN KEY (`ref_dept_id`) REFERENCES `ref_dept` (`id`),
  CONSTRAINT `ref_ibfk_1` FOREIGN KEY (`uni_id`) REFERENCES `university` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;



# Dump of table ref_dept
# ------------------------------------------------------------

DROP TABLE IF EXISTS `ref_dept`;

CREATE TABLE `ref_dept` (
  `id` int(11) unsigned NOT NULL AUTO_INCREMENT,
  `ref_dept_name` varchar(255) DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;



# Dump of table statistics
# ------------------------------------------------------------

DROP TABLE IF EXISTS `statistics`;

CREATE TABLE `statistics` (
  `id` int(11) unsigned NOT NULL AUTO_INCREMENT,
  `stat_date` date DEFAULT NULL,
  `dept_id` int(11) unsigned DEFAULT NULL,
  `no_of_jobs` int(11) unsigned DEFAULT NULL,
  `no_of_fourstar` int(11) unsigned DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `dept_id` (`dept_id`),
  CONSTRAINT `statistics_ibfk_1` FOREIGN KEY (`dept_id`) REFERENCES `department` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;



# Dump of table subject
# ------------------------------------------------------------

DROP TABLE IF EXISTS `subject`;

CREATE TABLE `subject` (
  `id` int(11) unsigned NOT NULL AUTO_INCREMENT,
  `main_sub` varchar(255) DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;



# Dump of table subject-ref
# ------------------------------------------------------------

DROP TABLE IF EXISTS `subject-ref`;

CREATE TABLE `subject-ref` (
  `id` int(11) unsigned NOT NULL AUTO_INCREMENT,
  `ref_dept_id` int(11) unsigned DEFAULT NULL,
  `main_sub_id` int(11) unsigned DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `ref_dept_id` (`ref_dept_id`),
  CONSTRAINT `subject-ref_ibfk_1` FOREIGN KEY (`ref_dept_id`) REFERENCES `ref_dept` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;



# Dump of table university
# ------------------------------------------------------------

DROP TABLE IF EXISTS `university`;

CREATE TABLE `university` (
  `id` int(11) unsigned NOT NULL AUTO_INCREMENT,
  `uni_name` varchar(255) DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;




/*!40111 SET SQL_NOTES=@OLD_SQL_NOTES */;
/*!40101 SET SQL_MODE=@OLD_SQL_MODE */;
/*!40014 SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
