/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET NAMES utf8 */;
/*!50503 SET NAMES utf8mb4 */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;
/*!40111 SET @OLD_SQL_NOTES=@@SQL_NOTES, SQL_NOTES=0 */;

CREATE DATABASE IF NOT EXISTS `almezphone` /*!40100 DEFAULT CHARACTER SET utf8 */;
USE `almezphone`;

CREATE TABLE IF NOT EXISTS `phones` (
  `phone_number` varchar(255) NOT NULL,
  `owner` varchar(255) DEFAULT NULL,
  `active` int(11) DEFAULT 1,
  PRIMARY KEY (`phone_number`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

/*!40000 ALTER TABLE `phones` DISABLE KEYS */;
INSERT INTO `phones` (`phone_number`, `owner`, `active`) VALUES
	('0625694444', 'steam:11000011a333b94', 1),
	('0635807291', 'steam:1100001070bb009', 1),
	('0646571180', 'steam:11000011a333b94', 1),
	('0654823133', 'steam:11000011a333b94', 1),
	('0679106987', 'steam:110000133f0ab57', 1),
	('0680221001', 'steam110000120ebbe03', 1),
	('0680287000', 'steam:11000011a333b94', 1),
	('0686222330', 'steam:110000114de54e5', 1);
/*!40000 ALTER TABLE `phones` ENABLE KEYS */;

CREATE TABLE IF NOT EXISTS `phone_messages` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `identifier` varchar(50) DEFAULT NULL,
  `owner_number` varchar(50) DEFAULT NULL,
  `number` varchar(50) DEFAULT NULL,
  `messages` text DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `identifier` (`identifier`),
  KEY `number` (`number`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

/*!40000 ALTER TABLE `phone_messages` DISABLE KEYS */;
INSERT INTO `phone_messages` (`id`, `identifier`, `owner_number`, `number`, `messages`) VALUES
	(6776, 'steam:110000114de54e5', '0686222330', '0646571180', '[{"date":"15-5-2021","messages":[{"message":"SA","data":[],"time":"11:21","type":"message","sender":"steam:110000114de54e5"},{"message":"?? Görüldü atma.","data":[],"time":"11:22","type":"message","sender":"steam:110000114de54e5"},{"message":"bebeğim trafikteyim diyorum niçin inanmıyorsun?","data":[],"time":"11:22","type":"message","sender":"steam:11000011a333b94"},{"message":"Of! Yalancı.","data":[],"time":"11:22","type":"message","sender":"steam:110000114de54e5"},{"message":"ne diyon it","data":[],"time":"17:20","type":"message","sender":"steam:11000011a333b94"}]}]'),
	(6783, 'steam:110000114de54e5', '0686222330', '0646571180', '[{"date":"15-5-2021","messages":[{"message":"SA","data":[],"time":"11:21","type":"message","sender":"steam:110000114de54e5"},{"message":"?? Görüldü atma.","data":[],"time":"11:22","type":"message","sender":"steam:110000114de54e5"},{"message":"bebeğim trafikteyim diyorum niçin inanmıyorsun?","data":[],"time":"11:22","type":"message","sender":"steam:11000011a333b94"},{"message":"Of! Yalancı.","data":[],"time":"11:22","type":"message","sender":"steam:110000114de54e5"},{"message":"ne diyon it","data":[],"time":"17:20","type":"message","sender":"steam:11000011a333b94"}]}]'),
	(6784, 'steam:110000114de54e5', '0646571180', '0686222330', '[]'),
	(6785, 'steam:11000011a333b94', '0646571180', '0686222330', '[{"date":"15-5-2021","messages":[{"message":"SA","data":[],"time":"11:21","type":"message","sender":"steam:110000114de54e5"},{"message":"?? Görüldü atma.","data":[],"time":"11:22","type":"message","sender":"steam:110000114de54e5"},{"message":"bebeğim trafikteyim diyorum niçin inanmıyorsun?","data":[],"time":"11:22","type":"message","sender":"steam:11000011a333b94"},{"message":"Of! Yalancı.","data":[],"time":"11:22","type":"message","sender":"steam:110000114de54e5"},{"message":"ne diyon it","data":[],"time":"17:20","type":"message","sender":"steam:11000011a333b94"}]}]'),
	(6786, 'steam:110000114de54e5', '0686222330', '0646571180', '[{"date":"15-5-2021","messages":[{"message":"SA","data":[],"time":"11:21","type":"message","sender":"steam:110000114de54e5"},{"message":"?? Görüldü atma.","data":[],"time":"11:22","type":"message","sender":"steam:110000114de54e5"},{"message":"bebeğim trafikteyim diyorum niçin inanmıyorsun?","data":[],"time":"11:22","type":"message","sender":"steam:11000011a333b94"},{"message":"Of! Yalancı.","data":[],"time":"11:22","type":"message","sender":"steam:110000114de54e5"},{"message":"ne diyon it","data":[],"time":"17:20","type":"message","sender":"steam:11000011a333b94"}]}]'),
	(6787, 'steam:11000011a333b94', '0646571180', '0686222330', '[{"date":"15-5-2021","messages":[{"message":"SA","data":[],"time":"11:21","type":"message","sender":"steam:110000114de54e5"},{"message":"?? Görüldü atma.","data":[],"time":"11:22","type":"message","sender":"steam:110000114de54e5"},{"message":"bebeğim trafikteyim diyorum niçin inanmıyorsun?","data":[],"time":"11:22","type":"message","sender":"steam:11000011a333b94"},{"message":"Of! Yalancı.","data":[],"time":"11:22","type":"message","sender":"steam:110000114de54e5"},{"message":"ne diyon it","data":[],"time":"17:20","type":"message","sender":"steam:11000011a333b94"}]}]'),
	(6788, 'steam:110000114de54e5', '0686222330', '0646571180', '[{"date":"15-5-2021","messages":[{"message":"SA","data":[],"time":"11:21","type":"message","sender":"steam:110000114de54e5"},{"message":"?? Görüldü atma.","data":[],"time":"11:22","type":"message","sender":"steam:110000114de54e5"},{"message":"bebeğim trafikteyim diyorum niçin inanmıyorsun?","data":[],"time":"11:22","type":"message","sender":"steam:11000011a333b94"},{"message":"Of! Yalancı.","data":[],"time":"11:22","type":"message","sender":"steam:110000114de54e5"},{"message":"ne diyon it","data":[],"time":"17:20","type":"message","sender":"steam:11000011a333b94"}]}]'),
	(6789, 'steam:11000011a333b94', '0646571180', '0686222330', '[{"date":"15-5-2021","messages":[{"message":"SA","data":[],"time":"11:21","type":"message","sender":"steam:110000114de54e5"},{"message":"?? Görüldü atma.","data":[],"time":"11:22","type":"message","sender":"steam:110000114de54e5"},{"message":"bebeğim trafikteyim diyorum niçin inanmıyorsun?","data":[],"time":"11:22","type":"message","sender":"steam:11000011a333b94"},{"message":"Of! Yalancı.","data":[],"time":"11:22","type":"message","sender":"steam:110000114de54e5"},{"message":"ne diyon it","data":[],"time":"17:20","type":"message","sender":"steam:11000011a333b94"}]}]');
/*!40000 ALTER TABLE `phone_messages` ENABLE KEYS */;

CREATE TABLE IF NOT EXISTS `player_contacts` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `phone_number` varchar(50) DEFAULT NULL,
  `name` varchar(50) DEFAULT NULL,
  `number` varchar(50) DEFAULT NULL,
  `iban` varchar(50) NOT NULL DEFAULT '0',
  PRIMARY KEY (`id`),
  KEY `identifier` (`phone_number`) USING BTREE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

/*!40000 ALTER TABLE `player_contacts` DISABLE KEYS */;
INSERT INTO `player_contacts` (`id`, `phone_number`, `name`, `number`, `iban`) VALUES
	(12433, '0617008463', 'Mehmet Ali Tanrıvermiş', '0620374891', '413'),
	(12434, '0617008463', 'Melih Bozkürt', '0645613606', '444'),
	(12435, '0617008463', 'Efe Duman', '0625694444', '223'),
	(12436, '0611754014', '31ci süleyman', '0681076388', '111'),
	(12441, '0681076388', 'Mal Viber', '0617008463', '313'),
	(12443, '0635807291', 'Serhat Malı', '0646571180', '414'),
	(12444, '0646571180', 'Mal Henry', '0635807291', '411'),
	(12445, '0635807291', 'Rick ', '0680221001', '312'),
	(12446, '0646571180', 'aa', '0686222330', '133'),
	(12447, '0646571180', 'Mal', '0686222330', ''),
	(12448, '0646571180', 'basd', '123', '111'),
	(12449, '0646571180', 'c22', '213', '222');
/*!40000 ALTER TABLE `player_contacts` ENABLE KEYS */;

CREATE TABLE IF NOT EXISTS `player_mails` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `phone_number` varchar(50) DEFAULT NULL,
  `sender` varchar(50) DEFAULT NULL,
  `subject` varchar(50) DEFAULT NULL,
  `message` text DEFAULT NULL,
  `read` tinyint(4) DEFAULT 0,
  `mailid` int(11) DEFAULT NULL,
  `date` timestamp NULL DEFAULT current_timestamp(),
  `button` text DEFAULT NULL,
  `messageUrl` longtext DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `identifier` (`phone_number`) USING BTREE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

/*!40000 ALTER TABLE `player_mails` DISABLE KEYS */;
INSERT INTO `player_mails` (`id`, `phone_number`, `sender`, `subject`, `message`, `read`, `mailid`, `date`, `button`, `messageUrl`) VALUES
	(67058, '0620374891', 'vibeR', ' almez', 'Deniyoz bisler', 0, 749918, '2021-06-08 05:23:44', NULL, 'https://cdn.discordapp.com/attachments/783410820604362763/849692449692712970/unknown.png'),
	(67065, '0646571180', 'almez', ' almez', 'qwe', 0, 835503, '2021-06-09 10:03:23', NULL, 'https://cdn.discordapp.com/attachments/783410820604362763/849692449692712970/unknown.png'),
	(67071, '0635807291', 'almez2', ' qwe', 'qwe', 0, 437445, '2021-06-09 14:08:57', NULL, 'https://media.discordapp.net/attachments/848342020057858098/852004950623911977/mqdefault.png'),
	(67072, '0635807291', 'almez2', ' qwe', 'qwe', 0, 227213, '2021-06-09 14:12:53', NULL, 'https://media.discordapp.net/attachments/848342020057858098/852004950623911977/mqdefault.png'),
	(67073, '0635807291', 'almez2', ' qwe', 'qwe', 0, 347927, '2021-06-09 14:13:16', NULL, 'https://media.discordapp.net/attachments/848342020057858098/852004950623911977/mqdefault.png'),
	(67074, '0646571180', 'Darkweb', 'Sipariş', 'Sipariş tamamlandı. Sipariş eline 2021-06-10 09:48:01 tarihinde geçecek. Teslimat yeri için medya kısmına bakın.', 0, 550862, '2021-06-10 08:48:01', NULL, 'https://media.discordapp.net/attachments/808631350105341982/833545626942963742/unknown.png');
/*!40000 ALTER TABLE `player_mails` ENABLE KEYS */;

CREATE TABLE IF NOT EXISTS `twitter_tweets` (
  `id` int(5) NOT NULL AUTO_INCREMENT,
  `owner_phone` varchar(50) DEFAULT NULL,
  `owner` varchar(50) DEFAULT NULL,
  `firstName` varchar(50) DEFAULT NULL,
  `lastName` varchar(50) DEFAULT NULL,
  `message` varchar(50) DEFAULT NULL,
  `url` longtext DEFAULT NULL,
  `time` varchar(50) DEFAULT NULL,
  `picture` longtext DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

/*!40000 ALTER TABLE `twitter_tweets` DISABLE KEYS */;
INSERT INTO `twitter_tweets` (`id`, `owner_phone`, `owner`, `firstName`, `lastName`, `message`, `url`, `time`, `picture`) VALUES
	(56, '0635807291', 'steam:1100001070bb009', 'Henry', 'Watson', 'Hey!', '', '2021-06-10T00:41:03.320Z', 'https://media.discordapp.net/attachments/833438258883985449/852075613492740096/unknown.png'),
	(57, '0646571180', 'steam:11000011a333b94', 'Serhat', 'Almez', 'asdf', '', '2021-06-11T08:53:15.855Z', 'https://media.discordapp.net/attachments/841808446004264962/852076587465310208/unknown.png'),
	(58, '0635807291', 'steam:1100001070bb009', 'Henry', 'Watson', 'asdfd', '', '2021-06-11T08:53:27.923Z', 'https://media.discordapp.net/attachments/833438258883985449/852075613492740096/unknown.png'),
	(59, '0635807291', 'steam:1100001070bb009', 'Henry', 'Watson', '#AnnenÖlsün', '', '2021-06-15T07:27:27.322Z', 'https://media.discordapp.net/attachments/833438258883985449/852075613492740096/unknown.png'),
	(60, '0646571180', 'steam:11000011a333b94', 'Serhat', 'Almez', 'asd', 'https://media.discordapp.net/attachments/703019458679013426/854266907909947442/screenshot.jpg', '2021-06-15T07:51:47.391Z', 'default'),
	(61, '0646571180', 'steam:11000011a333b94', 'Serhat', 'Almez', 'Selam!', 'https://media.discordapp.net/attachments/703019458679013426/854272917922643988/screenshot.jpg', '2021-06-15T08:15:36.293Z', 'default'),
	(62, '0686222330', 'steam:110000114de54e5', 'Mehmet Ali', 'Tanrıvermiş', 'Merhaba!', 'https://media.discordapp.net/attachments/703019458679013426/854273015411376128/screenshot.jpg', '2021-06-15T08:15:58.593Z', 'default'),
	(63, '0646571180', 'steam:11000011a333b94', 'Serhat', 'Almez', 'Naber Mehmet?', '', '2021-06-15T08:22:08.876Z', 'default'),
	(64, '0686222330', 'steam:110000114de54e5', 'Mehmet Ali', 'Tanrıvermiş', 'İyi, senden naber?', '', '2021-06-15T08:22:20.942Z', 'default');
/*!40000 ALTER TABLE `twitter_tweets` ENABLE KEYS */;

/*!40101 SET SQL_MODE=IFNULL(@OLD_SQL_MODE, '') */;
/*!40014 SET FOREIGN_KEY_CHECKS=IFNULL(@OLD_FOREIGN_KEY_CHECKS, 1) */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40111 SET SQL_NOTES=IFNULL(@OLD_SQL_NOTES, 1) */;
