DROP DATABASE if exists isanteplus; 
create database if not exists isanteplus;
ALTER DATABASE isanteplus CHARACTER SET utf8 COLLATE utf8_general_ci;
SET GLOBAL event_scheduler = 1 ;
SET innodb_lock_wait_timeout = 250;

use isanteplus;

CREATE TABLE if not exists `patient` (
  `identifier` varchar(50) DEFAULT NULL,
  `st_id` varchar(50) DEFAULT NULL,
  `national_id` varchar(50) DEFAULT NULL,
  `patient_id` int(11) NOT NULL,
  `location_id` int(11) DEFAULT NULL,
  `given_name` longtext,
  `family_name` longtext,
  `gender` varchar(10) DEFAULT NULL,
  `birthdate` date DEFAULT NULL,
  `telephone` varchar(50) DEFAULT NULL,
  `last_address` longtext,
  `degree` longtext,
  `vih_status` int(11) DEFAULT 0,
  `arv_status` int(11),
  `mother_name` longtext,
  `occupation` int(11),
  `maritalStatus` int(11),
  `place_of_birth` longtext,
  `creator` varchar(20) DEFAULT NULL,
  `date_created` date DEFAULT NULL,
  `death_date` date DEFAULT NULL,
  `cause_of_death` longtext,
  `first_visit_date` DATETIME,
  `last_visit_date` DATETIME,
  `date_started_arv` DATETIME,
  `next_visit_date` DATE,
  `last_inserted_date` datetime DEFAULT NULL,
  `last_updated_date` datetime DEFAULT NULL,
  `transferred_in` int(11),
  PRIMARY KEY (`patient_id`),
  KEY `location_id` (`location_id`),
  CONSTRAINT `patient_ibfk_1` FOREIGN KEY (`location_id`) REFERENCES openmrs.`location`(`location_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

CREATE TABLE  if not exists `patient_visit` (
  `visit_date` date DEFAULT NULL,
  `visit_id` int(11),
  `encounter_id` int(11) NOT NULL,
  `location_id` int(11) NOT NULL,
  `patient_id` int(11) NOT NULL,
  `start_date` date DEFAULT NULL,
  `stop_date` date DEFAULT NULL,
  `creator` varchar(20) DEFAULT NULL,
  `encounter_type` int(11) DEFAULT NULL,
  `form_id` int(11) DEFAULT NULL,
  `next_visit_date` date DEFAULT NULL,
  `last_insert_date` date DEFAULT NULL,
  last_updated_date DATETIME,
  KEY `location_id` (`location_id`),
  KEY `form_id` (`form_id`),
  KEY `patient_id` (`patient_id`),
  KEY `visit_id` (`visit_id`),
  KEY `patient_visit_ibfk_3_idx` (`patient_id`),
  CONSTRAINT `pk_visit` PRIMARY KEY(patient_id, encounter_id, location_id),
  CONSTRAINT `patient_visit_ibfk_3` FOREIGN KEY (`patient_id`) REFERENCES openmrs.`patient`(`patient_id`) ON DELETE NO ACTION ON UPDATE NO ACTION,
  CONSTRAINT `patient_visit_ibfk_2` FOREIGN KEY (`form_id`) REFERENCES openmrs.`form`(`form_id`),
  CONSTRAINT `patient_visit_ibfk_4` FOREIGN KEY (`location_id`) REFERENCES openmrs.`location`(`location_id`) ON DELETE NO ACTION ON UPDATE NO ACTION
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

/*Debut etl for tb reports*/

CREATE TABLE IF NOT EXISTS patient_tb_diagnosis (
	patient_id int(11) not null,
	provider_id int(11),
	location_id int(11),
	visit_id int(11),
	visit_date Datetime,
	encounter_id INT(11) not null,
	tb_diag int(11),
	mdr_tb_diag int(11),
	tb_new_diag int(11),
	tb_follow_up_diag int(11),
	cough_for_2wks_or_more INT(11),
	tb_pulmonaire INT(11),
	tb_multiresistante INT(11),
	tb_extrapul_ou_diss INT(11),
	tb_treatment_start_date DATE,
	status_tb_treatment INT(11) default 0,
	/*statuts_tb_treatment = Gueri(1),traitement_termine(2),
		Abandon(3),tranfere(4),decede(5), Actif(6)
	*/
	tb_treatment_stop_date DATE,
	last_updated_date DATETIME,
	PRIMARY KEY (`encounter_id`,location_id),
	CONSTRAINT FOREIGN KEY (patient_id) REFERENCES isanteplus.patient(patient_id),
	INDEX(visit_date),
	INDEX(encounter_id),
	INDEX(patient_id)
);
/*Table patient_dispensing for all drugs from the form ordonance medical*/

CREATE TABLE IF NOT EXISTS patient_dispensing (
	patient_id int(11) not null,
	visit_id int(11),
	location_id int(11),
	visit_date Datetime,
	encounter_id int(11) not null,
	provider_id int(11),
	drug_id int(11) not null,
	dose_day int(11),
	pills_amount int(11),
	dispensation_date date,
	next_dispensation_date Date,
	dispensation_location int(11) default 0,
	arv_drug int(11) default 1066, /*1066=No, 1065=YES*/
	rx_or_prophy int(11),
	last_updated_date DATETIME,
	CONSTRAINT pk_patient_dispensing PRIMARY KEY(encounter_id,location_id,drug_id),
    /*CONSTRAINT FOREIGN KEY (patient_id) REFERENCES isanteplus.patient(patient_id),*/
	INDEX(visit_date),
	INDEX(encounter_id),
	INDEX(patient_id)	
);
/*Table patient_imagerie*/

CREATE TABLE IF NOT EXISTS patient_imagerie (
	patient_id int(11) not null,
	location_id int(11),
	visit_id int(11) not null,
	encounter_id int(11) not null,
	visit_date Datetime,
	radiographie_pul int(11) default 0,
	radiographie_autre int(11),
	crachat_barr int(11),
	last_updated_date DATETIME,
	PRIMARY KEY (`location_id`,`encounter_id`),
	CONSTRAINT FOREIGN KEY (patient_id) REFERENCES isanteplus.patient(patient_id),
	INDEX(visit_date),
	INDEX(encounter_id),
	INDEX(patient_id)
);
/*Table that contains all the arv drugs*/
DROP TABLE if exists `arv_drugs`;
CREATE TABLE IF NOT EXISTS arv_drugs(
	id INT(11) NOT NULL AUTO_INCREMENT PRIMARY KEY,
	drug_id INT(11) NOT NULL UNIQUE,
	drug_name longtext NOT NULL,
	date_inserted DATE NOT NULL
);
TRUNCATE TABLE arv_drugs;
INSERT INTO arv_drugs(drug_id,drug_name,date_inserted)
VALUES(70056,'Abacavir(ABC)', DATE(now())),
	  (630,'Combivir(AZT+3TC)', DATE(now())),
	  (74807,'Didanosine(ddI)', DATE(now())),
	  (75628,'Emtricitabine(FTC)', DATE(now())),
	  (78643,'Lamivudine(3TC)', DATE(now())),
	  (84309,'Stavudine(d4T)', DATE(now())),
	  (84795,'Tenofovir(TDF)', DATE(now())),
	  (817,'Trizivir(ABC+AZT+3TC)', DATE(now())),
	  (86663,'Zidovudine(AZT)', DATE(now())),
	  (75523,'Efavirenz(EFV)', DATE(now())),
	  (80586,'Nevirapine(NVP)', DATE(now())),
	  (71647,'Atazanavir(ATV)', DATE(now())),
	  (159809,'Atazanavir+BostRTV', DATE(now())),
	  (77995,'Indinavir(IDV)', DATE(now())),
	  (794,'Lopinavir + BostRTV(Kaletra)', DATE(now())),
	  (74258,'Darunavir', DATE(now())),
	  (154378,'Raltegravir', DATE(now())),
	  (165085,'Dolutegravir(DTG)', DATE(now())),
	  (165093,'Elviltegravir(EVG)', DATE(now())),
	  (80487,'Nelfinavir (NFV)', DATE(now())),
	  (159810,'Etravirine(ETV)', DATE(now())),
	  (83690,'Saquinavir (SQV)', DATE(now()));

/*Table that contains the labels of ARV status*/
DROP TABLE IF EXISTS arv_status_loockup;
	CREATE TABLE IF NOT EXISTS arv_status_loockup(
	id int primary key auto_increment,
	name_en varchar(50),
	name_fr varchar(50),
	definition longtext,
	insertDate date)
	ENGINE=InnoDB DEFAULT CHARSET=utf8;

	insert into arv_status_loockup values 
	(1,'Death on ART','Décédés sous ARV','Tout patient mis sous ARV et ayant un rapport d’arrêt rempli pour motif de décès',date(now())),
	(2,'Transfert','Transférés sous ARV','Tout patient mis sous ARV et ayant un rapport d’arrêt rempli pour motif de transfert',date(now())),
	(3,'Stopped','Arrêtés sous ARV','Tout patient mis sous ARV et ayant un rapport d’arrêt rempli pour motif d’arrêt de traitement',date(now())),
	(4,'Died during the transition period','Décédé durant la période de transition',' Tout patient VIH+ non encore mis sous ARV ayant un rapport d’arrêt rempli pour cause de décès',date(now())),
	(5,'Transferred during the transition period','Transféré durant la période de transition','Tout patient VIH+ non encore mis sous ARV ayant un rapport d’arrêt rempli pour cause de transfert',date(now())),
	(6,'Regular','Réguliers (actifs sous ARV)','Tout patient mis sous ARV et n’ayant aucun rapport d’arrêt rempli pour motifs de décès, de transfert, ni d’arrêt de traitement. La date de prochain rendez-vous clinique ou de prochaine collecte de médicaments est située dans le futur de la période d’analyse. (Fiches à ne pas considérer, labo et counseling)',date(now())),
	(7,'Recent during the transition period','Récent durant la période de transition','Tout patient VIH+ non encore mis sous ARV ayant eu sa première visite (clinique « 1re visite VIH» ) au cours des 12 derniers mois tout en excluant tout patient ayant un rapport d’arrêt avec motifs décédé ou transféré',date(now())),
	(8,'Missing appointment','Rendez-vous ratés sous ARV','Tout patient mis sous ARV et n’ayant aucun rapport d’arrêt rempli pour motifs de décès, de transfert, ni d’arrêt de traitement. La date de la période d’analyse est supérieure à la date de rendez-vous clinique ou de collecte de médicaments la plus récente sans excéder 30 jours',date(now())),
	(9,'Lost to follow-up','Perdus de vue sous ARV','Tout patient mis sous ARV et n’ayant aucun rapport d’arrêt rempli pour motifs de décès, de transfert, ni d’arrêt de traitement. La date de la période d’analyse est supérieure à la date de rendez-vous clinique ou de collecte de médicaments la plus récente de plus de 30 jours',date(now())),
	(10,'Lost of follow up during the transition period','Perdu de vue durant la période de transition','Tout patient VIH+ non encore mis sous ARV n’ayant eu aucune visite (clinique « 1re visite VIH et suivi VIH uniquement », pharmacie, labo) au cours des 12 derniers mois et n’étant ni décédé ni transféré',date(now())),
	(11,'Active during the transition period','Actif durant  la période de transition','Tout patient VIH+ non encore mis sous ARV et ayant eu une visite (clinique de suivi VIH uniquement, ou de pharmacie ou de labo) au cours des 12 derniers mois et n’étant ni décédé ni transféré',date(now())),
	(12,'Discontinued during the transition period','Arrêtés durant la période de transition','Tout patient arrêtés durant la période de transition',date(now())),
	(13,'ongoing','En cours','La somme des patients sous ARV réguliers et ceux ayant raté leurs rendez-vous',date(now()));
 /*Table that contains all patients on ARV*/
	DROP TABLE IF EXISTS patient_on_arv;
	create table if not exists patient_on_arv(
	patient_id int(11),
	visit_id int(11),
	visit_date date,
	last_updated_date DATETIME,
	CONSTRAINT pk_patient_on_arv PRIMARY KEY (patient_id) 
	);
/*Table for all patients with reason of discontinuation
Perte de contact avec le patient depuis plus de trois mois = 5240
Transfert vers un autre établissement=159492
Décès=159
Discontinuations=1667
Raison d'arrêt inconnue=1067
*/
 DROP TABLE IF EXISTS discontinuation_reason;
	create table if not exists discontinuation_reason(
	patient_id int(11),
	visit_id int(11),
	visit_date date,
	reason int(11),
	reason_name longtext,
	last_updated_date DATETIME,
	CONSTRAINT pk_dreason PRIMARY KEY (patient_id,visit_id,reason)
	) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*Create a table for raison arretés concept_id = 1667, 
		answer_concept_id IN (1754,160415,115198,159737,5622)
		That table allow us to delete from the table discontinuation_reason
		WHERE the discontinuation_raison (arretés raison) not in Adhérence inadéquate=115198
		AND Préférence du patient=159737
		*/
	DROP TABLE IF EXISTS stopping_reason;
	create table if not exists stopping_reason(
	patient_id int(11),
	visit_id int(11),
	visit_date date,
	reason int(11),
	reason_name longtext,
	other_reason longtext,
	last_updated_date DATETIME,
	CONSTRAINT pk_stop_reason PRIMARY KEY (patient_id,visit_id,reason)
	);
/*Table patient_status_ARV contains all patients and their status*/
	DROP TABLE IF EXISTS patient_status_arv;
	create table if not exists patient_status_arv(
	patient_id int(11),
	id_status int,
	start_date date,
	end_date date,
	dis_reason int(11),
	last_updated_date DATETIME,
	CONSTRAINT pk_patient_status_arv PRIMARY KEY (patient_id,id_status,start_date)
	);
	
/*Create table for medicaments prescrits*/
DROP TABLE IF EXISTS patient_prescription;
CREATE TABLE IF NOT EXISTS patient_prescription (
	patient_id int(11) not null,
	visit_id int(11),
	location_id int(11),
	visit_date Datetime,
	encounter_id int(11) not null,
	provider_id int(11),
	drug_id int(11) not null,
	next_dispensation_date DATE,
	dispensation_location int(11) default 0, 
	arv_drug int(11) default 1066, /*1066=No, 1065=YES*/
	dispense int(11), /*1066=No, 1065=YES*/
	rx_or_prophy int(11),
    posology text,
    number_day int(11),	
	last_updated_date DATETIME,
	CONSTRAINT pk_patient_prescription PRIMARY KEY(encounter_id,location_id,drug_id),
	INDEX(visit_date),
	INDEX(encounter_id),
	INDEX(patient_id)	
);

 /*Create table for lab*/
	DROP TABLE IF EXISTS patient_laboratory;
	CREATE TABLE IF NOT EXISTS patient_laboratory(
		patient_id int(11) not null,
		visit_id int(11),
		location_id int(11),
		visit_date Datetime,
		encounter_id int(11) not null,
		provider_id int(11),
		test_id int(11) not null,
		test_done int(11) default 0,
		test_result text,
		date_test_done DATE,
		comment_test_done text,
		order_destination  varchar(50),
    	test_name text,
		last_updated_date DATETIME,
		CONSTRAINT pk_patient_laboratory PRIMARY KEY (patient_id,encounter_id,test_id),
		INDEX(visit_date),
		INDEX(encounter_id),
		INDEX(patient_id)	
	);
	
	DROP TABLE IF EXISTS patient_pregnancy;
	CREATE TABLE IF NOT EXISTS patient_pregnancy(
	patient_id int(11),
	encounter_id int(11),
	start_date date,
	end_date date,
	last_updated_date DATETIME,
	CONSTRAINT pk_patient_preg PRIMARY KEY (patient_id,encounter_id));
	
	/*Create table alert_lookup*/
	DROP TABLE IF EXISTS alert_lookup;
	CREATE TABLE IF NOT EXISTS alert_lookup(
		id int primary key auto_increment,
		message_fr text,
		message_en text,
		libelle text,
		insert_date date
	) ENGINE=InnoDB DEFAULT CHARSET=utf8;
	/*table alert_lookup insertion*/
	INSERT INTO alert_lookup(id,libelle,message_fr,message_en,insert_date) VALUES 
	(1,'Nombre de patient sous ARV depuis 6 mois sans un résultat de charge virale',
	'Le patient est sous ARV depuis 6 mois sans un résultat de charge virale',
	'Patients 6 months after ART initiation',DATE(now())),
	(2,'Patients sous ARV depuis 5 mois sans un résultat de charge virale',
	'Le patient sous  ARV depuis 5 mois sans un résultat de charge virale',
	'Patients 5 months after ART initiation',DATE(now())),
	(3,'Nombre de femmes enceintes, sous ARV depuis 4 mois sans un résultat de charge virale',
	'La patiente est enceinte, sous ARV depuis 4 mois sans un résultat de charge virale',
	'Pregnant woman 4 months after ART initiation',DATE(now())),
	(4,'Nombre de patients ayant leur dernière charge virale remontant à au moins 12 mois',
	'La dernière charge virale de ce patient remonte à au moins 12 mois',
	'Patient whose last viral load test was performed 12 months prior',DATE(now())),
	(5,'Nombre de patients ayant leur dernière charge virale remontant à au moins 3 mois et dont le résultat était > 1000 copies/ml',
	'La dernière charge virale de ce patient remonte à au moins 3 mois et le résultat était > 1000 copies/ml',
	'Patient  whose viral test result was greater than 1000 copies and was performed 3 months ago',DATE(now())),
	(6,'Patient avec une dernière charge viral >1000 copies/ml',
	'La dernière charge virale du patient est >1000 copies/ml','Patient with a VL test of >1000 copies',DATE(now())),
	(7,'Tout patient dont la prochaine date de dispensation (next_disp) arrive dans les 30 
	prochains jours par rapport à la date de consultation actuelle','Le patient doit venir renflouer ses ARV dans les 30 prochains jours',
	'The patient must replenish his ARVs within the next 30 days',DATE(now())),
	(8,'Tout patient dont la prochaine date de dispensation (next_disp) se situe 
	dans le passe par rapport à la date de consultation actuelle',
	'Le patient n a plus de médicaments disponibles','Patient no longer has medications available',DATE(now())),
	(9,'Patient sous ARV et traitement anti tuberculeux',
	'Patient sous ARV et traitement anti tuberculeux','Patient on ARV and anti-tuberculosis treatment',DATE(now()));
	
	
	/*Create table alert*/
	DROP TABLE IF EXISTS alert;
	CREATE TABLE IF NOT EXISTS alert(
	id int primary key auto_increment,
	patient_id int(11),
	id_alert int(11),
	encounter_id int(11),
	date_alert date,
	last_updated_date DATETIME)
	ENGINE=InnoDB DEFAULT CHARSET=utf8;
	
	/*TABLE patient_diagnosis, this table contains all patient diagnosis*/	
DROP TABLE IF EXISTS patient_diagnosis;
CREATE TABLE IF NOT EXISTS patient_diagnosis(
	patient_id int(11),
	encounter_id int(11),
	location_id int(11),
	encounter_date date,
	concept_group int(11),
	obs_group_id int(11),
	concept_id int(11),
	answer_concept_id int(11),
	suspected_confirmed int(11),
	primary_secondary int(11),
	last_updated_date DATETIME,
	constraint pk_patient_diagnosis 
	PRIMARY KEY (encounter_id,location_id,concept_group,concept_id,answer_concept_id)
);

/*Table visit_type for visit_type like : Gynécologique=160456,Prénatale=1622,
Postnatale=1623,Planification familiale=5483 (ex: OBGYN FORM) */
DROP TABLE IF EXISTS visit_type;
	CREATE TABLE IF NOT EXISTS visit_type(
	patient_id int(11),
	encounter_id int(11),
	location_id int(11),
	visit_id int(11),
	obs_group int(11) DEFAULT 0,
	concept_id int(11),
	v_type int(11),
	encounter_date date,
	last_updated_date DATETIME,
	CONSTRAINT pk_isanteplus_visit_type 
	PRIMARY KEY (encounter_id,location_id,obs_group,concept_id,v_type));

/*Create table virological_tests */
DROP TABLE IF EXISTS virological_tests;
 CREATE TABLE IF NOT EXISTS virological_tests(
	patient_id int(11),
	encounter_id int(11),
	location_id int(11),
	encounter_date date,
	concept_group int(11),
	obs_group_id int(11),
    test_id int(11),
	answer_concept_id int(11),
	test_result int(11),
	age int(11),
	age_unit int(11),
	test_date date,
	last_updated_date DATETIME,
	constraint pk_virological_tests PRIMARY KEY (encounter_id,location_id,obs_group_id,test_id));
	
/* Create patient_delivery table */
DROP TABLE IF EXISTS patient_delivery;
CREATE TABLE IF NOT EXISTS patient_delivery(
	patient_id int(11),
	encounter_id int(11),
	location_id int(11),
	delivery_date datetime,
	delivery_location int(11),
	vaginal int(11),
	forceps int(11),
	vacuum int(11),
	delivrance int(11),
	encounter_date date,
	last_updated_date DATETIME,
	constraint pk_patient_delivery PRIMARY KEY (encounter_id,location_id));
/*Create table pediatric_first_visit*/		   
	DROP TABLE IF EXISTS pediatric_hiv_visit;
	CREATE TABLE IF NOT EXISTS pediatric_hiv_visit(
	patient_id int(11),
	encounter_id int(11),
	location_id int(11),
	ptme int(11),
	prophylaxie72h int(11),
	actual_vih_status int(11),
	encounter_date date,
	constraint pk_pediatric_hiv_visit PRIMARY KEY (patient_id,encounter_id,location_id));
	
	/*Create table patient_menstruation*/		   
	DROP TABLE IF EXISTS patient_menstruation;
	CREATE TABLE IF NOT EXISTS patient_menstruation(
	patient_id int(11),
	encounter_id int(11),
	location_id int(11),
	duree_regle int(11),
	duree_cycle int(11),
	ddr date,
	encounter_date date,
	last_updated_date DATETIME,
	constraint pk_patient_menstruation PRIMARY KEY (patient_id,encounter_id,location_id));
	
	/*Create table for vih_risk_factor*/
	DROP TABLE IF EXISTS vih_risk_factor;
	CREATE TABLE IF NOT EXISTS vih_risk_factor(
	patient_id int(11),
	encounter_id int(11),
	location_id int(11),
	risk_factor int(11),
	encounter_date date,
	last_updated_date DATETIME,
	constraint pk_vih_risk_factor PRIMARY KEY (patient_id,encounter_id,location_id,risk_factor));

	/*Create table for vaccinations*/
	DROP TABLE IF EXISTS vaccination;
	CREATE TABLE IF NOT EXISTS vaccination(
	patient_id int(11),
	encounter_id int(11),
	encounter_date date,
	location_id int(11),
	age_range int(11),
	vaccination_done boolean DEFAULT false,
	constraint pk_vaccination PRIMARY KEY (patient_id,encounter_id,location_id));

	/*Create table for health qual visits*/
	DROP TABLE IF EXISTS health_qual_patient_visit;
	CREATE TABLE IF NOT EXISTS health_qual_patient_visit(
	patient_id int(11),
	encounter_id int(11),
	visit_date date,
	visit_id int(11),
	location_id int(11),
	encounter_type int(11) DEFAULT NULL,
	patient_bmi double DEFAULT NULL,
	adherence_evaluation int(11) DEFAULT NULL,
	family_planning_method_used boolean DEFAULT false,
	evaluated_of_tb boolean DEFAULT false,
	nutritional_assessment_completed boolean DEFAULT false,
	is_active_tb boolean DEFAULT false,
	age_in_years int(11),
	last_insert_date date DEFAULT NULL,
	last_updated_date DATETIME,
	constraint pk_health_qual_patient_visit PRIMARY KEY (patient_id, encounter_id, location_id));
	/*Eposed infants table
		
	*/
	DROP TABLE IF EXISTS exposed_infants;
	CREATE table IF NOT EXISTS exposed_infants(
		patient_id int(11),
		location_id int(11),
		encounter_id int(11),
		visit_date date,
		condition_exposee int(11)
	);
	/*serological_tests table*/
	DROP TABLE IF EXISTS serological_tests;
 CREATE TABLE IF NOT EXISTS serological_tests(
	patient_id int(11),
	encounter_id int(11),
	location_id int(11),
	encounter_date date,
	concept_group int(11),
	obs_group_id int(11),
    test_id int(11),
	answer_concept_id int(11),
	test_result int(11),
	age int(11),
	age_unit int(11),
	test_date date,
	last_updated_date DATETIME,
	constraint pk_serological_tests PRIMARY KEY (encounter_id,location_id,obs_group_id,test_id));
	
	/*Create table patient_pcr*/
	DROP TABLE IF EXISTS patient_pcr;
	CREATE TABLE IF NOT EXISTS patient_pcr(
		patient_id int(11),
		encounter_id int(11),
		location_id int(11),
		visit_date date,
		pcr_result int(11),
		test_date date,
		last_updated_date DATETIME
	);
	
	
	DROP TABLE if exists regimen;
CREATE TABLE regimen
(
	regID INT(11) PRIMARY KEY,
	regimenName VARCHAR(255),
	drugID1 INT(11),
	drugID2 INT(11),
	drugID3 INT(11),
	shortName VARCHAR(255) NOT NULL,
	regGroup VARCHAR(255)
);

CREATE TABLE if not exists pepfarTable (
	location_id INT(11),
	patient_id INT(11),
	visit_date DATE, 
	regimen VARCHAR(255),
	rx_or_prophy INT(11),
	last_updated_date DATETIME,
	CONSTRAINT pk_pepfarTable_primary_key PRIMARY KEY (location_id, patient_id, visit_date, regimen)
	);

insert into regimen(regID,regimenName,drugID1,drugID2,drugID3,shortName,regGroup) values(1,'1stReg1',84309,78643,80586,'d4T-3TC-NVP','1stReg1');
insert into regimen(regID,regimenName,drugID1,drugID2,drugID3,shortName,regGroup) values(2,'1stReg2',84309,78643,75523,'d4T-3TC-EFV','1stReg2');
insert into regimen(regID,regimenName,drugID1,drugID2,drugID3,shortName,regGroup) values(3,'1stReg3a',86663,78643,80586,'ZDV-3TC-NVP','1stReg3');
insert into regimen(regID,regimenName,drugID1,drugID2,drugID3,shortName,regGroup) values(5,'1stReg4a',86663,78643,75523,'ZDV-3TC-EFV','1stReg4');
insert into regimen(regID,regimenName,drugID1,drugID2,drugID3,shortName,regGroup) values(7,'2ndAdult1',86663,74807,794,'ZDV-ddI-LPV/r','2ndAdult1');
insert into regimen(regID,regimenName,drugID1,drugID2,drugID3,shortName,regGroup) values(8,'2ndAdult2',84309,74807,794,'d4T-ddI-LPV/r','2ndAdult2');
insert into regimen(regID,regimenName,drugID1,drugID2,drugID3,shortName,regGroup) values(9,'2ndChild1',84309,74807,80487,'d4T-ddI-NFV','2ndChild1');
insert into regimen(regID,regimenName,drugID1,drugID2,drugID3,shortName,regGroup) values(10,'1stReg8a',817,'0','0','ZDV-3TC-ABC','1stReg8');
insert into regimen(regID,regimenName,drugID1,drugID2,drugID3,shortName,regGroup) values(11,'2ndAdult3',86663,74807,77995,'ZDV-ddI-IDV','2ndAdult3');
insert into regimen(regID,regimenName,drugID1,drugID2,drugID3,shortName,regGroup) values(12,'2ndAdult4',86663,74807,80487,'ZDV-ddI-NFV','2ndAdult4');
insert into regimen(regID,regimenName,drugID1,drugID2,drugID3,shortName,regGroup) values(13,'1stReg7',84795,75628,75523,'FTC-TNF-EFV','1stReg7');
insert into regimen(regID,regimenName,drugID1,drugID2,drugID3,shortName,regGroup) values(14,'1stReg8b',86663,78643,70056,'ZDV-3TC-ABC','1stReg8');
insert into regimen(regID,regimenName,drugID1,drugID2,drugID3,shortName,regGroup) values(15,'1stReg8c',630,70056,'0','ZDV-3TC-ABC','1stReg8');
insert into regimen(regID,regimenName,drugID1,drugID2,drugID3,shortName,regGroup) values(16,'1stReg9',70056,74807,75628,'ABC-ddI-FTC','1stReg9');
insert into regimen(regID,regimenName,drugID1,drugID2,drugID3,shortName,regGroup) values(17,'1stReg10',70056,74807,78643,'ABC-ddI-3TC','1stReg10');
insert into regimen(regID,regimenName,drugID1,drugID2,drugID3,shortName,regGroup) values(18,'1stReg11',70056,74807,84309,'ABC-ddI-d4T','1stReg11');
insert into regimen(regID,regimenName,drugID1,drugID2,drugID3,shortName,regGroup) values(19,'1stReg12',70056,74807,86663,'ABC-ddI-ZDV','1stReg12');
insert into regimen(regID,regimenName,drugID1,drugID2,drugID3,shortName,regGroup) values(20,'1stReg13',70056,74807,84795,'ABC-ddI-TNF','1stReg13');
insert into regimen(regID,regimenName,drugID1,drugID2,drugID3,shortName,regGroup) values(21,'1stReg14',70056,74807,75523,'ABC-ddI-EFV','1stReg14');
insert into regimen(regID,regimenName,drugID1,drugID2,drugID3,shortName,regGroup) values(22,'1stReg15',70056,74807,80586,'ABC-ddI-NVP','1stReg15');
insert into regimen(regID,regimenName,drugID1,drugID2,drugID3,shortName,regGroup) values(23,'1stReg16',70056,75628,78643,'ABC-FTC-3TC','1stReg16');
insert into regimen(regID,regimenName,drugID1,drugID2,drugID3,shortName,regGroup) values(24,'1stReg17',70056,75628,84309,'ABC-FTC-d4T','1stReg17');
insert into regimen(regID,regimenName,drugID1,drugID2,drugID3,shortName,regGroup) values(25,'1stReg18',70056,75628,84795,'ABC-FTC-TNF','1stReg18');
insert into regimen(regID,regimenName,drugID1,drugID2,drugID3,shortName,regGroup) values(26,'1stReg19',70056,75628,86663,'ABC-FTC-ZDV','1stReg19');
insert into regimen(regID,regimenName,drugID1,drugID2,drugID3,shortName,regGroup) values(27,'1stReg20',70056,75628,75523,'ABC-FTC-EFV','1stReg20');
insert into regimen(regID,regimenName,drugID1,drugID2,drugID3,shortName,regGroup) values(28,'1stReg21',70056,75628,80586,'ABC-FTC-NVP','1stReg21');
insert into regimen(regID,regimenName,drugID1,drugID2,drugID3,shortName,regGroup) values(29,'1stReg22',70056,78643,84309,'ABC-3TC-d4T','1stReg22');
insert into regimen(regID,regimenName,drugID1,drugID2,drugID3,shortName,regGroup) values(30,'1stReg23',70056,78643,84795,'ABC-3TC-TNF','1stReg23');
insert into regimen(regID,regimenName,drugID1,drugID2,drugID3,shortName,regGroup) values(31,'1stReg24',70056,78643,75523,'ABC-3TC-EFV','1stReg24');
insert into regimen(regID,regimenName,drugID1,drugID2,drugID3,shortName,regGroup) values(32,'1stReg25',70056,78643,80586,'ABC-3TC-NVP','1stReg25');
insert into regimen(regID,regimenName,drugID1,drugID2,drugID3,shortName,regGroup) values(33,'1stReg26',70056,84309,84795,'ABC-d4T-TNF','1stReg26');
insert into regimen(regID,regimenName,drugID1,drugID2,drugID3,shortName,regGroup) values(34,'1stReg27',70056,84309,86663,'ABC-d4T-ZDV','1stReg27');
insert into regimen(regID,regimenName,drugID1,drugID2,drugID3,shortName,regGroup) values(35,'1stReg28',70056,84309,75523,'ABC-d4T-EFV','1stReg28');
insert into regimen(regID,regimenName,drugID1,drugID2,drugID3,shortName,regGroup) values(36,'1stReg29',70056,84309,80586,'ABC-d4T-NVP','1stReg29');
insert into regimen(regID,regimenName,drugID1,drugID2,drugID3,shortName,regGroup) values(37,'1stReg30',70056,84795,86663,'ABC-TNF-ZDV','1stReg30');
insert into regimen(regID,regimenName,drugID1,drugID2,drugID3,shortName,regGroup) values(38,'1stReg31',70056,84795,75523,'ABC-TNF-EFV','1stReg31');
insert into regimen(regID,regimenName,drugID1,drugID2,drugID3,shortName,regGroup) values(39,'1stReg32',70056,84795,80586,'ABC-TNF-NVP','1stReg32');
insert into regimen(regID,regimenName,drugID1,drugID2,drugID3,shortName,regGroup) values(40,'1stReg33',70056,86663,75523,'ABC-ZDV-EFV','1stReg33');
insert into regimen(regID,regimenName,drugID1,drugID2,drugID3,shortName,regGroup) values(41,'1stReg34',70056,86663,80586,'ABC-ZDV-NVP','1stReg34');
insert into regimen(regID,regimenName,drugID1,drugID2,drugID3,shortName,regGroup) values(42,'1stReg35a',86663,78643,74807,'ZDV-3TC-ddI','1stReg35');
insert into regimen(regID,regimenName,drugID1,drugID2,drugID3,shortName,regGroup) values(43,'1stReg36a',86663,78643,75628,'ZDV-3TC-FTC','1stReg36');
insert into regimen(regID,regimenName,drugID1,drugID2,drugID3,shortName,regGroup) values(44,'1stReg37a',86663,78643,84309,'ZDV-3TC-d4T','1stReg37');
insert into regimen(regID,regimenName,drugID1,drugID2,drugID3,shortName,regGroup) values(45,'1stReg38a',86663,78643,84795,'ZDV-3TC-TNF','1stReg38');
insert into regimen(regID,regimenName,drugID1,drugID2,drugID3,shortName,regGroup) values(46,'1stReg39',74807,75628,78643,'ddI-FTC-3TC','1stReg39');
insert into regimen(regID,regimenName,drugID1,drugID2,drugID3,shortName,regGroup) values(47,'1stReg40',74807,75628,84309,'ddI-FTC-d4T','1stReg40');
insert into regimen(regID,regimenName,drugID1,drugID2,drugID3,shortName,regGroup) values(48,'1stReg41',74807,75628,84795,'ddI-FTC-TNF','1stReg41');
insert into regimen(regID,regimenName,drugID1,drugID2,drugID3,shortName,regGroup) values(49,'1stReg42',74807,75628,86663,'ddI-FTC-ZDV','1stReg42');
insert into regimen(regID,regimenName,drugID1,drugID2,drugID3,shortName,regGroup) values(50,'1stReg43',74807,75628,75523,'ddI-FTC-EFV','1stReg43');
insert into regimen(regID,regimenName,drugID1,drugID2,drugID3,shortName,regGroup) values(51,'1stReg44',74807,75628,80586,'ddI-FTC-NVP','1stReg44');
insert into regimen(regID,regimenName,drugID1,drugID2,drugID3,shortName,regGroup) values(52,'1stReg45',74807,78643,84309,'ddI-3TC-d4T','1stReg45');
insert into regimen(regID,regimenName,drugID1,drugID2,drugID3,shortName,regGroup) values(53,'1stReg46',74807,78643,84795,'ddI-3TC-TNF','1stReg46');
insert into regimen(regID,regimenName,drugID1,drugID2,drugID3,shortName,regGroup) values(55,'1stReg48',74807,78643,75523,'ddI-3TC-EFV','1stReg48');
insert into regimen(regID,regimenName,drugID1,drugID2,drugID3,shortName,regGroup) values(56,'1stReg49',74807,78643,80586,'ddI-3TC-NVP','1stReg49');
insert into regimen(regID,regimenName,drugID1,drugID2,drugID3,shortName,regGroup) values(57,'1stReg50',74807,84309,84795,'ddI-d4T-TNF','1stReg50');
insert into regimen(regID,regimenName,drugID1,drugID2,drugID3,shortName,regGroup) values(58,'1stReg51',74807,84309,86663,'ddI-d4T-ZDV','1stReg51');
insert into regimen(regID,regimenName,drugID1,drugID2,drugID3,shortName,regGroup) values(59,'1stReg52',74807,84309,75523,'ddI-d4T-EFV','1stReg52');
insert into regimen(regID,regimenName,drugID1,drugID2,drugID3,shortName,regGroup) values(60,'1stReg53',74807,84309,80586,'ddI-d4T-NVP','1stReg53');
insert into regimen(regID,regimenName,drugID1,drugID2,drugID3,shortName,regGroup) values(61,'1stReg54',74807,84795,86663,'ddI-TNF-ZDV','1stReg54');
insert into regimen(regID,regimenName,drugID1,drugID2,drugID3,shortName,regGroup) values(62,'1stReg55',74807,84795,75523,'ddI-TNF-EFV','1stReg55');
insert into regimen(regID,regimenName,drugID1,drugID2,drugID3,shortName,regGroup) values(63,'1stReg56',74807,84795,80586,'ddI-TNF-NVP','1stReg56');
insert into regimen(regID,regimenName,drugID1,drugID2,drugID3,shortName,regGroup) values(64,'1stReg57',74807,86663,75523,'ddI-ZDV-EFV','1stReg57');
insert into regimen(regID,regimenName,drugID1,drugID2,drugID3,shortName,regGroup) values(65,'1stReg58',74807,86663,80586,'ddI-ZDV-NVP','1stReg58');
insert into regimen(regID,regimenName,drugID1,drugID2,drugID3,shortName,regGroup) values(66,'1stReg59',75628,78643,84309,'FTC-3TC-d4T','1stReg59');
insert into regimen(regID,regimenName,drugID1,drugID2,drugID3,shortName,regGroup) values(67,'1stReg60',75628,78643,84795,'FTC-3TC-TNF','1stReg60');
insert into regimen(regID,regimenName,drugID1,drugID2,drugID3,shortName,regGroup) values(69,'1stReg62',75628,78643,75523,'FTC-3TC-EFV','1stReg62');
insert into regimen(regID,regimenName,drugID1,drugID2,drugID3,shortName,regGroup) values(70,'1stReg63',75628,78643,80586,'FTC-3TC-NVP','1stReg63');
insert into regimen(regID,regimenName,drugID1,drugID2,drugID3,shortName,regGroup) values(71,'1stReg64',75628,84309,84795,'FTC-d4T-TNF','1stReg64');
insert into regimen(regID,regimenName,drugID1,drugID2,drugID3,shortName,regGroup) values(72,'1stReg65',75628,84309,86663,'FTC-d4T-ZDV','1stReg65');
insert into regimen(regID,regimenName,drugID1,drugID2,drugID3,shortName,regGroup) values(73,'1stReg66',75628,84309,75523,'FTC-d4T-EFV','1stReg66');
insert into regimen(regID,regimenName,drugID1,drugID2,drugID3,shortName,regGroup) values(74,'1stReg67',75628,84309,80586,'FTC-d4T-NVP','1stReg67');
insert into regimen(regID,regimenName,drugID1,drugID2,drugID3,shortName,regGroup) values(75,'1stReg68',75628,84795,86663,'FTC-TNF-ZDV','1stReg68');
insert into regimen(regID,regimenName,drugID1,drugID2,drugID3,shortName,regGroup) values(76,'1stReg69',75628,84795,80586,'FTC-TNF-NVP','1stReg69');
insert into regimen(regID,regimenName,drugID1,drugID2,drugID3,shortName,regGroup) values(77,'1stReg70',75628,86663,75523,'FTC-ZDV-EFV','1stReg70');
insert into regimen(regID,regimenName,drugID1,drugID2,drugID3,shortName,regGroup) values(78,'1stReg71',75628,86663,80586,'FTC-ZDV-NVP','1stReg71');
insert into regimen(regID,regimenName,drugID1,drugID2,drugID3,shortName,regGroup) values(79,'1stReg72',78643,84309,84795,'3TC-d4T-TNF','1stReg72');
insert into regimen(regID,regimenName,drugID1,drugID2,drugID3,shortName,regGroup) values(80,'1stReg73',78643,84795,75523,'3TC-TNF-EFV','1stReg73');
insert into regimen(regID,regimenName,drugID1,drugID2,drugID3,shortName,regGroup) values(81,'1stReg74',78643,84795,80586,'3TC-TNF-NVP','1stReg74');
insert into regimen(regID,regimenName,drugID1,drugID2,drugID3,shortName,regGroup) values(82,'1stReg75',84309,84795,86663,'d4T-TNF-ZDV','1stReg75');
insert into regimen(regID,regimenName,drugID1,drugID2,drugID3,shortName,regGroup) values(83,'1stReg76',84309,84795,75523,'d4T-TNF-EFV','1stReg76');
insert into regimen(regID,regimenName,drugID1,drugID2,drugID3,shortName,regGroup) values(84,'1stReg77',84309,84795,80586,'d4T-TNF-NVP','1stReg77');
insert into regimen(regID,regimenName,drugID1,drugID2,drugID3,shortName,regGroup) values(85,'1stReg78',84309,86663,75523,'d4T-ZDV-EFV','1stReg78');
insert into regimen(regID,regimenName,drugID1,drugID2,drugID3,shortName,regGroup) values(86,'1stReg79',84309,86663,80586,'d4T-ZDV-NVP','1stReg79');
insert into regimen(regID,regimenName,drugID1,drugID2,drugID3,shortName,regGroup) values(87,'1stReg80',84795,86663,75523,'TNF-ZDV-EFV','1stReg80');
insert into regimen(regID,regimenName,drugID1,drugID2,drugID3,shortName,regGroup) values(88,'1stReg81',84795,86663,80586,'TNF-ZDV-NVP','1stReg81');
insert into regimen(regID,regimenName,drugID1,drugID2,drugID3,shortName,regGroup) values(89,'2ndReg4',84795,75628,794,'TNF-FTC-LPV/r','2ndReg4');
insert into regimen(regID,regimenName,drugID1,drugID2,drugID3,shortName,regGroup) values(90,'2ndReg5a',86663,78643,794,'ZDV-3TC-LPV/r','2ndReg5');
insert into regimen(regID,regimenName,drugID1,drugID2,drugID3,shortName,regGroup) values(93,'2ndReg8',84309,78643,77995,'d4T-3TC-IDV','2ndReg8');
insert into regimen(regID,regimenName,drugID1,drugID2,drugID3,shortName,regGroup) values(94,'2ndReg9',84309,78643,794,'d4T-3TC-LPV/r','2ndReg9');
insert into regimen(regID,regimenName,drugID1,drugID2,drugID3,shortName,regGroup) values(95,'2ndReg10',84309,78643,80487,'d4T-3TC-NFV','2ndReg10');
insert into regimen(regID,regimenName,drugID1,drugID2,drugID3,shortName,regGroup) values(96,'2ndReg11',84309,74807,77995,'d4T-ddI-IDV','2ndReg11');
insert into regimen(regID,regimenName,drugID1,drugID2,drugID3,shortName,regGroup) values(98,'2ndReg13a',86663,78643,77995,'ZDV-3TC-IDV','2ndReg13');
insert into regimen(regID,regimenName,drugID1,drugID2,drugID3,shortName,regGroup) values(99,'2ndReg13b',630,77995,'0','ZDV-3TC-IDV','2ndReg13');
insert into regimen(regID,regimenName,drugID1,drugID2,drugID3,shortName,regGroup) values(54,'1stReg35b',630,74807,'0','ZDV-3TC-ddI','1stReg35');
insert into regimen(regID,regimenName,drugID1,drugID2,drugID3,shortName,regGroup) values(68,'1stReg36b',630,75628,'0','ZDV-3TC-FTC','1stReg36');
insert into regimen(regID,regimenName,drugID1,drugID2,drugID3,shortName,regGroup) values(91,'1stReg37b',630,84309,'0','ZDV-3TC-d4T','1stReg37');
insert into regimen(regID,regimenName,drugID1,drugID2,drugID3,shortName,regGroup) values(92,'1stReg38b',630,84795,'0','ZDV-3TC-TNF','1stReg38');
insert into regimen(regID,regimenName,drugID1,drugID2,drugID3,shortName,regGroup) values(97,'2ndReg5b',630,794,'0','ZDV-3TC-LPV/r','2ndReg5');
insert into regimen(regID,regimenName,drugID1,drugID2,drugID3,shortName,regGroup) values(100,'2nd2009-1',84795,78643,159809,'TNF-3TC-ATV/r','2nd2009-1');
insert into regimen(regID,regimenName,drugID1,drugID2,drugID3,shortName,regGroup) values(101,'2nd2009-2',84795,78643,794,'TNF-3TC-LPV/r','2nd2009-2');
insert into regimen(regID,regimenName,drugID1,drugID2,drugID3,shortName,regGroup) values(102,'2nd2009-3',84795,75628,159809,'TNF-FTC-ATV/r','2nd2009-3');
insert into regimen(regID,regimenName,drugID1,drugID2,drugID3,shortName,regGroup) values(103,'2nd2009-5',630,159809,'0','AZT-3TC-ATV/r','2nd2009-5');
insert into regimen(regID,regimenName,drugID1,drugID2,drugID3,shortName,regGroup) values(104,'2nd2009-5',86663,78643,159809,'AZT-3TC-ATV/r','2nd2009-5');
insert into regimen(regID,regimenName,drugID1,drugID2,drugID3,shortName,regGroup) values(105,'2nd2009-10',630,84795,159809,'AZT-TNF-3TC-ATV/r','2nd2009-10');
insert into regimen(regID,regimenName,drugID1,drugID2,drugID3,shortName,regGroup) values(106,'2nd2009-12',630,84795,794,'AZT-TNF-3TC-LPV/r','2nd2009-12');
insert into regimen(regID,regimenName,drugID1,drugID2,drugID3,shortName,regGroup) values(107,'2nd2016-1',84795,75628,74258,'TNF+FTC+DRV/r','2nd2016-1');
insert into regimen(regID,regimenName,drugID1,drugID2,drugID3,shortName,regGroup) values(108,'1stReg2016-2',630,80586,'0','AZT+3TC+NVP','1stReg2016');
insert into regimen(regID,regimenName,drugID1,drugID2,drugID3,shortName,regGroup) values(109,'2nd2016-3',84795,78643,74258,'TNF+3TC+DRV/r','2nd2016-3');
insert into regimen(regID,regimenName,drugID1,drugID2,drugID3,shortName,regGroup) values(110,'2nd2016-4',630,74258,'0','AZT+3TC+DRV/r','2nd2016-4');
insert into regimen(regID,regimenName,drugID1,drugID2,drugID3,shortName,regGroup) values(111,'2nd2016-5',630,794,'0','AZT+3TC+LPR/r','2nd2016-5');
insert into regimen(regID,regimenName,drugID1,drugID2,drugID3,shortName,regGroup) values(112,'1stReg2016-6',630,75523,'0','AZT+3TC+EFV','1stReg2016');
insert into regimen(regID,regimenName,drugID1,drugID2,drugID3,shortName,regGroup) values(113,'1stReg2016-7',70056,86663,78643,'ABC + AZT+3TC','1stReg2016');
insert into regimen(regID,regimenName,drugID1,drugID2,drugID3,shortName,regGroup) values(114,'2nd2016-8',74258,75523,154378,'DRV/r+EFV+RAL','2nd2016-8');
insert into regimen(regID,regimenName,drugID1,drugID2,drugID3,shortName,regGroup) values(115,'2nd',70056,78643,794,'ABC-3TC-LPV/r','2nd');
insert into regimen(regID,regimenName,drugID1,drugID2,drugID3,shortName,regGroup) values(116,'2nd',70056,78643,159809,'ABC-3TC-ATV/r','2nd');
insert into regimen(regID,regimenName,drugID1,drugID2,drugID3,shortName,regGroup) values(117,'1stReg',84795,78643,165085,'TNF-3TC-DTG','1stReg');
insert into regimen(regID,regimenName,drugID1,drugID2,drugID3,shortName,regGroup) values(118,'2nd',70056,78643,74258,'ABC-3TC-DRV/r','1stReg');
insert into regimen(regID,regimenName,drugID1,drugID2,drugID3,shortName,regGroup) values(119,'3rd',74258,165085,159810,'DRV-DTG-ETV','3rd');
insert into regimen(regID,regimenName,drugID1,drugID2,drugID3,shortName,regGroup) values(120,'1stReg',630,165085,'0','AZT-3TC-DTG','1stReg');
insert into regimen(regID,regimenName,drugID1,drugID2,drugID3,shortName,regGroup) values(121,'1stReg',70056,78643,165085,'ABC-3TC-DTG','1stReg');
insert into regimen(regID,regimenName,drugID1,drugID2,drugID3,shortName,regGroup) values(122,'1stReg127',70056,78643,154378,'ABC+3TC+RAL','1stReg127');
insert into regimen(regID,regimenName,drugID1,drugID2,drugID3,shortName,regGroup) values(123,'1stReg128',630,154378,0,'AZT+3TC+RAL','1stReg128');
insert into regimen(regID,regimenName,drugID1,drugID2,drugID3,shortName,regGroup) values(124,'1stReg129',86663,78643,154378,'AZT+3TC+RAL','1stReg129');

CREATE TABLE IF NOT EXISTS `openmrs.isanteplus_patient_arv` (
  `patient_id` int(11) NOT NULL,
  `arv_status` varchar(255) DEFAULT NULL,
  `arv_regimen` varchar(255) DEFAULT NULL,
  `date_started_arv` date DEFAULT NULL,
  `next_visit_date` date DEFAULT NULL,
  `date_created` datetime NOT NULL,
  `date_changed` datetime DEFAULT NULL,
  PRIMARY KEY (`patient_id`),
  CONSTRAINT `isanteplus_patient_id_fk` FOREIGN KEY (`patient_id`) REFERENCES `patient` (`patient_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

/* <begin malaria surveillance> */
DROP TABLE IF EXISTS isanteplus.patient_malaria;
CREATE TABLE IF NOT EXISTS `isanteplus`.`patient_malaria` (
  `patient_id` INT(11) NOT NULL,
  `location_id` INT(11) NOT NULL,
  `visit_id` INT(11) NOT NULL,
  `visit_date` DATE NOT NULL,
  `encounter_id` INT(11) NOT NULL,
  `encounter_type_id` INT(11) NOT NULL,
  `last_updated_date` DATE NOT NULL, 
  `voided` TINYINT(1) NOT NULL DEFAULT 0,
  PRIMARY KEY (`patient_id`),
  CONSTRAINT `isanteplus_patient_malaria_patient_id_fk` FOREIGN KEY (`patient_id`) REFERENCES `patient` (`patient_id`)
) ENGINE=INNODB DEFAULT CHARSET=utf8;
	

ALTER TABLE  isanteplus.patient_malaria 
ADD COLUMN fever_for_less_than_2wks TINYINT(1) AFTER encounter_type_id;

ALTER TABLE  isanteplus.patient_malaria 
ADD COLUMN suspected_malaria TINYINT(1) AFTER fever_for_less_than_2wks;

ALTER TABLE  isanteplus.patient_malaria 
ADD COLUMN confirmed_malaria TINYINT(1) AFTER suspected_malaria;

ALTER TABLE  isanteplus.patient_malaria 
ADD COLUMN treated_with_chloroquine TINYINT(1) AFTER suspected_malaria;

ALTER TABLE  isanteplus.patient_malaria 
ADD COLUMN treated_with_primaquine TINYINT(1) AFTER treated_with_chloroquine;

ALTER TABLE  isanteplus.patient_malaria 
ADD COLUMN treated_with_quinine TINYINT(1) AFTER treated_with_primaquine;

ALTER TABLE  isanteplus.patient_malaria 
ADD COLUMN microscopic_test TINYINT(1) AFTER treated_with_quinine;

ALTER TABLE  isanteplus.patient_malaria 
ADD COLUMN positive_microscopic_test_result TINYINT(1) AFTER microscopic_test;

ALTER TABLE  isanteplus.patient_malaria 
ADD COLUMN negative_microscopic_test_result TINYINT(1) AFTER positive_microscopic_test_result;

ALTER TABLE  isanteplus.patient_malaria 
ADD COLUMN positive_plasmodium_falciparum_test_result TINYINT(1) AFTER negative_microscopic_test_result;

ALTER TABLE  isanteplus.patient_malaria 
ADD COLUMN mixed_positive_test_result TINYINT(1) AFTER positive_plasmodium_falciparum_test_result;

ALTER TABLE  isanteplus.patient_malaria 
ADD COLUMN positive_plasmodium_vivax_test_result TINYINT(1) AFTER mixed_positive_test_result;

ALTER TABLE  isanteplus.patient_malaria 
ADD COLUMN rapid_test TINYINT(1) AFTER positive_plasmodium_vivax_test_result;

ALTER TABLE  isanteplus.patient_malaria 
ADD COLUMN positve_rapid_test_result TINYINT(1) AFTER rapid_test;

ALTER TABLE  isanteplus.patient_malaria 
ADD COLUMN severe_malaria TINYINT(1) AFTER positve_rapid_test_result;

ALTER TABLE  isanteplus.patient_malaria 
ADD COLUMN hospitallized TINYINT(1) AFTER severe_malaria;

ALTER TABLE  isanteplus.patient_malaria 
ADD COLUMN confirmed_malaria_preganancy TINYINT(1) AFTER hospitallized;

/* </end malaria surveillance> */
	
GRANT SELECT ON isanteplus.* TO 'openmrs_user'@'localhost';


DELIMITER $$
	DROP PROCEDURE IF EXISTS isanteplus.set_scheduler_and_lock_wait_variable$$
	CREATE PROCEDURE isanteplus.set_scheduler_and_lock_wait_variable()
	BEGIN
			SET GLOBAL event_scheduler = 1 ;
			SET innodb_lock_wait_timeout = 250;
    
    END$$
	DELIMITER ;

GRANT EXECUTE ON PROCEDURE isanteplus.set_scheduler_and_lock_wait_variable TO 'openmrs_user'@'localhost';

/*Adding column voided for all the table*/
ALTER TABLE isanteplus.patient
ADD COLUMN voided tinyint(1);

ALTER TABLE isanteplus.patient_visit
ADD COLUMN voided tinyint(1);

ALTER TABLE isanteplus.patient_tb_diagnosis
ADD COLUMN voided tinyint(1);

ALTER TABLE isanteplus.patient_dispensing
ADD COLUMN voided tinyint(1);

ALTER TABLE isanteplus.patient_imagerie
ADD COLUMN voided tinyint(1);

ALTER TABLE isanteplus.patient_on_arv
ADD COLUMN voided tinyint(1);

ALTER TABLE isanteplus.patient_prescription
ADD COLUMN voided tinyint(1);

ALTER TABLE isanteplus.patient_laboratory
ADD COLUMN voided tinyint(1);

ALTER TABLE isanteplus.patient_pregnancy
ADD COLUMN voided tinyint(1);

ALTER TABLE isanteplus.patient_diagnosis
ADD COLUMN voided tinyint(1);

ALTER TABLE isanteplus.visit_type
ADD COLUMN voided tinyint(1);

ALTER TABLE isanteplus.virological_tests
ADD COLUMN voided tinyint(1);

ALTER TABLE isanteplus.patient_delivery
ADD COLUMN voided tinyint(1);

ALTER TABLE isanteplus.pediatric_hiv_visit
ADD COLUMN voided tinyint(1);

ALTER TABLE isanteplus.patient_menstruation
ADD COLUMN voided tinyint(1);

ALTER TABLE isanteplus.vih_risk_factor
ADD COLUMN voided tinyint(1);

ALTER TABLE isanteplus.vaccination
ADD COLUMN voided tinyint(1);

ALTER TABLE isanteplus.health_qual_patient_visit
ADD COLUMN voided tinyint(1);

ALTER TABLE isanteplus.serological_tests
ADD COLUMN voided tinyint(1);

ALTER TABLE isanteplus.patient_status_arv
ADD COLUMN date_started_status datetime;

ALTER TABLE isanteplus.patient_status_arv
ADD COLUMN encounter_id INT(11) AFTER start_date;

ALTER TABLE isanteplus.patient_prescription
ADD COLUMN dispensation_date DATE AFTER drug_id;

ALTER TABLE isanteplus.patient_prescription
ADD COLUMN number_day_dispense DOUBLE AFTER number_day;

ALTER TABLE isanteplus.patient_prescription
ADD COLUMN pills_amount_dispense DOUBLE AFTER number_day_dispense;

ALTER TABLE isanteplus.patient
ADD COLUMN isante_id varchar(50) AFTER national_id;

ALTER TABLE isanteplus.patient
ADD COLUMN contact_name text AFTER mother_name;
/*Adding a column for the openmrs.obs.obs_id in the table patient_dispensing*/
ALTER TABLE isanteplus.patient_dispensing
ADD COLUMN obs_id int(11) AFTER location_id;

ALTER TABLE isanteplus.patient_dispensing
ADD COLUMN obs_group_id int(11) AFTER obs_id;

/*Adding a column for the openmrs.obs.obs_id in the table patient_prescription*/
ALTER TABLE isanteplus.patient_prescription
ADD COLUMN obs_id int(11) AFTER location_id;

ALTER TABLE isanteplus.patient_prescription
ADD COLUMN obs_group_id int(11) AFTER obs_id;

ALTER TABLE patient_status_arv DROP PRIMARY KEY;
ALTER TABLE patient_status_arv ADD CONSTRAINT pk_patient_status_arv_new 
PRIMARY KEY (patient_id,id_status,start_date,date_started_status); 
/*CREATE INDEX patient_id_index ON patient_status_arv(patient_id);
CREATE INDEX id_status_index ON patient_status_arv(id_status);
CREATE INDEX start_date_index ON patient_status_arv(start_date);
CREATE INDEX date_started_status_index ON patient_status_arv(date_started_status);
CREATE INDEX last_updated_date_index ON patient_status_arv(last_updated_date);
*/
DROP TABLE IF EXISTS openmrs.isanteplus_alert;
		create table if not exists openmrs.isanteplus_alert(
		patient_id int(11),
		id_alert int(11),
		visit_date date,
		last_updated_date DATETIME,
		CONSTRAINT pk_isanteplus_alert PRIMARY KEY (patient_id, id_alert)
		);
/* <Begin TB Treatment columns>*/

ALTER TABLE  isanteplus.patient_tb_diagnosis 
ADD COLUMN encounter_type_id int(11) AFTER visit_date;

ALTER TABLE  isanteplus.patient_tb_diagnosis 
ADD COLUMN dyspnea  tinyint(1) AFTER cough_for_2wks_or_more;

ALTER TABLE  isanteplus.patient_tb_diagnosis 
ADD COLUMN tb_diag_sputum tinyint(1) AFTER dyspnea; 

ALTER TABLE  isanteplus.patient_tb_diagnosis 
ADD COLUMN tb_diag_xray tinyint(1) AFTER tb_diag_sputum;

ALTER TABLE  isanteplus.patient_tb_diagnosis 
ADD COLUMN tb_test_result_mon_0 int(11) AFTER tb_diag_xray;

ALTER TABLE  isanteplus.patient_tb_diagnosis 
ADD COLUMN tb_test_result_mon_2 int(11) AFTER tb_test_result_mon_0;

ALTER TABLE  isanteplus.patient_tb_diagnosis 
ADD COLUMN tb_test_result_mon_3 int(11) AFTER tb_test_result_mon_2;

ALTER TABLE  isanteplus.patient_tb_diagnosis 
ADD COLUMN tb_test_result_mon_5 int(11) AFTER tb_test_result_mon_3;

ALTER TABLE  isanteplus.patient_tb_diagnosis 
ADD COLUMN tb_test_result_end int(11) AFTER tb_test_result_mon_5;

ALTER TABLE  isanteplus.patient_tb_diagnosis 
ADD COLUMN age_at_visit_years int(11) AFTER tb_test_result_end;

ALTER TABLE  isanteplus.patient_tb_diagnosis 
ADD COLUMN age_at_visit_months int(11) AFTER age_at_visit_years;

ALTER TABLE  isanteplus.patient_tb_diagnosis 
ADD COLUMN tb_class_pulmonary tinyint(1) AFTER tb_new_diag;

ALTER TABLE  isanteplus.patient_tb_diagnosis 
ADD COLUMN tb_class_extrapulmonary tinyint(1) AFTER tb_class_pulmonary;

ALTER TABLE  isanteplus.patient_tb_diagnosis 
ADD COLUMN tb_extra_meningitis tinyint(1) AFTER tb_class_extrapulmonary;

ALTER TABLE  isanteplus.patient_tb_diagnosis 
ADD COLUMN tb_extra_genital tinyint(1) AFTER tb_extra_meningitis;

ALTER TABLE  isanteplus.patient_tb_diagnosis 
ADD COLUMN tb_extra_pleural tinyint(1) AFTER tb_extra_genital;

ALTER TABLE  isanteplus.patient_tb_diagnosis 
ADD COLUMN tb_extra_miliary tinyint(1) AFTER tb_extra_pleural;

ALTER TABLE  isanteplus.patient_tb_diagnosis 
ADD COLUMN tb_extra_gangliponic tinyint(1) AFTER tb_extra_miliary;

ALTER TABLE  isanteplus.patient_tb_diagnosis 
ADD COLUMN tb_extra_intestinal tinyint(1) AFTER tb_extra_gangliponic;

ALTER TABLE  isanteplus.patient_tb_diagnosis 
ADD COLUMN tb_extra_other tinyint(1) AFTER tb_extra_intestinal;

ALTER TABLE  isanteplus.patient_tb_diagnosis 
ADD COLUMN tb_started_treatment tinyint(1) AFTER tb_treatment_start_date;

ALTER TABLE  isanteplus.patient_tb_diagnosis 
ADD COLUMN tb_medication_provided tinyint(1) AFTER tb_started_treatment;

ALTER TABLE  isanteplus.patient_tb_diagnosis 
ADD COLUMN tb_hiv_test_result tinyint(1) AFTER status_tb_treatment;

ALTER TABLE  isanteplus.patient_tb_diagnosis 
ADD COLUMN tb_prophy_cotrimoxazole tinyint(1) AFTER tb_hiv_test_result;

ALTER TABLE  isanteplus.patient_tb_diagnosis 
ADD COLUMN on_arv tinyint(1) AFTER tb_prophy_cotrimoxazole;


/* </End TB Treatment columns> */

/* <begin Nutrition table>*/
CREATE TABLE IF NOT EXISTS patient_nutrition (
	patient_id INT(11) NOT NULL,
	location_id INT(11),
	visit_id INT(11),
	visit_date DATE,
	encounter_id INT(11) NOT NULL,
	encounter_type_id INT(11) NOT NULL,
	age_at_visit_years INT(11),
	age_at_visit_months INT(11),
	weight DOUBLE,
	height DOUBLE,
	bmi DOUBLE,
	bmi_for_age INT,
	weight_for_height INT,
	edema TINYINT(1),
	last_updated_date DATETIME,
	voided TINYINT(1),
	PRIMARY KEY (`encounter_id`,location_id),
	CONSTRAINT FOREIGN KEY (patient_id) REFERENCES isanteplus.patient(patient_id),
	INDEX(visit_date),
	INDEX(encounter_id),
	INDEX(patient_id)
);
/* <end NUtrition table>*/

/* <begin ob/gyn>*/
CREATE TABLE IF NOT EXISTS patient_ob_gyn (
	patient_id INT(11) NOT NULL,
	location_id INT(11),
	visit_id INT(11),
	visit_date DATE,
	encounter_id INT(11) NOT NULL,
	encounter_type_id INT(11) NOT NULL,
	muac INT(11),
	pregnant INT(1),
	next_visit_date DATE,
	edd DATE,
	birth_plan INT(1),
	high_risk INT(1),
	gestation_greater_than_12_wks INT(1),
	iron_supplement INT(1),
	folic_acid_supplement INT(1),
	tetanus_toxoid_vaccine INT(1),
	iron_defiency_anemia INT(1),
	prescribed_iron INT(1),
	prescribed_folic_acid INT(1),
	elevated_blood_pressure INT(1),
	toxemia_signs INT(1),
	over_20_weeks_pregnancy INT(1),
	last_updated_date DATETIME,
	voided TINYINT(1),
	PRIMARY KEY (`encounter_id`,location_id),
	CONSTRAINT FOREIGN KEY (patient_id) REFERENCES isanteplus.patient(patient_id),
	INDEX(visit_date),
	INDEX(encounter_id),
	INDEX(patient_id)
);

/* <end ob/gyn>*/

	/*Create table for art reort*/
	DROP TABLE IF EXISTS patient_on_art;
	CREATE TABLE IF NOT EXISTS patient_on_art(
	patient_id int(11),
	date_completed_preventive_tb_treatment DATETIME ,
	enrolled_on_art int(11) DEFAULT NULL,
	gender varchar(10) DEFAULT NULL,
	key_population VARCHAR(255),
	tested_hiv_postive int(11) DEFAULT NULL,
	date_tested_hiv_postive DATETIME,
	reason_non_enrollment VARCHAR(255),
	date_non_enrollment DATETIME,
	date_enrolled_on_tb_treatment DATETIME ,
	transferred int(11) DEFAULT NULL,
	tb_screened int(11) DEFAULT NULL,
	date_tb_screened DATETIME,
   tb_status varchar(10) DEFAULT NULL,
   tb_genexpert_test int(11) DEFAULT NULL,
   tb_other_test int(11) DEFAULT NULL,
   tb_crachat_test int(11) DEFAULT NULL,
   date_sample_sent_for_diagnositic_tb DATETIME ,
   started_anti_tb_treatment int(11) DEFAULT NULL,
   date_started_anti_tb_treatment DATETIME,
   tb_bacteriological_test_status varchar(10) DEFAULT NULL,
   lost int(11) DEFAULT NULL,
   date_inactive  DATETIME ,
   inactive_reason VARCHAR(20) DEFAULT NULL,
   inactive int(11) DEFAULT NULL,
   deceased int(11) DEFAULT NULL,
   receive_arv int(11) DEFAULT NULL,
   date_started_arv DATETIME,
   date_started_receiving_arv DATETIME,
   receive_clinical_followup int(11) DEFAULT NULL,
   treatment_regime_lines text DEFAULT NULL,
   date_started_regime_treatment DATETIME,
   lost_reason varchar(10) DEFAULT NULL,
   date_lost DATETIME,
   period_lost varchar(10) DEFAULT NULL,
   cause_of_death_for_lost varchar(10) DEFAULT NULL,
   viral_load_targeted int(11) DEFAULT NULL,
   viral_load_targeted_result int(11) DEFAULT NULL,
   resumed_arv_after_lost int(11) DEFAULT NULL,
   recomended_family_planning int(11) DEFAULT NULL,
   accepted_family_planning_method varchar(10) DEFAULT NULL,
   date_accepted_family_planning_method DATETIME,
   using_family_planning_method varchar(10) DEFAULT NULL,
   date_using_family_planning_method varchar(10) DEFAULT NULL,
	first_vist_date  DATETIME,
	second_last_folowup_vist_date  DATETIME,
	last_folowup_vist_date  DATETIME,
	date_started_arv_for_transfered DATETIME,	
	screened_cervical_cancer int(11) DEFAULT NULL,
   date_screened_cervical_cancer DATETIME ,	
   cervical_cancer_status varchar(10) DEFAULT NULL,
   date_started_cervical_cancer_status DATETIME ,
   cervical_cancer_treatment varchar(10) DEFAULT NULL,
   date_cervical_cancer_treatment  DATETIME ,
   breast_feeding int(11) DEFAULT NULL,
   date_breast_feeding  DATETIME ,
   date_started_breast_feeding  DATETIME,
   date_full_6_months_of_inh_has_px DATETIME ,
   migrated int(11) DEFAULT NULL,
	constraint pk_patient_art PRIMARY KEY (patient_id));

/* <end patient_art>*/
ALTER TABLE patient_dispensing
MODIFY COLUMN pills_amount double;

ALTER TABLE patient_prescription 
MODIFY COLUMN pills_amount_dispense double;

/*For ART Report*/
/* Adding new columns to the isanteplus tables */
/*Adding viral_load_target_or_routine on the patient_laboratory table*/
	ALTER TABLE isanteplus.patient_laboratory
	ADD COLUMN viral_load_target_or_routine int(11) AFTER comment_test_done;
	
	/* Adding regimen line for each prescription */
	ALTER TABLE isanteplus.patient_dispensing
	ADD COLUMN treatment_regime_lines text AFTER rx_or_prophy;
	
	/*Create a table for key_populations */
	DROP TABLE IF EXISTS key_populations;
	create table if not exists key_populations(
	patient_id int(11),
	encounter_id int(11),
	location_id int(11),
	key_population int(11),
	encounter_date datetime,
	voided TINYINT(1) NOT NULL DEFAULT 0,
	last_updated_date datetime,
	CONSTRAINT pk_patient_key_population PRIMARY KEY (patient_id,encounter_id,key_population,voided)
	);
	
	DROP TABLE IF EXISTS family_planning;
	create table if not exists family_planning(
	patient_id int(11),
	encounter_id int(11),
	location_id int(11),
	planning int(11),
	encounter_date datetime,
	family_planning_method_name text,
	accepting_or_using_fp int(11),
	voided TINYINT(1) NOT NULL DEFAULT 0,
	last_updated_date datetime,
	CONSTRAINT pk_family_planning PRIMARY KEY (patient_id,encounter_id,planning,voided)
	);
	
	ALTER TABLE isanteplus.patient
	ADD COLUMN site_code text AFTER location_id;
	
	ALTER TABLE isanteplus.patient_prescription
	ADD COLUMN posology_alt text AFTER posology;
	
	ALTER TABLE isanteplus.patient_prescription
	ADD COLUMN posology_alt_disp text AFTER posology_alt;
	
	DROP TABLE IF EXISTS isanteplus.patient_immunization;
	CREATE TABLE IF NOT EXISTS isanteplus.patient_immunization (
	  patient_id INT(11) NOT NULL,
	  location_id INT(11) NOT NULL,
	  encounter_id INT(11) NOT NULL,
	  vaccine_obs_group_id INT(11),
	  vaccine_concept_id INT(11) NOT NULL,
	  dose double,
	  vaccine_date datetime,
	  encounter_date datetime,
	  lot_number text,
	  manufacturer text,
	  vaccine_uuid varchar(255),
	  voided TINYINT(1) NOT NULL DEFAULT 0,
	  CONSTRAINT pk_patient_immunization PRIMARY KEY (patient_id,vaccine_obs_group_id,vaccine_concept_id)
	) ENGINE=INNODB DEFAULT CHARSET=utf8;
	
	
CREATE DATABASE IF NOT EXISTS tempNotif;

GRANT ALL ON tempNotif.* TO 'solution_user'@'localhost' IDENTIFIED BY 'solution123';
GRANT SELECT ON openmrs.* TO 'solution_user'@'localhost' IDENTIFIED BY 'solution123';
GRANT SELECT ON isanteplus.* TO 'solution_user'@'localhost' IDENTIFIED BY 'solution123';

DROP TABLE if exists immunization_lookup;
CREATE TABLE if not exists immunization_lookup (
  id INT(11) NOT NULL,
  vaccine_concept_id INT(11),
  vaccine_name text NOT NULL,
  uuid char(38) NOT NULL,
  register_date datetime,
  PRIMARY KEY (uuid)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

INSERT INTO immunization_lookup (id,vaccine_name,uuid,register_date)
VALUES(1,'Hépatite B','782AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA',now()),
(2,'Polio (OPV/IPV)','783AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA',now()),
(3,'DiTePer','781AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA',now()),
(4,'HIB','5261AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA',now()),
(5,'Pentavalent','1423AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA',now()),
(6,'Pneumocoque','82215AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA',now()),
(7,'Rotavirus','83531AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA',now()),
(8,'ROR','159701AAAAAAAAAAAAAAAAAAAAAAAAAAAAAA',now()),
(9,'RR','162586AAAAAAAAAAAAAAAAAAAAAAAAAAAAAA',now()),
(10,'DT','17AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA',now()),
(11,'Varicelle','73193AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA',now()),
(12,'Typhimvi','86208AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA',now()),
(13,'Meningo AC','105030AAAAAAAAAAAAAAAAAAAAAAAAAAAAAA',now()),
(14,'Hépatite A','77424AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA',now()),
(15,'Cholera','73354AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA',now()),
(16,'BCG','886AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA',now()),
(17,'HPV','159708AAAAAAAAAAAAAAAAAAAAAAAAAAAAAA',now()),
(18,'Diphtérie/Tétanos','104528AAAAAAAAAAAAAAAAAAAAAAAAAAAAAA',now()),
(19,'Oxford AstraZeneca','166156AAAAAAAAAAAAAAAAAAAAAAAAAAAAAA',now()),
(20,'Moderna','166154AAAAAAAAAAAAAAAAAAAAAAAAAAAAAA',now()),
(21,'Pfizer-BioNTech','166155AAAAAAAAAAAAAAAAAAAAAAAAAAAAAA',now()),
(22,'Gamaleya-Sputnick V (Russia)','166157AAAAAAAAAAAAAAAAAAAAAAAAAAAAAA',now()),
(23,'Sinovac(China)/Sinopharm(China)','166249AAAAAAAAAAAAAAAAAAAAAAAAAAAAAA',now()),
(24,'Johnson and Johnson (Janssen)','166355AAAAAAAAAAAAAAAAAAAAAAAAAAAAAA',now());

UPDATE immunization_lookup iml, openmrs.concept c
SET iml.vaccine_concept_id = c.concept_id
WHERE iml.uuid = c.uuid;

DROP TABLE if exists immunization_dose;
CREATE TABLE if not exists immunization_dose (
  patient_id int(11) NOT NULL,
  vaccine_concept_id INT(11) NOT NULL,
  dose0 datetime,
  dose1 datetime,
  dose2 datetime,
  dose3 datetime,
  dose4 datetime,
  dose5 datetime,
  dose6 datetime,
  dose7 datetime,
  dose8 datetime,
  PRIMARY KEY (patient_id,vaccine_concept_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

ALTER TABLE isanteplus.patient_prescription 
MODIFY COLUMN number_day double;

ALTER TABLE isanteplus.patient
ADD COLUMN date_transferred_in DATETIME AFTER transferred_in;

ALTER TABLE isanteplus.patient
ADD COLUMN date_started_arv_other_site DATETIME 
AFTER date_transferred_in;
/*Field modify on 17_12_2021*/
ALTER TABLE isanteplus.patient_on_art 
MODIFY COLUMN cervical_cancer_treatment TEXT;
/*Field added on 19 janv 2022*/
ALTER TABLE isanteplus.patient_dispensing
ADD COLUMN ddp int(11) default 0 AFTER dispensation_location;

ALTER TABLE patient_dispensing
MODIFY COLUMN dose_day double;





/*INSERT FLAGS*/
/*use openmrs;*/

	SET SQL_SAFE_UPDATES = 0;
	SET FOREIGN_KEY_CHECKS = 0;
	
	truncate table openmrs.patientflags_flag_tag;
	truncate table openmrs.patientflags_tag_displaypoint;
	truncate table openmrs.patientflags_flag;
	truncate table openmrs.patientflags_tag;
	truncate table openmrs.patientflags_priority;
				
	SET SQL_SAFE_UPDATES = 1;
	SET FOREIGN_KEY_CHECKS = 1;

	INSERT INTO openmrs.patientflags_tag VALUES (2,'Tag',NULL,1,'2018-05-28 09:44:50',NULL,NULL,0,NULL,NULL,NULL,'4dbe134d-a67a-44be-871f-5890b05d328c');
 	
 	INSERT INTO openmrs.patientflags_priority VALUES 
	(1,'Liste VL','color:red',1,NULL,1,'2018-05-28 02:17:38',1,'2018-05-28 02:19:27',0,NULL,NULL,NULL,'f2e0e461-170e-4df9-80fc-da2d93663328');
	INSERT INTO openmrs.patientflags_priority VALUES 
	(2,'Liste Medicament','color: red',2,NULL,1,'2018-05-31 15:02:47',NULL,NULL,0,NULL,NULL,NULL,'5d87ef2b-5cc2-4ef5-a241-a122977170d6');
	INSERT INTO openmrs.patientflags_priority VALUES 
	(3,'Liste TB','color: blue',3,NULL,1,'2018-05-31 15:02:47',NULL,NULL,0,NULL,NULL,NULL,'439d2dfa-29ee-4271-9e18-97a80d0eb475');

/* Dernière charge virale de ce patient remonte à au moins 12 mois */
 	INSERT INTO openmrs.patientflags_flag VALUES 
	(2,'Dernière charge virale de ce patient remonte à 12 mois ou plus',
	'select distinct a.patient_id FROM isanteplus.alert a WHERE a.id_alert = 4',
	'Dernière charge virale de ce patient remonte à 12 mois ou plus',1,
	'org.openmrs.module.patientflags.evaluator.SQLFlagEvaluator',
	NULL,1,'2018-05-28 02:18:18',1,'2018-05-31 13:43:43',0,NULL,NULL,NULL,
	'8c176fcb-9354-43fa-b13c-c293e6f910dc',1);
				
/*patient sous ARV depuis 6 mois sans un résultat de charge virale*/
				
/*INSERT INTO openmrs.patientflags_flag VALUES 
				(3,'patient sous ARV depuis 6 mois sans un résultat de charge virale',
				'select distinct a.patient_id FROM isanteplus.alert a WHERE a.id_alert = 1',
				 'Le patient est sous ARV depuis 6 mois sans un résultat de charge virale',1,
				 'org.openmrs.module.patientflags.evaluator.SQLFlagEvaluator',NULL,
				 1,'2018-05-31 14:58:13',1,'2018-05-31 14:59:31',0,NULL,NULL,NULL,
				 '1d968997-4d6d-41d4-ab91-9b7936030ace',1); */

/* Patient sous ARV et traitement anti tuberculeux */
				
	INSERT INTO openmrs.patientflags_flag VALUES 
	(4,'Coïnfection TB/VIH',
	'select distinct a.patient_id FROM isanteplus.alert a WHERE a.id_alert = 9',
	'Coïnfection TB/VIH',1,
	'org.openmrs.module.patientflags.evaluator.SQLFlagEvaluator',NULL,1,'2018-05-31 15:03:40',
	NULL,NULL,0,NULL,NULL,NULL,'a1d4c4ba-348c-456d-aca1-755190b78b0c',3);
				 
				 
/* Dernière charge virale de ce patient remonte à au moins 3 mois et le résultat était supérieur 1000 copies/ml */
 	INSERT INTO openmrs.patientflags_flag VALUES 
	(5,'Le patient a au moins 3 mois de sa dernière charge virale supérieur à 1000 copies/ml',
	'select distinct a.patient_id FROM isanteplus.alert a WHERE a.id_alert = 5',
	'Le patient a au moins 3 mois de sa dernière charge virale supérieur à 1000 copies/ml',1,
	'org.openmrs.module.patientflags.evaluator.SQLFlagEvaluator',
	NULL,1,'2018-05-28 02:18:18',1,'2018-05-31 13:43:43',0,NULL,NULL,NULL,
	'8c176fcb-9354-43fa-b13c-c293e6f910dc',1);
	
/*Le patient doit venir renflouer ses ARV dans les 30 prochains jours*/
	INSERT INTO openmrs.patientflags_flag VALUES 
	(7,'Le patient doit venir renflouer ses ARV dans les 30 prochains jours',
	'select distinct a.patient_id FROM isanteplus.alert a WHERE a.id_alert = 7',
	'Le patient doit venir renflouer ses ARV dans les 30 prochains jours',1,
	'org.openmrs.module.patientflags.evaluator.SQLFlagEvaluator',
	NULL,1,'2018-05-28 02:18:18',1,'2018-05-31 13:43:43',0,NULL,NULL,NULL,
	'8c176fcb-9354-43fa-b13c-c293e6f910dc',2);
	
/*Le patient n'a plus de médicaments disponibles*/
	INSERT INTO openmrs.patientflags_flag VALUES 
	(8,'Le patient n\'a plus de médicaments disponibles',
	'select distinct a.patient_id FROM isanteplus.alert a WHERE a.id_alert = 8',
	'Le patient n\'a plus de médicaments disponibles',1,
	'org.openmrs.module.patientflags.evaluator.SQLFlagEvaluator',
	NULL,1,'2018-05-28 02:18:18',1,'2018-05-31 13:43:43',0,NULL,NULL,NULL,
	'8c176fcb-9354-43fa-b13c-c293e6f910dc',2);
	
/*Patient sous ARV depuis au moins 3 mois sans un résultat de charge virale*/
	INSERT INTO openmrs.patientflags_flag VALUES 
	(9,'Patient sous ARV depuis au moins 3 mois sans un résultat de charge virale',
	'select distinct a.patient_id FROM isanteplus.alert a WHERE a.id_alert = 10',
	'Patient sous ARV depuis au moins 3 mois sans un résultat de charge virale',1,
	'org.openmrs.module.patientflags.evaluator.SQLFlagEvaluator',NULL,
	1,'2020-02-05 14:58:13',1,'2020-02-05 14:59:31',0,NULL,NULL,NULL,
	'c874aaf5-9e64-4fca-ba49-3f903158fa5f',1);
				 
	INSERT INTO openmrs.patientflags_flag VALUES 
	(10,'Nouveau enrôlé aux ARV sans prophylaxie INH',
	'select distinct a.patient_id FROM isanteplus.alert a WHERE a.id_alert = 11',
	'Nouveau enrôlé aux ARV sans prophylaxie INH',1,
	'org.openmrs.module.patientflags.evaluator.SQLFlagEvaluator',
	NULL,1,'2020-02-05 02:18:18',1,'2020-02-05 13:43:43',0,NULL,NULL,NULL,
	'c26c358d-ec66-4588-8546-e39511723ded',2);
				
/*Patient Abonne au DDP*/
	INSERT INTO openmrs.patientflags_flag VALUES 
	(11,'Ce patient est abonné au DDP',
	'select distinct a.patient_id FROM isanteplus.alert a WHERE a.id_alert = 12',
	'Ce patient est abonné au DDP',1,
	'org.openmrs.module.patientflags.evaluator.SQLFlagEvaluator',
	NULL,1,'2021-08-02 13:18:18',1,'2021-08-02 13:18:18',0,NULL,NULL,
	NULL,'38125986-383c-4426-b825-87dc0effa6de',2);
				 
	INSERT INTO openmrs.patientflags_flag_tag VALUES (2,2),(4,2),(5,2),(7,2),(8,2),(9,2),(10,2),(11,2);
	INSERT INTO openmrs.patientflags_tag_displaypoint VALUES (2,1);
		
/*Update global_property to Set where the alert should appear*/			
	UPDATE openmrs.global_property SET property_value = 'false' 
	WHERE property = 'patientflags.patientHeaderDisplay';
	UPDATE openmrs.global_property SET property_value = 'true'
	WHERE property = 'patientflags.patientOverviewDisplay';
		

	SET SQL_SAFE_UPDATES = 0;
	SET FOREIGN_KEY_CHECKS = 0;
			
	truncate table openmrs.patientflags_tag_role;
	
/*Insert patientflags_tag_role*/
	INSERT INTO openmrs.patientflags_tag_role (`tag_id`,`role`) VALUES (2,'Anonymous');
	INSERT INTO openmrs.patientflags_tag_role (`tag_id`,`role`) VALUES (2,'Application: Administers System');
	INSERT INTO openmrs.patientflags_tag_role (`tag_id`,`role`) VALUES (2,'Application: Configures Appointment Scheduling');
	INSERT INTO openmrs.patientflags_tag_role (`tag_id`,`role`) VALUES (2,'Application: Configures Forms');
	INSERT INTO openmrs.patientflags_tag_role (`tag_id`,`role`) VALUES (2,'Application: Configures Metadata');
	INSERT INTO openmrs.patientflags_tag_role (`tag_id`,`role`) VALUES (2,'Application: Edits Existing Encounters');
	INSERT INTO openmrs.patientflags_tag_role (`tag_id`,`role`) VALUES (2,'Application: Enters ADT Events');
	INSERT INTO openmrs.patientflags_tag_role (`tag_id`,`role`) VALUES (2,'Application: Enters Vitals');
	INSERT INTO openmrs.patientflags_tag_role (`tag_id`,`role`) VALUES (2,'Application: Has Super User Privileges');
	INSERT INTO openmrs.patientflags_tag_role (`tag_id`,`role`) VALUES (2,'Application: Manages Atlas');
	INSERT INTO openmrs.patientflags_tag_role (`tag_id`,`role`) VALUES (2,'Application: Manages Provider Schedules');
	INSERT INTO openmrs.patientflags_tag_role (`tag_id`,`role`) VALUES (2,'Application: Records Allergies');
	INSERT INTO openmrs.patientflags_tag_role (`tag_id`,`role`) VALUES (2,'Application: Registers Patients');
	INSERT INTO openmrs.patientflags_tag_role (`tag_id`,`role`) VALUES (2,'Application: Requests Appointments');
	INSERT INTO openmrs.patientflags_tag_role (`tag_id`,`role`) VALUES (2,'Application: Schedules And Overbooks Appointments');
	INSERT INTO openmrs.patientflags_tag_role (`tag_id`,`role`) VALUES (2,'Application: Schedules Appointments');
	INSERT INTO openmrs.patientflags_tag_role (`tag_id`,`role`) VALUES (2,'Application: Sees Appointment Schedule');
	INSERT INTO openmrs.patientflags_tag_role (`tag_id`,`role`) VALUES (2,'Application: Uses Capture Vitals App');
	INSERT INTO openmrs.patientflags_tag_role (`tag_id`,`role`) VALUES (2,'Application: Uses Patient Summary');
	INSERT INTO openmrs.patientflags_tag_role (`tag_id`,`role`) VALUES (2,'Application: View Reports');
	INSERT INTO openmrs.patientflags_tag_role (`tag_id`,`role`) VALUES (2,'Application: Writes Clinical Notes');
	INSERT INTO openmrs.patientflags_tag_role (`tag_id`,`role`) VALUES (2,'Authenticated');
	INSERT INTO openmrs.patientflags_tag_role (`tag_id`,`role`) VALUES (2,'Organizational: Doctor');
	INSERT INTO openmrs.patientflags_tag_role (`tag_id`,`role`) VALUES (2,'Organizational: Hospital Administrator');
	INSERT INTO openmrs.patientflags_tag_role (`tag_id`,`role`) VALUES (2,'Organizational: Nurse');
	INSERT INTO openmrs.patientflags_tag_role (`tag_id`,`role`) VALUES (2,'Organizational: Registration Clerk');
	INSERT INTO openmrs.patientflags_tag_role (`tag_id`,`role`) VALUES (2,'Organizational: System Administrator');
	INSERT INTO openmrs.patientflags_tag_role (`tag_id`,`role`) VALUES (2,'Privilege Level: Full');
	INSERT INTO openmrs.patientflags_tag_role (`tag_id`,`role`) VALUES (2,'Provider');
	INSERT INTO openmrs.patientflags_tag_role (`tag_id`,`role`) VALUES (2,'System Developer');
	INSERT INTO openmrs.patientflags_tag_role (`tag_id`,`role`) VALUES (2,'Application: View Reports');
	
	SET SQL_SAFE_UPDATES = 1;
	SET FOREIGN_KEY_CHECKS = 1;








