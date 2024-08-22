/*Creation des tables pour le jour en question*/

use isanteplus;

CREATE TABLE IF NOT EXISTS obs_by_day(
  `obs_id` int(11) NOT NULL AUTO_INCREMENT,
  `person_id` int(11) NOT NULL,
  `concept_id` int(11) NOT NULL DEFAULT '0',
  `encounter_id` int(11) DEFAULT NULL,
  `order_id` int(11) DEFAULT NULL,
  `obs_datetime` datetime NOT NULL,
  `location_id` int(11) DEFAULT NULL,
  `obs_group_id` int(11) DEFAULT NULL,
  `accession_number` varchar(255) DEFAULT NULL,
  `value_group_id` int(11) DEFAULT NULL,
  `value_coded` int(11) DEFAULT NULL,
  `value_coded_name_id` int(11) DEFAULT NULL,
  `value_drug` int(11) DEFAULT NULL,
  `value_datetime` datetime DEFAULT NULL,
  `value_numeric` double DEFAULT NULL,
  `value_modifier` varchar(2) DEFAULT NULL,
  `value_text` text,
  `value_complex` varchar(255) DEFAULT NULL,
  `comments` varchar(255) DEFAULT NULL,
  `creator` int(11) NOT NULL DEFAULT '0',
  `date_created` datetime NOT NULL,
  `voided` tinyint(1) NOT NULL DEFAULT '0',
  `voided_by` int(11) DEFAULT NULL,
  `date_voided` datetime DEFAULT NULL,
  `void_reason` varchar(255) DEFAULT NULL,
  `uuid` char(38) NOT NULL,
  `previous_version` int(11) DEFAULT NULL,
  `form_namespace_and_path` varchar(255) DEFAULT NULL,
  PRIMARY KEY (`obs_id`)
) ENGINE=InnoDB AUTO_INCREMENT=654767 DEFAULT CHARSET=utf8;

/*Create table patient_dispensing_day*/
CREATE TABLE IF NOT EXISTS patient_dispensing_day (
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
	voided tinyint(1),
	CONSTRAINT pk_patient_dispensing_day PRIMARY KEY(encounter_id,location_id,drug_id),
	INDEX(visit_date),
	INDEX(encounter_id),
	INDEX(patient_id)	
);


/*Create table patient_prescription_day*/
CREATE TABLE IF NOT EXISTS patient_prescription_day (
	patient_id int(11) not null,
	visit_id int(11),
	location_id int(11),
	visit_date Datetime,
	encounter_id int(11) not null,
	provider_id int(11),
	drug_id int(11) not null,
	dispensation_date DATE,
	next_dispensation_date DATE,
	dispensation_location int(11) default 0, 
	arv_drug int(11) default 1066, /*1066=No, 1065=YES*/
	dispense int(11), /*1066=No, 1065=YES*/
	rx_or_prophy int(11),
        posology text,
        number_day int(11),	
	last_updated_date DATETIME,
	voided tinyint(1),
	CONSTRAINT pk_patient_prescription_day PRIMARY KEY(encounter_id,location_id,drug_id),
	INDEX(visit_date),
	INDEX(encounter_id),
	INDEX(patient_id)	
);

/*Table patient_status_ARV contains all patients and their status*/
	create table if not exists patient_status_arv_day(
	patient_id int(11),
	id_status int,
	start_date date,
	encounter_id INT(11),
	end_date date,
	dis_reason int(11),
	last_updated_date DATETIME,
	date_started_status datetime,
	CONSTRAINT pk_patient_status_arv_day PRIMARY KEY (patient_id,id_status,start_date)
	);
	

	CREATE table IF NOT EXISTS exposed_infants_day(
		patient_id int(11),
		location_id int(11),
		encounter_id int(11),
		visit_date date,
		condition_exposee int(11)
	);
	

	create table if not exists last_obs(
	obs_id int(11),
	last_updated_date DATETIME
	);

/*Started DML queries*/
/* insert data to patient table */
	SET SQL_SAFE_UPDATES = 0;
			
	INSERT INTO isanteplus.obs_by_day
	SELECT o.obs_id,o.person_id,o.concept_id,o.encounter_id,o.order_id,o.obs_datetime,
	o.location_id,o.obs_group_id,o.accession_number,o.value_group_id,
	o.value_coded,o.value_coded_name_id,o.value_drug,o.value_datetime,
	o.value_numeric,o.value_modifier,o.value_text,o.value_complex,o.comments,
	o.creator,o.date_created,o.voided,o.voided_by,
	o.date_voided,o.void_reason,o.uuid,o.previous_version,o.form_namespace_and_path
	FROM openmrs.obs o WHERE DATE(o.date_created) = DATE(now())
	ON DUPLICATE KEY UPDATE
	obs_datetime = o.obs_datetime,
	obs_group_id = o.obs_group_id,
	value_datetime = o.value_datetime,
	value_coded = o.value_coded,
	value_numeric = o.value_numeric,
	value_text = o.value_text,
	voided = o.voided;		
			
		
	
/*Started DML queries*/
/* insert data to patient table */
	SET SQL_SAFE_UPDATES = 0;
			
	insert into patient
	(
	 patient_id,
	 given_name,
	 family_name,
	 gender,
	 birthdate, 
	 creator, 
	 date_created,
	 last_inserted_date,
	 last_updated_date,
	 voided
	)
	select pn.person_id,
		   pn.given_name,
		   pn.family_name,
		   pe.gender,
		   pe.birthdate,
		   pn.creator,
		   pn.date_created,
		   now() as last_inserted_date,
		   now() as last_updated_date,
		   pn.voided
	from openmrs.person_name pn, openmrs.person pe, openmrs.patient pa 
	where pe.person_id=pn.person_id AND pe.person_id=pa.patient_id
	AND DATE(pa.date_created) = DATE(now())
	on duplicate key update 
		given_name=pn.given_name,
		family_name=pn.family_name,
		gender=pe.gender,
		birthdate=pe.birthdate,
		creator=pn.creator,
		date_created=pn.date_created,
		last_updated_date = now(),
		voided = pn.voided;
						
	UPDATE patient p, openmrs.encounter en, openmrs.encounter_type ent
	SET p.vih_status=1
	WHERE p.patient_id=en.patient_id AND en.encounter_type=ent.encounter_type_id
	AND (ent.uuid='17536ba6-dd7c-4f58-8014-08c7cb798ac7'
	 OR ent.uuid='204ad066-c5c2-4229-9a62-644bc5617ca2'
	 OR ent.uuid='349ae0b4-65c1-4122-aa06-480f186c8350'
	 OR ent.uuid='33491314-c352-42d0-bd5d-a9d0bffc9bf1')
	AND en.voided = 0
	AND DATE(p.date_created) = DATE(now());
	
	
	
/*Started DML queries*/
/* insert data to patient table */
	SET SQL_SAFE_UPDATES = 0;
			
/* Insert for dispensing drugs */
				
	INSERT into patient_dispensing_day
	(
	 patient_id,
	 encounter_id,
	 location_id,
	 drug_id,
	 dispensation_date,
	 last_updated_date,
	 voided
	)
	select distinct ob.person_id,ob.encounter_id,ob.location_id,ob.value_coded,DATE(ob2.obs_datetime), now(), ob.voided
	from isanteplus.obs_by_day ob, isanteplus.obs_by_day ob1,isanteplus.obs_by_day ob2
	where ob.person_id=ob1.person_id
	AND ob.encounter_id=ob1.encounter_id
	AND ob.obs_group_id=ob1.obs_id
	AND ob1.obs_id = ob2.obs_group_id
	AND ob1.concept_id=163711	
	AND ob.concept_id=1282
	AND ob2.concept_id IN(1444, 159368, 1443, 1276)
	ON DUPLICATE KEY UPDATE
	dispensation_date = ob2.obs_datetime,
	last_updated_date = now(),
	voided = ob.voided;
					
/*update next_dispensation_date for table patient_dispensing*/	
	update patient_dispensing_day patdisp, isanteplus.obs_by_day ob 
	set patdisp.next_dispensation_date = DATE(ob.value_datetime)
	WHERE patdisp.encounter_id=ob.encounter_id
	AND ob.concept_id=162549
	AND ob.voided = 0;
					
/* Update on patient_dispensing where the drug is a ARV drug */
	UPDATE patient_dispensing_day pdis, (SELECT ad.drug_id FROM arv_drugs ad) B
	SET pdis.arv_drug = 1065
	WHERE pdis.drug_id = B.drug_id;
				   
/*update visit_id, visit_date for table patient_dispensing*/
	update patient_dispensing_day patdisp, openmrs.visit vi, openmrs.encounter en
	set patdisp.visit_id=vi.visit_id, patdisp.visit_date=vi.date_started
	where patdisp.encounter_id=en.encounter_id
	AND en.visit_id=vi.visit_id;
					
/*update rx_or_prophy for table patient_dispensing*/
	update isanteplus.patient_dispensing_day pdisp, isanteplus.obs_by_day ob1, isanteplus.obs_by_day ob2, isanteplus.obs_by_day ob3
	set pdisp.rx_or_prophy=ob2.value_coded
	WHERE pdisp.encounter_id=ob2.encounter_id
	AND ob1.obs_id=ob2.obs_group_id
	AND ob1.obs_id=ob3.obs_group_id
	AND pdisp.patient_id = ob2.person_id
	AND pdisp.location_id = ob2.location_id
	AND ob1.concept_id=1442
	AND ob2.concept_id=160742
	AND ob3.concept_id=1282
	AND pdisp.drug_id=ob3.value_coded
	AND ob2.voided=0;
				   
/*INSERTION for patient on ARV*/
/*  INSERT INTO patient_on_arv(patient_id,visit_id,visit_date, last_updated_date)
				   SELECT DISTINCT pdisp.patient_id, pdisp.visit_id,MIN(DATE(pdisp.visit_date)),now()
				   FROM patient_dispensing_day pdisp 
				   WHERE pdisp.arv_drug = 1065
				   AND (pdisp.rx_or_prophy = 138405 OR pdisp.rx_or_prophy is null)
				   AND pdisp.voided <> 1
				   GROUP BY pdisp.patient_id
					on duplicate key update
					visit_id = visit_id,
					visit_date = visit_date,
					last_updated_date = now();*/
					
/*DELETE all patients whose prescription form are modified, 
	because the provider can put a patient on ART by mistake, and correct the error after */
/*DELETE FROM patient_on_arv WHERE patient_id NOT IN
					(SELECT pdisp.patient_id FROM patient_dispensing pdisp
					WHERE pdisp.arv_drug = 1065 AND (pdisp.rx_or_prophy = 138405 
					OR pdisp.rx_or_prophy is null) AND pdisp.voided <> 1);*/
					
						
/*Insertion drug prescription */
				
	INSERT into patient_prescription_day
	(
	patient_id,
	encounter_id,
	location_id,
	drug_id,
	dispense,
	last_updated_date,
	voided
	)
	select distinct ob.person_id,
	ob.encounter_id,ob.location_id,ob.value_coded,
	IF(ob1.concept_id=163711, 1065, 1066), now(), ob.voided
	from isanteplus.obs_by_day ob, isanteplus.obs_by_day ob1, isanteplus.obs_by_day ob2
	where ob.person_id=ob1.person_id
	AND ob.encounter_id=ob1.encounter_id
	AND ob.obs_group_id=ob1.obs_id
	AND ob1.obs_id = ob2.obs_group_id
	AND (ob1.concept_id=1442 OR ob1.concept_id=163711)
	AND ob.concept_id=1282
	AND ob2.concept_id IN(160742,1276,1444,159368,1443)
	on duplicate key update
	encounter_id = ob.encounter_id,
	last_updated_date = now(),
	voided = ob.voided;
					
/*Insert for dispensing drugs*/
	
	INSERT into patient_prescription_day
	(
	patient_id,
	encounter_id,
	location_id,
	drug_id,
	dispensation_date,
	dispense,
	last_updated_date,
	voided
	)
	select distinct ob.person_id,
	ob.encounter_id,ob.location_id,ob.value_coded,ob2.obs_datetime, 1065, now(), ob.voided
	from isanteplus.obs_by_day ob, isanteplus.obs_by_day ob1,isanteplus.obs_by_day ob2
	where ob.person_id=ob1.person_id
	AND ob.encounter_id=ob1.encounter_id
	AND ob.obs_group_id=ob1.obs_id
	AND ob1.obs_id = ob2.obs_group_id
	AND ob1.concept_id=163711	
	AND ob.concept_id=1282
	AND ob2.concept_id IN(1276,1444,159368,1443)
	ON DUPLICATE KEY UPDATE
	dispensation_date = ob2.obs_datetime,
	dispense = 1065,
	last_updated_date = now(),
	voided = ob.voided;
				
/*update visit_id, visit_date for table patient_prescription*/
	update patient_prescription_day patp, openmrs.visit vi, openmrs.encounter en
	set patp.visit_id=vi.visit_id, patp.visit_date=vi.date_started
	where patp.encounter_id=en.encounter_id
	AND en.visit_id=vi.visit_id;
					
/* Update on patient_prescription where the drug is a ARV drug */
	UPDATE patient_prescription_day ppres, (SELECT ad.drug_id FROM arv_drugs ad) B
	SET ppres.arv_drug = 1065
	WHERE ppres.drug_id = B.drug_id;
					
/*update rx_or_prophy for table patient_prescription*/
	update isanteplus.patient_prescription_day pp, isanteplus.obs_by_day ob1, 
	isanteplus.obs_by_day ob2, isanteplus.obs_by_day ob3
	set pp.rx_or_prophy=ob2.value_coded
	WHERE pp.encounter_id=ob2.encounter_id
	AND ob1.obs_id=ob2.obs_group_id
	AND ob1.obs_id=ob3.obs_group_id
	AND ob1.concept_id=1442
	AND ob2.concept_id=160742
	AND ob3.concept_id=1282
	AND pp.drug_id=ob3.value_coded
	AND ob2.voided=0;   
			   
	
/*Started DML queries*/
	SET SQL_SAFE_UPDATES = 0;
/*SET FOREIGN_KEY_CHECKS=0;*/
/*Starting patient_laboratory */
/*Insertion for patient_laboratory*/
	INSERT into patient_laboratory
	(
	patient_id,
	encounter_id,
	location_id,
	test_id,
	last_updated_date,
	voided
	)
	select distinct ob.person_id,
	ob.encounter_id,ob.location_id,ob.value_coded, now(), ob.voided
	from isanteplus.obs_by_day ob, openmrs.encounter enc, 
	openmrs.encounter_type entype
	where ob.encounter_id=enc.encounter_id
	AND enc.encounter_type=entype.encounter_type_id
	AND ob.concept_id=1271
	AND entype.uuid='f037e97b-471e-4898-a07c-b8e169e0ddc4'
	on duplicate key update
	encounter_id = ob.encounter_id,
	last_updated_date = now(),
	voided = ob.voided;	
    
/*update visit_id, visit_date for table patient_laboratory*/
	update patient_laboratory lab, openmrs.visit vi, openmrs.encounter en
	set lab.visit_id=vi.visit_id, lab.visit_date=vi.date_started
	where lab.encounter_id=en.encounter_id
	AND en.visit_id=vi.visit_id
	AND vi.voided = 0;
	
/*update test_done,date_test_done,comment_test_done for patient_laboratory*/
	UPDATE patient_laboratory plab,openmrs.obs ob
	SET plab.test_done=1,
	plab.test_result=CASE WHEN ob.value_coded IS NOT NULL
	THEN ob.value_coded
	WHEN ob.value_numeric IS NOT NULL 
	THEN ob.value_numeric
	WHEN ob.value_text IS NOT NULL THEN ob.value_text
	END,
	plab.date_test_done=ob.obs_datetime,
	plab.comment_test_done=ob.comments
	WHERE plab.test_id=ob.concept_id
	AND plab.encounter_id=ob.encounter_id
	AND ob.voided = 0
	AND (ob.value_coded IS NOT NULL OR ob.value_numeric IS NOT NULL
	OR ob.value_text IS NOT NULL);

/*End of patient_laboratory*/

		
	SET SQL_SAFE_UPDATES = 0;
/*insertion of virological tests (PCR) in the table virological_tests*/

	INSERT into virological_tests
	(
	patient_id,
	encounter_id,
	location_id,
	concept_group,
	obs_group_id,
	test_id,
	answer_concept_id,
	last_updated_date,
	voided
	)
	select distinct ob.person_id,ob.encounter_id,
	ob.location_id,ob1.concept_id,ob.obs_group_id,ob.concept_id, ob.value_coded, now(), ob.voided
	from isanteplus.obs_by_day ob, isanteplus.obs_by_day ob1, openmrs.concept c
	where ob.person_id=ob1.person_id
	AND ob.encounter_id=ob1.encounter_id
	AND ob.obs_group_id=ob1.obs_id
	AND ob1.concept_id = c.concept_id
	AND c.uuid IN ('eaa7f684-1473-4f59-acb4-686bada87846',
		'9a05c0d5-2c03-4c3a-a810-6bc513ae7ee7',
		'535b63e9-0773-4f4e-94af-69ff8f412411')	
	AND ob.concept_id=162087
	AND ob.value_coded=1030
	on duplicate key update
	encounter_id = ob.encounter_id,
	last_updated_date = now(),
	voided = ob.voided;
	
/*Update for area test_result for PCR*/
	update virological_tests vtests, isanteplus.obs_by_day ob
	SET vtests.test_result=ob.value_coded
	WHERE ob.concept_id=1030
	AND vtests.obs_group_id=ob.obs_group_id
	and vtests.encounter_id=ob.encounter_id
	AND vtests.location_id=ob.location_id
	AND ob.voided = 0;
	
/*Update for area age for PCR*/
	update virological_tests vtests, isanteplus.obs_by_day ob
	SET vtests.age=ob.value_numeric
	WHERE ob.concept_id=163540
	AND vtests.obs_group_id=ob.obs_group_id
	and vtests.encounter_id=ob.encounter_id
	AND vtests.location_id=ob.location_id
	AND ob.voided = 0;
	
/*Update for age_unit for PCR*/
	update virological_tests vtests, isanteplus.obs_by_day ob
	SET vtests.age_unit=ob.value_coded
	WHERE ob.concept_id=163541
	AND vtests.obs_group_id=ob.obs_group_id
	and vtests.encounter_id=ob.encounter_id
	AND vtests.location_id=ob.location_id
	AND ob.voided = 0;
	
/*Update encounter date for virological_tests*/	   
	update virological_tests vtests, openmrs.encounter enc
	SET vtests.encounter_date=DATE(enc.encounter_datetime)
	WHERE vtests.location_id=enc.location_id
	AND vtests.encounter_id=enc.encounter_id
	AND enc.voided = 0;
	
/*Update to fill test_date area*/
	update virological_tests vtests, patient p 
	SET vtests.test_date =
	CASE WHEN(vtests.age_unit=1072 AND (ADDDATE(DATE(p.birthdate), INTERVAL vtests.age DAY) < DATE(now()))) 
	THEN ADDDATE(DATE(p.birthdate), INTERVAL vtests.age DAY)
	WHEN(vtests.age_unit=1074
	AND (ADDDATE(DATE(p.birthdate), INTERVAL vtests.age MONTH) < DATE(now()))) THEN ADDDATE(DATE(p.birthdate), INTERVAL vtests.age MONTH)
	ELSE
	vtests.encounter_date
	END
	WHERE vtests.patient_id = p.patient_id
	AND vtests.test_id = 162087
	AND answer_concept_id = 1030;
	
/*END of virological_tests table*/
	
/* DECLARE myIndex INT;
		select count(*) into myIndex from information_schema.statistics where table_name = 'patient_status_arv' and index_name = 'patient_status_arv_index' and table_schema = 'isanteplus';
		if(myIndex=0) then 
			create unique index patient_status_arv_index on patient_status_arv (patient_id, id_status, start_date);
		end if;*/
	SET SQL_SAFE_UPDATES = 0;
/*SET FOREIGN_KEY_CHECKS = 0;*/
	
/*Insertion for exposed infants*/
/*Le dernier PCR en date doit être négatif fiche Premiere visite VIH pediatrique et Laboratoire 
	condition_exposee = 1
*/
	truncate table exposed_infants_day;
		
/*	PCR_Concept_id=844,Positif=1301,Negatif=1302,Equivoque=1300,Echantillon de pauvre qualite=1304
		Fiche laboratoire, condition_exposee = 1
		*/
/* Dernier PCR negatif */

	DROP table IF EXISTS patient_pcr_negative;
	CREATE TEMPORARY TABLE IF NOT EXISTS patient_pcr_negative
	SELECT o.person_id as patient_id, o.encounter_id, o.location_id, e.encounter_datetime as encounter_date, o.concept_id, o.value_coded, o.obs_datetime
	FROM openmrs.obs o, openmrs.encounter e, openmrs.encounter_type et,
	(SELECT en.patient_id, MAX(en.encounter_datetime) as visit_date FROM openmrs.obs ob,
	openmrs.encounter en, openmrs.encounter_type ety
	WHERE ob.encounter_id = en.encounter_id 
	AND en.encounter_type = ety.encounter_type_id AND ob.concept_id IN (1030, 844)
	AND ety.uuid IN('349ae0b4-65c1-4122-aa06-480f186c8350','f037e97b-471e-4898-a07c-b8e169e0ddc4')
	AND ob.voided <> 1 AND en.voided <> 1 GROUP BY 1) B
	WHERE o.person_id = e.patient_id
	AND o.encounter_id = e.encounter_id
	AND e.encounter_type = et.encounter_type_id
	AND e.patient_id = B.patient_id
	AND DATE(e.encounter_datetime) = DATE(B.visit_date)
	AND et.uuid IN ('349ae0b4-65c1-4122-aa06-480f186c8350','f037e97b-471e-4898-a07c-b8e169e0ddc4')
	AND o.concept_id IN (1030, 844)
	AND (o.value_coded = 664 OR o.value_coded = 1302)
	AND o.voided <> 1
	AND e.voided <> 1;

	INSERT INTO exposed_infants_day(patient_id,location_id,encounter_id,visit_date,condition_exposee)
	SELECT ppn.patient_id,ppn.location_id,ppn.encounter_id,ppn.encounter_date,1
	FROM patient_pcr_negative ppn
	WHERE (ppn.concept_id = 1030 AND ppn.value_coded = 664)
	OR (ppn.concept_id = 844 AND ppn.value_coded = 1302);
			  
	DROP table IF EXISTS patient_pcr_negative;
	
/*	Condition B - Enfant exposé doit être coché
		Fiche Premiere visit VIH pediatrique
		condition_exposee = 3
	*/
	INSERT INTO exposed_infants_day(patient_id,location_id,encounter_id,visit_date,condition_exposee)
	select distinct ob.person_id,ob.location_id,ob.encounter_id,
	DATE(enc.encounter_datetime),3
	from openmrs.obs ob, openmrs.encounter enc, 
	openmrs.encounter_type ent
	WHERE ob.encounter_id	= enc.encounter_id
	AND enc.encounter_type	= ent.encounter_type_id
	AND ob.concept_id = 1401
	AND ob.value_coded = 1405
	AND ob.voided <> 1
	AND enc.voided <> 1
	AND (ent.uuid ="349ae0b4-65c1-4122-aa06-480f186c8350"
	OR ent.uuid = "33491314-c352-42d0-bd5d-a9d0bffc9bf1");
	
/* Condition D - Des ARV prescrits en prophylaxie
		patient_prescription.rx_or_prophy=163768
		Fiche Ordonance medicale, condition_exposee = 4
		*/
	INSERT INTO exposed_infants_day(patient_id,location_id,encounter_id,visit_date,condition_exposee)
	select distinct pdisp.patient_id,pdisp.location_id,pdisp.encounter_id,pdisp.visit_date,4
	from patient_dispensing pdisp, (select ppres.patient_id, 
	MAX(ppres.visit_date) as visit_date FROM patient_dispensing ppres 
	WHERE ppres.arv_drug = 1065 AND ppres.voided <> 1 GROUP BY 1) B
	WHERE pdisp.patient_id = B.patient_id
	AND pdisp.visit_date = B.visit_date
	AND pdisp.rx_or_prophy = 163768
	AND pdisp.arv_drug = 1065
	AND pdisp.voided <> 1; 
		
/*End insertion for exposed infants*/
/*Delete patients from the exposed_infants_day whose have a Positive PCR*/
	
/*Patient with PCR positive*/
	DROP table IF EXISTS patient_pcr_positif;
	CREATE TEMPORARY TABLE IF NOT EXISTS patient_pcr_positif
	SELECT o.person_id as patient_id, o.concept_id, o.value_coded, o.obs_datetime
	FROM openmrs.obs o, openmrs.encounter e, openmrs.encounter_type et
	WHERE o.person_id = e.patient_id
	AND o.encounter_id = e.encounter_id
	AND e.encounter_type = et.encounter_type_id
	AND et.uuid = '349ae0b4-65c1-4122-aa06-480f186c8350'
	AND o.concept_id = 1030
	AND o.value_coded = 703
	AND o.voided <> 1
	AND e.voided <> 1;
	
	INSERT INTO patient_pcr_positif(patient_id, concept_id, value_coded, obs_datetime)
	SELECT o.person_id as patient_id, o.concept_id, o.value_coded, o.obs_datetime
	FROM openmrs.obs o, openmrs.encounter e, openmrs.encounter_type et
	WHERE o.person_id = e.patient_id
	AND o.encounter_id = e.encounter_id
	AND e.encounter_type = et.encounter_type_id
	AND et.uuid = 'f037e97b-471e-4898-a07c-b8e169e0ddc4'
	AND o.concept_id = 844
	AND o.value_coded = 1301
	AND o.voided <> 1
	AND e.voided <> 1;
	
	DELETE exposed_infants_day FROM exposed_infants_day, patient_pcr_positif 
	WHERE exposed_infants_day.patient_id = patient_pcr_positif.patient_id;
	
	DROP table IF EXISTS patient_pcr_positif;
/*END for Delete patient from the exposed_infants_day whose have a Positive PCR*/
/*Delete from exposed_infants_day where patient has a HIV Positive TEST */
	DELETE exposed_infants_day FROM exposed_infants_day,
	(SELECT pl.patient_id FROM patient_laboratory pl, patient p 
	WHERE pl.patient_id = p.patient_id AND pl.test_id = 1040 
	AND pl.test_done = 1 AND pl.test_result = 703 AND pl.voided <> 1
	AND (TIMESTAMPDIFF(MONTH, p.birthdate,DATE(now())) >= 18)) C
	WHERE exposed_infants_day.patient_id = C.patient_id;
	
/*DELETE from exposed_infants_day where VIH positif - confirmé par test sérologique > 18 mois*/
	DELETE exposed_infants_day FROM exposed_infants_day,
	(select distinct ob.person_id from openmrs.obs ob, openmrs.encounter enc, openmrs.encounter_type ent
	WHERE ob.encounter_id	=	enc.encounter_id
	AND enc.encounter_type	=	ent.encounter_type_id
	AND ob.person_id = enc.patient_id
	AND ob.concept_id = 1401
	AND ob.value_coded = 163717
	AND ob.voided <> 1
	AND (ent.uuid =	"349ae0b4-65c1-4122-aa06-480f186c8350"
	OR ent.uuid = "33491314-c352-42d0-bd5d-a9d0bffc9bf1")) C
	WHERE exposed_infants_day.patient_id = C.person_id;
						
/*	Condition 5 - Séroréversion doit être coché
		Rapport d''arrêt du programme soins et traitement VIH/SIDA
		condition_exposee = 5
	*/
	INSERT INTO exposed_infants_day(patient_id,location_id,encounter_id,visit_date,condition_exposee)
	select distinct ob.person_id,ob.location_id,ob.encounter_id,
	DATE(enc.encounter_datetime),5
	from openmrs.obs ob, openmrs.encounter enc, 
	openmrs.encounter_type ent
	WHERE ob.encounter_id	=	enc.encounter_id
	AND enc.encounter_type	=	ent.encounter_type_id
	AND ob.concept_id = 1667
	AND ob.value_coded = 165439
	AND ob.voided <> 1
	AND ent.uuid =	"9d0113c6-f23a-4461-8428-7e9a7344f2ba";
		
/*TRUNCATE TABLE patient_status_arv;*/
	/*Insertion for patient_status Décédés=1,Arrêtés=2,Transférés=3 on ARV
	We use max(start_date) OR max(date_started) because
	we can''t find the historic of the patient status
*/
/*Starting patient_status_arv*/
/*====================================================*/
/*Insertion for patient_status Décédés en Pré-ARV=4 */
	INSERT INTO patient_status_arv_day(patient_id,id_status,start_date,encounter_id,last_updated_date, date_started_status)
	SELECT v.patient_id,4 AS id_status,DATE(v.date_started) AS start_date, 
	enc.encounter_id as encounter_id, now(), now()
	FROM isanteplus.patient ispat,openmrs.visit v,
	openmrs.encounter_type entype,openmrs.encounter enc,
	openmrs.obs ob, (SELECT pvi.patient_id, MAX(DATE(pvi.date_started)) as visit_date 
	FROM openmrs.visit pvi where pvi.voided = 0 GROUP BY 1) B
	WHERE ispat.patient_id = v.patient_id
	AND v.visit_id = enc.visit_id
	AND entype.encounter_type_id = enc.encounter_type
	AND enc.encounter_id = ob.encounter_id
	AND v.patient_id = B.patient_id
	AND v.date_started = B.visit_date
	AND entype.uuid = '9d0113c6-f23a-4461-8428-7e9a7344f2ba'
	AND ob.concept_id = 161555
	AND ob.value_coded = 159
	AND ispat.vih_status = 1
	AND enc.patient_id NOT IN(SELECT parv.patient_id 
	FROM isanteplus.patient_on_arv parv)
	AND ob.voided = 0
	GROUP BY v.patient_id
	on duplicate key update 
	last_updated_date = values(last_updated_date);
	
/*Insertion for patient_status Transférés en Pré-ARV=5*/
	INSERT INTO patient_status_arv_day(patient_id,id_status,start_date,encounter_id,last_updated_date, date_started_status)
	SELECT v.patient_id,5 AS id_status,DATE(v.date_started) AS start_date, 
	enc.encounter_id as encounter_id, now(), now()
	FROM isanteplus.patient ispat,openmrs.visit v,
	openmrs.encounter_type entype,openmrs.encounter enc,
	openmrs.obs ob, (SELECT pvi.patient_id, MAX(DATE(pvi.date_started)) as visit_date 
	FROM openmrs.visit pvi where pvi.voided = 0 GROUP BY 1) B
	WHERE ispat.patient_id = v.patient_id
	AND v.visit_id = enc.visit_id
	AND entype.encounter_type_id = enc.encounter_type
	AND enc.encounter_id = ob.encounter_id
	AND v.patient_id = B.patient_id
	AND v.date_started = B.visit_date
	AND entype.uuid = '9d0113c6-f23a-4461-8428-7e9a7344f2ba'
	AND ob.concept_id = 161555
	AND ob.value_coded = 159492
	AND ispat.vih_status = 1
	AND enc.patient_id NOT IN(SELECT parv.patient_id 
	FROM isanteplus.patient_on_arv parv)
	AND ob.voided = 0
	GROUP BY v.patient_id
	on duplicate key update 
	last_updated_date = values(last_updated_date);
	
	
/*Insertion for patient_status réguliers=6*/
	INSERT INTO patient_status_arv_day(patient_id,id_status,start_date,encounter_id,last_updated_date, date_started_status)
	SELECT pdis.patient_id,6 as id_status,MAX(DATE(pdis.visit_date)) as start_date,pdis.encounter_id as encounter_id,
	now(), now()
	FROM isanteplus.patient ipat,isanteplus.patient_dispensing_day pdis,
	(select pdisp.patient_id, MAX(pdisp.next_dispensation_date) as mnext_disp 
	from isanteplus.patient_dispensing_day pdisp WHERE pdisp.voided <> 1 AND pdisp.arv_drug = 1065 group by 1) mndisp,
	openmrs.encounter enc,
	openmrs.encounter_type entype
	WHERE ipat.patient_id = pdis.patient_id
	AND pdis.visit_id = enc.visit_id
	AND pdis.patient_id = mndisp.patient_id
	AND pdis.next_dispensation_date = mndisp.mnext_disp
	AND enc.encounter_type=entype.encounter_type_id
	AND enc.patient_id	
	NOT IN(SELECT dreason.patient_id FROM discontinuation_reason dreason
	WHERE dreason.reason IN(159,1667,159492))
	AND pdis.arv_drug = 1065
	AND entype.uuid IN ('10d73929-54b6-4d18-a647-8b7316bc1ae3',
	                        'a9392241-109f-4d67-885b-57cc4b8c638f')
	AND((DATE(now()) <= pdis.next_dispensation_date))
	GROUP BY pdis.patient_id
	on duplicate key update 
	last_updated_date = values(last_updated_date);
	
/*create index patient_status_arv_index_a on patient_status_arv_temp_a (patient_id, id_status, start_date);*/
/*Adding status into patient_status_arv table */
/*INSERT INTO patient_status_arv(patient_id,id_status,start_date,last_updated_date)
    select distinct psat.patient_id, psat.id_status, psat.start_date, now() 
	from patient_status_arv_temp_a psat
	on duplicate key update 
	start_date = start_date,
	last_updated_date = now();*/
	
/*truncate the temporary table after the insertion */
/*truncate table patient_status_arv_temp_a;*/
/*=========================================================*/
	
/*Insertion for patient_status Rendez-vous ratés=8*/
/*INSERT INTO patient_status_arv_temp_a*/
	INSERT INTO patient_status_arv_day(patient_id,id_status,start_date, encounter_id,last_updated_date, date_started_status)
	SELECT pdis.patient_id,8 as id_status,MAX(DATE(pdis.visit_date)) as start_date, pdis.encounter_id as encounter_id,
	now(), now()
	FROM isanteplus.patient ipat,isanteplus.patient_dispensing_day pdis,
	(select pdisp.patient_id, MAX(pdisp.next_dispensation_date) as mnext_disp 
	from isanteplus.patient_dispensing_day pdisp WHERE pdisp.voided <> 1 AND pdisp.arv_drug = 1065 group by 1) mndisp,
	openmrs.encounter enc,
	openmrs.encounter_type entype
	WHERE ipat.patient_id=pdis.patient_id
	AND pdis.visit_id=enc.visit_id
	AND pdis.patient_id = mndisp.patient_id
	AND pdis.next_dispensation_date = mndisp.mnext_disp
	AND enc.encounter_type=entype.encounter_type_id
	AND enc.patient_id	
	NOT IN(SELECT dreason.patient_id FROM discontinuation_reason dreason
	WHERE dreason.reason IN(159,1667,159492))
	AND enc.patient_id IN (SELECT parv.patient_id 
	FROM isanteplus.patient_on_arv parv)
	AND entype.uuid IN ('10d73929-54b6-4d18-a647-8b7316bc1ae3',
	                        'a9392241-109f-4d67-885b-57cc4b8c638f'
							) 
	AND (DATEDIFF(DATE(now()),pdis.next_dispensation_date)<=30)
	AND((DATE(now()) > pdis.next_dispensation_date))
	GROUP BY pdis.patient_id
	on duplicate key update 
	last_updated_date = values(last_updated_date);

/*Insertion for status on the table patient_arv_status Rendez-vous ratés=8*/
/*Adding status into patient_status_arv table */
/*INSERT INTO patient_status_arv(patient_id,id_status,start_date,last_updated_date)
    select distinct psat.patient_id,psat.id_status,psat.start_date,now() 
	from patient_status_arv_temp_a psat
	on duplicate key update 
	start_date = psat.start_date,
	last_updated_date = now();*/
/*truncate the temporary table after the insertion */
/*truncate table patient_status_arv_temp_a;*/
	
/*Insertion for patient_status Perdus de vue=9*/
	INSERT INTO patient_status_arv_day(patient_id,id_status,start_date,encounter_id,last_updated_date, date_started_status)
	SELECT pdis.patient_id,9 as id_status,MAX(DATE(pdis.visit_date)) as start_date, pdis.encounter_id as encounter_id,
	now(), now()
	FROM isanteplus.patient_dispensing_day pdis,
	(select pdisp.patient_id, MAX(pdisp.next_dispensation_date) as mnext_disp 
	from isanteplus.patient_dispensing_day pdisp WHERE pdisp.voided <> 1 AND pdisp.arv_drug = 1065 group by 1) mndisp,
	openmrs.encounter enc,openmrs.encounter_type entype
	WHERE pdis.visit_id=enc.visit_id
	AND pdis.patient_id = mndisp.patient_id
	AND pdis.next_dispensation_date = mndisp.mnext_disp
	AND enc.encounter_type=entype.encounter_type_id
	AND enc.patient_id 
	NOT IN(SELECT dreason.patient_id FROM discontinuation_reason dreason
	WHERE dreason.reason IN(159,1667,159492))
	AND pdis.arv_drug = 1065
	AND (DATE(now()) > pdis.next_dispensation_date)
	AND (DATEDIFF(DATE(now()),pdis.next_dispensation_date)>30)
	AND entype.uuid IN ('10d73929-54b6-4d18-a647-8b7316bc1ae3',
	                        'a9392241-109f-4d67-885b-57cc4b8c638f')
	GROUP BY pdis.patient_id
	on duplicate key update 
	last_updated_date = values(last_updated_date);
	
/*Insertion for status on the table patient_arv_status Perdus de vue=9*/
/*Adding status into patient_status_arv table */
/*INSERT INTO patient_status_arv(patient_id,id_status,start_date,last_updated_date)
    select distinct psat.patient_id,psat.id_status,psat.start_date,now() 
	from patient_status_arv_temp_a psat
	on duplicate key update 
	start_date = psat.start_date,
	last_updated_date = now();*/
/*truncate the temporary table after the insertion */
/*truncate table patient_status_arv_temp_a;*/
	
/*INSERTION for patient status,
     Perdus de vue en Pré-ARV=10 */
	INSERT INTO patient_status_arv_day(patient_id,id_status,start_date,encounter_id,last_updated_date,date_started_status)
	SELECT v.patient_id,10,
	MAX(DATE(v.date_started)) AS start_date, enc.encounter_id as encounter_id, now(), now()
	FROM isanteplus.patient ispat,
	openmrs.visit v,openmrs.encounter enc,
	openmrs.encounter_type entype, (SELECT pvi.patient_id, MAX(DATE(pvi.date_started)) as visit_date 
						FROM openmrs.visit pvi WHERE pvi.voided <> 1 GROUP BY 1) B
	WHERE ispat.patient_id=v.patient_id
	AND v.visit_id=enc.visit_id 
	AND enc.encounter_type=entype.encounter_type_id
	AND v.patient_id = B.patient_id
	AND v.date_started = B.visit_date
	AND enc.patient_id NOT IN 
	(SELECT dreason.patient_id FROM discontinuation_reason dreason
	WHERE dreason.reason IN(159,159492))
	AND ispat.vih_status=1
	AND ispat.patient_id NOT IN (SELECT parv.patient_id
	FROM isanteplus.patient_on_arv parv)
	AND entype.uuid NOT IN('17536ba6-dd7c-4f58-8014-08c7cb798ac7',
		'349ae0b4-65c1-4122-aa06-480f186c8350',
		'204ad066-c5c2-4229-9a62-644bc5617ca2',
		'33491314-c352-42d0-bd5d-a9d0bffc9bf1',
		'10d73929-54b6-4d18-a647-8b7316bc1ae3',
		'a9392241-109f-4d67-885b-57cc4b8c638f',
		'f037e97b-471e-4898-a07c-b8e169e0ddc4'
		)
	AND (TIMESTAMPDIFF(MONTH, v.date_started,DATE(now())) > 12)
	GROUP BY v.patient_id
	on duplicate key update 
	last_updated_date = values(last_updated_date);
	
/*=========================================================*/
/*INSERTION for patient status Recent on PRE-ART=7,Actifs en Pré-ARV=11 */
	INSERT INTO patient_status_arv_day(patient_id,id_status,start_date,encounter_id,last_updated_date,date_started_status)
	SELECT v.patient_id,7 AS id_status,
	MAX(DATE(v.date_started)) AS start_date, enc.encounter_id as encounter_id, now(), now()
	FROM isanteplus.patient ispat,
	openmrs.visit v,openmrs.encounter enc,
	openmrs.encounter_type entype,(SELECT pvi.patient_id, MAX(DATE(pvi.date_started)) as visit_date 
	FROM openmrs.visit pvi WHERE pvi.voided <> 1 GROUP BY 1) B
	WHERE ispat.patient_id = v.patient_id
	AND v.visit_id = enc.visit_id 
	AND enc.encounter_type = entype.encounter_type_id
	AND v.patient_id = B.patient_id
	AND v.date_started = B.visit_date
	AND enc.patient_id NOT IN 
	(SELECT dreason.patient_id FROM discontinuation_reason dreason
	WHERE dreason.reason IN(159,159492))
	AND ispat.vih_status = 1
	AND ispat.patient_id NOT IN (SELECT parv.patient_id
	FROM isanteplus.patient_on_arv parv)
	AND entype.uuid IN('17536ba6-dd7c-4f58-8014-08c7cb798ac7',
		'349ae0b4-65c1-4122-aa06-480f186c8350')
	AND (TIMESTAMPDIFF(MONTH,v.date_started,DATE(now()))<=12)
	GROUP BY v.patient_id
	on duplicate key update 
	last_updated_date = values(last_updated_date);
	
/*INSERTION for patient status Actifs en Pré-ARV=11 */
	INSERT INTO patient_status_arv_day(patient_id,id_status,start_date,encounter_id,last_updated_date,date_started_status)
	SELECT v.patient_id,11 AS id_status,
	MAX(DATE(v.date_started)) AS start_date, enc.encounter_id as encounter_id, now(), now()
	FROM isanteplus.patient ispat,
	openmrs.visit v,openmrs.encounter enc,
	openmrs.encounter_type entype,(SELECT pvi.patient_id, MAX(DATE(pvi.date_started)) as visit_date 
	FROM openmrs.visit pvi WHERE pvi.voided <> 1 GROUP BY 1) B
	WHERE ispat.patient_id = v.patient_id
	AND v.visit_id = enc.visit_id 
	AND enc.encounter_type = entype.encounter_type_id
	AND v.patient_id = B.patient_id
	AND v.date_started = B.visit_date
	AND enc.patient_id NOT IN 
	(SELECT dreason.patient_id FROM discontinuation_reason dreason
	WHERE dreason.reason IN(159,159492))
	AND ispat.vih_status = 1
	AND ispat.patient_id NOT IN (SELECT parv.patient_id
	FROM isanteplus.patient_on_arv parv)
	AND entype.uuid IN('204ad066-c5c2-4229-9a62-644bc5617ca2',
		'33491314-c352-42d0-bd5d-a9d0bffc9bf1',
		'10d73929-54b6-4d18-a647-8b7316bc1ae3',
		'a9392241-109f-4d67-885b-57cc4b8c638f',
		'f037e97b-471e-4898-a07c-b8e169e0ddc4')
	AND (TIMESTAMPDIFF(MONTH,v.date_started,DATE(now()))<=12)
	GROUP BY v.patient_id
	on duplicate key update 
	last_updated_date = values(last_updated_date);
	
/*Décédés=1*/
	INSERT INTO patient_status_arv_day(patient_id,id_status,start_date,encounter_id,
	last_updated_date, date_started_status)
	SELECT enc.patient_id, 1 as id_status, MAX(DATE(enc.encounter_datetime)) AS start_date, 
	enc.encounter_id as encounter_id, now(), now()
	FROM openmrs.encounter enc,openmrs.encounter_type entype,isanteplus.obs_by_day ob,
	isanteplus.patient_on_arv parv
	WHERE enc.encounter_type = entype.encounter_type_id
	AND enc.encounter_id = ob.encounter_id
	AND enc.patient_id = ob.person_id
	AND enc.patient_id = parv.patient_id
	AND entype.uuid = '9d0113c6-f23a-4461-8428-7e9a7344f2ba'
	AND ob.concept_id = 161555
	AND ob.value_coded = 159
	AND ob.voided = 0
	AND enc.voided = 0
	GROUP BY enc.patient_id
	on duplicate key update 
	last_updated_date = values(last_updated_date);
	
/*Transférés=2*/
	INSERT INTO patient_status_arv_day(patient_id,id_status,start_date, encounter_id,
	last_updated_date, date_started_status)
	SELECT enc.patient_id, 2 as id_status, MAX(DATE(enc.encounter_datetime)) AS start_date, 
	enc.encounter_id as encounter_id, now(), now()
	FROM openmrs.encounter enc,openmrs.encounter_type entype,
	isanteplus.obs_by_day ob,isanteplus.patient_on_arv parv
	WHERE enc.encounter_type = entype.encounter_type_id
	AND enc.patient_id = ob.person_id
	AND enc.encounter_id = ob.encounter_id
	AND enc.patient_id = parv.patient_id
	AND entype.uuid = '9d0113c6-f23a-4461-8428-7e9a7344f2ba'
	AND ob.concept_id = 161555
	AND ob.value_coded = 159492
	AND ob.voided = 0
	AND enc.voided = 0
	GROUP BY enc.patient_id
	on duplicate key update 
	last_updated_date = values(last_updated_date);
	
/*Arrêtés=3*/
	INSERT INTO patient_status_arv_day(patient_id,id_status,start_date,encounter_id,
	last_updated_date, date_started_status)
	SELECT enc.patient_id,3 as id_status, MAX(DATE(enc.encounter_datetime)) AS start_date, 
	enc.encounter_id as encounter_id, now(), now()
	FROM openmrs.encounter enc,
	openmrs.encounter_type entype,isanteplus.obs_by_day ob, 
	isanteplus.obs_by_day ob2,isanteplus.patient_on_arv parv
	WHERE enc.encounter_type = entype.encounter_type_id
	AND enc.patient_id = ob.person_id
	AND enc.encounter_id = ob.encounter_id
	AND enc.patient_id = parv.patient_id
	AND ob.encounter_id = ob2.encounter_id
	AND entype.uuid = '9d0113c6-f23a-4461-8428-7e9a7344f2ba'
	AND ob.concept_id = 161555
	AND ob.value_coded = 1667
	AND ob.voided = 0
	AND enc.voided = 0
	AND ob2.concept_id = 1667
	AND ob2.value_coded IN (115198,159737)
	GROUP BY enc.patient_id
	on duplicate key update 
	last_updated_date = values(last_updated_date);
		
/*DROP TABLE patient_status_arv_temp_a;*/
	
/*===========================================================*/
/*UPDATE Discontinuations reason in table patient_status_ARV*/
	UPDATE patient_status_arv_day psarv,discontinuation_reason dreason
	SET psarv.dis_reason=dreason.reason
	WHERE psarv.patient_id=dreason.patient_id
	AND psarv.start_date <= dreason.visit_date;	
/*Delete Exposed infants from patient_arv_status*/
	DELETE patient_status_arv_day FROM patient_status_arv_day,exposed_infants_day
	WHERE patient_status_arv_day.patient_id = exposed_infants_day.patient_id;
	
/*Update patient table for having the last patient arv status*/
	update patient p,patient_status_arv_day psa, 
	(SELECT psarv.patient_id, MAX(psarv.last_updated_date) as last_updated_date 
	FROM patient_status_arv_day psarv GROUP BY 1) B
	SET p.arv_status = psa.id_status
	WHERE p.patient_id = psa.patient_id
	AND psa.patient_id = B.patient_id
	AND DATE(psa.last_updated_date) = DATE(B.last_updated_date);
	
/*End of patient Status*/
/*Delete data from patient_status_arv that contain patient_status_arv_day*/
	DELETE patient_status_arv FROM patient_status_arv, patient_status_arv_day psad
	WHERE patient_status_arv.patient_id = psad.patient_id
	AND patient_status_arv.id_status = psad.id_status
	AND patient_status_arv.start_date = psad.start_date
	AND DATE(patient_status_arv.date_started_status) = DATE(psad.date_started_status);
	
/*Transfer data from patient_status_arv_day to patient_status_arv*/
	INSERT INTO patient_status_arv(patient_id,id_status,start_date,encounter_id,last_updated_date,
	date_started_status)
	SELECT ps.patient_id,ps.id_status,ps.start_date,ps.encounter_id,ps.last_updated_date,
	MAX(ps.date_started_status) FROM patient_status_arv_day ps
	GROUP BY ps.patient_id
	on duplicate key update 
	last_updated_date = values(last_updated_date);

	
	
	SET SQL_SAFE_UPDATES = 0;
/*SET FOREIGN_KEY_CHECKS = 0;*/
			
	INSERT INTO last_obs(obs_id,last_updated_date)
	SELECT MAX(obs_id), now() FROM obs_by_day
	ON DUPLICATE KEY UPDATE
	last_updated_date = now();
			
	DROP TABLE if exists pepfarTableTemp_day;
	DROP TABLE if exists oneDrugRegimenPrefixTemp_day;
	DROP TABLE if exists twoDrugRegimenPrefixTemp_day;
	
/*Insertion regimen for one drug arv*/
	create temporary table pepfarTableTemp_day
	(location_id int(11),
	patient_id int(11),
	visit_date datetime,
	regimen varchar(255),
	rx_or_prophy int(11));

	create temporary table oneDrugRegimenPrefixTemp_day (
	location_id int(11),
	patient_id int(11),
	visit_date datetime,
	drugID1 int(11),
	rx_or_prophy int(11)
	);

	insert into oneDrugRegimenPrefixTemp_day
	select d1.location_id, d1.patient_id, d1.visit_date, d1.drug_id, d1.rx_or_prophy
	from patient_prescription_day d1
	join patient p on d1.patient_id = p.patient_id
	join (select distinct drugID1 from regimen) r
	on r.drugID1 = d1.drug_id
	where d1.arv_drug = 1065
	AND d1.voided <> 1;

	insert into pepfarTableTemp_day (location_id, patient_id, visit_date, regimen, rx_or_prophy)
	select distinct location_id, patient_id, visit_date, shortname, rx_or_prophy
	from oneDrugRegimenPrefixTemp_day d1
	join regimen r
	on r.drugID1 = d1.drugID1
	where r.drugID2 = 0
	and r.drugID3 = 0;

/*Insertion regimen for two drugs arv*/
	create temporary table twoDrugRegimenPrefixTemp_day (
	location_id int(11),
	patient_id int(11),
	visit_date datetime,
	drugID1 int(11),
	drugID2 int(11),
	rx_or_prophy int(11)
	);

	insert into twoDrugRegimenPrefixTemp_day
	select location_id, patient_id, visit_date, d1.drugID1, d2.drug_id, d1.rx_or_prophy
	from oneDrugRegimenPrefixTemp_day d1
	join patient_prescription_day d2 using (location_id, patient_id, visit_date)
	join (select distinct drugID1, drugID2 from regimen) r
	on r.drugID1 = d1.drugID1
	and r.drugID2 = d2.drug_id
	WHERE d2.voided <> 1;

	insert into pepfarTableTemp_day (location_id, patient_id, visit_date, regimen, rx_or_prophy)
	select distinct location_id, patient_id, visit_date, shortname, prefix.rx_or_prophy
	from twoDrugRegimenPrefixTemp_day prefix
	join regimen r
	on prefix.drugID1 = r.drugID1
	and prefix.drugID2 = r.drugID2
	where r.drugID3 = 0;

/*Insertion regimen for three drugs arv*/

	insert into pepfarTableTemp_day (location_id, patient_id, visit_date, regimen, rx_or_prophy)
	select distinct location_id, patient_id, visit_date, shortname,prefix.rx_or_prophy
	from twoDrugRegimenPrefixTemp_day prefix
	join patient_prescription_day using (location_id, patient_id, visit_date)
	join regimen r
	on prefix.drugID1 = r.drugID1
	and prefix.drugID2 = r.drugID2
	and patient_prescription_day.drug_id = r.drugID3
	where r.drugID3 != 0
	AND patient_prescription_day.voided <> 1;

	insert into pepfarTable (location_id, patient_id, visit_date, regimen, rx_or_prophy, last_updated_date)
	select p.location_id, p.patient_id, p.visit_date, p.regimen, p.rx_or_prophy, now() from pepfarTableTemp_day p
	ON DUPLICATE KEY UPDATE
	rx_or_prophy = p.rx_or_prophy,
	last_updated_date = now();

	INSERT INTO openmrs.isanteplus_patient_arv (patient_id, arv_regimen, date_created, date_changed)
	SELECT pft.patient_id, pft.regimen, pft.visit_date, now() FROM pepfarTable pft, openmrs.patient po,
	(SELECT pf.patient_id, max(pf.visit_date) as visit_date_regimen FROM pepfarTable pf GROUP BY 1) B
	WHERE pft.patient_id = po.patient_id
	AND pft.patient_id = B.patient_id
	AND pft.visit_date = B.visit_date_regimen
	ON DUPLICATE KEY UPDATE
	arv_regimen = pft.regimen,
	date_changed = now();


	drop temporary table oneDrugRegimenPrefixTemp_day;
	drop temporary table twoDrugRegimenPrefixTemp_day;
	drop temporary table pepfarTableTemp_day;
			
/*Transfer next_visit_date, date_started_arv, patient_status to 
		openmrs.isanteplus_patient_arv table*/
	INSERT INTO openmrs.isanteplus_patient_arv
	(patient_id, arv_status, date_started_arv, next_visit_date, date_created, date_changed)
	SELECT p.patient_id, asl.name_fr,DATE(p.date_started_arv), 
	DATE(p.next_visit_date), now(), now() FROM isanteplus.patient p INNER JOIN openmrs.patient po
	ON p.patient_id = po.patient_id
	LEFT OUTER JOIN isanteplus.arv_status_loockup asl
	ON p.arv_status = asl.id
	WHERE(
	p.arv_status is not null
	OR p.next_visit_date is not null
	OR p.date_started_arv is not null
	)
	ON DUPLICATE KEY UPDATE 
	arv_status = asl.name_fr,
	date_started_arv = p.date_started_arv,
	next_visit_date = p.next_visit_date,
	date_changed = now();
		
/*delete from obs_by_day where obs_id < (select lo.obs_id from last_obs lo);*/
			
	TRUNCATE TABLE patient_dispensing_day;
	TRUNCATE TABLE patient_prescription_day;		
	TRUNCATE TABLE patient_status_arv_day;	
	TRUNCATE TABLE last_obs;
	TRUNCATE TABLE obs_by_day;

	
	
	
	
	
