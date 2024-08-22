
-- MySQL dump 10.13  Distrib 8.0.21, for Win64 (x86_64)
--
-- Host: 127.0.0.1    Database: isanteplus
-- ------------------------------------------------------
-- Server version	5.6.49-log

/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!50503 SET NAMES utf8 */;
/*!40103 SET @OLD_TIME_ZONE=@@TIME_ZONE */;
/*!40103 SET TIME_ZONE='+00:00' */;
/*!40014 SET @OLD_UNIQUE_CHECKS=@@UNIQUE_CHECKS, UNIQUE_CHECKS=0 */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;
/*!40111 SET @OLD_SQL_NOTES=@@SQL_NOTES, SQL_NOTES=0 */;

--
-- Table structure for table `druglookup`
--

DROP TABLE IF EXISTS `druglookup`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `druglookup` (
  `drugLookup_id` int(10) unsigned NOT NULL,
  `drugID` int(10) unsigned NOT NULL DEFAULT '0',
  isanteplus_drug_id int(11),
  isanteplus_drug_uuid char(38),
  `drugName` varchar(255) DEFAULT NULL,
  `drugLabel` varchar(60) DEFAULT NULL,
  `drugGroup` varchar(40) DEFAULT NULL,
  `stdDosageDescription` varchar(255) DEFAULT NULL,
  `shortName` varchar(20) DEFAULT NULL,
  `drugLabelen` varchar(255) DEFAULT NULL,
  `drugLabelfr` varchar(255) DEFAULT NULL,
  `pedStdDosageEn1` varchar(255) DEFAULT NULL,
  `pedStdDosageEn2` varchar(255) DEFAULT NULL,
  `pedStdDosageFr1` varchar(255) DEFAULT NULL,
  `pedStdDosageFr2` varchar(255) DEFAULT NULL,
  `pedDosageLabel` varchar(255) DEFAULT NULL,
  PRIMARY KEY (`drugID`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `druglookup`
--

LOCK TABLES `druglookup` WRITE;
/*!40000 ALTER TABLE `druglookup` DISABLE KEYS */;
INSERT INTO `druglookup` VALUES 
(1,1,70056,NULL,'abacavir','Abacavir (ABC)','NRTIs','300mg BID','ABC','Abacavir (ABC)','Abacavir (ABC)','300mg caplet','20mg/ml liquid','300mg comprim&#xe9;','20mg/ml sirop','qd'),
(2,2,70245,NULL,'acyclovir','Acyclovir','Other Treatments',NULL,'','Acyclovir','Acyclovir',NULL,NULL,NULL,NULL,NULL),
(3,3,NULL, NULL,'amprenavir','Amprenavir (AMP)','Pls','1200mg BID','AMP','Amprenavir (AMP)','Amprenavir (AMP)',NULL,NULL,NULL,NULL,NULL),
(4,4,NULL,NULL,'amprenavirPlusBostRtv','Amprenavir+BostRTV','Pls','1200mg/200mg qd','AMP+BostRTV','Amprenavir+BostRTV','Amprenavir+BostRTV',NULL,NULL,NULL,NULL,NULL),
(5,5,71647,NUll,'atazanavir','Atazanavir (ATZN)','Pls','400mg qd','ATZN','Atazanavir (ATZN)','Atazanavir (ATZN)','150 mg qd',NULL,'150 mg qd',NULL,NULL),
(6,6,159809,NULL,'atazanavirPlusBostRtv','Atazanavir+BostRTV','Pls','300mg/100mg qd','ATZN+BostRTV','Atazanavir+BostRTV','Atazanavir+BostRTV',NULL,NULL,NULL,NULL,NULL),
(7,7,NULL,NULL,'capravirine','Capravirine (CPV)','NNRTIs','1400mg BID','CPV','Capravirine (CPV)','Capravirine (CPV)',NULL,NULL,NULL,NULL,NULL),
(8,8,630,NULL,'combivir','Combivir (AZT+3TC)','NRTIs','300mg/150mg BID','AZT+3TC','Combivir (AZT+3TC)','Combivir (AZT+3TC)','300mg/150mg',NULL,'300mg/150mg',NULL,'BID'),
(9,9,105281,NULL,'cotrimoxazole','Cotrimoxazole (TMS)','Antibiotic',NULL,'TMS','Cotrimoxazole (TMS)','Cotrimoxazole (TMS)',NULL,NULL,NULL,NULL,NULL),
(10,10,74807,NULL,'didanosine','Didanosine (ddI)','NRTIs','EC 400mg qd','ddI','Didanosine (ddI)','Didanosine (ddI)','400mg tablet','10mg/ml liquid','400mg tablette','10mg/ml sirop','qd'),
(11,11,75523,NULL,'efavirenz','Efavirenz (EFV)','NNRTIs','600mg qd','EFV','Efavirenz (EFV)','Efavirenz (EFV)','600mg caplet','30mg/ml liquid','600mg comprim&#xe9;','30mg/ml sirop','qd'),
(12,12,75628,NULL,'emtricitabine','Emtricitabine (FTC)','NRTIs','200mg qd','FTC','Emtricitabine (FTC)','Emtricitabine (FTC)','200mg',NULL,'200mg',NULL,'qd'),
(13,13,75948, NULL,'ethambutol','Ethambutol','Anti-TB',NULL,'','Ethambutol','Ethambutol',NULL,NULL,NULL,NULL,NULL),
(14,14,76488,NULL,'fluconazole','Fluconazole','Antifungal',NULL,'','Fluconazole','Fluconazole',NULL,NULL,NULL,NULL,NULL),
(15,15,NULL,NULL,'fosamprenavir','Fosamprenavir','Pls','1400mg BID','FPV','Fosamprenavir','Fosamprenavir',NULL,NULL,NULL,NULL,NULL),
(16,16,77995,NULL,'indinavir','Indinavir (IDV)','Pls','800mg TID','IDV','Indinavir (IDV)','Indinavir (IDV)',NULL,NULL,NULL,NULL,NULL),
(17,17,NULL,NULL,'indinavirPlusBostRtv','Indinavir+BostRTV','Pls','800mg/200mg BID','IDV+BostRTV','Indinavir+BostRTV','Indinavir+BostRTV',NULL,NULL,NULL,NULL,NULL),
(18,18,78280,NULL,'isoniazid','Isoniazid (INH)','Anti-TB',NULL,'INH','Isoniazid (INH)','Isoniazid (INH)',NULL,NULL,NULL,NULL,NULL),
(19,19,78476,NULL,'ketaconazole','Ketaconazole','Antifungal',NULL,'','Ketaconazole','Ketaconazole',NULL,NULL,NULL,NULL,NULL),
(20,20,78643,NULL,'lamivudine','Lamivudine (3TC)','NRTIs','150mg BID','3TC','Lamivudine (3TC)','Lamivudine (3TC)','150mg caplet','10mg/ml liquid','150mg comprim&#xe9;','10mg/ml sirop','BID'),
(21,21,794,NULL,'lopinavirPlusBostRtv','Lopinavir+BostRTV (Kaletra)','Pls','400mg/100mg BID','Kaletra','Lopinavir+BostRTV (Kaletra)','Lopinavir+BostRTV (Kaletra)','40mg/10mg caplet','80mg/20mg/ml liquid','40mg/10mg capsule','80mg/20mg/ml sirop','BID'),
(22,22,NULL,NULL,'nelfinavir','Nelfinavir (NFV)','Pls','1250mg BID','NFV','Nelfinavir (NFV)','Nelfinavir (NFV)','250mg caplet','200mg/5ml liquid','250mg comprim&#xe9;','200mg/5ml sirop','BID'),
(23,23,80586,NULL,'nevirapine','Nevirapine (NVP)','NNRTIs','200mg BID','NVP','Nevirapine (NVP)','Nevirapine (NVP)','200mg caplet','10mg/ml','200mg comprim&#xe9;','10mg/ml','BID'),
(24,24,82900,NULL,'pyrazinamide','Pyrazinamide','Anti-TB',NULL,'','Pyrazinamide','Pyrazinamide',NULL,NULL,NULL,NULL,NULL),
(25,25,767,NULL,'rifampicine','Rifampicine','Anti-TB',NULL,'','Rifampicine','Rifampicine',NULL,NULL,NULL,NULL,NULL),
(26,26,83412,NULL,'ritonavir','Ritonavir (RTV) FULL','Pls','600mg BID','RTV','Ritonavir (RTV) FULL','Ritonavir (RTV) FULL','100mg caplet','80mg/ml','100mg comprim&#xe9;','80mg/ml','BID'),
(27,27,83690,NULL,'saquinavir','Saquinavir (SQV)','Pls','1200mg BID','SQV','Saquinavir (SQV)','Saquinavir (SQV)','200mg',NULL,'200mg',NULL,'TID'),
(28,28,NULL,NULL,'saquinavirPlusBostRtv','Saquinavir+BostRTV (SQV)','Pls','400mg/400mg BID','SQV','Saquinavir+BostRTV (SQV)','Saquinavir+BostRTV (SQV)',NULL,NULL,NULL,NULL,NULL),
(29,29,84309,NULL,'stavudine','Stavudine (d4T)','NRTIs','40mg BID','d4T','Stavudine (d4T)','Stavudine (d4T)','40mg capsule','1mg/ml liquid','40mg capsule','1mg/ml sirop','BID'),
(30,30,84360,NULL,'streptomycine','Streptomycine','Anti-TB',NULL,'','Streptomycine','Streptomycine',NULL,NULL,NULL,NULL,NULL),
(31,31,84795,NULL,'tenofovir','Tenofovir (TNF)','NRTIs','300mg qd','TNF','Tenofovir (TNF)','Tenofovir (TNF)','300mg',NULL,'300mg',NULL,'qd'),
(32,32,NULL,NULL,'tipranavir','Tipranavir (TPV)','Pls','phase III','TPV','Tipranavir (TPV)','Tipranavir (TPV)',NULL,NULL,NULL,NULL,NULL),
(33,33,817,NULL,'trizivir','Trizivir (ABC+AZT+3TC)','NRTIs','300mg/300mg/150mg BID','ABC+AZT+3TC','Trizivir (ABC+AZT+3TC)','Trizivir (ABC+AZT+3TC)','300mg/300mg/150mg',NULL,'300mg/300mg/150mg',NULL,'BID'),
(34,34,86663,NULL,'zidovudine','Zidovudine (AZT)','NRTIs','300mg BID','AZT','Zidovudine (AZT)','Zidovudine (AZT)','300mg capsule','10mg/ml liquid','300mg capsule','10mg/ml sirop','BID'),
(37,35,NULL,NULL,'traditional','Traditional','Other Treatments',NULL,NULL,'Traditional','Traditional',NULL,NULL,NULL,NULL,NULL),
(39,36,70116,NULL,'acetaminophen','Acetaminophen','Analgesic',NULL,NULL,'Acetaminophen','Acetaminophen',NULL,NULL,NULL,NULL,NULL),
(40,37,71617,NULL,'aspirin','Aspirin','Analgesic',NULL,NULL,'Aspirin','Aspirin',NULL,NULL,NULL,NULL,NULL),
(41,38,77897,NULL,'ibuprofen','Ibuprofen','Analgesic',NULL,NULL,'Ibuprofen','Ibuprofen',NULL,NULL,NULL,NULL,NULL),
(42,39,70116,NULL,'paracetamol','Paracetamol','Analgesic',NULL,NULL,'Paracetamol','Paracetamol',NULL,NULL,NULL,NULL,NULL),
(43,40,NULL,NULL,'tylenol','Tylenol','Analgesic',NULL,NULL,'Tylenol','Tylenol',NULL,NULL,NULL,NULL,NULL),
(44,41,70439,NULL,'albendazol','Albendazol','Antiparasite',NULL,NULL,'Albendazol','Albendazol',NULL,NULL,NULL,NULL,NULL),
(45,42,73449,NULL,'ciprofloxacin','Ciprofloxacin','Antibiotic',NULL,NULL,'Ciprofloxacin','Ciprofloxacin',NULL,NULL,NULL,NULL,NULL),
(46,43,75842,NULL,'erythromycin','Erythromycin','Antibiotic',NULL,NULL,'Erythromycin','Erythromycin',NULL,NULL,NULL,NULL,NULL),
(47,44,79782,NULL,'metromidazole','Metromidazole','Antibiotic',NULL,NULL,'Metromidazole','Metromidazole',NULL,NULL,NULL,NULL,NULL),
(48,45,79831,NULL,'miconazole','Miconazole','Antifungal',NULL,NULL,'Miconazole','Miconazole',NULL,NULL,NULL,NULL,NULL),
(49,46,80945,NULL,'nystatin','Nystatin','Antifungal',NULL,NULL,'Nystatin','Nystatin',NULL,NULL,NULL,NULL,NULL),
(50,47,86341,NULL,'bcomplex','Bcomplex','Micronutrients',NULL,NULL,'B Complex','B Complexe',NULL,NULL,NULL,NULL,NULL),
(51,48,NULL,NULL,'folicacid','Folicacid','Micronutrients',NULL,NULL,'Folic Acid','Acide Folique',NULL,NULL,NULL,NULL,NULL),
(52,49,NULL,NULL,'iron','Iron','Micronutrients',NULL,NULL,'Iron','Fer',NULL,NULL,NULL,NULL,NULL),
(53,50,461,NULL,'multivitamin','Multivitamin','Micronutrients',NULL,NULL,'Multivitamin','Multivitamine',NULL,NULL,NULL,NULL,NULL),
(54,51,82767,NULL,'proteinsupplement','Proteinsupplement','Micronutrients',NULL,NULL,'Protein Supplement','Suppl&#xe9;ment Prot&#xe9;inique',NULL,NULL,NULL,NULL,NULL),
(55,52,71589,NULL,'vitaminc','Vitaminc','Micronutrients',NULL,NULL,'Vitamin C','Vitamine C',NULL,NULL,NULL,NULL,NULL),
(56,53,79037,NULL,'loperamide','Loperamide','Other Treatments',NULL,NULL,'Loperamide','Loperamide',NULL,NULL,NULL,NULL,NULL),
(57,54,82667,NULL,'promethazine','Promethazine','Other Treatments',NULL,NULL,'Promethazine','Promethazine',NULL,NULL,NULL,NULL,NULL),
(58,55,NULL,NULL,'amoxicilline','Amoxicilline','Antibiotic',NULL,NULL,'Amoxicilline','Amoxicilline',NULL,NULL,NULL,NULL,NULL),
(59,56,73498,NULL,'clarithromycin','Clarithromycin','Antibiotic',NULL,NULL,'Clarithromycin','Clarithromycin',NULL,NULL,NULL,NULL,NULL),
(60,57,73546,NULL,'clindamycine','Clindamycine','Antibiotic',NULL,NULL,'Clindamycine','Clindamycine',NULL,NULL,NULL,NULL,NULL),
(61,58,71184,NULL,'amphotericineb','Amphotericine B','Antifungal',NULL,NULL,'Amphotericine B','Amphotericine B',NULL,NULL,NULL,NULL,NULL),
(62,59,78338,NULL,'itraconazole','Itraconazole','Antifungal',NULL,NULL,'Itraconazole','Itraconazole',NULL,NULL,NULL,NULL,NULL),
(63,60,73300,NULL,'chloroquine','Chloroquine','Antiparasite',NULL,NULL,'Chloroquine','Chloroquine',NULL,NULL,NULL,NULL,NULL),
(64,61,NULL,NULL,'pyrimthamine','Pyrimthamine','Antiparasite',NULL,NULL,'Pyrimthamine','Pyrimthamine',NULL,NULL,NULL,NULL,NULL),
(65,62,83023,NULL,'quinine','Quinine','Antiparasite',NULL,NULL,'Quinine','Quinine',NULL,NULL,NULL,NULL,NULL),
(66,63,84459,NULL,'sulfadiazine','Sulfadiazine','Antiparasite',NULL,NULL,'Sulfadiazine','Sulfadiazine',NULL,NULL,NULL,NULL,NULL),
(67,64,78342,NULL,'ivermectine','Ivermectine','Antiparasite',NULL,NULL,'Ivermectine','Ivermectine',NULL,NULL,NULL,NULL,NULL),
(68,65,82912,NULL,'pyridoxine','Pyridoxine','Micronutrients',NULL,NULL,'Pyridoxine','Pyridoxine',NULL,NULL,NULL,NULL,NULL),
(69,66,NULL,NULL,'azythroProph','Azythromycin for MAC prophylaxis','Antibiotic',NULL,NULL,'Azythromycin, <i>MAC prophylaxis indication</i>','Azythromycin, <i>indication de la prophylaxie du MAC</i>',NULL,NULL,NULL,NULL,NULL),
(70,67,NULL,NULL,'azythroOther','Azythromycin for other indication','Antibiotic',NULL,NULL,'Azythromycin, <i>other indication</i>','Azythromycin, <i>autre indication</i>',NULL,NULL,NULL,NULL,NULL),
(71,68,73498,NULL,'clarithromycin','Clarithromycin','Antibiotic',NULL,NULL,'Clarithromycin','Clarithromycin',NULL,NULL,NULL,NULL,NULL),
(72,69,NULL,NULL,'cotrimoxazoleProph','Cotrimoxazole (TMS) for MAC prophylaxis','Antibiotic',NULL,'TMS','Cotrimoxazole (TMS), <i>PCP prophylaxis indication</i>','Cotrimoxazole (TMS), <i>indication de la prophylaxie du PCP</i>',NULL,NULL,NULL,NULL,NULL),
(73,70,NULL,NULL,'cotrimoxazoleOther','Cotrimoxazole (TMS) for other indication','Antibiotic',NULL,'TMS','Cotrimoxazole (TMS), <i>other indication</i>','Cotrimoxazole (TMS), <i>autre indication</i>',NULL,NULL,NULL,NULL,NULL),
(74,71,NULL,NULL,'asa','ASA','Analgesic',NULL,NULL,'ASA','ASA',NULL,NULL,NULL,NULL,NULL),
(75,72,74778,NULL,'diclofenac','Diclofenac Sodium','Analgesic',NULL,NULL,'Diclofenac Sodium','Diclof&#xe9;nac de Sodium',NULL,NULL,NULL,NULL,NULL),
(76,73,NULL,NULL,'amoxicillineclav','Amoxicillin + clavulanic acid','Antibiotic',NULL,NULL,'Amoxicillin + clavulanic acid','Amoxicilline + acide clavulanique',NULL,NULL,NULL,NULL,NULL),
(77,74,71780,NULL,'azithromycin','Azithromycin','Antibiotic',NULL,NULL,'Azithromycin','Azithromycin',NULL,NULL,NULL,NULL,NULL),
(78,75,79413,NULL,'mebendazole','Mebendazol','Antiparasite',NULL,NULL,'Mebendazol','M&#xe9;bendazole',NULL,NULL,NULL,NULL,NULL),
(97,76,72075,NULL,'benzyl','Benzoate de benzyl','Other Treatments',NULL,'benzyl','Benzyl Benzoate','Benzoate de benzyl',NULL,NULL,NULL,NULL,NULL),
(98,77,72401,NULL,'bromhexine','Bromhexine','Other Treatments',NULL,'bromhexine','Bromhexine','Bromhexine',NULL,NULL,NULL,NULL,NULL),
(99,78,493,NULL,'calamine','Calamine','Other Treatments',NULL,'calamine','Calamine','Calamine',NULL,NULL,NULL,NULL,NULL),
(100,79,NULL,NULL,'doxycycline','Doxycycline','Antibiotic',NULL,'doxycycline','Doxycycline','Doxycycline',NULL,NULL,NULL,NULL,NULL),
(101,80,75633,NULL,'enalapril','Enalapril','Other Treatments',NULL,'enalapril','Enalapril','Enalapril',NULL,NULL,NULL,NULL,NULL),
(102,81,77696,NULL,'hctz','Hctz','Other Treatments',NULL,'hctz','hctz','Hctz',NULL,NULL,NULL,NULL,NULL),
(103,82,70994,NULL,'hydroxalum','Hydroxyde d\'aluminium','Other Treatments',NULL,'hydroxalum','Aluminum Hydroxide','Hydroxyde d\'aluminium',NULL,NULL,NULL,NULL,NULL),
(104,83,NULL,NULL,'mucolitique','Mucolitique','Other Treatments',NULL,'mesna','Mucolitique','Mucolitique',NULL,NULL,NULL,NULL,NULL),
(105,84,81724,NULL,'pnc','Pnc','Antibiotic',NULL,'pnc','Pnc','Pnc',NULL,NULL,NULL,NULL,NULL),
(106,85,82521,NULL,'primaquine','Primaquine','Antiparasite',NULL,NULL,'Primaquine','Primaquine',NULL,NULL,NULL,NULL,NULL),
(108,87,154378,NULL,'Raltegravir','Raltegravir','II','400 mg 1Co BID','RAL','Raltegravir','Raltegravir','400 mg BID',NULL,'400 mg BID',NULL,NULL),
(109,88,74258,NULL,'Darunavir','Darunavir','Pls','300mg 2co BID','DRV','Darunavir','Darunavir',NULL,NULL,NULL,NULL,'BID'),
(110,89,165085,NULL,'dolutegravir','Dolutegravir','II','50 mg qd','DTG','Dolutegravir','Dolutegravir','50 mg qd',NULL,'50 mg qd',NULL,NULL),
(111,90,159810,NULL,'etravirine','Etravirine','NNRTIs',NULL,'ETV','Etravirine','Etravirine',NULL,NULL,NULL,NULL,NULL),
(112,91,165093,NULL,'Elviltegravir','Elviltegravir','II','150 mg qd','EVG','Elviltegravir','Elviltegravir','150 mg qd',NULL,'150 mg qd',NULL,NULL);
/*!40000 ALTER TABLE `druglookup` ENABLE KEYS */;
UNLOCK TABLES;
/*!40103 SET TIME_ZONE=@OLD_TIME_ZONE */;

/*!40101 SET SQL_MODE=@OLD_SQL_MODE */;
/*!40014 SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS */;
/*!40014 SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
/*!40111 SET SQL_NOTES=@OLD_SQL_NOTES */;

-- Dump completed on 2021-03-28 22:17:20

/*DELETE FROM openmrs.role WHERE role = 'Application: View reports' AND uuid = 'b12a19bb-7f36-4176-bd91-c503cf7ce80b';
DELETE FROM openmrs.privilege WHERE privilege = 'App: reportingui.reports' AND uuid = '3a0803b1-72a9-4b15-850a-4cbcdedd8e4f';
DELETE FROM openmrs.role_privilege WHERE role = 'Application: View reports' AND privilege = 'App: reportingui.reports';

INSERT INTO openmrs.role (role, description, uuid)
VALUES ('Application: View reports','Able to view reports','b12a19bb-7f36-4176-bd91-c503cf7ce80b');

INSERT INTO openmrs.privilege (privilege, description, uuid)
VALUES ('App: reportingui.reports', 'Able to access reports', '3a0803b1-72a9-4b15-850a-4cbcdedd8e4f');

INSERT INTO openmrs.role_privilege (role, privilege)
VALUES ('Application: View reports', 'App: reportingui.reports');*/
