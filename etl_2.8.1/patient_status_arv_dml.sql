use isanteplus;


	SET SQL_SAFE_UPDATES = 0;
	
			
/*DELETE all patients whose prescription form are modified, 
because the provider can put a patient on ART by mistake, and correct the error after */
	
	DELETE FROM patient_on_arv WHERE patient_id NOT IN
	(SELECT pdisp.patient_id FROM patient_dispensing pdisp
	WHERE pdisp.arv_drug = 1065 AND (pdisp.rx_or_prophy = 138405 
	OR pdisp.rx_or_prophy is null) AND pdisp.voided <> 1);
	
/*SET FOREIGN_KEY_CHECKS = 0;*/
	
/*Insertion for exposed infants*/
/*Le dernier PCR en date doit être négatif fiche Premiere visite VIH pediatrique et Laboratoire 
condition_exposee = 1
*/
	truncate table exposed_infants;
		
/*	PCR_Concept_id=844,Positif=1301,Negatif=1302,Equivoque=1300,Echantillon de pauvre qualite=1304
Fiche laboratoire, condition_exposee = 1
*/
/* Dernier PCR negatif */

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
	
	INSERT INTO exposed_infants(patient_id,location_id,encounter_id,visit_date,condition_exposee)
	SELECT ppn.patient_id,ppn.location_id,ppn.encounter_id,ppn.encounter_date,1
	FROM patient_pcr_negative ppn
	WHERE (ppn.concept_id = 1030 AND ppn.value_coded = 664)
	OR (ppn.concept_id = 844 AND ppn.value_coded = 1302);
			  
	DROP table IF EXISTS patient_pcr_negative;
	
/*	Condition B - Enfant exposé doit être coché
Fiche Premiere visit VIH pediatrique
condition_exposee = 3
*/
	INSERT INTO exposed_infants(patient_id,location_id,encounter_id,visit_date,condition_exposee)
	select distinct ob.person_id,ob.location_id,ob.encounter_id,
	DATE(enc.encounter_datetime),3
	from openmrs.obs ob, openmrs.encounter enc, 
	openmrs.encounter_type ent
	WHERE ob.encounter_id	=	enc.encounter_id
	AND enc.encounter_type	=	ent.encounter_type_id
	AND ob.concept_id = 1401
	AND ob.value_coded = 1405
	AND enc.voided <> 1
	AND ob.voided <> 1
	AND (ent.uuid =	"349ae0b4-65c1-4122-aa06-480f186c8350"
	OR ent.uuid = "33491314-c352-42d0-bd5d-a9d0bffc9bf1");
	
/* Condition D - Des ARV prescrits en prophylaxie
		patient_prescription.rx_or_prophy=163768
		Fiche Ordonance medicale, condition_exposee = 4
		*/
		
	INSERT INTO exposed_infants(patient_id,location_id,encounter_id,visit_date,condition_exposee)
	select distinct pdisp.patient_id,pdisp.location_id,pdisp.encounter_id,pdisp.visit_date,4
	from patient_dispensing pdisp, (select ppres.patient_id, 
	MAX(ppres.visit_date) as visit_date FROM patient_dispensing ppres 
	WHERE ppres.voided <> 1 GROUP BY 1) B
	WHERE pdisp.patient_id = B.patient_id
	AND pdisp.visit_date = B.visit_date
	AND pdisp.rx_or_prophy = 163768
	AND pdisp.arv_drug = 1065
	AND pdisp.voided <> 1; 
		
/*End insertion for exposed infants*/
/*Delete patients from the exposed_infants whose have a Positive PCR*/
	
/*Patient with PCR positive*/

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
	
	DELETE exposed_infants FROM exposed_infants, patient_pcr_positif 
	WHERE exposed_infants.patient_id = patient_pcr_positif.patient_id;
	
	DROP table IF EXISTS patient_pcr_positif;
	
/*END for Delete patient from the exposed_infants whose have a Positive PCR*/
/*Delete from exposed_infants where patient has a HIV Positive TEST */

	DELETE exposed_infants FROM exposed_infants,
	(SELECT pl.patient_id FROM patient_laboratory pl, patient p 
	WHERE pl.patient_id = p.patient_id AND pl.test_id = 1040 
	AND pl.test_done = 1 AND pl.test_result = 703 AND pl.voided <> 1
	AND (TIMESTAMPDIFF(MONTH, p.birthdate,DATE(now())) >= 18)) C
	WHERE exposed_infants.patient_id = C.patient_id;
	
/*DELETE from exposed_infants where VIH positif - confirmé par test sérologique > 18 mois*/
	DELETE exposed_infants FROM exposed_infants,
	(select distinct ob.person_id from openmrs.obs ob, openmrs.encounter enc, openmrs.encounter_type ent
	WHERE ob.encounter_id	=	enc.encounter_id
	AND enc.encounter_type	=	ent.encounter_type_id
	AND ob.person_id = enc.patient_id
    	AND ob.concept_id = 1401
	AND ob.value_coded = 163717
	AND ob.voided <> 1
	AND (ent.uuid =	"349ae0b4-65c1-4122-aa06-480f186c8350"
	OR ent.uuid = "33491314-c352-42d0-bd5d-a9d0bffc9bf1")) C
	WHERE exposed_infants.patient_id = C.person_id;
						
/*	Condition 5 - Séroréversion doit être coché
		Rapport d'arrêt du programme soins et traitement VIH/SIDA
		condition_exposee = 5
	*/
	INSERT INTO exposed_infants(patient_id,location_id,encounter_id,visit_date,condition_exposee)
	select distinct ob.person_id,ob.location_id,ob.encounter_id,
	DATE(enc.encounter_datetime),5
	from openmrs.obs ob, openmrs.encounter enc, 
	openmrs.encounter_type ent
	WHERE ob.encounter_id	=enc.encounter_id
	AND enc.encounter_type	=ent.encounter_type_id
	AND ob.concept_id = 1667
	AND ob.value_coded = 165439
	AND ob.voided <> 1
	AND ent.uuid =	"9d0113c6-f23a-4461-8428-7e9a7344f2ba";
	
/*TRUNCATE TABLE patient_status_arv;*/
/*Insertion for patient_status Décédés=1,Arrêtés=2,Transférés=3 on ARV
		We use max(start_date) OR max(date_started) because
		we can't find the historic of the patient status
	*/
/*Starting patient_status_arv*/
	
/*DELETE all status for today before executing the patient status queries*/
	DELETE FROM patient_status_arv WHERE DATE(date_started_status) = DATE(now()); 
	
/*====================================================*/
/*Insertion for patient_status Décédés en Pré-ARV=4 */
	INSERT INTO patient_status_arv(patient_id,id_status,start_date,encounter_id,last_updated_date, date_started_status)
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
	AND ispat.voided = 0
	GROUP BY v.patient_id
	on duplicate key update 
	last_updated_date = values(last_updated_date);
	
/*Insertion for patient_status Transférés en Pré-ARV=5*/
	INSERT INTO patient_status_arv(patient_id,id_status,start_date,encounter_id,last_updated_date, date_started_status)
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
	AND ispat.voided = 0
	GROUP BY v.patient_id
	on duplicate key update 
	last_updated_date = values(last_updated_date);
	
/*Insertion for patient_status réguliers=6*/
	INSERT INTO patient_status_arv(patient_id,id_status,start_date,encounter_id,last_updated_date, date_started_status)
	SELECT pdis.patient_id,6 as id_status,MAX(DATE(pdis.visit_date)) as start_date,pdis.encounter_id as encounter_id,
	now(), now()
	FROM isanteplus.patient ipat,isanteplus.patient_dispensing pdis,isanteplus.patient_on_arv p,
	(select pdisp.patient_id, MAX(pdisp.next_dispensation_date) as mnext_disp 
	from isanteplus.patient_dispensing pdisp WHERE pdisp.voided <> 1 AND pdisp.arv_drug = 1065 group by 1) mndisp,
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
	AND enc.patient_id = p.patient_id
	AND pdis.arv_drug = 1065
	AND entype.uuid IN ('10d73929-54b6-4d18-a647-8b7316bc1ae3',
	                        'a9392241-109f-4d67-885b-57cc4b8c638f')
	AND((DATE(now()) <= pdis.next_dispensation_date))
	AND pdis.voided <> 1
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

	INSERT INTO patient_status_arv(patient_id,id_status,start_date, encounter_id,last_updated_date, date_started_status)
	SELECT pdis.patient_id,8 as id_status,MAX(DATE(pdis.visit_date)) as start_date, pdis.encounter_id as encounter_id,
	now(), now()
	FROM isanteplus.patient ipat,isanteplus.patient_dispensing pdis,
	(select pdisp.patient_id, MAX(pdisp.next_dispensation_date) as mnext_disp 
	from isanteplus.patient_dispensing pdisp WHERE pdisp.voided <> 1 AND pdisp.arv_drug = 1065 group by 1) mndisp,
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
                           'a9392241-109f-4d67-885b-57cc4b8c638f') 
	AND (DATEDIFF(DATE(now()),pdis.next_dispensation_date)<=30)
	AND((DATE(now()) > pdis.next_dispensation_date))
	AND pdis.voided <> 1
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
	INSERT INTO patient_status_arv(patient_id,id_status,start_date,encounter_id,last_updated_date, date_started_status)
	SELECT pdis.patient_id,9 as id_status,MAX(DATE(pdis.visit_date)) as start_date, pdis.encounter_id as encounter_id,
	now(), now()
	FROM isanteplus.patient_dispensing pdis,
	(select pdisp.patient_id, MAX(pdisp.next_dispensation_date) as mnext_disp 
	from isanteplus.patient_dispensing pdisp WHERE pdisp.voided <> 1 AND pdisp.arv_drug = 1065 group by 1) mndisp,
	openmrs.encounter enc,openmrs.encounter_type entype
	WHERE pdis.visit_id=enc.visit_id
	AND pdis.patient_id = mndisp.patient_id
	AND pdis.next_dispensation_date = mndisp.mnext_disp
	AND enc.encounter_type=entype.encounter_type_id
	AND enc.patient_id 
	NOT IN(SELECT dreason.patient_id FROM discontinuation_reason dreason
	WHERE dreason.reason IN(159,1667,159492))
	AND enc.patient_id IN (SELECT parv.patient_id 
	FROM isanteplus.patient_on_arv parv)
	AND pdis.arv_drug = 1065
	AND pdis.voided <> 1
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
     
	INSERT INTO patient_status_arv(patient_id,id_status,start_date,encounter_id,last_updated_date,date_started_status)
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
	AND v.voided <> 1
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

	INSERT INTO patient_status_arv(patient_id,id_status,start_date,encounter_id,last_updated_date,date_started_status)
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
	AND v.voided <> 1
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

	INSERT INTO patient_status_arv(patient_id,id_status,start_date,encounter_id,last_updated_date,date_started_status)
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
	AND v.voided <> 1
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
		'f037e97b-471e-4898-a07c-b8e169e0ddc4'
		)
	AND (TIMESTAMPDIFF(MONTH,v.date_started,DATE(now()))<=12)
	GROUP BY v.patient_id
	on duplicate key update 
	last_updated_date = values(last_updated_date);
	
	
/*Décédés=1*/
	INSERT INTO patient_status_arv(patient_id,id_status,start_date,encounter_id,
	last_updated_date, date_started_status)
	SELECT enc.patient_id, 1 as id_status, MAX(DATE(enc.encounter_datetime)) AS start_date,
	enc.encounter_id as encounter_id, now(), now()
	FROM openmrs.encounter enc,openmrs.encounter_type entype,openmrs.obs ob,
	isanteplus.patient_on_arv parv
	WHERE enc.encounter_type = entype.encounter_type_id
	AND enc.patient_id = ob.person_id
	AND enc.encounter_id = ob.encounter_id
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
	
	INSERT INTO patient_status_arv(patient_id,id_status,start_date,encounter_id,
	last_updated_date, date_started_status)
	SELECT enc.patient_id, 2 as id_status, MAX(DATE(enc.encounter_datetime)) AS start_date,
	enc.encounter_id as encounter_id, now(), now()
	FROM openmrs.encounter enc,openmrs.encounter_type entype,openmrs.obs ob,
	isanteplus.patient_on_arv parv
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

	INSERT INTO patient_status_arv(patient_id,id_status,start_date,encounter_id,
	last_updated_date, date_started_status)
	SELECT enc.patient_id,3 as id_status, MAX(DATE(enc.encounter_datetime)) AS start_date, 
	enc.encounter_id as encounter_id, now(), now()
	FROM openmrs.encounter enc,
	openmrs.encounter_type entype,openmrs.obs ob, openmrs.obs ob2,isanteplus.patient_on_arv parv
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
	UPDATE patient_status_arv psarv,discontinuation_reason dreason
	SET psarv.dis_reason = dreason.reason
	WHERE psarv.patient_id = dreason.patient_id
	AND psarv.start_date <= dreason.visit_date;	
	
/*Delete Exposed infants from patient_arv_status*/
/*DELETE FROM patient_status_arv WHERE 
	patient_id IN (SELECT ei.patient_id FROM exposed_infants ei);*/
	DELETE patient_status_arv FROM patient_status_arv,exposed_infants
	WHERE patient_status_arv.patient_id = exposed_infants.patient_id;
	
/* SET arv_status to null */
	UPDATE patient SET arv_status = null;
	
/*Update patient table for having the last patient arv status*/
	update patient p,patient_status_arv psa, 
	(SELECT psarv.patient_id, MAX(psarv.date_started_status) as date_started_status 
	FROM patient_status_arv psarv GROUP BY 1) B
	SET p.arv_status = psa.id_status
	WHERE p.patient_id = psa.patient_id
	AND psa.patient_id = B.patient_id
	AND DATE(psa.date_started_status) = DATE(B.date_started_status);
	
/*End of patient Status*/	
		

	SET SQL_SAFE_UPDATES = 0;
/*SET FOREIGN_KEY_CHECKS = 0;*/
			
			
			
	DELETE pepfarTable FROM pepfarTable, patient_prescription
	WHERE pepfarTable.patient_id = patient_prescription.patient_id
	AND pepfarTable.location_id = patient_prescription.location_id
	AND DATE(pepfarTable.visit_date) = DATE(patient_prescription.visit_date)
	AND patient_prescription.voided = 1;
			
/*Insertion regimen for one drug arv*/
	create temporary table pepfarTableTemp
		(location_id int(11),
		patient_id int(11),
		visit_date datetime,
		regimen varchar(255),
		rx_or_prophy int(11)
	);

	create temporary table oneDrugRegimenPrefixTemp (
		location_id int(11),
		patient_id int(11),
		visit_date datetime,
		drugID1 int(11),
		rx_or_prophy int(11)
	);

	insert into oneDrugRegimenPrefixTemp
	select d1.location_id, d1.patient_id, d1.visit_date, d1.drug_id, d1.rx_or_prophy
	from patient_prescription d1
	join patient p on d1.patient_id = p.patient_id
	join (select distinct drugID1 from regimen) r
	on r.drugID1 = d1.drug_id
	where d1.arv_drug = 1065
	AND d1.voided <> 1;

	insert into pepfarTableTemp (location_id, patient_id, visit_date, regimen, rx_or_prophy)
	select distinct location_id, patient_id, visit_date, shortname, rx_or_prophy
	from oneDrugRegimenPrefixTemp d1
	join regimen r
	on r.drugID1 = d1.drugID1
	where r.drugID2 = 0
	and r.drugID3 = 0;

/*Insertion regimen for two drugs arv*/
	create temporary table twoDrugRegimenPrefixTemp (
		location_id int(11),
		patient_id int(11),
		visit_date datetime,
		drugID1 int(11),
		drugID2 int(11),
		rx_or_prophy int(11)
	);

	insert into twoDrugRegimenPrefixTemp
	select location_id, patient_id, visit_date, d1.drugID1, d2.drug_id, d1.rx_or_prophy
	from oneDrugRegimenPrefixTemp d1
	join patient_prescription d2 using (location_id, patient_id, visit_date)
	join (select distinct drugID1, drugID2 from regimen) r
	on r.drugID1 = d1.drugID1
	and r.drugID2 = d2.drug_id
	WHERE d2.voided <> 1;

	insert into pepfarTableTemp (location_id, patient_id, visit_date, regimen, rx_or_prophy)
	select distinct location_id, patient_id, visit_date, shortname, prefix.rx_or_prophy
	from twoDrugRegimenPrefixTemp prefix
	join regimen r
	on prefix.drugID1 = r.drugID1
	and prefix.drugID2 = r.drugID2
	where r.drugID3 = 0;

/*Insertion regimen for three drugs arv*/

	insert into pepfarTableTemp (location_id, patient_id, visit_date, regimen, rx_or_prophy)
	select distinct location_id, patient_id, visit_date, shortname,prefix.rx_or_prophy
	from twoDrugRegimenPrefixTemp prefix
	join patient_prescription using (location_id, patient_id, visit_date)
	join regimen r
	on prefix.drugID1 = r.drugID1
	and prefix.drugID2 = r.drugID2
	and patient_prescription.drug_id = r.drugID3
	where r.drugID3 != 0
	AND patient_prescription.voided <> 1;

	insert into pepfarTable (location_id, patient_id, visit_date, regimen, rx_or_prophy, last_updated_date)
	select p.location_id, p.patient_id, p.visit_date, p.regimen, p.rx_or_prophy, now() from pepfarTableTemp p
	ON DUPLICATE KEY UPDATE
	rx_or_prophy = p.rx_or_prophy,
	last_updated_date = now();

	INSERT INTO openmrs.isanteplus_patient_arv (patient_id, arv_regimen, date_created, date_changed)
	SELECT pft.patient_id, pft.regimen, pft.visit_date, now() FROM pepfarTable pft, 
	(SELECT pf.patient_id, max(pf.visit_date) as visit_date_regimen FROM pepfarTable pf GROUP BY 1) B
	WHERE pft.patient_id = B.patient_id
	AND pft.visit_date = B.visit_date_regimen
	ON DUPLICATE KEY UPDATE
	arv_regimen = pft.regimen,
	date_changed = now();


	drop temporary table oneDrugRegimenPrefixTemp;
	drop temporary table twoDrugRegimenPrefixTemp;
	drop temporary table pepfarTableTemp;
			
/*Transfer next_visit_date, date_started_arv, petient_status to 
		openmrs.isanteplus_patient_arv table*/
	INSERT INTO openmrs.isanteplus_patient_arv
	(patient_id, arv_status, date_started_arv, next_visit_date, date_created, date_changed)
	SELECT p.patient_id, asl.name_fr,DATE(p.date_started_arv), 
	DATE(p.next_visit_date), now(), now() FROM isanteplus.patient p
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

	
		
/*INSERT FLAGS*/
/*use openmrs;*/
	SET SQL_SAFE_UPDATES = 0;
/*Starting insertion for alert (charge viral)*/
/*Insertion for Nombre de patient sous ARV depuis 6 mois sans un résultat de charge virale*/

	TRUNCATE TABLE alert;
	INSERT INTO alert(patient_id,id_alert,encounter_id,date_alert, last_updated_date)
	SELECT distinct B.patient_id,1,B.encounter_id, B.visit_date, now()
	FROM isanteplus.patient p,
	(select pdis.patient_id, pdis.encounter_id as encounter_id, MIN(DATE(pdis.visit_date)) as visit_date 
	FROM isanteplus.patient_dispensing pdis WHERE pdis.arv_drug = 1065 GROUP BY 1) B
	WHERE p.patient_id = B.patient_id
	AND p.date_started_arv = B.visit_date
	AND (TIMESTAMPDIFF(MONTH,DATE(p.date_started_arv),DATE(now())) >= 6)
	AND p.patient_id NOT IN(SELECT pl.patient_id FROM isanteplus.patient_laboratory pl
			WHERE pl.test_id IN(856, 1305) AND pl.test_done = 1 AND pl.voided <> 1 AND 
			((pl.test_result is not null) OR (pl.test_result <> '')))
	AND p.patient_id NOT IN (select enc.patient_id FROM openmrs.encounter enc, openmrs.encounter_type et 
				where enc.encounter_type = et.encounter_type_id AND et.uuid = '9d0113c6-f23a-4461-8428-7e9a7344f2ba'
				AND enc.patient_id IN (select dr.patient_id FROM isanteplus.discontinuation_reason dr))
	AND p.vih_status = 1;
	
	
/*patients sous ARV depuis 5 mois sans un résultat de charge virale*/

	INSERT INTO alert(patient_id,id_alert,encounter_id,date_alert, last_updated_date)
	SELECT distinct B.patient_id,2,B.encounter_id, B.visit_date, now()
	FROM isanteplus.patient p,
	(select pdis.patient_id, pdis.encounter_id as encounter_id, MIN(DATE(pdis.visit_date)) as visit_date 
	FROM isanteplus.patient_dispensing pdis WHERE pdis.arv_drug = 1065 GROUP BY 1) B
	WHERE p.patient_id = B.patient_id
	AND p.date_started_arv = B.visit_date
	AND (TIMESTAMPDIFF(MONTH,DATE(p.date_started_arv),DATE(now())) = 5)
	AND p.patient_id NOT IN(SELECT pl.patient_id FROM isanteplus.patient_laboratory pl
			WHERE pl.test_id IN(856, 1305) AND pl.test_done=1 AND pl.voided <> 1 AND ((pl.test_result is not null) OR (pl.test_result <> '')))
	AND p.patient_id NOT IN (select enc.patient_id FROM openmrs.encounter enc, openmrs.encounter_type et 
				where enc.encounter_type = et.encounter_type_id AND et.uuid = '9d0113c6-f23a-4461-8428-7e9a7344f2ba')
	AND p.vih_status = 1;
	
	
/*Insertion for Nombre de femmes enceintes, sous ARV depuis 4 mois sans un résultat de charge virale*/	
	
	INSERT INTO alert(patient_id,id_alert,encounter_id,date_alert, last_updated_date)		
	SELECT distinct B.patient_id,3,B.encounter_id, B.visit_date, now()
	FROM isanteplus.patient p,
	(select pdis.patient_id, pdis.encounter_id as encounter_id, MIN(DATE(pdis.visit_date)) as visit_date 
	FROM isanteplus.patient_dispensing pdis WHERE pdis.arv_drug = 1065 GROUP BY 1) B,
	isanteplus.patient_pregnancy pp
	WHERE p.patient_id = B.patient_id
	AND p.date_started_arv = B.visit_date
	AND p.patient_id = pp.patient_id
	AND (TIMESTAMPDIFF(MONTH,DATE(p.date_started_arv),DATE(now())) >= 4)
	AND p.patient_id NOT IN(SELECT pl.patient_id FROM isanteplus.patient_laboratory pl
			WHERE pl.test_id IN(856, 1305) AND pl.test_done=1 AND pl.voided <> 1 AND ((pl.test_result is not null) OR (pl.test_result <> '')))
	AND p.patient_id NOT IN (select enc.patient_id FROM openmrs.encounter enc, openmrs.encounter_type et 
				where enc.encounter_type = et.encounter_type_id AND et.uuid = '9d0113c6-f23a-4461-8428-7e9a7344f2ba'
				AND enc.patient_id IN (select dr.patient_id FROM isanteplus.discontinuation_reason dr))
	AND p.vih_status = 1;
	
	
/*Insertion for Nombre de patients ayant leur dernière charge virale remontant à au moins 12 mois*/
/* Dernière charge virale de ce patient remonte à au moins 12 mois  */
	INSERT INTO alert(patient_id,id_alert,encounter_id,date_alert, last_updated_date)		
	SELECT distinct plab.patient_id,4,plab.encounter_id, ifnull(DATE(plab.date_test_done),DATE(plab.visit_date)), now()
	FROM isanteplus.patient p, isanteplus.patient_laboratory plab,
	(SELECT pl.patient_id, MAX(ifnull(DATE(date_test_done),DATE(pl.visit_date))) as visit_date FROM isanteplus.patient_laboratory pl
			WHERE pl.test_id IN(856, 1305) AND pl.test_result > 0 AND pl.voided <> 1 GROUP BY 1) C,
			isanteplus.patient_on_arv parv
	WHERE p.patient_id = plab.patient_id
	AND plab.patient_id = C.patient_id
	AND ifnull(DATE(plab.date_test_done),DATE(plab.visit_date)) = DATE(C.visit_date)
	AND p.patient_id = parv.patient_id
	AND (TIMESTAMPDIFF(MONTH,DATE(C.visit_date),DATE(now())) >= 12)
	AND ((plab.test_id = 856 AND plab.test_result < 1000) 
	OR (plab.test_id = 1305 AND plab.test_result = 1306))
	AND p.arv_status NOT IN(1,2,3)
	AND p.vih_status = 1;
	
	
/*Insertion for Nombre de patients ayant leur dernière charge virale remontant à au moins 3 mois et dont le résultat était > 1000 copies/ml*/
/*INSERT INTO alert(patient_id,id_alert,encounter_id,date_alert, last_updated_date)		
	SELECT distinct plab.patient_id,5,plab.encounter_id, ifnull(DATE(plab.date_test_done),DATE(plab.visit_date)), now()
	FROM isanteplus.patient p, isanteplus.patient_laboratory plab,
	(SELECT pl.patient_id, MAX(ifnull(DATE(date_test_done),DATE(pl.visit_date))) as visit_date FROM isanteplus.patient_laboratory pl
			WHERE pl.test_id IN(856, 1305) AND pl.test_done=1 AND pl.voided <> 1 
			AND ((pl.test_result is not null) OR (pl.test_result <> '')) GROUP BY 1) C,
			isanteplus.patient_on_arv parv
	WHERE p.patient_id = plab.patient_id
	AND plab.patient_id = C.patient_id
	AND ifnull(DATE(plab.date_test_done),DATE(plab.visit_date)) = C.visit_date
	AND p.patient_id = parv.patient_id
	AND (TIMESTAMPDIFF(MONTH,DATE(C.visit_date),DATE(now())) > 3)
	AND plab.test_result > 1000
	AND p.patient_id NOT IN (select enc.patient_id FROM openmrs.encounter enc, openmrs.encounter_type et 
				where enc.encounter_type = et.encounter_type_id AND et.uuid = '9d0113c6-f23a-4461-8428-7e9a7344f2ba'
				AND enc.patient_id IN (select dr.patient_id FROM isanteplus.discontinuation_reason dr))
	AND p.vih_status = 1;*/
	
/* Dernière charge virale de ce patient remonte à au moins
		3 mois et le résultat était supérieur 1000 copies/ml */
		
	INSERT INTO alert (patient_id,id_alert,encounter_id, date_alert,last_updated_date)
	select distinct ob.person_id, 5, ob.encounter_id, DATE(ob.obs_datetime), now()
	from openmrs.encounter e, openmrs.obs ob, isanteplus.patient p, (select o.person_id, max(DATE(o.obs_datetime)) as obs_date
	FROM openmrs.obs o
	WHERE o.concept_id IN (856,1305) AND o.voided <> 1 group by 1) B
	WHERE e.patient_id = ob.person_id
	AND ob.person_id = p.patient_id
	AND ob.person_id = B.person_id
	AND DATE(ob.obs_datetime) = DATE(B.obs_date)
	AND ((ob.concept_id = 856 AND ob.value_numeric > 1000)
		OR (ob.concept_id = 1305 AND ob.value_coded = 1301))
	AND (TIMESTAMPDIFF(MONTH, DATE(ob.obs_datetime),DATE(now())) >= 3) 
	AND p.arv_status NOT IN(1,2,3)
	AND ob.voided <> 1;
	
	
/*patient avec une dernière charge viral >1000 copies/ml*/
	INSERT INTO alert(patient_id,id_alert,encounter_id,date_alert, last_updated_date)		
	SELECT distinct plab.patient_id,6,plab.encounter_id, ifnull(DATE(plab.date_test_done),DATE(plab.visit_date)), now()
	FROM isanteplus.patient p, isanteplus.patient_laboratory plab,
	(SELECT pl.patient_id, MAX(ifnull(DATE(date_test_done),DATE(pl.visit_date))) as visit_date FROM isanteplus.patient_laboratory pl
			WHERE pl.test_id = 856 AND pl.test_done=1 AND pl.voided <> 1 
			AND ((pl.test_result is not null) OR (pl.test_result <> '')) GROUP BY 1) C,
			isanteplus.patient_on_arv parv
	WHERE p.patient_id = plab.patient_id
	AND plab.patient_id = C.patient_id
	AND ifnull(DATE(plab.date_test_done),DATE(plab.visit_date)) = C.visit_date
	AND p.patient_id = parv.patient_id
	AND plab.test_id = 856
	AND plab.test_result > 1000
	AND p.patient_id NOT IN (select enc.patient_id FROM openmrs.encounter enc, openmrs.encounter_type et 
				where enc.encounter_type = et.encounter_type_id AND et.uuid = '9d0113c6-f23a-4461-8428-7e9a7344f2ba'
				AND enc.patient_id IN (select dr.patient_id FROM isanteplus.discontinuation_reason dr))
	AND p.vih_status = 1;
	
	
/*Tout patient dont la prochaine date de dispensation (next_disp) arrive dans les 30 
	prochains jours par rapport à la date de consultation actuelle*/
/* Le patient doit venir renflouer ses ARV dans les 30 prochains jours */

	INSERT INTO alert(patient_id,id_alert,encounter_id,date_alert, last_updated_date)
	SELECT distinct pdisp.patient_id,7,pdisp.encounter_id, DATE(pdisp.visit_date), now()
	FROM isanteplus.patient p, isanteplus.patient_dispensing pdisp,
	(SELECT pd.patient_id, MAX(pd.next_dispensation_date) as next_dispensation_date 
	FROM isanteplus.patient_dispensing pd WHERE pd.arv_drug = 1065 AND 
	(pd.rx_or_prophy <> 163768 OR pd.rx_or_prophy is null) AND pd.voided <> 1 GROUP BY 1) B
	WHERE p.patient_id = pdisp.patient_id
	AND pdisp.patient_id = B.patient_id
	AND pdisp.next_dispensation_date = B.next_dispensation_date
	AND DATEDIFF(pdisp.next_dispensation_date,now()) between 0 and 30
/*AND p.patient_id NOT IN (select enc.patient_id FROM openmrs.encounter enc, openmrs.encounter_type et 
				where enc.encounter_type = et.encounter_type_id AND et.uuid = '9d0113c6-f23a-4461-8428-7e9a7344f2ba'
				AND enc.patient_id IN (select dr.patient_id FROM isanteplus.discontinuation_reason dr))*/
	AND p.arv_status NOT IN(1,2,3);
	
	
/*Tout patient dont la prochaine date de dispensation (next_disp) se situe 
	dans le passe par rapport à la date de consultation actuelle*/
/* Le patient n'a plus de médicaments disponibles */

	INSERT INTO alert(patient_id,id_alert,encounter_id,date_alert,last_updated_date)
	SELECT distinct pdisp.patient_id,8,pdisp.encounter_id, DATE(pdisp.visit_date), now()
	FROM isanteplus.patient p, isanteplus.patient_dispensing pdisp,
	(SELECT pd.patient_id, MAX(pd.next_dispensation_date) as next_dispensation_date 
	FROM isanteplus.patient_dispensing pd WHERE pd.arv_drug = 1065 AND 
	(pd.rx_or_prophy <> 163768 OR pd.rx_or_prophy is null) AND pd.voided <> 1 GROUP BY 1) B
	WHERE p.patient_id = pdisp.patient_id
	AND pdisp.patient_id = B.patient_id
	AND pdisp.next_dispensation_date = B.next_dispensation_date
	AND DATEDIFF(B.next_dispensation_date,now()) < 0
/*AND p.patient_id NOT IN (select enc.patient_id FROM openmrs.encounter enc, openmrs.encounter_type et 
				where enc.encounter_type = et.encounter_type_id AND et.uuid = '9d0113c6-f23a-4461-8428-7e9a7344f2ba')*/
	AND p.arv_status NOT IN(1,2,3);
	
	
	
/* Patient sous ARV et traitement anti tuberculeux Message: coïnfection TB/VIH*/
/* Patient sous ARV et traitement anti tuberculeux Message: coïnfection TB/VIH*/
/* Patient recevant rifampicine et isoniazide en Traitement dans une fiche d'ordonance*/
/* ISONIAZID */


	CREATE TABLE IF NOT EXISTS traitement_tuberculeux
	select distinct p.patient_id, 9 as id_alert, p.encounter_id, p.drug_id, 
	DATE(p.visit_date) as visit_date, now() as last_updated_date
	from isanteplus.patient_dispensing p, isanteplus.patient_on_arv poa,
	(SELECT pdi.patient_id, MAX(DATE(pdi.visit_date)) as visit_date
	FROM isanteplus.patient_dispensing pdi GROUP BY 1) B
	WHERE p.patient_id = poa.patient_id
	AND p.patient_id = B.patient_id
	AND DATE(p.visit_date) = DATE(B.visit_date)
	AND p.rx_or_prophy = 138405
	AND p.drug_id = 78280;
	
			
/* 	Rifampicine */		

	INSERT INTO traitement_tuberculeux(patient_id,id_alert,encounter_id,
	drug_id,visit_date,last_updated_date)
	select distinct p.patient_id, 9 as id_alert, p.encounter_id, p.drug_id, 
	DATE(p.visit_date) as visit_date, now() as last_updated_date
	from isanteplus.patient_dispensing p, isanteplus.patient_on_arv poa,
	(SELECT pdi.patient_id, MAX(DATE(pdi.visit_date)) as visit_date
	FROM isanteplus.patient_dispensing pdi GROUP BY 1) B
	WHERE p.patient_id = poa.patient_id
	AND p.patient_id = B.patient_id
	AND DATE(p.visit_date) = DATE(B.visit_date)
	AND p.drug_id = 767;
	
			
/*Mettre les requetes dans la table alert*/

	INSERT INTO alert(patient_id,id_alert,encounter_id,date_alert,last_updated_date)
	select distinct tb.patient_id, tb.id_alert, tb.encounter_id, tb.visit_date, tb.last_updated_date
	FROM traitement_tuberculeux tb, traitement_tuberculeux tb1, isanteplus.patient p
	WHERE tb.patient_id = tb1.patient_id
	AND tb.visit_date = tb1.visit_date
	AND tb.encounter_id = tb1.encounter_id
	AND tb.drug_id = 78280
	AND tb1.drug_id = 767
	AND tb.patient_id = p.patient_id
	AND p.arv_status NOT IN (1,2,3);
	
			
	DROP table IF EXISTS traitement_tuberculeux;
	
	
/* Fiche Premiere Visit VIH et Suivi */
	
/*ISONIAZID*/
	CREATE TABLE IF NOT EXISTS traitement_tuberculeux
	select distinct o.person_id as patient_id, 9 as id_alert, o.encounter_id, o.value_coded as drug_id, 
	DATE(e.encounter_datetime) as visit_date, now() as last_updated_date
	from openmrs.obs o1, openmrs.obs o2, openmrs.obs o, openmrs.encounter e, openmrs.concept c,
	(SELECT en.patient_id, MAX(en.encounter_datetime) as visit_date FROM 
	openmrs.encounter en, openmrs.encounter_type ety WHERE
	en.encounter_type = ety.encounter_type_id
	AND ety.uuid IN ('17536ba6-dd7c-4f58-8014-08c7cb798ac7',
	'204ad066-c5c2-4229-9a62-644bc5617ca2',
	'349ae0b4-65c1-4122-aa06-480f186c8350','33491314-c352-42d0-bd5d-a9d0bffc9bf1') GROUP BY 1) B
	WHERE o.person_id = e.patient_id
	AND o.encounter_id = e.encounter_id
	AND e.patient_id = B.patient_id
	AND DATE(e.encounter_datetime) = DATE(B.visit_date)
	AND o1.obs_id = o2.obs_group_id
	AND o2.obs_group_id = o.obs_group_id
	AND o1.concept_id = c.concept_id
	AND c.uuid = 'fee8bd39-2a95-47f9-b1f5-3f9e9b3ee959'
	AND o.concept_id = 1282
	AND o.value_coded = 78280
	AND o2.concept_id = 159367
	AND o2.value_coded = 1065
	AND o2.voided = 0;
	
	
/*Rifampicine*/	

	INSERT INTO traitement_tuberculeux (patient_id,id_alert,encounter_id,drug_id, visit_date,last_updated_date)
	select distinct o.person_id as patient_id, 9 as id_alert, o.encounter_id, o.value_coded as drug_id, 
	DATE(e.encounter_datetime) as visit_date, now() as last_updated_date
	from openmrs.obs o1, openmrs.obs o2, openmrs.obs o, openmrs.encounter e, openmrs.concept c,
	(SELECT en.patient_id, MAX(en.encounter_datetime) as visit_date FROM 
	openmrs.encounter en, openmrs.encounter_type ety WHERE
	en.encounter_type = ety.encounter_type_id
	AND ety.uuid IN ('17536ba6-dd7c-4f58-8014-08c7cb798ac7',
	'204ad066-c5c2-4229-9a62-644bc5617ca2',
	'349ae0b4-65c1-4122-aa06-480f186c8350','33491314-c352-42d0-bd5d-a9d0bffc9bf1') GROUP BY 1) B
	WHERE o.person_id = e.patient_id
	AND o.encounter_id = e.encounter_id
	AND e.patient_id = B.patient_id
	AND DATE(e.encounter_datetime) = DATE(B.visit_date)
	AND o1.obs_id = o2.obs_group_id
	AND o2.obs_group_id = o.obs_group_id
	AND o1.concept_id = c.concept_id
	AND c.uuid = '2b2053bd-37f3-429d-be0b-f1f8952fe55e'
	AND o.concept_id = 1282
	AND o.value_coded = 767
	AND o2.concept_id = 159367
	AND o2.value_coded = 1065
	AND o2.voided = 0;
	
	
			
/*Mettre les requetes dans la table alert*/

	INSERT INTO alert(patient_id,id_alert,encounter_id,date_alert,last_updated_date)
	select distinct tb.patient_id, tb.id_alert, tb.encounter_id, tb.visit_date, tb.last_updated_date
	FROM traitement_tuberculeux tb, traitement_tuberculeux tb1, isanteplus.patient p
	WHERE tb.patient_id = tb1.patient_id
	AND tb.visit_date = tb1.visit_date
	AND tb.encounter_id = tb1.encounter_id
	AND tb.drug_id = 78280
	AND tb1.drug_id = 767
	AND tb.patient_id = p.patient_id
	AND p.arv_status NOT IN (1,2,3);
			
	DROP table IF EXISTS traitement_tuberculeux;
	
		
/* FIN Patient sous ARV et traitement anti tuberculeux Message: coïnfection TB/VIH*/
			
/*Patient sous ARV depuis au moins 3 mois sans un résultat de charge virale*/
/*Create a temporary table to put all the viral load in*/
	

	CREATE TEMPORARY TABLE IF NOT EXISTS patient_viral_load
	SELECT pl.patient_id FROM isanteplus.patient_laboratory pl
	WHERE pl.test_id = 856 
	AND (pl.test_result is not null AND pl.test_result <> '')
	AND pl.voided <> 1;
			
	INSERT INTO patient_viral_load (patient_id)
	SELECT pl1.patient_id FROM isanteplus.patient_laboratory pl1
	WHERE pl1.test_id = 1305 
	AND pl1.test_result IN (1301,1306)
	AND pl1.voided <> 1;
	
	
	INSERT INTO alert(patient_id,id_alert,encounter_id,date_alert, last_updated_date)
	SELECT distinct B.patient_id,10,B.encounter_id, B.visit_date, now()
	FROM isanteplus.patient p, isanteplus.patient_dispensing padis, (select pdis.patient_id, pdis.encounter_id as encounter_id,
	MIN(DATE(pdis.visit_date)) as visit_date 
	FROM isanteplus.patient_dispensing pdis WHERE pdis.arv_drug = 1065 AND pdis.voided <> 1 GROUP BY 1) B
	WHERE p.patient_id = padis.patient_id
	AND padis.patient_id = B.patient_id
	AND DATE(padis.visit_date) = DATE(B.visit_date)
	AND (TIMESTAMPDIFF(MONTH,DATE(B.visit_date),DATE(now())) >= 3)
	AND p.patient_id NOT IN(SELECT DISTINCT pvl.patient_id FROM patient_viral_load pvl)
	AND p.arv_status NOT IN(1,2,3,4)
	AND p.vih_status = 1
	AND padis.voided <> 1;
	
	DROP TABLE IF EXISTS patient_viral_load;
	
	
/* Patients  enrôlés aux ARV sans prophylaxie INH */

	INSERT INTO alert(patient_id,id_alert,encounter_id,date_alert, last_updated_date)
	SELECT distinct pdisp.patient_id,11,pdisp.encounter_id,DATE(pdisp.visit_date), now()
	FROM isanteplus.patient p, isanteplus.patient_dispensing pdisp
	WHERE p.patient_id = pdisp.patient_id
	AND pdisp.arv_drug = 1065
	AND pdisp.rx_or_prophy <> 163768
	AND p.arv_status NOT IN(1,2,3)
	AND p.vih_status = 1
	AND p.patient_id NOT IN(SELECT DISTINCT o.person_id 
	FROM openmrs.obs o, openmrs.encounter e, openmrs.encounter_type et
	WHERE o.person_id = e.patient_id AND o.encounter_id = e.encounter_id
	AND e.encounter_type = et.encounter_type_id
	AND o.concept_id = 1282
	AND value_coded = 78280
	AND et.uuid IN('10d73929-54b6-4d18-a647-8b7316bc1ae3', 'a9392241-109f-4d67-885b-57cc4b8c638f'));
				
				
/*Alert DDP*/

	INSERT INTO alert(patient_id,id_alert,encounter_id,date_alert, last_updated_date)
	SELECT distinct o.person_id,12,o.encounter_id,DATE(o.obs_datetime), now()
	FROM openmrs.obs o, openmrs.concept c
	WHERE o.concept_id = c.concept_id 
	AND o.value_coded = 1065
	AND c.uuid = 'c2aacdc8-156e-4527-8934-a8fb94162419';
	
			
	INSERT INTO isanteplus.patient_immunization(patient_id,location_id,encounter_id,vaccine_obs_group_id,
	vaccine_concept_id,encounter_date,vaccine_uuid,voided)
	select o.person_id, o.location_id,o.encounter_id,o.obs_group_id,o.value_coded,
	o.obs_datetime,c.uuid,o.voided
	from openmrs.obs ob, openmrs.obs o, openmrs.concept c
	WHERE ob.obs_id = o.obs_group_id
	AND o.value_coded = c.concept_id
	AND o.concept_id = 984
	AND ob.concept_id = 1421
	ON DUPLICATE KEY UPDATE
	voided = o.voided;
	
	SET SQL_SAFE_UPDATES = 0;
	
	UPDATE isanteplus.patient_immunization pim, openmrs.obs o 
	SET pim.dose = o.value_numeric
	WHERE pim.vaccine_obs_group_id = o.obs_group_id
	AND o.concept_id = 1418;
	
	UPDATE isanteplus.patient_immunization pim, openmrs.obs o 
	SET pim.vaccine_date = o.value_datetime
	WHERE pim.vaccine_obs_group_id = o.obs_group_id
	AND o.concept_id = 1410;
	
		
/*Vaccine Dose*/
	TRUNCATE TABLE immunization_dose;
	INSERT INTO immunization_dose (patient_id,vaccine_concept_id)
	SELECT DISTINCT pati.patient_id,pati.vaccine_concept_id
	FROM patient_immunization pati WHERE pati.voided <> 1
	ON DUPLICATE KEY UPDATE
	vaccine_concept_id = pati.vaccine_concept_id;
	
/*dose0*/
	UPDATE immunization_dose idose,patient_immunization pati
	SET idose.dose0 = pati.vaccine_date
	WHERE idose.patient_id = pati.patient_id
	AND idose.vaccine_concept_id = pati.vaccine_concept_id
	AND CONVERT(pati.dose, SIGNED INTEGER) = 0 AND voided <> 1;
	
/*dose1*/
	UPDATE immunization_dose idose,patient_immunization pati
	SET idose.dose1 = pati.vaccine_date
	WHERE idose.patient_id = pati.patient_id
	AND idose.vaccine_concept_id = pati.vaccine_concept_id
	AND CONVERT(pati.dose, SIGNED INTEGER) = 1 AND voided <> 1;
	
/*dose2*/
	UPDATE immunization_dose idose,patient_immunization pati
	SET idose.dose2 = pati.vaccine_date
	WHERE idose.patient_id = pati.patient_id
	AND idose.vaccine_concept_id = pati.vaccine_concept_id
	AND CONVERT(pati.dose, SIGNED INTEGER) = 2 AND voided <> 1;
	
/*dose3*/
	UPDATE immunization_dose idose,patient_immunization pati
	SET idose.dose3 = pati.vaccine_date
	WHERE idose.patient_id = pati.patient_id
	AND idose.vaccine_concept_id = pati.vaccine_concept_id
	AND CONVERT(pati.dose, SIGNED INTEGER) = 3 AND voided <> 1;
	
/*dose4*/
	UPDATE immunization_dose idose,patient_immunization pati
	SET idose.dose4 = pati.vaccine_date
	WHERE idose.patient_id = pati.patient_id
	AND idose.vaccine_concept_id = pati.vaccine_concept_id
	AND CONVERT(pati.dose, SIGNED INTEGER) = 4 AND voided <> 1;
	
/*dose5*/
	UPDATE immunization_dose idose,patient_immunization pati
	SET idose.dose5 = pati.vaccine_date
	WHERE idose.patient_id = pati.patient_id
	AND idose.vaccine_concept_id = pati.vaccine_concept_id
	AND CONVERT(pati.dose, SIGNED INTEGER) = 5 AND voided <> 1;
	
/*dose6*/
	UPDATE immunization_dose idose,patient_immunization pati
	SET idose.dose6 = pati.vaccine_date
	WHERE idose.patient_id = pati.patient_id
	AND idose.vaccine_concept_id = pati.vaccine_concept_id
	AND CONVERT(pati.dose, SIGNED INTEGER) = 6 AND voided <> 1;
	
/*dose7*/
	UPDATE immunization_dose idose,patient_immunization pati
	SET idose.dose7 = pati.vaccine_date
	WHERE idose.patient_id = pati.patient_id
	AND idose.vaccine_concept_id = pati.vaccine_concept_id
	AND CONVERT(pati.dose, SIGNED INTEGER) = 7 AND voided <> 1;
	
/*dose8*/
	UPDATE immunization_dose idose,patient_immunization pati
	SET idose.dose8 = pati.vaccine_date
	WHERE idose.patient_id = pati.patient_id
	AND idose.vaccine_concept_id = pati.vaccine_concept_id
	AND CONVERT(pati.dose, SIGNED INTEGER) = 8 AND voided <> 1;
		
		
	SET SQL_SAFE_UPDATES = 1;
			
	

		
