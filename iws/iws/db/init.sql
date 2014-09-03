-- MySQL dump 10.13  Distrib 5.1.40, for unknown-linux-gnu (x86_64)
--
-- Host: localhost    Database: iws
-- ------------------------------------------------------
-- Server version	5.1.40-log

/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8 */;
/*!40103 SET @OLD_TIME_ZONE=@@TIME_ZONE */;
/*!40103 SET TIME_ZONE='+00:00' */;
/*!40014 SET @OLD_UNIQUE_CHECKS=@@UNIQUE_CHECKS, UNIQUE_CHECKS=0 */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;
/*!40111 SET @OLD_SQL_NOTES=@@SQL_NOTES, SQL_NOTES=0 */;

--
-- Table structure for table `action`
--

DROP TABLE IF EXISTS `action`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `action` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `name` varchar(50) NOT NULL,
  `desc` tinytext NOT NULL,
  `act_hook` varchar(200) DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=2 DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `action`
--

LOCK TABLES `action` WRITE;
/*!40000 ALTER TABLE `action` DISABLE KEYS */;
INSERT INTO `action` VALUES (1,'cut_flow','xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx','http://10.81.10.112:8120/index.php/tagmaps');
/*!40000 ALTER TABLE `action` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `issue`
--

DROP TABLE IF EXISTS `issue`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `issue` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `name` varchar(50) DEFAULT NULL,
  `product_id` int(10) unsigned NOT NULL,
  `weight` int(10) unsigned NOT NULL,
  `dashboard_url` varchar(200) DEFAULT NULL,
  `action_list` varchar(100) DEFAULT NULL,
  `alarm_mail` varchar(100) DEFAULT NULL,
  `alarm_sms` varchar(100) DEFAULT NULL,
  `warn_thr` float unsigned DEFAULT '0.9999',
  `error_thr` float unsigned DEFAULT '0.999',
  `query_url` varchar(100) DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=3 DEFAULT CHARSET=utf8 COMMENT='issue desc';
/*!40101 SET character_set_client = @saved_cs_client */;

CREATE TABLE `trace` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `title` varchar(50) DEFAULT NULL,
  `context` text,
  `status` enum('open','close','doing','fixed','pending') NOT NULL,
  `owner` varchar(50),
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=3 DEFAULT CHARSET=utf8 
;

--
-- Dumping data for table `issue`
--

LOCK TABLES `issue` WRITE;
/*!40000 ALTER TABLE `issue` DISABLE KEYS */;
INSERT INTO `issue` VALUES (1,'nginx_ff',1,1,'http://10.50.35.55:8057/home.php','1,1','wenli@baidu.com','13651832128',0.99999,0.9999,'http://10.50.35.55:8057/data/FF.php');
/*!40000 ALTER TABLE `issue` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `issue_data`
--

DROP TABLE IF EXISTS `issue_data`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `issue_data` (
  `time` datetime NOT NULL,
  `issue_id` int(10) unsigned NOT NULL,
  `value` float unsigned NOT NULL,
  UNIQUE KEY `time_issue_id` (`time`,`issue_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `issue_data`
--

LOCK TABLES `issue_data` WRITE;
/*!40000 ALTER TABLE `issue_data` DISABLE KEYS */;
/*!40000 ALTER TABLE `issue_data` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `issue_history`
--

DROP TABLE IF EXISTS `issue_history`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `issue_history` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `start_time` datetime NOT NULL,
  `close_time` datetime NOT NULL,
  `name` varchar(50) NOT NULL,
  `issue_id` int(11) NOT NULL,
  `desc` text,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=127 DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `issue_history`
--

LOCK TABLES `issue_history` WRITE;
/*!40000 ALTER TABLE `issue_history` DISABLE KEYS */;
/*!40000 ALTER TABLE `issue_history` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `issue_kpi`
--

DROP TABLE IF EXISTS `issue_kpi`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `issue_kpi` (
  `month` date NOT NULL,
  `issue_id` int(11) NOT NULL,
  `stability` float NOT NULL,
  `mttr` float NOT NULL,
  `mtbf` int(11) DEFAULT NULL,
  `cnt` int(11) DEFAULT NULL,
  KEY `month_issue_id` (`month`,`issue_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `issue_kpi`
--

LOCK TABLES `issue_kpi` WRITE;
/*!40000 ALTER TABLE `issue_kpi` DISABLE KEYS */;
/*!40000 ALTER TABLE `issue_kpi` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `issue_queue`
--

DROP TABLE IF EXISTS `issue_queue`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `issue_queue` (
  `start_time` datetime NOT NULL,
  `issue_id` int(11) unsigned NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `issue_queue`
--

LOCK TABLES `issue_queue` WRITE;
/*!40000 ALTER TABLE `issue_queue` DISABLE KEYS */;
/*!40000 ALTER TABLE `issue_queue` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `issue_state`
--

DROP TABLE IF EXISTS `issue_state`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `issue_state` (
  `issue_id` int(11) unsigned NOT NULL,
  `state` enum('fine','warn','error','missing') NOT NULL,
  `last_fine` datetime NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `issue_state`
--

LOCK TABLES `issue_state` WRITE;
/*!40000 ALTER TABLE `issue_state` DISABLE KEYS */;
INSERT INTO `issue_state` VALUES (1,'fine','2013-12-31 11:05:02');
/*!40000 ALTER TABLE `issue_state` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `product`
--

DROP TABLE IF EXISTS `product`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `product` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `name` varchar(50) NOT NULL DEFAULT '0',
  `alarm_mail` varchar(100) NOT NULL DEFAULT '0',
  `alarm_sms` varchar(100) NOT NULL DEFAULT '0',
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=2 DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `product`
--

LOCK TABLES `product` WRITE;
/*!40000 ALTER TABLE `product` DISABLE KEYS */;
INSERT INTO `product` VALUES (1,'columbus','wenli@baidu.com','13651832128');
/*!40000 ALTER TABLE `product` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `product_kpi`
--

DROP TABLE IF EXISTS `product_kpi`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `product_kpi` (
  `month` date NOT NULL,
  `product_id` int(11) NOT NULL,
  `stability` float NOT NULL,
  `mttr` float NOT NULL,
  `mtbf` int(11) DEFAULT NULL,
  `cnt` int(11) DEFAULT NULL,
  KEY `month_issue_id` (`month`,`product_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 ROW_FORMAT=COMPACT;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `product_kpi`
--

LOCK TABLES `product_kpi` WRITE;
/*!40000 ALTER TABLE `product_kpi` DISABLE KEYS */;
/*!40000 ALTER TABLE `product_kpi` ENABLE KEYS */;
UNLOCK TABLES;
/*!40103 SET TIME_ZONE=@OLD_TIME_ZONE */;

/*!40101 SET SQL_MODE=@OLD_SQL_MODE */;
/*!40014 SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS */;
/*!40014 SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
/*!40111 SET SQL_NOTES=@OLD_SQL_NOTES */;

-- Dump completed on 2013-12-31 11:05:45
