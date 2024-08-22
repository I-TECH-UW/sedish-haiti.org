USE isanteplus;



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
		on duplicate key update 
			given_name=pn.given_name,
			family_name=pn.family_name,
			gender=pe.gender,
			birthdate=pe.birthdate,
			creator=pn.creator,
			date_created=pn.date_created,
			last_updated_date = now(),
			voided = pn.voided;

/* update patient with identifier */

/*ST CODE*/
	update patient p,openmrs.patient_identifier pi, 
	openmrs.patient_identifier_type pit set p.st_id=pi.identifier 
	where p.patient_id=pi.patient_id 
	AND pi.identifier_type=pit.patient_identifier_type_id
	and pit.uuid="d059f6d0-9e42-4760-8de1-8316b48bc5f1"
	and pi.voided=0;
	
/*National ID*/
	update patient p,openmrs.patient_identifier pi, 
	openmrs.patient_identifier_type pit set p.national_id=pi.identifier 
	where p.patient_id=pi.patient_id 
	AND pi.identifier_type=pit.patient_identifier_type_id
	and pit.uuid="9fb4533d-4fd5-4276-875b-2ab41597f5dd";
	
/*iSantePlus_ID*/
	update patient p,openmrs.patient_identifier pi, 
	openmrs.patient_identifier_type pit set p.identifier=pi.identifier 
	where p.patient_id=pi.patient_id 
	AND pi.identifier_type=pit.patient_identifier_type_id
	and pit.uuid="05a29f94-c0ed-11e2-94be-8c13b969e334";
	
/*isante_id*/
	update patient p,openmrs.patient_identifier pi, 
	openmrs.patient_identifier_type pit set p.isante_id = pi.identifier 
	where p.patient_id=pi.patient_id 
	AND pi.identifier_type=pit.patient_identifier_type_id
	and pit.uuid="0e0c7cc2-3491-4675-b705-746e372ff346";

/* update location_id for patients*/
	update patient p,
	(select distinct pid.patient_id,pid.location_id 
	from openmrs.patient_identifier pid, openmrs.patient_identifier_type pidt 
	WHERE pid.identifier_type=pidt.patient_identifier_type_id 
	AND pidt.uuid="05a29f94-c0ed-11e2-94be-8c13b969e334") pi 
	set p.location_id=pi.location_id 
	where p.patient_id=pi.patient_id
        AND pi.location_id is not null;
        
/*Adding iSante Site_code to the patient table*/
					
	CREATE TABLE IF NOT EXISTS location(
		name text,
		location_id INT(11),
		isante_location_id text,
		CONSTRAINT pk_reports_location PRIMARY KEY(location_id)
	)ENGINE=InnoDB DEFAULT CHARSET=utf8;

	INSERT INTO location (name, location_id,isante_location_id)
	SELECT distinct l.name, l.location_id,la.value_reference
	FROM openmrs.location l, openmrs.location_attribute la, openmrs.location_attribute_type lat
	WHERE l.location_id = la.location_id
	AND la.attribute_type_id = lat.location_attribute_type_id
	AND lat.uuid = "0e52924e-4ebb-40ba-9b83-b198b532653b"
	ON duplicate key update
	name = l.name,
	isante_location_id = la.value_reference;

	update isanteplus.patient p, isanteplus.location l SET site_code = l.isante_location_id
	WHERE p.location_id = l.location_id;
			
/*update patient with address*/	
	update patient p, openmrs.person_address padd 
	SET p.last_address=
	    CASE WHEN ((padd.address1 <> '' AND padd.address1 is not null) 
	          AND (padd.address2 <> '' AND padd.address2 is not null))
                 THEN CONCAT(padd.address1,' ',padd.address2) 
                 WHEN ((padd.address1 <> '' AND padd.address1 is not null) 
                  AND (padd.address2 = '' OR padd.address2 is null))
               THEN padd.address1 ELSE padd.address2
            END
	  WHERE p.patient_id = padd.person_id;
			
/* update patient with person attribute */
/*Update for birthPlace*/
	update patient p, openmrs.person_attribute pa,openmrs.person_attribute_type pat
	SET p.place_of_birth = pa.value
	WHERE p.patient_id = pa.person_id
	AND pa.person_attribute_type_id = pat.person_attribute_type_id
	AND pat.uuid='8d8718c2-c2cc-11de-8d13-0010c6dffd0f';
			
/*Update for telephone*/
	update patient p, openmrs.person_attribute pa,openmrs.person_attribute_type pat
	SET p.telephone = pa.value
	WHERE p.patient_id = pa.person_id
	AND pa.person_attribute_type_id = pat.person_attribute_type_id
	AND pat.uuid='14d4f066-15f5-102d-96e4-000c29c2a5d7';
			
/*Update for mother''s Name*/
	update patient p, openmrs.person_attribute pa,openmrs.person_attribute_type pat
	SET p.mother_name = pa.value
	WHERE p.patient_id = pa.person_id
	AND pa.person_attribute_type_id = pat.person_attribute_type_id
	AND pat.uuid='8d871d18-c2cc-11de-8d13-0010c6dffd0f';
			
/*Update for Civil Status  */
	drop table if exists patient_obs_temp;
	CREATE TEMPORARY TABLE patient_obs_temp
	select person_id, MAX(obs_datetime) as obsDt, value_coded 
	FROM openmrs.obs WHERE concept_id = 1054
	GROUP BY person_id;
	
	update patient p, patient_obs_temp po
	SET p.maritalStatus = po.value_coded
	WHERE p.patient_id = po.person_id;
			
/*Update for Occupation */
	drop table if exists patient_obs_temp;
	CREATE TEMPORARY TABLE patient_obs_temp
	select person_id, MAX(obs_datetime) as obsDt, value_coded 
	FROM openmrs.obs WHERE concept_id = 1542
	GROUP BY person_id;
	
	update patient p, patient_obs_temp po
	SET p.occupation = po.value_coded
	WHERE p.patient_id = po.person_id;
			
/*Update for Contact Name*/
			
	update patient p, openmrs.obs o, openmrs.obs ob
	SET p.contact_name = o.value_text
	WHERE p.patient_id = o.person_id
        AND o.person_id = ob.person_id
        AND o.obs_group_id = ob.obs_id
        AND o.concept_id = 163258
        AND ob.concept_id = 165210
        AND (o.value_text is not null AND o.value_text <> '');
			
/* update patient with vih_status when patient has a HIV form*/
			
	UPDATE patient p, openmrs.encounter en, openmrs.encounter_type ent
	SET p.vih_status=1
	WHERE p.patient_id=en.patient_id AND en.encounter_type=ent.encounter_type_id
	AND (ent.uuid='17536ba6-dd7c-4f58-8014-08c7cb798ac7'
	 OR ent.uuid='204ad066-c5c2-4229-9a62-644bc5617ca2'
	 OR ent.uuid='349ae0b4-65c1-4122-aa06-480f186c8350'
	 OR ent.uuid='33491314-c352-42d0-bd5d-a9d0bffc9bf1')
	AND en.voided = 0;
	
/*Update vih_status WHEN patient has a laboratory form WITH
HIV test positive*/
	UPDATE patient p, openmrs.encounter en, openmrs.encounter_type ent, openmrs.obs o
	SET p.vih_status=1
	WHERE p.patient_id = en.patient_id AND en.encounter_type = ent.encounter_type_id
        AND en.encounter_id = o.encounter_id
        AND en.patient_id = o.person_id
	AND ent.uuid = 'f037e97b-471e-4898-a07c-b8e169e0ddc4'
        AND o.concept_id IN (1040,1042)
        AND o.value_coded = 703
	AND en.voided <> 1
        ANd o.voided <> 1;
        
/*Update for vih_status = 1 where the patient has a labs test hiv positive*/
/*UPDATE patient p, openmrs.encounter en, openmrs.obs ob
SET p.vih_status=1
WHERE p.patient_id=en.patient_id AND en.patient_id = ob.person_id
AND (
(ob.concept_id = 1042 AND ob.value_coded = 703)
OR
(ob.concept_id = 1040 AND ob.value_coded = 703)
)
AND en.voided = 0
AND ob.voided = 0;*/

/* update patient with death information */
				
				
/*Update patient table for having first visit date */
   	update patient p, openmrs.visit vi, (select v.patient_id, MIN(v.date_started) as date_started 
	FROM openmrs.visit v GROUP BY v.patient_id) B
	SET p.first_visit_date = vi.date_started
	WHERE p.patient_id=vi.patient_id
	AND vi.patient_id = B.patient_id
	AND vi.date_started = B.date_started
	AND vi.voided = 0;
			
/*Update patient table for having last visit date */
   	update patient p, openmrs.visit vi, (select v.patient_id, MAX(v.date_started) as date_started 
	FROM openmrs.visit v GROUP BY v.patient_id) B
	SET p.last_visit_date = vi.date_started
	WHERE p.patient_id = vi.patient_id
	AND vi.patient_id = B.patient_id
	AND vi.date_started = B.date_started
	AND vi.voided = 0;
			   
/*Update next_visit_date on table patient, find the last next_visit_date for all patients*/
			
	drop table if exists patient_obs_temp;
	CREATE TEMPORARY TABLE patient_obs_temp
	select person_id, MAX(value_datetime) as obsDt, value_coded 
	FROM openmrs.obs WHERE concept_id IN(5096,162549) AND voided = 0 
	AND value_datetime is not null
	GROUP BY person_id;
	
	update patient p, patient_obs_temp po
	SET p.next_visit_date = DATE(po.obsDt)
	WHERE p.patient_id = po.person_id;
			
/*Update for date_started_arv area in patient table */
	drop table if exists patient_obs_temp;
	CREATE TEMPORARY TABLE patient_obs_temp
	SELECT o.person_id, MIN(o.obs_datetime) AS obsDt, o.value_coded 
	FROM openmrs.obs ob
	JOIN openmrs.obs o ON ob.obs_id = o.obs_group_id
	JOIN openmrs.obs ob2 ON o.obs_group_id = ob2.obs_group_id
	JOIN isanteplus.arv_drugs darv ON o.value_coded = darv.drug_id
	WHERE 
	ob.concept_id = 163711
	AND o.concept_id = 1282
	AND ob2.concept_id IN (1276, 1444, 159368, 1443)
	AND o.voided = 0
	GROUP BY 
	o.person_id;
	
	update patient p, patient_obs_temp po
	SET p.date_started_arv = po.obsDt
	WHERE p.patient_id = po.person_id;
	
	drop table patient_obs_temp;
	
	update patient p, openmrs.obs o
	SET p.transferred_in = 1
	WHERE p.patient_id = o.person_id
	AND o.concept_id  = 159936
	AND o.value_coded = 5622;

/*Date des premiers soins dans cet établissement*/
	update patient p, openmrs.obs o, openmrs.concept c
	SET p.date_transferred_in = o.value_datetime
	WHERE p.patient_id = o.person_id
	AND o.concept_id = c.concept_id
	AND c.uuid = 'd9885523-a923-474b-88df-f3294d422c3c'
	AND o.value_datetime IS NOT NULL;
			
/*Date début des ARV dans l’établissement de référence*/
	update patient p, openmrs.obs o
	SET p.date_started_arv_other_site = o.value_datetime
	WHERE p.patient_id = o.person_id
	AND o.concept_id  = 159599
	AND o.value_datetime IS NOT NULL;
			


/*Started DML queries*/
/* insert data to patient table */
			SET SQL_SAFE_UPDATES = 0;
/*SET FOREIGN_KEY_CHECKS=0;*/
	INSERT INTO patient_visit
	(visit_date,visit_id,encounter_id,location_id,
	 patient_id,start_date,stop_date,creator,
	 encounter_type,form_id,next_visit_date,
	last_insert_date, last_updated_date, voided)
	SELECT v.date_started AS visit_date,
		   v.visit_id,e.encounter_id,v.location_id,
		   v.patient_id,v.date_started,v.date_stopped,
		   v.creator,e.encounter_type,e.form_id,o.value_datetime,
		   NOW() AS last_inserted_date, NOW() AS last_updated_date, v.voided
	FROM openmrs.visit v,openmrs.encounter e,openmrs.obs o
	WHERE v.visit_id=e.visit_id AND v.patient_id=e.patient_id
		  AND o.person_id=e.patient_id AND o.encounter_id=e.encounter_id
		AND o.concept_id='5096'
		AND o.voided = 0
		ON DUPLICATE KEY UPDATE 
		next_visit_date = o.value_datetime,
		last_updated_date = NOW(),
		voided = v.voided;
/* insert data to patient_visit table */



	SET SQL_SAFE_UPDATES = 0;
/*Insert for patient_id,encounter_id, drug_id areas*/
  
  INSERT INTO patient_dispensing
		(
		 patient_id,
		 encounter_id,
		 location_id,
		 obs_id,
		 obs_group_id,
		 drug_id,
		 dispensation_date,
		 last_updated_date,
		 voided
		)
		select distinct ob.person_id,
		ob.encounter_id,ob.location_id,ob.obs_id, ob.obs_group_id, 
		ob.value_coded,ob2.obs_datetime, now(), ob.voided
		from openmrs.obs ob, openmrs.obs ob1,openmrs.obs ob2
		where ob.person_id=ob1.person_id
		AND ob.encounter_id=ob1.encounter_id
		AND ob.obs_group_id=ob1.obs_id
		AND ob1.obs_id = ob2.obs_group_id
	        AND ob1.concept_id=163711	
		AND ob.concept_id=1282
		AND ob2.concept_id IN(1444,159368,1443,1276)
		ON DUPLICATE KEY UPDATE
		obs_id = ob.obs_id,
		obs_group_id = ob.obs_group_id,
		dispensation_date = ob2.obs_datetime,
		last_updated_date = NOW(),
		voided = ob.voided;
	
/*update dispensation_date for table patient_dispensing */	
	update patient_dispensing patdisp, openmrs.obs ob, openmrs.obs o 
	set patdisp.dispensation_date = DATE(ob.obs_datetime)
	WHERE patdisp.encounter_id = ob.encounter_id
	AND o.concept_id = 1282
	AND ob.concept_id = 1276
	AND ob.obs_group_id = o.obs_group_id
	AND patdisp.drug_id = o.value_coded
	AND ob.voided = 0;
	
/*update next_dispensation_date for table patient_dispensing*/	
	UPDATE patient_dispensing patdisp, openmrs.obs ob 
	SET patdisp.next_dispensation_date = DATE(ob.value_datetime)
	WHERE patdisp.encounter_id=ob.encounter_id
	AND ob.concept_id=162549
	AND ob.voided = 0;

/*update provider for patient_dispensing???*/
	UPDATE patient_dispensing padisp, openmrs.encounter_provider enp
	SET padisp.provider_id=enp.provider_id
	WHERE padisp.encounter_id=enp.encounter_id
	AND enp.voided = 0;
	
/*Update dose_day, pill_amount for patient_dispensing*/
	UPDATE isanteplus.patient_dispensing patdisp, openmrs.obs ob, openmrs.obs ob1
	SET patdisp.dose_day=ob.value_numeric
	WHERE patdisp.encounter_id=ob.encounter_id
	AND ob.encounter_id=ob1.encounter_id
	AND ob.obs_group_id=ob1.obs_id
	AND ob1.concept_id=163711
	AND ob.concept_id=159368
	AND ob.voided = 0;
	
/*Update pill_amount for patient_dispensing*/
	UPDATE isanteplus.patient_dispensing patdisp, openmrs.obs ob, openmrs.obs ob1
	SET patdisp.pills_amount=ob.value_numeric
	WHERE patdisp.encounter_id=ob.encounter_id
	AND ob.encounter_id=ob1.encounter_id
	AND ob.obs_group_id=ob1.obs_id
    	AND ob1.concept_id=163711
	AND ob.concept_id=1443
	AND ob.voided = 0;
	
/*update visit_id, visit_date for table patient_dispensing*/
	UPDATE patient_dispensing patdisp, openmrs.visit vi, openmrs.encounter en
   	SET patdisp.visit_id=vi.visit_id, patdisp.visit_date=vi.date_started
	WHERE patdisp.encounter_id=en.encounter_id
	AND en.visit_id=vi.visit_id;
	
/*update dispensation_location Dispensation communautaire=1755 for table patient_dispensing*/	
	UPDATE patient_dispensing patdisp, openmrs.obs ob 
	SET patdisp.dispensation_location=1755
	WHERE patdisp.encounter_id=ob.encounter_id
	AND ob.concept_id=1755
	AND ob.value_coded=1065
	AND ob.voided = 0;
	
/*UPDATE ddp field for patient on DDP, ddp=1065 for patient on DDP
	 and ddp = 0 for patient not on DDP*/
	UPDATE patient_dispensing patdisp, openmrs.obs ob, openmrs.concept c 
	SET patdisp.ddp = 1065
	WHERE patdisp.encounter_id = ob.encounter_id
	AND ob.concept_id = c.concept_id
	AND c.uuid = 'c2aacdc8-156e-4527-8934-a8fb94162419'
	AND ob.value_coded = 1065
	AND ob.voided = 0; 
	
/* Update on patient_dispensing where the drug is a ARV drug */
	UPDATE patient_dispensing pdis, (SELECT ad.drug_id FROM arv_drugs ad) B
		   SET pdis.arv_drug = 1065
		   WHERE pdis.drug_id = B.drug_id;

/*update rx_or_prophy for table patient_dispensing*/
	update isanteplus.patient_dispensing pdisp, openmrs.obs ob1, openmrs.obs ob2, openmrs.obs ob3
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
           
/*Update voided for drug removing*/
	UPDATE isanteplus.patient_dispensing pp, (select pap.obs_group_id, count(ob.obs_group_id) FROM openmrs.obs ob,
	  isanteplus.patient_prescription pap
	  WHERE pap.encounter_id = ob.encounter_id
	  AND ob.obs_group_id = pap.obs_group_id
	  AND ob.voided = 0
	  GROUP BY 1
	  HAVING count(ob.obs_group_id) <= 1) B
	SET pp.voided = 1
	WHERE pp.obs_group_id = B.obs_group_id
	AND pp.voided <> 1;
		   
/*INSERTION for patient on ARV*/
	INSERT INTO patient_on_arv(patient_id,visit_id,visit_date, last_updated_date)
	SELECT DISTINCT pdisp.patient_id, pdisp.visit_id,MIN(DATE(pdisp.visit_date)),now()
	FROM patient_dispensing pdisp 
	WHERE pdisp.arv_drug = 1065
	AND (pdisp.rx_or_prophy = 138405 OR pdisp.rx_or_prophy is null)
	AND pdisp.voided <> 1
	GROUP BY pdisp.patient_id
	on duplicate key update
	visit_id = visit_id,
	visit_date = visit_date,
	last_updated_date = now();
			
/*DELETE all patients whose prescription form are modified, 
	because the provider can put a patient on ART by mistake, and correct the error after */
	
/*DELETE FROM patient_on_arv WHERE patient_id NOT IN
					(SELECT pdisp.patient_id FROM patient_dispensing pdisp
					WHERE pdisp.arv_drug = 1065 AND (pdisp.rx_or_prophy = 138405 
					OR pdisp.rx_or_prophy is null) AND pdisp.voided <> 1);*/
		   

/*Started DML queries*/
	SET SQL_SAFE_UPDATES = 0;
/*SET FOREIGN_KEY_CHECKS=0;*/
			
/*Starting patient_prescription*/
/*Insert for patient_id,encounter_id, drug_id areas*/
  INSERT into patient_prescription(
		 patient_id,
		 encounter_id,
		 location_id,
		 obs_id,
		 obs_group_id,
		 drug_id,
		 dispense,
		 last_updated_date,
		 voided
		)
		select distinct ob.person_id,
		ob.encounter_id,ob.location_id,ob.obs_id, ob.obs_group_id,ob.value_coded,
		 IF(ob1.concept_id=163711, 1065, 1066), now(), ob.voided
		from openmrs.obs ob, openmrs.obs ob1, openmrs.obs ob2
		where ob.person_id=ob1.person_id
		AND ob.encounter_id=ob1.encounter_id
		AND ob.obs_group_id=ob1.obs_id
		AND ob1.obs_id = ob2.obs_group_id
               AND (ob1.concept_id=1442 OR ob1.concept_id=163711)
		AND ob.concept_id=1282
		AND ob2.concept_id IN(160742,1276,1444,159368,1443)
		on duplicate key update
		encounter_id = ob.encounter_id,
		obs_id = ob.obs_id,
		obs_group_id = ob.obs_group_id,
		last_updated_date = now(),
		voided = ob.voided;
					
/*Insert for dispensing drugs*/
	
	INSERT into patient_prescription(
		 patient_id,
		 encounter_id,
		 location_id,
		 obs_id,
		 obs_group_id,
		 drug_id,
		 dispensation_date,
		 dispense,
		 last_updated_date,
		 voided
		)
		select distinct ob.person_id,
		ob.encounter_id,ob.location_id,ob.obs_id,ob.obs_group_id,
		ob.value_coded,DATE(ob2.obs_datetime), 1065, now(), ob.voided
		from openmrs.obs ob, openmrs.obs ob1,openmrs.obs ob2
		where ob.person_id=ob1.person_id
		AND ob.encounter_id=ob1.encounter_id
		AND ob.obs_group_id=ob1.obs_id
		AND ob1.obs_id = ob2.obs_group_id
               AND ob1.concept_id=163711	
		AND ob.concept_id=1282
		AND ob2.concept_id IN(1276,1444,159368,1443)
		ON DUPLICATE KEY UPDATE
		obs_id = ob.obs_id,
		obs_group_id = ob.obs_group_id,
		dispensation_date = ob2.obs_datetime,
		dispense = 1065,
		last_updated_date = now(),
		voided = ob.voided;
					
/* Update on patient_prescription where the drug is a ARV drug */
	   UPDATE patient_prescription ppres, (SELECT ad.drug_id FROM arv_drugs ad) B
	   SET ppres.arv_drug = 1065
	   WHERE ppres.drug_id = B.drug_id;
	   
/*update provider for patient_prescription*/
	UPDATE patient_prescription pp, openmrs.encounter_provider enp
	SET pp.provider_id=enp.provider_id
	WHERE pp.encounter_id=enp.encounter_id;
	
/*update visit_id, visit_date for table patient_prescription*/
	UPDATE patient_prescription patp, openmrs.visit vi, openmrs.encounter en
        SET patp.visit_id=vi.visit_id, patp.visit_date=vi.date_started
	WHERE patp.encounter_id=en.encounter_id
	AND en.visit_id=vi.visit_id;
	
/*update next_dispensation_date for table patient_prescription*/	
	UPDATE patient_prescription pp, openmrs.obs ob 
	SET pp.next_dispensation_date = DATE(ob.value_datetime)
	WHERE pp.encounter_id=ob.encounter_id
	AND ob.concept_id=162549
	AND ob.voided = 0;
	
/*update dispensation_location Dispensation communautaire=1755 for table patient_prescription*/	
	UPDATE patient_prescription pp, openmrs.obs ob 
	SET pp.dispensation_location = 1755
	WHERE pp.encounter_id = ob.encounter_id
	AND ob.concept_id = 1755
	AND ob.value_coded = 1065
	AND ob.voided = 0;
	
/*update rx_or_prophy for table patient_prescription*/
	UPDATE isanteplus.patient_prescription pp, openmrs.obs ob1, openmrs.obs ob2, openmrs.obs ob3
	   SET pp.rx_or_prophy=ob2.value_coded
	   WHERE pp.encounter_id=ob2.encounter_id
	   AND ob1.obs_id=ob2.obs_group_id
           AND ob1.obs_id=ob3.obs_group_id
	   AND ob1.concept_id=1442
	   AND ob2.concept_id=160742
           AND ob3.concept_id=1282
           AND pp.drug_id=ob3.value_coded
           AND ob2.voided=0;
	
/*update posology_day for table patient_prescription*/
	UPDATE isanteplus.patient_prescription pp, openmrs.obs ob1, openmrs.obs ob2, openmrs.obs ob3
	   SET pp.posology=ob2.value_text
	   WHERE pp.encounter_id=ob2.encounter_id
	   AND ob1.obs_id=ob2.obs_group_id
           AND ob1.obs_id=ob3.obs_group_id
	   AND ob1.concept_id=1442
	   AND ob2.concept_id=1444
           AND ob3.concept_id=1282
           AND pp.drug_id=ob3.value_coded
           AND ob2.voided = 0;
           
             
/*Update for posology_alt */
	UPDATE isanteplus.patient_prescription pp, openmrs.obs ob1, openmrs.obs ob2, openmrs.obs ob3, openmrs.concept c
	   SET pp.posology_alt = ob2.value_text
	   WHERE pp.encounter_id = ob2.encounter_id
	   AND ob1.obs_id = ob2.obs_group_id
           AND ob1.obs_id = ob3.obs_group_id
	   AND ob1.concept_id = 1442
	   AND ob2.concept_id = c.concept_id
           AND ob3.concept_id = 1282
           AND pp.drug_id = ob3.value_coded
           AND ob2.voided = 0
	   AND c.uuid = 'ca8bc9c3-7f97-450a-8f33-e98f776b90e1';
		   
/*update posology_alt_disp for table patient_prescription*/
	UPDATE isanteplus.patient_prescription pp, openmrs.obs ob1, openmrs.obs ob2, openmrs.obs ob3
	   SET pp.posology_alt_disp = ob2.value_text
	   WHERE pp.encounter_id = ob2.encounter_id
	   AND ob1.obs_id = ob2.obs_group_id
           AND ob1.obs_id = ob3.obs_group_id
	   AND ob1.concept_id = 163711
	   AND ob2.concept_id = 1444
           AND ob3.concept_id = 1282
           AND pp.drug_id = ob3.value_coded
           AND ob2.voided = 0;
	
/*update number_day for table patient_prescription*/
	UPDATE isanteplus.patient_prescription pp, openmrs.obs ob1, openmrs.obs ob2, openmrs.obs ob3
	   SET pp.number_day=ob2.value_numeric
	   WHERE pp.encounter_id=ob2.encounter_id
	   AND ob1.obs_id=ob2.obs_group_id
           AND ob1.obs_id=ob3.obs_group_id
	   AND (ob1.concept_id=1442 OR ob1.concept_id=163711)
	   AND ob2.concept_id=159368
           AND ob3.concept_id=1282
           AND pp.drug_id=ob3.value_coded
           AND ob2.voided = 0;
           
/*Update number_day_dispense for patient_prescription*/
	UPDATE isanteplus.patient_prescription patdisp, openmrs.obs ob, openmrs.obs ob1
	SET patdisp.number_day_dispense=ob.value_numeric
	WHERE patdisp.encounter_id=ob.encounter_id
	AND ob.encounter_id=ob1.encounter_id
	AND ob.obs_group_id=ob1.obs_id
   	 AND ob1.concept_id=163711
	AND ob.concept_id=159368
	AND ob.voided = 0;
	
/*Update pills_amount_dispense for patient_prescription*/
	UPDATE isanteplus.patient_prescription patdisp, openmrs.obs ob, openmrs.obs ob1
	SET patdisp.pills_amount_dispense=ob.value_numeric
	WHERE patdisp.encounter_id=ob.encounter_id
	AND ob.encounter_id=ob1.encounter_id
	AND ob.obs_group_id=ob1.obs_id
    	AND ob1.concept_id=163711
	AND ob.concept_id=1443
	AND ob.voided = 0;
	
/*Update for having dispensation_date of the drug*/
	UPDATE isanteplus.patient_prescription pp, openmrs.obs ob1, openmrs.obs ob2, openmrs.obs ob3
	SET pp.dispensation_date = DATE(ob3.obs_datetime)
	WHERE pp.encounter_id = ob3.encounter_id
	AND ob1.obs_id = ob2.obs_group_id
	AND ob1.obs_id = ob3.obs_group_id
	AND ob1.concept_id = 163711
	AND ob2.concept_id = 1282
	AND ob3.concept_id = 1276
	AND pp.drug_id = ob2.value_coded
	AND ob3.voided = 0;
		   
		   
	UPDATE isanteplus.patient_prescription pp, (select pap.obs_group_id, count(ob.obs_group_id) FROM openmrs.obs ob,
	isanteplus.patient_prescription pap
	WHERE pap.encounter_id = ob.encounter_id
	AND ob.obs_group_id = pap.obs_group_id
	AND ob.voided = 0
	GROUP BY 1
	HAVING count(ob.obs_group_id) <= 1) B
	SET pp.voided = 1
	WHERE pp.obs_group_id = B.obs_group_id
	AND pp.voided <> 1;
		   
/*End of patient_prescription*/	


	
/*Started DML queries for isanteplusreports_patient_visit_dml*/
	SET SQL_SAFE_UPDATES = 0;
/*SET FOREIGN_KEY_CHECKS=0;*/
/* Insert data to health_qual_patient_visit table */
	INSERT INTO health_qual_patient_visit (visit_date, visit_id, encounter_id, location_id, patient_id, encounter_type, last_insert_date, last_updated_date, voided)
	SELECT v.date_started AS visit_date, v.visit_id, e.encounter_id,v.location_id, v.patient_id, e.encounter_type, NOW() AS last_insert_date, NOW() AS last_updated_date, 			v.voided
	FROM openmrs.visit v,openmrs.encounter e,openmrs.obs o
	WHERE v.visit_id = e.visit_id
	AND v.patient_id = e.patient_id
	AND o.person_id = e.patient_id
	AND o.encounter_id = e.encounter_id
	AND o.voided = 0
	ON DUPLICATE KEY UPDATE
	encounter_id = e.encounter_id,
	last_updated_date = NOW(),
		voided = v.voided;

/*Update health_qual_patient_visit table for having bmi*/
        UPDATE isanteplus.health_qual_patient_visit pv, (
          SELECT hs.visit_id, ws.weight , hs.height, ( ws.weight / (hs.height*hs.height/10000) ) AS 'patient_bmi'
          FROM (
            SELECT pv.visit_id, o.value_numeric AS 'height'
            FROM isanteplus.health_qual_patient_visit pv, openmrs.obs o, openmrs.encounter e
            WHERE o.person_id = pv.patient_id
              AND pv.visit_id = e.visit_id
              AND e.encounter_id= o.encounter_id
              AND e.encounter_id = pv.encounter_id
              AND o.concept_id = 5090
			  AND o.voided = 0
            ) AS hs
          JOIN (
            SELECT pv.visit_id, o.value_numeric AS 'weight'
            FROM isanteplus.health_qual_patient_visit pv, openmrs.obs o, openmrs.encounter e
            WHERE o.person_id = pv.patient_id
              AND pv.visit_id = e.visit_id
              AND e.encounter_id= o.encounter_id
              AND e.encounter_id = pv.encounter_id
              AND o.concept_id = 5089
			  AND o.voided = 0
            ) AS ws
          ON hs.visit_id = ws.visit_id
          ) AS bmi
          SET pv.patient_bmi = bmi.patient_bmi
          WHERE pv.visit_id = bmi.visit_id;

/*Update patient_visit table for having family method planning indicator.*/
	UPDATE isanteplus.health_qual_patient_visit pv, (
	SELECT pv.visit_id, o.value_coded
	FROM isanteplus.health_qual_patient_visit pv, openmrs.obs o, openmrs.encounter e
	WHERE o.person_id = pv.patient_id
	AND pv.visit_id = e.visit_id
	AND e.encounter_id= o.encounter_id
	AND e.encounter_id = pv.encounter_id
	AND o.concept_id=374
		  AND o.voided = 0) AS family_planning
	SET pv.family_planning_method_used = TRUE
	WHERE family_planning.visit_id = pv.visit_id
	AND value_coded IS NOT NULL;

/*Update health_qual_patient_visit table for adherence evaluation.*/
	UPDATE isanteplus.health_qual_patient_visit pv, (
	SELECT pv.visit_id, o.value_numeric
	FROM isanteplus.health_qual_patient_visit pv, openmrs.obs o, openmrs.encounter e
	WHERE o.person_id = pv.patient_id
	AND pv.visit_id = e.visit_id
	AND e.encounter_id= o.encounter_id
	AND o.concept_id=163710
        AND o.voided = 0) AS adherence
	SET pv.adherence_evaluation = adherence.value_numeric
	WHERE adherence.visit_id = pv.visit_id
	AND value_numeric IS NOT NULL;

/*Update health_qual_patient_visit table for evaluation of TB flag.*/
	UPDATE isanteplus.health_qual_patient_visit pv, (
	SELECT pv.visit_id, o.value_coded
	FROM isanteplus.health_qual_patient_visit pv, openmrs.obs o, openmrs.encounter e
	WHERE o.person_id = pv.patient_id
	AND pv.visit_id = e.visit_id
	AND e.encounter_id= o.encounter_id
	AND e.encounter_id = pv.encounter_id
	AND (o.concept_id IN (160265, 1659, 1110, 163283, 162320, 163284, 1633, 1389, 163951, 159431, 1113, 159798, 159398))
	AND o.voided = 0) AS evaluation_of_tb
	SET pv.evaluated_of_tb = TRUE
	WHERE evaluation_of_tb.visit_id = pv.visit_id
	AND value_coded IS NOT NULL;

/*update for nutritional_assessment_status*/
/* UPDATE isanteplus.health_qual_patient_visit hqpv, (
            SELECT pv.encounter_id, o.concept_id
            FROM isanteplus.health_qual_patient_visit pv, openmrs.obs o, openmrs.encounter e
            WHERE o.person_id = pv.patient_id
              AND pv.visit_id = e.visit_id
              AND e.encounter_id= o.encounter_id
              AND e.encounter_id = pv.encounter_id
            ) AS visits
          SET hqpv.nutritional_assessment_completed = true
          WHERE
            visits.encounter_id = hqpv.encounter_id
            AND (
              (visits.concept_id = 5089 AND 5090)
              OR visits.concept_id = 5314
              OR visits.concept_id = 1343
            );*/
			
	UPDATE isanteplus.health_qual_patient_visit hqpv, (
	SELECT pv.encounter_id, o.concept_id
	FROM isanteplus.health_qual_patient_visit pv, openmrs.obs o, openmrs.encounter e
	WHERE o.person_id = pv.patient_id
	AND pv.visit_id = e.visit_id
	AND e.encounter_id= o.encounter_id
	AND e.encounter_id = pv.encounter_id
	  AND (
	  (o.concept_id = 5089 AND o.concept_id = 5090)
	  OR o.concept_id = 5314
	  OR o.concept_id = 1343
	)
	 AND o.voided = 0
	) AS visits
	SET hqpv.nutritional_assessment_completed = TRUE
	WHERE
	visits.encounter_id = hqpv.encounter_id;

/*update for is_active_tb*/
	UPDATE isanteplus.health_qual_patient_visit hqpv, (
	SELECT pv.encounter_id FROM isanteplus.health_qual_patient_visit pv, 
	openmrs.obs o, openmrs.encounter e 
	WHERE o.person_id = pv.patient_id AND pv.visit_id = e.visit_id 
	AND e.encounter_id= o.encounter_id AND e.encounter_id = pv.encounter_id AND 
	((o.concept_id=160592 AND o.value_coded=113489) OR (o.concept_id=160749 AND o.value_coded=1065))
	AND o.voided = 0) v
	SET hqpv.is_active_tb = TRUE
	WHERE v.encounter_id = hqpv.encounter_id;
		
/*Update health_qual_patient_visit table for age patient at the visit.*/
	UPDATE isanteplus.health_qual_patient_visit pv, openmrs.person pe
	SET pv.age_in_years = TIMESTAMPDIFF(YEAR, pe.birthdate, pv.visit_date)
	WHERE pe.person_id = pv.patient_id;


/*Started DML queries*/
	SET SQL_SAFE_UPDATES = 0;
/*SET FOREIGN_KEY_CHECKS=0;*/
/*Starting patient_laboratory */
/*Insertion for patient_laboratory*/
	INSERT INTO patient_laboratory(
		 patient_id,
		 encounter_id,
		 location_id,
		 test_id,
		 last_updated_date,
		 voided
		)
		SELECT DISTINCT ob.person_id,
		ob.encounter_id,ob.location_id,ob.value_coded, NOW(), ob.voided
		FROM openmrs.obs ob, openmrs.encounter enc, 
		openmrs.encounter_type entype
		WHERE ob.encounter_id=enc.encounter_id
		AND enc.encounter_type=entype.encounter_type_id
		AND ob.concept_id=1271
		AND entype.uuid='f037e97b-471e-4898-a07c-b8e169e0ddc4'
		ON DUPLICATE KEY UPDATE
		encounter_id = ob.encounter_id,
		last_updated_date = NOW(),
		voided = ob.voided;	
		
/*update provider for patient_laboratory*/
	UPDATE patient_laboratory lab, openmrs.encounter_provider enp
	SET lab.provider_id=enp.provider_id
	WHERE lab.encounter_id=enp.encounter_id
	AND enp.voided = 0;
		
/* Insert date_created into patient_labory table*/

	/*ALTER TABLE isanteplus.patient_laboratory ADD column creation_date DATETIME AFTER visit_date; */
	
/*update visit_id, visit_date for table patient_laboratory*/
	UPDATE patient_laboratory lab, openmrs.visit vi, openmrs.encounter en
	SET lab.visit_id=vi.visit_id, lab.visit_date=vi.date_started, lab.creation_date=vi.date_created
	WHERE lab.encounter_id=en.encounter_id
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

/*update order_destination for patient_laboratory*/
	UPDATE patient_laboratory plab,openmrs.obs ob
	SET plab.order_destination = ob.value_text
	WHERE ob.concept_id = 160632
	AND plab.encounter_id = ob.encounter_id
	AND ob.voided = 0;

/*update test_name for patient_laboratory*/
	UPDATE patient_laboratory plab, openmrs.concept_name cn
	SET plab.test_name=cn.name
	WHERE plab.test_id = cn.concept_id
	AND cn.locale="fr"
	AND cn.voided = 0;

/*End of patient_laboratory*/


/*Started DML queries*/
SET SQL_SAFE_UPDATES = 0;
/*SET FOREIGN_KEY_CHECKS=0;*/
			
				/*---------------------------------------------------*/	
/*Queries for filling the patient_tb_diagnosis table*/
/*Insert when Tuberculose [A15.0] remplir la section Tuberculose ci-dessous
 AND MDR TB remplir la section Tuberculose ci-dessous [Z16.24] areas are checked*/
insert into patient_tb_diagnosis
				(
	 patient_id,
	 encounter_id,
	 location_id,
	 last_updated_date,
	 voided
	)
	select distinct ob.person_id,
		   ob.encounter_id,ob.location_id, now(), ob.voided
	from openmrs.obs ob, openmrs.obs ob1, openmrs.concept c
	where ob.person_id=ob1.person_id
	AND ob.encounter_id=ob1.encounter_id
	AND ob1.concept_id = c.concept_id
	AND ob.obs_group_id=ob1.obs_id
/*AND ob1.concept_id=159947*/
	AND c.uuid IN ('30d2b9eb-0a2f-4b0a-9ae9-31476ec13ed6',
	'b148cd09-496d-4a97-8cd5-75500f2d684f')
	AND ((ob.concept_id=1284 AND ob.value_coded=112141)
	OR
	(ob.concept_id=1284 AND ob.value_coded=159345))
	on duplicate key update
	encounter_id = ob.encounter_id,
	last_updated_date = now(),
	voided = ob.voided;
	
/*Insert when Nouveau diagnostic Or suivi in the tuberculose menu are checked*/						
insert into patient_tb_diagnosis
	(
	patient_id,
	encounter_id,
	location_id,
	last_updated_date,
	voided
	)
	select distinct ob.person_id,ob.encounter_id,ob.location_id, now(), ob.voided
	FROM openmrs.obs ob
	where ob.concept_id=1659
	AND (ob.value_coded=160567 OR ob.value_coded=1662 OR ob.value_coded=1663)
	on duplicate key update
	encounter_id = ob.encounter_id,
	last_updated_date = now(),
	voided = ob.voided;
/*Insert when the area Toux >= 2 semaines is checked*/			
INSERT INTO patient_tb_diagnosis
	(
	patient_id,
	encounter_id,
	location_id,
	last_updated_date, 
	voided
	)
	SELECT DISTINCT ob.person_id,ob.encounter_id,ob.location_id, NOW(), ob.voided
	FROM openmrs.obs ob
	WHERE ob.concept_id=159614
	AND ob.value_coded=159799
	ON DUPLICATE KEY UPDATE
	encounter_id = ob.encounter_id,
	last_updated_date = NOW(),
	voided = ob.voided;
	
/*Insert when one of the status tb is checked on the resultat du traitement(tb) menu*/			
INSERT INTO patient_tb_diagnosis
	(
	patient_id,
	encounter_id,
	location_id,
	last_updated_date,
	voided
	)
	SELECT DISTINCT ob.person_id,ob.encounter_id,ob.location_id, NOW(), ob.voided
	FROM openmrs.obs ob
	WHERE ob.concept_id=159786
	AND (ob.value_coded=159791 OR ob.value_coded=160035
	OR ob.value_coded=159874 OR ob.value_coded=160031
	OR ob.value_coded=160034)
	ON DUPLICATE KEY UPDATE
	encounter_id = ob.encounter_id,
	last_updated_date = NOW(),
	voided = ob.voided;
/*Insert when the HIV patient has a TB diagnosis 
(we will find these concepts particularly in the first and follow-up visits HIV forms)*/

INSERT INTO patient_tb_diagnosis
	(
	patient_id,
	encounter_id,
	location_id,
	last_updated_date,
	voided
	)
	SELECT DISTINCT ob.person_id,ob.encounter_id,ob.location_id, NOW(), ob.voided
	FROM openmrs.obs ob
	WHERE (ob.concept_id = 6042 OR ob.concept_id = 6097)
	AND (ob.value_coded = 159355 OR ob.value_coded = 42 
			OR ob.value_coded = 118890 OR ob.value_coded = 5042)
	ON DUPLICATE KEY UPDATE
	encounter_id = ob.encounter_id,
	last_updated_date = NOW(),
	voided = ob.voided;
	
/*update for visit_id AND visit_date*/ 
UPDATE patient_tb_diagnosis pat, openmrs.visit vi, openmrs.encounter en
   SET pat.visit_id=vi.visit_id, pat.visit_date=vi.date_started
	WHERE pat.encounter_id=en.encounter_id
	AND en.visit_id=vi.visit_id
	AND vi.voided = 0;
	
/*update provider ???*/
UPDATE patient_tb_diagnosis pat, openmrs.encounter_provider enp
	SET pat.provider_id=enp.provider_id
	WHERE pat.encounter_id=enp.encounter_id
	AND enp.voided = 0;
	
/*Update tb_diag and mdr_tb_diag*/
update patient_tb_diagnosis pat, openmrs.obs ob,openmrs.obs ob1, openmrs.concept c
	set pat.tb_diag=1
	where ob.obs_group_id=ob1.obs_id
	AND ob1.concept_id = c.concept_id
/*AND ob1.concept_id=159947*/

	AND c.uuid = '30d2b9eb-0a2f-4b0a-9ae9-31476ec13ed6'
	AND (ob.concept_id=1284 AND ob.value_coded=112141)
	AND pat.encounter_id=ob.encounter_id
	AND ob.voided = 0;
					
	update patient_tb_diagnosis pat, openmrs.obs ob,openmrs.obs ob1, openmrs.concept c
	set pat.mdr_tb_diag=1
	where ob.obs_group_id=ob1.obs_id
	AND ob1.concept_id = c.concept_id
/*AND ob1.concept_id=159947*/

	AND c.uuid = 'b148cd09-496d-4a97-8cd5-75500f2d684f'	
	AND (ob.concept_id=1284 AND ob.value_coded=159345)
	AND pat.encounter_id=ob.encounter_id
	AND ob.voided = 0;
	
/*update for M. tuberculosis(TB) pulmonaire*/
	UPDATE patient_tb_diagnosis pat, openmrs.obs ob
	SET pat.tb_pulmonaire = 1
	WHERE ob.concept_id IN (6042,6097)	
	AND ob.value_coded = 42
	AND pat.encounter_id = ob.encounter_id
	AND ob.voided = 0;
	
/*update for Tuberculose multirésistante*/
	UPDATE patient_tb_diagnosis pat, openmrs.obs ob
	SET pat.tb_multiresistante = 1
	WHERE ob.concept_id IN (6042,6097)	
	AND ob.value_coded = 159355
	AND pat.encounter_id = ob.encounter_id
	AND ob.voided = 0;
	
/*update for M. tuberculosis (TB) extrapulmonaire ou disséminée*/
	UPDATE patient_tb_diagnosis pat, openmrs.obs ob
	SET pat.tb_extrapul_ou_diss = 1
	WHERE ob.concept_id IN (6042,6097)	
	AND ob.value_coded IN (118890,5042)
	AND pat.encounter_id = ob.encounter_id
	AND ob.voided = 0;
/*update tb_new_diag AND tb_follow_up_diag*/
	UPDATE patient_tb_diagnosis pat, openmrs.obs ob
	SET pat.tb_new_diag=1
	WHERE pat.encounter_id=ob.encounter_id
	AND (ob.concept_id=1659 AND ob.value_coded=160567)
	AND ob.voided = 0;
	
	UPDATE patient_tb_diagnosis pat, openmrs.obs ob
	SET pat.tb_follow_up_diag=1
	WHERE pat.encounter_id=ob.encounter_id
	AND (ob.concept_id=1659 AND ob.value_coded=1662)
	AND ob.voided = 0;
/*update cough_for_2wks_or_more*/
	UPDATE patient_tb_diagnosis pat, openmrs.obs ob
	SET pat.cough_for_2wks_or_more=1
	WHERE pat.encounter_id=ob.encounter_id
	AND (ob.concept_id=159614 AND ob.value_coded=159799)
	AND ob.voided = 0;
/*update tb_treatment_start_date*/
	UPDATE patient_tb_diagnosis pat, openmrs.obs ob
	SET pat.tb_treatment_start_date=ob.value_datetime
	WHERE pat.encounter_id=ob.encounter_id
	AND ob.concept_id=1113
	AND ob.voided = 0;
/*update for status_tb_treatment*/
/*
	statuts_tb_treatment = Gueri(1),traitement termine(2),
		Abandon(3),tranfere(4),decede(5), actuellement sous traitement(6)
<obs conceptId="CIEL:159786" 
answerConceptIds="CIEL:159791,CIEL:160035,CIEL:159874,CIEL:160031,CIEL:160034" 
answerLabels="Guéri,Traitement Terminé,Abandon,Transféré,Décédé" style="radio"/>
*/
	UPDATE patient_tb_diagnosis pat, openmrs.obs ob
	SET pat.status_tb_treatment=
	CASE WHEN ob.value_coded=159791 THEN 1 -- Cured
	WHEN ob.value_coded=160035 THEN 2 -- Completed Treatment
	WHEN ob.value_coded=159874 THEN 4 -- Treatment failure
	WHEN ob.value_coded=5240 OR ob.value_coded=160031 THEN 8 -- Defaulted
	WHEN ob.value_coded=160034 THEN 5 -- Died
	WHEN ob.value_coded=159492 THEN 16 -- Transfered out
	END
	WHERE pat.encounter_id=ob.encounter_id
	AND ob.concept_id=159786
	AND ob.voided = 0;
	
/*Update for Actif and Gueri for TB diagnosis for HIV patient*/
	UPDATE patient_tb_diagnosis pat, openmrs.obs ob,
	(SELECT o.person_id, o.encounter_id, COUNT(o.encounter_id) AS nb 
	FROM openmrs.obs o WHERE o.concept_id=6042 AND o.value_coded IN (42,159355,118890) GROUP BY 1) a
	SET pat.status_tb_treatment =
	CASE WHEN (ob.concept_id = 6097 AND a.nb = 0)  THEN 1
	WHEN (ob.concept_id = 6042 AND a.nb > 0)  THEN 6
	END
	WHERE pat.encounter_id = ob.encounter_id
	AND ob.encounter_id = a.encounter_id
	AND ob.person_id = a.person_id
	AND ob.value_coded IN (42,159355,118890,5042)
	AND ob.voided = 0;
	
/*Guéri*/
	
	 UPDATE isanteplus.patient_tb_diagnosis pat, openmrs.obs ob
	SET pat.status_tb_treatment = 1
	WHERE pat.encounter_id = ob.encounter_id
    AND pat.patient_id = ob.person_id
	AND ob.concept_id = 6097
	AND ob.value_coded IN (42,159355,118890,5042)
	AND ob.voided = 0;
    
/*Actif*/
    UPDATE isanteplus.patient_tb_diagnosis pat, openmrs.obs ob
	SET pat.status_tb_treatment = 6
	WHERE pat.encounter_id = ob.encounter_id
    AND pat.patient_id = ob.person_id
	AND ob.concept_id = 6042
	AND ob.value_coded IN (42,159355,118890)
	AND ob.voided = 0;
	
	
/*Update for traitement TB COMPLETE AND Actuellement sous traitement 
(Area in the HIV first and follow-up visit forms)*/
	UPDATE patient_tb_diagnosis pat, openmrs.obs ob
	SET pat.status_tb_treatment=
	CASE WHEN ob.value_coded=1663 THEN 2
	WHEN ob.value_coded=1662 THEN 6
	ELSE NULL
	END
	WHERE pat.encounter_id=ob.encounter_id
	AND ob.concept_id=1659
	AND ob.voided = 0;
	
/*update tb_treatment_stop_date*/
   UPDATE patient_tb_diagnosis pat, openmrs.obs ob
	SET pat.tb_treatment_stop_date=ob.value_datetime
	WHERE pat.encounter_id=ob.encounter_id
	AND ob.concept_id=159431
	AND ob.voided = 0;

/* Update encounter type id*/
    UPDATE patient_tb_diagnosis pat, openmrs.encounter enc
	SET pat.encounter_type_id=enc.encounter_type
	WHERE pat.encounter_id=enc.encounter_id
	AND enc.voided = 0;
	
/* Age at visit in years and Age at Visit in Months*/
    UPDATE patient_tb_diagnosis pat, patient p
	SET pat.age_at_visit_years=TIMESTAMPDIFF(YEAR, p.birthdate, pat.visit_date),
		pat.age_at_visit_months=TIMESTAMPDIFF(MONTH, p.birthdate, pat.visit_date)		
	WHERE pat.patient_id=p.patient_id;

/* Started TB Treatment*/
    UPDATE patient_tb_diagnosis pat, openmrs.obs o
	SET pat.tb_started_treatment=1
	WHERE pat.encounter_id=o.encounter_id
	AND o.concept_id=1113
	AND o.value_datetime IS NOT NULL
	AND o.voided = 0;

/* Dyspnea*/
    UPDATE patient_tb_diagnosis pat, openmrs.obs o
	SET pat.tb_started_treatment=1
	WHERE pat.encounter_id=o.encounter_id
	AND o.concept_id=159614
	AND o.value_coded=122496
	AND o.voided = 0;

/*Dyspnea */    
	UPDATE patient_tb_diagnosis pat, openmrs.obs o
	SET pat.dyspnea =1
	WHERE pat.encounter_id=o.encounter_id
	AND o.concept_id=159614
	AND o.value_coded=122496
	AND o.voided = 0;

/*Diagnosis based on sputum*/    
	UPDATE patient_tb_diagnosis pat, openmrs.obs o
	SET pat.tb_diag_sputum=1
	WHERE pat.encounter_id=o.encounter_id
	AND o.concept_id=163752
	AND o.value_coded=307
	AND o.voided = 0;
 
/*Diagnosis based on Xray*/    
	UPDATE patient_tb_diagnosis pat, openmrs.obs o
	SET pat.tb_diag_xray=1
	WHERE pat.encounter_id=o.encounter_id
	AND o.concept_id=163752
	AND o.value_coded=12
	AND o.voided = 0;

/*Sputum Results at Month 0*/    
	UPDATE patient_tb_diagnosis pat, openmrs.obs ob, openmrs.obs ob1 
		SET pat.tb_test_result_mon_0=(CASE WHEN ob1.value_coded = 703 THEN 1 WHEN 664 THEN 2 ELSE NULL END) 
	WHERE pat.encounter_id=ob1.encounter_id
		AND ob.obs_id=ob1.obs_group_id
		AND ob.concept_id = 166136
		AND ob1.concept_id = 307;
 
/*Sputum Results at Month 2*/    
	UPDATE patient_tb_diagnosis pat, openmrs.obs ob, openmrs.obs ob1 
		SET pat.tb_test_result_mon_2=(CASE WHEN ob1.value_coded = 703 THEN 1 WHEN 664 THEN 2 ELSE NULL END) 
	WHERE pat.encounter_id=ob1.encounter_id
		AND ob.obs_id=ob1.obs_group_id
		AND ob.concept_id = 166134
		AND ob1.concept_id = 307;

/*Sputum Results at Month 3*/
	UPDATE patient_tb_diagnosis pat, openmrs.obs ob, openmrs.obs ob1 
		SET pat.tb_test_result_mon_3=(CASE WHEN ob1.value_coded = 703 THEN 1 WHEN 664 THEN 2 ELSE NULL END) 
	WHERE pat.encounter_id=ob1.encounter_id
		AND ob.obs_id=ob1.obs_group_id
		AND ob.concept_id = 165978
		AND ob1.concept_id = 307;

/*Sputum Results at Month 5*/    
	UPDATE patient_tb_diagnosis pat, openmrs.obs ob, openmrs.obs ob1 
		SET pat.tb_test_result_mon_5=(CASE WHEN ob1.value_coded = 703 THEN 1 WHEN 664 THEN 2 ELSE NULL END) 
	WHERE pat.encounter_id=ob1.encounter_id
		AND ob.obs_id=ob1.obs_group_id
		AND ob.concept_id = 165999
		AND ob1.concept_id = 307;

/*Sputum Results at End*/    
	UPDATE patient_tb_diagnosis pat, openmrs.obs ob, openmrs.obs ob1 
		SET pat.tb_test_result_end=(CASE WHEN ob1.value_coded = 703 THEN 1 WHEN 664 THEN 2 ELSE NULL END) 
	WHERE pat.encounter_id=ob1.encounter_id
		AND ob.obs_id=ob1.obs_group_id
		AND ob.concept_id = 165804
		AND ob1.concept_id = 307;

/*Pulmonary TB Classification*/    
	UPDATE patient_tb_diagnosis pat, openmrs.obs o
	SET pat.tb_class_pulmonary=1
	WHERE pat.encounter_id=o.encounter_id
	AND o.concept_id=160040
	AND o.value_coded=42
	AND o.voided = 0;

/*Extra Pulmonary TB Clasification*/    
	UPDATE patient_tb_diagnosis pat, openmrs.obs o
	SET pat.tb_class_extrapulmonary=1
	WHERE pat.encounter_id=o.encounter_id
	AND o.concept_id=160040
	AND o.value_coded=5042
	AND o.voided = 0;

/*Meningitis TB*/    
	UPDATE patient_tb_diagnosis pat, openmrs.obs o
	SET pat.tb_extra_meningitis=1
	WHERE pat.encounter_id=o.encounter_id
	AND o.concept_id=160040
	AND o.value_coded=111967
	AND o.voided = 0;

/*Genital TB*/    
	UPDATE patient_tb_diagnosis pat, openmrs.obs o
	SET pat.tb_extra_genital=1
	WHERE pat.encounter_id=o.encounter_id
	AND o.concept_id=160040
	AND o.value_coded=159167
	AND o.voided = 0;

/*Pleural TB*/    
	UPDATE patient_tb_diagnosis pat, openmrs.obs o
	SET pat.tb_extra_pleural=1
	WHERE pat.encounter_id=o.encounter_id
	AND o.concept_id=160040
	AND o.value_coded=111946
	AND o.voided = 0;

/*Miliary TB*/    
	UPDATE patient_tb_diagnosis pat, openmrs.obs o
	SET pat.tb_extra_miliary=1
	WHERE pat.encounter_id=o.encounter_id
	AND o.concept_id=160040
	AND o.value_coded=115753
	AND o.voided = 0;

/*Gangliponic TB*/    
	UPDATE patient_tb_diagnosis pat, openmrs.obs o
	SET pat.tb_extra_gangliponic=1
	WHERE pat.encounter_id=o.encounter_id
	AND o.concept_id=160040
	AND o.value_coded=111873
	AND o.voided = 0;

/*Intestinal TB*/    
	UPDATE patient_tb_diagnosis pat, openmrs.obs o
	SET pat.tb_extra_intestinal=1
	WHERE pat.encounter_id=o.encounter_id
	AND o.concept_id=160040
	AND o.value_coded=161355
	AND o.voided = 0;

/*Other TB*/    
	UPDATE patient_tb_diagnosis pat, openmrs.obs o
	SET pat.tb_extra_other=1
	WHERE pat.encounter_id=o.encounter_id
	AND o.concept_id=160040
	AND o.value_coded=5622
	AND o.voided = 0;

/*Any TB Medication Prescribed*/    
	UPDATE patient_tb_diagnosis pat, openmrs.obs o
	SET pat.tb_medication_provided=1
	WHERE pat.encounter_id=o.encounter_id
	AND o.concept_id=1111
	AND o.value_coded IN (75948, 160093, 160096, 160095, 160092, 84360, 163753, 160094, 82900)
	AND o.voided = 0;

/*HIV Test result*/    
	UPDATE patient_tb_diagnosis pat, openmrs.obs o
	SET pat.tb_hiv_test_result=(
		CASE WHEN(o.value_coded=703) THEN 4 -- Positive
		    WHEN (o.value_coded=664) THEN 2 -- Negative
		END	
	)
	WHERE pat.encounter_id=o.encounter_id
	AND o.concept_id=1169
	AND o.value_coded IN (1402, 664, 703)
	AND o.voided = 0;

/*Cotrimoxazole prophylaxis*/    
	UPDATE patient_tb_diagnosis pat, openmrs.obs o
	SET pat.tb_prophy_cotrimoxazole=1
	WHERE pat.encounter_id=o.encounter_id
	AND o.concept_id=1109
	AND o.value_coded=105281
	AND o.voided = 0;

/*On ARVs*/    
	UPDATE patient_tb_diagnosis pat, openmrs.obs o
	SET pat.on_arv=(CASE WHEN o.value_coded = 160119 THEN 1 WHEN 1461 THEN 2 ELSE NULL END) 
	WHERE pat.encounter_id=o.encounter_id
	AND o.concept_id=160117
	AND o.value_coded IN (160119, 1461)
	AND o.voided = 0;


/* <begin Nutrition surveillance> */
INSERT INTO patient_nutrition
	(
	 patient_id,
	 encounter_type_id,
	 encounter_id,
	 location_id,
	 last_updated_date,
	 visit_id,
	 visit_date,
	 voided
	)
	SELECT DISTINCT 
		enc.patient_id,
		enct.encounter_type_id,
		enc.encounter_id,
		enc.location_id, 
		NOW(), 
		enc.visit_id,
		CAST(enc.encounter_datetime AS DATE),
		enc.voided
	FROM openmrs.encounter enc, openmrs.encounter_type enct
	WHERE enc.encounter_type=enct.encounter_type_id
	AND enct.uuid IN (
		'12f4d7c3-e047-4455-a607-47a40fe32460', -- Soins de santé primaire--premiére consultation (Adult intital consultation)
		'a5600919-4dde-4eb8-a45b-05c204af8284', -- Soins de santé primaire--consultation (Adult followp consultation)
		'709610ff-5e39-4a47-9c27-a60e740b0944', -- Soins de santé primaire--premiére con. p (Paeditric initial consultation)
		'fdb5b14f-555f-4282-b4c1-9286addf0aae' -- Soins de santé primaire--con. pédiatrique (Paediatric followup consultation)
	)
	ON DUPLICATE KEY UPDATE
	encounter_id = enc.encounter_id,
	visit_date=CAST(enc.encounter_datetime AS DATE),
	last_updated_date = NOW(),
	voided = enc.voided;		
	
/*Age At Visit in Years*/    
	UPDATE isanteplus.patient_nutrition pat, openmrs.obs o, isanteplus.patient p
	 SET pat.age_at_visit_years=TIMESTAMPDIFF(YEAR,p.birthdate,pat.visit_date)
	 WHERE pat.encounter_id=o.encounter_id
	 AND pat.patient_id=p.patient_id
	 AND o.voided = 0;
	 
/*Age At Visit In Months*/    
	UPDATE isanteplus.patient_nutrition pat, openmrs.obs o, isanteplus.patient p
	 SET pat.age_at_visit_months=TIMESTAMPDIFF(MONTH,p.birthdate,pat.visit_date)
	 WHERE pat.encounter_id=o.encounter_id
	 AND pat.patient_id=p.patient_id
	 AND o.voided = 0;
	 
/*Weight*/    
	UPDATE isanteplus.patient_nutrition pat, openmrs.obs o
	 SET pat.weight=o.value_numeric
	 WHERE pat.encounter_id=o.encounter_id
	 AND o.concept_id=5089
	 AND o.voided = 0;
	 
/*Height*/    
	UPDATE isanteplus.patient_nutrition pat, openmrs.obs o
	 SET pat.height=o.value_numeric
	 WHERE pat.encounter_id=o.encounter_id
	 AND o.concept_id=5090
	 AND o.voided = 0;

/*BMI*/
	UPDATE isanteplus.patient_nutrition pat
	 SET pat.bmi=ROUND((pat.weight/(pat.height/100*pat.height/100)),1)
	 WHERE pat.age_at_visit_years>=20 
	 AND pat.voided = 0;
	 
/*Edema*/    
	UPDATE isanteplus.patient_nutrition pat, openmrs.obs o
	 SET pat.edema=(CASE WHEN o.concept_id=159614 AND o.value_coded=460 THEN 1 ELSE 0 END)
	 WHERE pat.encounter_id=o.encounter_id
	 AND o.voided = 0;

/*Weight for height*/    
	UPDATE isanteplus.patient_nutrition pat, openmrs.obs o
	 SET pat.weight_for_height=(CASE 
					WHEN o.value_coded=1115 THEN 1 -- Normal
					WHEN o.value_coded=164131 THEN 2 -- SAM
					WHEN o.value_coded=123815 THEN 2 -- MAM
				END)
	 WHERE pat.encounter_id=o.encounter_id
	 AND o.concept_id=163515
	 AND o.value_coded IN (1115, 164131, 123815)
	 AND o.voided = 0;
/* <end Nutrition surveillance> */

/* <begin patient OB/GYN> */
	INSERT INTO patient_ob_gyn
	(
	 patient_id,
	 encounter_type_id,
	 encounter_id,
	 location_id,
	 last_updated_date,
	 visit_id,
	 visit_date,
	 voided
	)
	SELECT DISTINCT 
		enc.patient_id,
		enct.encounter_type_id,
		enc.encounter_id,
		enc.location_id, 
		NOW(), 
		enc.visit_id,
		CAST(enc.encounter_datetime AS DATE),
		enc.voided
	FROM openmrs.encounter enc, openmrs.encounter_type enct
	WHERE enc.encounter_type=enct.encounter_type_id
	AND enct.uuid IN (
		'5c312603-25c1-4dbe-be18-1a167eb85f97', -- Saisie Première ob/gyn (intital consultation)
		'49592bec-dd22-4b6c-a97f-4dd2af6f2171' -- Ob/gyn Suivi ( followup consultation)
	)
	ON DUPLICATE KEY UPDATE
	encounter_id = enc.encounter_id,
	visit_date=CAST(enc.encounter_datetime AS DATE),
	last_updated_date = NOW(),
	voided = enc.voided;

/*MUAC*/
	UPDATE isanteplus.patient_ob_gyn pat, openmrs.obs o
	 SET pat.muac=o.value_numeric
	 WHERE pat.encounter_id=o.encounter_id
	 AND o.concept_id=1343
	 AND o.voided = 0;

/*Pregnant*/    
	UPDATE isanteplus.patient_ob_gyn pat, openmrs.obs o
	 SET pat.pregnant=1
	 WHERE pat.encounter_id=o.encounter_id
	 AND o.concept_id=160288
	 AND o.value_coded=1622
	 AND o.voided = 0;
	 
/*Next Visit Date*/    
	UPDATE isanteplus.patient_ob_gyn pat, openmrs.obs o
	 SET pat.next_visit_date=o.value_datetime
	 WHERE pat.encounter_id=o.encounter_id
	 AND o.concept_id=5096
	 AND o.voided = 0;
	 
/*Edd*/    
	UPDATE isanteplus.patient_ob_gyn pat, openmrs.obs o
	 SET pat.edd=o.value_datetime
	 WHERE pat.encounter_id=o.encounter_id
	 AND o.concept_id=5596
	 AND o.voided = 0;
	 
/*Birth Plan*/    
	UPDATE isanteplus.patient_ob_gyn pat, openmrs.obs o
	 SET pat.birth_plan=1
	 WHERE pat.encounter_id=o.encounter_id
	 AND o.concept_id IN (163764, 161007, 160112, 163765, 163766) 
	 AND o.value_coded=1065
	 AND o.voided = 0;
	 
/*High Risk*/    
	UPDATE isanteplus.patient_ob_gyn pat, openmrs.obs o
	 SET pat.high_risk=1
	 WHERE pat.encounter_id=o.encounter_id
	 AND o.concept_id=160079
	 AND o.value_coded IN (1107, 145777, 148834, 119476, 460, 1053, 163119, 163120)
	 AND o.voided = 0;
	 
/*Gestation Greater Than 12Wks*/    
	UPDATE isanteplus.patient_ob_gyn pat, openmrs.obs o
	 SET pat.gestation_greater_than_12_wks=1
	 WHERE pat.encounter_id=o.encounter_id
	 AND o.concept_id=1438
	 AND o.value_numeric>=12
	 AND o.voided = 0;
	 
/*Iron Supplement*/    
	UPDATE isanteplus.patient_ob_gyn pat, openmrs.obs o
	 SET pat.iron_supplement=1
	 WHERE pat.encounter_id=o.encounter_id
	 AND o.concept_id=1282
	 AND o.value_coded=5843
	 AND o.voided = 0;
	 
/*Folic Acid Supplement*/    
	UPDATE isanteplus.patient_ob_gyn pat, openmrs.obs o
	 SET pat.folic_acid_supplement=1
	 WHERE pat.encounter_id=o.encounter_id
	 AND o.concept_id=1282
	 AND o.value_coded=76613
	 AND o.voided = 0;
	 
/*Tetanus Toxoid Vaccine*/    
	UPDATE isanteplus.patient_ob_gyn pat, openmrs.obs o
	 SET pat.tetanus_toxoid_vaccine=1
	 WHERE pat.encounter_id=o.encounter_id
	 AND o.concept_id=984
	 AND o.value_coded=84879
	 AND o.voided = 0;
	 
/*Iron Defiency Anemia*/    
	UPDATE isanteplus.patient_ob_gyn pat, openmrs.obs o
	 SET pat.iron_defiency_anemia=1
	 WHERE pat.encounter_id=o.encounter_id
	 AND o.concept_id=160079
	 AND o.value_coded=148834
	 AND o.voided = 0;
	 
/*Prescribed Iron*/    
	UPDATE isanteplus.patient_ob_gyn pat, openmrs.obs o
	 SET pat.prescribed_iron=1
	 WHERE pat.encounter_id=o.encounter_id
	 AND o.concept_id=1282
	 AND o.value_coded=78218
	 AND o.voided = 0;
	 
/*Prescribed Folic Acid*/    
	UPDATE isanteplus.patient_ob_gyn pat, openmrs.obs o
	 SET pat.prescribed_folic_acid=1
	 WHERE pat.encounter_id=o.encounter_id
	 AND o.concept_id=1282
	 AND o.value_coded=76613
	 AND o.voided = 0;
	 
/*Elevated Blood Pressure*/    
	UPDATE isanteplus.patient_ob_gyn pat, openmrs.obs o
	 SET pat.elevated_blood_pressure=1
	 WHERE pat.encounter_id=o.encounter_id
	 AND (o.concept_id=5085 AND o.value_numeric>=120 AND o.value_numeric<=129) -- bp systolic
	 AND (o.concept_id=5086 AND o.value_numeric<80)	-- bp diastolic
	 AND o.voided = 0;

/* <end Nutrition OB/GYN> */

/*Insertion for patient_id, visit_id,encounter_id,visit_date for table patient_imagerie */
INSERT INTO patient_imagerie (patient_id,location_id,visit_id,encounter_id,visit_date, voided)
	SELECT DISTINCT ob.person_id,ob.location_id,vi.visit_id, ob.encounter_id,vi.date_started, vi.voided
	FROM openmrs.obs ob, openmrs.encounter en, 
	openmrs.encounter_type enctype, openmrs.visit vi
	WHERE ob.encounter_id=en.encounter_id
	AND en.encounter_type=enctype.encounter_type_id
	AND en.visit_id=vi.visit_id
	AND(ob.concept_id=12 OR ob.concept_id=309 OR ob.concept_id=307)
	AND enctype.uuid='a4cab59f-f0ce-46c3-bd76-416db36ec719'
	ON DUPLICATE KEY UPDATE
	visit_date = vi.date_started,
	voided = vi.voided;
	
/*update radiographie_pul of table patient_imagerie*/
	UPDATE isanteplus.patient_imagerie patim, openmrs.obs ob
	SET patim.radiographie_pul=ob.value_coded
	WHERE patim.encounter_id=ob.encounter_id
	AND ob.concept_id=12
	AND ob.voided = 0;
	
/*update radiographie_autre of table patient_imagerie*/
	UPDATE isanteplus.patient_imagerie patim, openmrs.obs ob
	SET patim.radiographie_autre=ob.value_coded
	WHERE patim.encounter_id=ob.encounter_id
	AND ob.concept_id=309
	AND ob.voided = 0;
	
/*update crachat_barr of table patient_imagerie*/
	UPDATE isanteplus.patient_imagerie patim, openmrs.obs ob
	SET patim.crachat_barr=ob.value_coded
	WHERE patim.encounter_id=ob.encounter_id
	AND ob.concept_id=307
	AND ob.voided = 0;

/*Part of patient Status*/
	TRUNCATE TABLE discontinuation_reason;
	INSERT INTO discontinuation_reason(patient_id,visit_id,visit_date,reason,reason_name)
	SELECT v.patient_id,v.visit_id, MAX(v.date_started),ob.value_coded,
	CASE WHEN(ob.value_coded=5240) THEN 'Perdu de vue'
	     WHEN (ob.value_coded=159492) THEN 'Transfert'
	     WHEN (ob.value_coded=159) THEN 'Décès'
	     WHEN (ob.value_coded=1667) THEN 'Discontinuations'
	     WHEN (ob.value_coded=1067) THEN 'Inconnue'
	END
	FROM openmrs.visit v, openmrs.encounter enc,
	openmrs.encounter_type etype,openmrs.obs ob
	WHERE v.visit_id=enc.visit_id
	AND enc.encounter_type=etype.encounter_type_id
	AND enc.encounter_id=ob.encounter_id
	AND etype.uuid='9d0113c6-f23a-4461-8428-7e9a7344f2ba'
	AND ob.concept_id=161555
	AND ob.voided = 0
	AND enc.voided <> 1
	GROUP BY v.patient_id, ob.value_coded;
	
/*INSERT for stopping_reason*/
	
	TRUNCATE TABLE stopping_reason;
	INSERT INTO stopping_reason(patient_id,visit_id,visit_date,reason,reason_name,other_reason)
	SELECT v.patient_id,v.visit_id,
		MAX(v.date_started),ob.value_coded,
	CASE WHEN(ob.value_coded=1754) THEN 'ARVs non-disponibles'
	    WHEN (ob.value_coded=160415) THEN 'Patient a déménagé'
		WHEN (ob.value_coded=115198) THEN 'Adhérence inadéquate'
		WHEN (ob.value_coded=159737) THEN 'Préférence du patient'
		WHEN (ob.value_coded=5622) THEN 'Autre raison, préciser'
	END, ob.comments
	FROM openmrs.visit v, openmrs.encounter enc,
	openmrs.encounter_type etype,openmrs.obs ob
	WHERE v.visit_id=enc.visit_id
	AND enc.encounter_type=etype.encounter_type_id
	AND enc.encounter_id=ob.encounter_id
	AND etype.uuid='9d0113c6-f23a-4461-8428-7e9a7344f2ba'
	AND ob.concept_id=1667
	AND ob.value_coded IN(1754,160415,115198,159737,5622)
	AND ob.voided = 0
	GROUP BY v.patient_id, ob.value_coded;
	
/*Delete FROM discontinuation_reason WHERE visit_id NOT IN Adhérence inadéquate=115198 
OR Préférence du patient=159737*/
	DELETE FROM discontinuation_reason
	WHERE visit_id NOT IN(SELECT str.visit_id FROM stopping_reason str
	WHERE str.reason = 115198 OR str.reason = 159737)
	AND reason = 1667;
	
/*Starting insertion for patient_prenancy table*/
/*Patient_pregnancy insertion*/
	INSERT INTO patient_pregnancy (patient_id,encounter_id,start_date,last_updated_date, voided)
	SELECT DISTINCT ob.person_id,ob.encounter_id,DATE(ob.obs_datetime) AS start_date, now(), ob.voided
	FROM openmrs.obs ob, openmrs.obs ob1, openmrs.concept c
	WHERE ob1.concept_id = c.concept_id
	AND ob.obs_group_id=ob1.obs_id
	AND ob.concept_id=1284
	AND ob.value_coded IN (46,129251,132678,47,163751,1449,118245,129211/*(No)*/,141631,158489,490,118744)
/*AND ob1.concept_id=159947*/
	AND c.uuid IN ('3fea18d4-88f1-40c1-aadc-41dca3449f9d','73da2a29-a035-41b5-8891-717ba99a3081',
	'361bd482-59a9-4ee8-80f0-e7e39b1d1827','fd7987b1-d551-4451-b8e2-59a998adf1d5',
	'ee6c7fd3-6a2f-4af0-8978-e1c5e06a9a62','6e639f6c-1b62-41c4-8cfd-fb76b3205313',
	'f9d52515-6c56-41b3-881a-1b40f355144c','1dfb560d-6627-441e-a8e2-d1517b51c8b4',
	'756f00e4-b1b6-40cd-b5ab-d5cce8a571fb','1dfb560d-6627-441e-a8e2-d1517b51c8b4',
	'22be1344-65f9-4310-9be3-1d300e57820b','cb4d6c75-c218-4a26-9046-41e0939e55c4')
	on duplicate key update
	start_date = start_date,
	last_updated_date = now(),
	voided = ob.voided;
	
/*Patient_pregnancy insertion for area Femme enceinte (Grossesse)*/
	INSERT INTO patient_pregnancy (patient_id,encounter_id,start_date,last_updated_date, voided)
	SELECT ob.person_id,ob.encounter_id,DATE(ob.obs_datetime) AS start_date, NOW(), ob.voided
	FROM openmrs.obs ob
	WHERE ob.concept_id=162225
	AND ob.value_coded=1434
	ON DUPLICATE KEY UPDATE
	start_date = start_date,
	last_updated_date = NOW(),
	voided = ob.voided;
	
/*Patient_pregnancy insertion for area Conseils sur l’allaitement maternel
	And Visite Domiciliaire AND Club des Mères Groupe de Support
	AND Dispensation ARV AND Education Individuelle
	*/
	INSERT INTO patient_pregnancy (patient_id,encounter_id,start_date,last_updated_date, voided)
	SELECT ob.person_id,ob.encounter_id,DATE(ob.obs_datetime) AS start_date, NOW(), ob.voided
	FROM openmrs.obs ob
	WHERE ob.concept_id = 1592
	AND ob.value_coded IN (1910,162186,5486,5576,163106,1622)
	ON DUPLICATE KEY UPDATE
	start_date = start_date,
	last_updated_date = NOW(),
	voided = ob.voided;
	
/*Insertion in patient_pregnancy table where prenatale is checked in the OBGYN form*/
	INSERT INTO patient_pregnancy(patient_id,encounter_id,start_date, last_updated_date, voided)
	SELECT DISTINCT ob.person_id,ob.encounter_id,DATE(enc.encounter_datetime) AS start_date,NOW(), ob.voided
	FROM openmrs.obs ob, openmrs.encounter enc, 
	openmrs.encounter_type ent
	WHERE ob.encounter_id = enc.encounter_id
	AND enc.encounter_type = ent.encounter_type_id
	AND ob.concept_id = 160288
	AND ob.value_coded = 1622
	AND ent.uuid IN("5c312603-25c1-4dbe-be18-1a167eb85f97","49592bec-dd22-4b6c-a97f-4dd2af6f2171")
	ON DUPLICATE KEY UPDATE
	start_date = start_date,
	last_updated_date = NOW(),
	voided = ob.voided;
/*Insertion in patient_pregnancy table where DPA is filled*/

	INSERT INTO patient_pregnancy(patient_id,encounter_id,start_date,last_updated_date, voided)
	SELECT DISTINCT ob.person_id,ob.encounter_id,DATE(enc.encounter_datetime) AS start_date, NOW(), ob.voided
	FROM openmrs.obs ob, openmrs.encounter enc, 
	openmrs.encounter_type ent
	WHERE ob.encounter_id = enc.encounter_id
	AND enc.encounter_type = ent.encounter_type_id
        AND ob.concept_id = 5596
	AND (ob.value_datetime <> "" AND ob.value_datetime IS NOT NULL)
	AND ent.uuid IN("5c312603-25c1-4dbe-be18-1a167eb85f97","49592bec-dd22-4b6c-a97f-4dd2af6f2171")
	ON DUPLICATE KEY UPDATE
	start_date = start_date,
	last_updated_date = NOW(),
	voided = ob.voided;
	
/*Patient_pregnancy insertion for areas B-HCG(positif),Test de Grossesse(positif) */
	INSERT INTO patient_pregnancy(patient_id,encounter_id,start_date,last_updated_date, voided)
	SELECT ob.person_id,ob.encounter_id,DATE(ob.obs_datetime) AS start_date, NOW(), ob.voided
	FROM openmrs.obs ob
	WHERE (ob.concept_id=1945 OR ob.concept_id=45)
	AND ob.value_coded=703
	ON DUPLICATE KEY UPDATE
	start_date = start_date,
	last_updated_date = NOW(),
	voided = ob.voided;
	
/*INSERTION in patient_pregnancy for area 
	- (Si domicile et femme VIH positif : est-ce qu’il y a une
	planification faite pour la prophylaxie ARV de l’enfant, AND Si domicile et femme VIH positif)
	- AND Si domicile : Planification pour la présence d’une matrone
	- AND Planification pour transition dans une Maison de Naissance
	- AND Inscrite dans un Club des Mères
	*/
	INSERT INTO patient_pregnancy(patient_id,encounter_id,start_date,last_updated_date, voided)
	SELECT ob.person_id,ob.encounter_id,DATE(ob.obs_datetime) AS start_date, NOW(), ob.voided
	FROM openmrs.obs ob
	WHERE ob.concept_id IN (163764,161007,163765,163766)
	AND ob.value_coded = 1065
	ON DUPLICATE KEY UPDATE
	start_date = start_date,
	last_updated_date = NOW(),
	voided = ob.voided;
	
/*Insertion in patient_pregnancy for area Changement dans la fréquence
	et/ou intensité des mouvements foetaux*/
	INSERT INTO patient_pregnancy(patient_id,encounter_id,start_date,last_updated_date, voided)
	SELECT ob.person_id,ob.encounter_id,DATE(ob.obs_datetime) AS start_date, NOW(), ob.voided
	FROM openmrs.obs ob
	WHERE ob.concept_id = 159614
	AND ob.value_coded IN (113377,159937)
	ON DUPLICATE KEY UPDATE
	start_date = start_date,
	last_updated_date = NOW(),
	voided = ob.voided;
	
/*Insertion in patient_pregnancy table where a form travail et accouchement is filled*/
	INSERT INTO patient_pregnancy(patient_id,encounter_id,start_date, end_date, last_updated_date, voided)
	SELECT DISTINCT ob.person_id,ob.encounter_id,(DATE(enc.encounter_datetime)- INTERVAL 9 MONTH) AS start_date,
	DATE(enc.encounter_datetime) AS end_date, NOW(), ob.voided
	FROM openmrs.obs ob, openmrs.encounter enc, 
	openmrs.encounter_type ent
	WHERE ob.encounter_id = enc.encounter_id
	AND enc.encounter_type = ent.encounter_type_id
	AND ent.uuid = "d95b3540-a39f-4d1e-a301-8ee0e03d5eab"
	ON DUPLICATE KEY UPDATE
	start_date = start_date,
	end_date = end_date,
	last_updated_date = NOW(),
	voided = ob.voided;
	
/*Insertion in patient_pregnancy table where (Date Probable d’accouchement)/ Lieu is filled
	*/
	INSERT INTO patient_pregnancy(patient_id,encounter_id,start_date,last_updated_date, voided)
	SELECT DISTINCT ob.person_id,ob.encounter_id,DATE(enc.encounter_datetime) AS start_date, NOW(), ob.voided
	FROM openmrs.obs ob, openmrs.encounter enc, 
	openmrs.encounter_type ent
	WHERE ob.encounter_id = enc.encounter_id
	AND enc.encounter_type = ent.encounter_type_id
        AND ob.concept_id IN(7957,159758)
	AND ob.value_coded = 1589
	AND (ob.comments IS NOT NULL AND ob.comments <> "")
	AND ent.uuid IN("5c312603-25c1-4dbe-be18-1a167eb85f97","49592bec-dd22-4b6c-a97f-4dd2af6f2171")
	ON DUPLICATE KEY UPDATE
	start_date = start_date,
	last_updated_date = NOW(),
	voided = ob.voided;
	
/*Insertion in patient_pregnancy table where Suivi et planification/
	- Semaine de Gestation is filled
	- Rythme cardiaque fœtal is filled
	- Hauteur utérine 
	*/
	INSERT INTO patient_pregnancy(patient_id,encounter_id,start_date,last_updated_date, voided)
	SELECT DISTINCT ob.person_id,ob.encounter_id,DATE(enc.encounter_datetime) AS start_date, NOW(), ob.voided
	FROM openmrs.obs ob, openmrs.encounter enc, 
	openmrs.encounter_type ent
	WHERE ob.encounter_id = enc.encounter_id
	AND enc.encounter_type = ent.encounter_type_id
        AND ob.concept_id IN(1438,1440,1439)
	AND ob.value_numeric > 0
	AND ent.uuid IN("5c312603-25c1-4dbe-be18-1a167eb85f97","49592bec-dd22-4b6c-a97f-4dd2af6f2171")
	ON DUPLICATE KEY UPDATE
	start_date = start_date,
	last_updated_date = NOW(),
	voided = ob.voided;
	
/*Patient_pregnancy - Insertion for Position*/
	INSERT INTO patient_pregnancy(patient_id,encounter_id,start_date,last_updated_date, voided)
	SELECT DISTINCT ob.person_id,ob.encounter_id,DATE(enc.encounter_datetime) AS start_date, NOW(), ob.voided
	FROM openmrs.obs ob, openmrs.encounter enc, 
	openmrs.encounter_type ent
	WHERE ob.encounter_id = enc.encounter_id
	AND enc.encounter_type = ent.encounter_type_id
        AND ob.concept_id = 163749
	AND ob.value_coded IN (5141,5139)
	AND ent.uuid IN("5c312603-25c1-4dbe-be18-1a167eb85f97","49592bec-dd22-4b6c-a97f-4dd2af6f2171")
	ON DUPLICATE KEY UPDATE
	start_date = start_date,
	last_updated_date = NOW(),
	voided = ob.voided;
	
/*Patient_pregnancy - Insertion for Présentation*/
	INSERT INTO patient_pregnancy(patient_id,encounter_id,start_date,last_updated_date, voided)
	SELECT DISTINCT ob.person_id,ob.encounter_id,DATE(enc.encounter_datetime) AS start_date, NOW(), ob.voided
	FROM openmrs.obs ob, openmrs.encounter enc, 
	openmrs.encounter_type ent
	WHERE ob.encounter_id = enc.encounter_id
	AND enc.encounter_type = ent.encounter_type_id
        AND ob.concept_id = 160090
	AND ob.value_coded IN (160001,139814,112259)
	AND ent.uuid IN("5c312603-25c1-4dbe-be18-1a167eb85f97","49592bec-dd22-4b6c-a97f-4dd2af6f2171")
	ON DUPLICATE KEY UPDATE
	start_date = start_date,
	last_updated_date = NOW(),
	voided = ob.voided;
	
/*Patient_pregnancy - Insertion for Position*/
	INSERT INTO patient_pregnancy(patient_id,encounter_id,start_date,last_updated_date, voided)
	SELECT DISTINCT ob.person_id,ob.encounter_id,DATE(enc.encounter_datetime) AS start_date, NOW(), ob.voided
	FROM openmrs.obs ob, openmrs.encounter enc, 
	openmrs.encounter_type ent
	WHERE ob.encounter_id = enc.encounter_id
	AND enc.encounter_type = ent.encounter_type_id
        AND ob.concept_id = 163750
	AND ob.value_coded IN (163748,163747)
	AND ent.uuid IN("5c312603-25c1-4dbe-be18-1a167eb85f97","49592bec-dd22-4b6c-a97f-4dd2af6f2171")
	ON DUPLICATE KEY UPDATE
	start_date = start_date,
	last_updated_date = NOW(),
	voided = ob.voided;
	
/* Patient_pregnancy updated date_stop for area DPA: <obs conceptId="CIEL:5596"/>*/
	UPDATE patient_pregnancy ppr,openmrs.obs ob
	SET end_date = DATE(ob.value_datetime)
	WHERE ppr.patient_id = ob.person_id
	AND ob.concept_id = 5596
	AND ob.voided = 0
	AND ppr.start_date < DATE(ob.value_datetime)
	AND ppr.end_date IS NULL;
	
/*Patient_pregnancy updated end_date for La date d’une fiche de travail et d’accouchement > a la date de début*/
	UPDATE patient_pregnancy ppr,openmrs.encounter enc, 
	openmrs.encounter_type etype
	SET end_date = DATE(enc.encounter_datetime)
	WHERE ppr.patient_id = enc.patient_id
	AND ppr.start_date < DATE(enc.encounter_datetime)
	AND ppr.end_date is null
	AND enc.encounter_type = etype.encounter_type_id
	AND enc.voided = 0
	AND etype.uuid = 'd95b3540-a39f-4d1e-a301-8ee0e03d5eab';
	
/*Patient_pregnancy updated for DDR – 3 mois + 7 jours=1427 */
	UPDATE patient_pregnancy ppr,openmrs.obs ob, openmrs.encounter enc
	SET end_date=DATE(ob.value_datetime) - INTERVAL 3 MONTH + INTERVAL 7 DAY + INTERVAL 1 YEAR
	WHERE ppr.patient_id=ob.person_id
	AND ob.person_id=enc.patient_id
	AND ob.concept_id=1427
	AND ob.voided = 0
	AND ppr.start_date <= DATE(enc.encounter_datetime) 
	AND ppr.end_date IS NULL;
	
/*update patient_pregnancy (Add 9 Months on the start_date 
	    for finding the end_date) */
    UPDATE patient_pregnancy ppr 
	SET ppr.end_date=ppr.start_date + INTERVAL 9 MONTH
	WHERE (TIMESTAMPDIFF(MONTH,ppr.start_date,DATE(NOW()))>=9)
	AND ppr.end_date IS NULL;
	
/*Ending insertion for patient_prenancy table*/
/*Starting insertion for alert (charge viral)*/
/*Insertion for Nombre de patient sous ARV depuis 6 mois sans un résultat de charge virale*/
	TRUNCATE TABLE alert;
	INSERT INTO alert(patient_id,id_alert,encounter_id,date_alert)
	SELECT DISTINCT B.patient_id,1,B.encounter_id, B.visit_date
	FROM isanteplus.patient p,
	(SELECT pdis.patient_id, pdis.encounter_id AS encounter_id, MIN(DATE(pdis.visit_date)) AS visit_date 
	FROM isanteplus.patient_dispensing pdis WHERE pdis.arv_drug = 1065 GROUP BY 1) B
	WHERE p.patient_id = B.patient_id
	AND p.date_started_arv = B.visit_date
	AND (TIMESTAMPDIFF(MONTH,DATE(p.date_started_arv),DATE(NOW())) >= 6)
	AND p.patient_id NOT IN(SELECT pl.patient_id FROM isanteplus.patient_laboratory pl
			WHERE pl.test_id IN(856, 1305) AND pl.test_done=1 AND pl.voided <> 1 AND ((pl.test_result IS NOT NULL) OR (pl.test_result <> '')))
	AND p.patient_id NOT IN (SELECT enc.patient_id FROM openmrs.encounter enc, openmrs.encounter_type et 
				WHERE enc.encounter_type = et.encounter_type_id AND et.uuid = '9d0113c6-f23a-4461-8428-7e9a7344f2ba'
				AND enc.patient_id IN (SELECT dr.patient_id FROM isanteplus.discontinuation_reason dr))
	AND p.vih_status = 1;
	
/*Insertion for Nombre de femmes enceintes, sous ARV depuis 4 mois sans un résultat de charge virale*/		
	INSERT INTO alert(patient_id,id_alert,encounter_id,date_alert)		
	SELECT DISTINCT B.patient_id,2,B.encounter_id, B.visit_date
	FROM isanteplus.patient p,
	(SELECT pdis.patient_id, pdis.encounter_id AS encounter_id, MIN(DATE(pdis.visit_date)) AS visit_date 
	FROM isanteplus.patient_dispensing pdis WHERE pdis.arv_drug = 1065 GROUP BY 1) B,
	isanteplus.patient_pregnancy pp
	WHERE p.patient_id = B.patient_id
	AND p.date_started_arv = B.visit_date
	AND p.patient_id = pp.patient_id
	AND (TIMESTAMPDIFF(MONTH,DATE(p.date_started_arv),DATE(NOW())) >= 4)
	AND p.patient_id NOT IN(SELECT pl.patient_id FROM isanteplus.patient_laboratory pl
			WHERE pl.test_id IN(856, 1305) AND pl.test_done=1 AND pl.voided <> 1 AND ((pl.test_result IS NOT NULL) OR (pl.test_result <> '')))
	AND p.patient_id NOT IN (SELECT enc.patient_id FROM openmrs.encounter enc, openmrs.encounter_type et 
				WHERE enc.encounter_type = et.encounter_type_id AND et.uuid = '9d0113c6-f23a-4461-8428-7e9a7344f2ba'
				AND enc.patient_id IN (SELECT dr.patient_id FROM isanteplus.discontinuation_reason dr))
	AND p.vih_status = 1;
	
/*Insertion for Nombre de patients ayant leur dernière charge virale remontant à au moins 12 mois*/
	INSERT INTO alert(patient_id,id_alert,encounter_id,date_alert)		
	SELECT DISTINCT plab.patient_id,3,plab.encounter_id, IFNULL(DATE(plab.date_test_done),DATE(plab.visit_date))
	FROM isanteplus.patient p, isanteplus.patient_laboratory plab,
	(SELECT pl.patient_id, MAX(IFNULL(DATE(date_test_done),DATE(pl.visit_date))) AS visit_date FROM isanteplus.patient_laboratory pl
			WHERE pl.test_id IN(856, 1305) AND pl.test_done=1 AND pl.voided <> 1 
			AND ((pl.test_result IS NOT NULL) OR (pl.test_result <> '')) GROUP BY 1) C,
			isanteplus.patient_on_arv parv
	WHERE p.patient_id = plab.patient_id
	AND plab.patient_id = C.patient_id
	AND IFNULL(DATE(plab.date_test_done),DATE(plab.visit_date)) = C.visit_date
	AND p.patient_id = parv.patient_id
	AND (TIMESTAMPDIFF(MONTH,DATE(C.visit_date),DATE(NOW())) >= 12)
	AND p.patient_id NOT IN (SELECT enc.patient_id FROM openmrs.encounter enc, openmrs.encounter_type et 
				WHERE enc.encounter_type = et.encounter_type_id AND et.uuid = '9d0113c6-f23a-4461-8428-7e9a7344f2ba'
				AND enc.patient_id IN (SELECT dr.patient_id FROM isanteplus.discontinuation_reason dr))
	AND p.vih_status = 1;
	
/*Insertion for Nombre de patients ayant leur dernière charge virale remontant à au moins 3 mois et dont le résultat était > 1000 copies/ml*/
	INSERT INTO alert(patient_id,id_alert,encounter_id,date_alert)		
	SELECT DISTINCT plab.patient_id,4,plab.encounter_id, IFNULL(DATE(plab.date_test_done),DATE(plab.visit_date))
	FROM isanteplus.patient p, isanteplus.patient_laboratory plab,
	(SELECT pl.patient_id, MAX(IFNULL(DATE(date_test_done),DATE(pl.visit_date))) AS visit_date FROM isanteplus.patient_laboratory pl
			WHERE pl.test_id IN(856, 1305) AND pl.test_done=1 AND pl.voided <> 1 
			AND ((pl.test_result IS NOT NULL) OR (pl.test_result <> '')) GROUP BY 1) C,
			isanteplus.patient_on_arv parv
	WHERE p.patient_id = plab.patient_id
	AND plab.patient_id = C.patient_id
	AND IFNULL(DATE(plab.date_test_done),DATE(plab.visit_date)) = C.visit_date
	AND p.patient_id = parv.patient_id
	AND (TIMESTAMPDIFF(MONTH,DATE(C.visit_date),DATE(NOW())) > 3)
	AND plab.test_result > 1000
	AND p.patient_id NOT IN (SELECT enc.patient_id FROM openmrs.encounter enc, openmrs.encounter_type et 
				WHERE enc.encounter_type = et.encounter_type_id AND et.uuid = '9d0113c6-f23a-4461-8428-7e9a7344f2ba'
				AND enc.patient_id IN (SELECT dr.patient_id FROM isanteplus.discontinuation_reason dr))
	AND p.vih_status = 1;
	
/*patient avec une dernière charge viral >1000 copies/ml*/
	INSERT INTO alert(patient_id,id_alert,encounter_id,date_alert)		
	SELECT DISTINCT plab.patient_id,5,plab.encounter_id, IFNULL(DATE(plab.date_test_done),DATE(plab.visit_date))
	FROM isanteplus.patient p, isanteplus.patient_laboratory plab,
	(SELECT pl.patient_id, MAX(IFNULL(DATE(date_test_done),DATE(pl.visit_date))) AS visit_date FROM isanteplus.patient_laboratory pl
			WHERE pl.test_id IN(856, 1305) AND pl.test_done=1 AND pl.voided <> 1 
			AND ((pl.test_result IS NOT NULL) OR (pl.test_result <> '')) GROUP BY 1) C,
			isanteplus.patient_on_arv parv
	WHERE p.patient_id = plab.patient_id
	AND plab.patient_id = C.patient_id
	AND IFNULL(DATE(plab.date_test_done),DATE(plab.visit_date)) = C.visit_date
	AND p.patient_id = parv.patient_id
	AND plab.test_result > 1000
	AND p.patient_id NOT IN (SELECT enc.patient_id FROM openmrs.encounter enc, openmrs.encounter_type et 
				WHERE enc.encounter_type = et.encounter_type_id AND et.uuid = '9d0113c6-f23a-4461-8428-7e9a7344f2ba'
				AND enc.patient_id IN (SELECT dr.patient_id FROM isanteplus.discontinuation_reason dr))
	AND p.vih_status = 1;
	
/*Tout patient dont la prochaine date de dispensation (next_disp) arrive dans les 30 
	prochains jours par rapport à la date de consultation actuelle*/
	
	INSERT INTO alert(patient_id,id_alert,encounter_id,date_alert)
	SELECT DISTINCT pdisp.patient_id,7,pdisp.encounter_id, DATE(pdisp.visit_date)
	FROM isanteplus.patient p, isanteplus.patient_dispensing pdisp,
	(SELECT pd.patient_id, MAX(pd.next_dispensation_date) AS next_dispensation_date 
	FROM isanteplus.patient_dispensing pd WHERE pd.arv_drug = 1065 AND 
	(pd.rx_or_prophy <> 163768 OR pd.rx_or_prophy IS NULL) AND pd.voided <> 1 GROUP BY 1) B
	WHERE p.patient_id = pdisp.patient_id
	AND pdisp.patient_id = B.patient_id
	AND pdisp.next_dispensation_date = B.next_dispensation_date
	AND DATEDIFF(pdisp.next_dispensation_date,NOW()) BETWEEN 0 AND 30
	AND p.patient_id NOT IN (SELECT enc.patient_id FROM openmrs.encounter enc, openmrs.encounter_type et 
				WHERE enc.encounter_type = et.encounter_type_id AND et.uuid = '9d0113c6-f23a-4461-8428-7e9a7344f2ba'
				AND enc.patient_id IN (SELECT dr.patient_id FROM isanteplus.discontinuation_reason dr));
	
/*Tout patient dont la prochaine date de dispensation (next_disp) se situe 
	dans le passe par rapport à la date de consultation actuelle*/
	
	INSERT INTO alert(patient_id,id_alert,encounter_id,date_alert)
	SELECT DISTINCT pdisp.patient_id,7,pdisp.encounter_id, DATE(pdisp.visit_date)
	FROM isanteplus.patient p, isanteplus.patient_dispensing pdisp,
	(SELECT pd.patient_id, MAX(pd.next_dispensation_date) AS next_dispensation_date 
	FROM isanteplus.patient_dispensing pd WHERE pd.arv_drug = 1065 AND 
	(pd.rx_or_prophy <> 163768 OR pd.rx_or_prophy IS NULL) AND pd.voided <> 1 GROUP BY 1) B
	WHERE p.patient_id = pdisp.patient_id
	AND pdisp.patient_id = B.patient_id
	AND pdisp.next_dispensation_date = B.next_dispensation_date
	AND DATEDIFF(B.next_dispensation_date,NOW()) < 0
	AND p.patient_id NOT IN (SELECT enc.patient_id FROM openmrs.encounter enc, openmrs.encounter_type et 
				WHERE enc.encounter_type = et.encounter_type_id AND et.uuid = '9d0113c6-f23a-4461-8428-7e9a7344f2ba');
	
/*patients sous ARV depuis 5 mois sans un résultat de charge virale*/
	INSERT INTO alert(patient_id,id_alert,encounter_id,date_alert)
	SELECT DISTINCT B.patient_id,8,B.encounter_id, B.visit_date
	FROM isanteplus.patient p,
	(SELECT pdis.patient_id, pdis.encounter_id AS encounter_id, MIN(DATE(pdis.visit_date)) AS visit_date 
	FROM isanteplus.patient_dispensing pdis WHERE pdis.arv_drug = 1065 GROUP BY 1) B
	WHERE p.patient_id = B.patient_id
	AND p.date_started_arv = B.visit_date
	AND (TIMESTAMPDIFF(MONTH,DATE(p.date_started_arv),DATE(NOW())) = 5)
	AND p.patient_id NOT IN(SELECT pl.patient_id FROM isanteplus.patient_laboratory pl
			WHERE pl.test_id IN(856, 1305) AND pl.test_done=1 AND pl.voided <> 1 AND ((pl.test_result IS NOT NULL) OR (pl.test_result <> '')))
	AND p.patient_id NOT IN (SELECT enc.patient_id FROM openmrs.encounter enc, openmrs.encounter_type et 
				WHERE enc.encounter_type = et.encounter_type_id AND et.uuid = '9d0113c6-f23a-4461-8428-7e9a7344f2ba')
	AND p.vih_status = 1;
/*Ending insertion for alert*/
/*Part of patient_diagnosis*/
/*insertion of all diagnosis in the table patient_diagnosis*/
INSERT into patient_diagnosis
		(
		 patient_id,
		 encounter_id,
		 location_id,
		 concept_group,
		 obs_group_id,
		 concept_id,
		 answer_concept_id,
		 voided
		)
		select distinct ob.person_id,ob.encounter_id,
		ob.location_id,ob1.concept_id,ob.obs_group_id,ob.concept_id, ob.value_coded, ob.voided
		from openmrs.obs ob, openmrs.obs ob1, openmrs.encounter e, openmrs.encounter_type et
		where ob.person_id = ob1.person_id
		AND ob.encounter_id = ob1.encounter_id
		AND ob.obs_group_id = ob1.obs_id
		AND ob.encounter_id = e.encounter_id
		AND e.encounter_type = et.encounter_type_id	
		AND ob.concept_id = 1284
		AND (ob.value_coded <> '' OR ob.value_coded is not null)
		AND et.uuid IN (
				'5c312603-25c1-4dbe-be18-1a167eb85f97',
				'49592bec-dd22-4b6c-a97f-4dd2af6f2171',
				'12f4d7c3-e047-4455-a607-47a40fe32460',
				'a5600919-4dde-4eb8-a45b-05c204af8284',
				'709610ff-5e39-4a47-9c27-a60e740b0944',
				'fdb5b14f-555f-4282-b4c1-9286addf0aae')
		on duplicate key update
		encounter_id = ob.encounter_id,
		voided = ob.voided;
		
/*update patient diagnosis for suspected_confirmed area*/					
	update patient_diagnosis pdiag, openmrs.obs ob
	 SET pdiag.suspected_confirmed = ob.value_coded
	 WHERE pdiag.patient_id = ob.person_id
		   AND pdiag.obs_group_id = ob.obs_group_id
		   AND pdiag.encounter_id = ob.encounter_id
		   AND ob.concept_id = 159394
		   AND ob.value_coded IN (159392,159393)
		   AND ob.voided = 0;
		   
/*Update for primary_secondary area*/
	update patient_diagnosis pdiag, openmrs.obs ob
	 SET pdiag.primary_secondary = ob.value_coded
	 WHERE pdiag.patient_id = ob.person_id
		   AND pdiag.obs_group_id = ob.obs_group_id
		   AND pdiag.encounter_id = ob.encounter_id
		   AND ob.concept_id = 159946
		   AND ob.value_coded IN (159943,159944)
		   AND ob.voided = 0;
		   
/*Update encounter date for patient_diagnosis*/	   
	update patient_diagnosis pdiag, openmrs.encounter enc
	SET pdiag.encounter_date = DATE(enc.encounter_datetime)
	WHERE pdiag.location_id = enc.location_id
	AND pdiag.encounter_id = enc.encounter_id
	AND enc.voided = 0;
	
/*Ending patient_diagnosis*/
/*Part of visit_type*/
/*Insertion for the type of the visit_type
Gynécologique=160456,Prénatale=1622,Postnatale=1623,Planification familiale=5483
*/
INSERT INTO visit_type(patient_id,encounter_id,location_id,
visit_id,concept_id,v_type,encounter_date, last_updated_date, voided)
SELECT ob.person_id, ob.encounter_id,ob.location_id, enc.visit_id,
 ob.concept_id,ob.value_coded, DATE(enc.encounter_datetime), NOW(), ob.voided
 FROM openmrs.obs ob, openmrs.encounter enc
 WHERE ob.encounter_id=enc.encounter_id
 AND ob.concept_id=160288
 AND ob.value_coded IN (160456,1622,1623,5483)
 ON DUPLICATE KEY UPDATE
 encounter_id = ob.encounter_id,
 last_updated_date = NOW(),
 voided = ob.voided;
 
/*End part of visit_type*/
/*Part of patient_delivery table*/
/* Insertion for table patient_delivery */
	INSERT INTO patient_delivery
		(
		 patient_id,
		 encounter_id,
		 location_id,
		 delivery_location,
		 encounter_date,
		 last_updated_date,
		 voided
		)
		SELECT DISTINCT ob.person_id,ob.encounter_id,
		ob.location_id,ob.value_coded, DATE(enc.encounter_datetime), NOW(), ob.voided
		FROM openmrs.obs ob, openmrs.encounter enc, 
		openmrs.encounter_type ent
		WHERE ob.encounter_id=enc.encounter_id
		AND enc.encounter_type=ent.encounter_type_id
		AND ob.concept_id=1572
		AND ob.value_coded IN(163266,1501,1502,5622)
		AND ent.uuid="d95b3540-a39f-4d1e-a301-8ee0e03d5eab"
		ON DUPLICATE KEY UPDATE
		delivery_location = ob.value_coded,
		last_updated_date = NOW(),
		voided = ob.voided;

	UPDATE patient_delivery pdel, openmrs.obs ob
	 SET pdel.delivery_date=ob.value_datetime
	 WHERE ob.concept_id=5599
	   AND pdel.encounter_id=ob.encounter_id
	   AND pdel.location_id=ob.location_id
	   AND ob.voided = 0;

/*END of Insertion for table patient_delivery*/
/*Part of virological_tests table*/
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
		from openmrs.obs ob, openmrs.obs ob1, openmrs.concept c
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
	UPDATE virological_tests vtests, openmrs.obs ob
	 SET vtests.test_result=ob.value_coded
	 WHERE ob.concept_id=1030
	   AND vtests.obs_group_id=ob.obs_group_id
	   AND vtests.encounter_id=ob.encounter_id
	   AND vtests.location_id=ob.location_id
	   AND ob.voided = 0;
	   
/*Update for area age for PCR*/
	UPDATE virological_tests vtests, openmrs.obs ob
	 SET vtests.age=ob.value_numeric
	 WHERE ob.concept_id=163540
	   AND vtests.obs_group_id=ob.obs_group_id
	   AND vtests.encounter_id=ob.encounter_id
	   AND vtests.location_id=ob.location_id
	   AND ob.voided = 0;
	   
/*Update for age_unit for PCR*/
	UPDATE virological_tests vtests, openmrs.obs ob
	 SET vtests.age_unit=ob.value_coded
	 WHERE ob.concept_id=163541
	   AND vtests.obs_group_id=ob.obs_group_id
	   AND vtests.encounter_id=ob.encounter_id
	   AND vtests.location_id=ob.location_id
	   AND ob.voided = 0;
	   
/*Update encounter date for virological_tests*/	   
	UPDATE virological_tests vtests, openmrs.encounter enc
    SET vtests.encounter_date=DATE(enc.encounter_datetime)
    WHERE vtests.location_id=enc.location_id
          AND vtests.encounter_id=enc.encounter_id
		  AND enc.voided = 0;
		  
/*Update to fill test_date area*/
	UPDATE virological_tests vtests, patient p 
	SET vtests.test_date =
	CASE WHEN(vtests.age_unit=1072 AND (ADDDATE(DATE(p.birthdate), INTERVAL vtests.age DAY) < DATE(NOW()))) 
	THEN ADDDATE(DATE(p.birthdate), INTERVAL vtests.age DAY)
	WHEN(vtests.age_unit=1074
	AND (ADDDATE(DATE(p.birthdate), INTERVAL vtests.age MONTH) < DATE(NOW()))) THEN ADDDATE(DATE(p.birthdate), INTERVAL vtests.age MONTH)
	ELSE
		vtests.encounter_date
	END
	WHERE vtests.patient_id = p.patient_id
	AND vtests.test_id = 162087
	AND answer_concept_id = 1030;
/*END of virological_tests table*/
/*Part of pediatric_hiv_visit table*/
/*Insertion for pediatric_hiv_visit */
	INSERT INTO pediatric_hiv_visit
		(
		 patient_id,
		 encounter_id,
		 location_id,
		 encounter_date,
		 voided
		)
		SELECT DISTINCT ob.person_id,ob.encounter_id,
		ob.location_id,DATE(enc.encounter_datetime), ob.voided
		FROM openmrs.obs ob, openmrs.encounter enc, 
		openmrs.encounter_type ent
		WHERE ob.encounter_id=enc.encounter_id
		AND enc.encounter_type=ent.encounter_type_id
                AND ob.concept_id IN(163776,5665,1401)
		AND (ent.uuid="349ae0b4-65c1-4122-aa06-480f186c8350"
		OR ent.uuid="33491314-c352-42d0-bd5d-a9d0bffc9bf1")
		ON DUPLICATE KEY UPDATE
		encounter_id = ob.encounter_id,
		voided = ob.voided;
		
/*update for ptme*/
	UPDATE pediatric_hiv_visit pv, openmrs.obs ob
	 SET pv.ptme=ob.value_coded
	 WHERE ob.concept_id=163776
	   AND pv.encounter_id=ob.encounter_id
	   AND pv.location_id=ob.location_id
	   AND ob.voided = 0;
	   
/*update for prophylaxie72h*/
	UPDATE pediatric_hiv_visit pv, openmrs.obs ob
	 SET pv.prophylaxie72h=ob.value_coded
	 WHERE ob.concept_id=5665
	   AND pv.encounter_id=ob.encounter_id
	   AND pv.location_id=ob.location_id
	   AND ob.voided = 0;
	   
/*update for actual_vih_status*/
	UPDATE pediatric_hiv_visit pv, openmrs.obs ob
	 SET pv.actual_vih_status=ob.value_coded
	 WHERE ob.concept_id=1401
		   AND pv.encounter_id=ob.encounter_id
		   AND pv.location_id=ob.location_id
		   AND ob.voided = 0;
		   
/*End of pediatric_hiv_visit table*/
/*Starting Insertion for table patient_menstruation*/
	/*Insertion for patient_menstruation*/
	INSERT INTO patient_menstruation
			(
			 patient_id,
			 encounter_id,
			 location_id,
			 encounter_date,
			 last_updated_date,
			 voided
			)
		SELECT DISTINCT ob.person_id,ob.encounter_id,
		ob.location_id,DATE(enc.encounter_datetime), NOW(), ob.voided
		FROM openmrs.obs ob, openmrs.encounter enc, 
		openmrs.encounter_type ent
		WHERE ob.encounter_id=enc.encounter_id
		AND enc.encounter_type=ent.encounter_type_id
               AND ob.concept_id IN(163732,160597,1427)
		AND (ent.uuid="5c312603-25c1-4dbe-be18-1a167eb85f97"
		OR ent.uuid="49592bec-dd22-4b6c-a97f-4dd2af6f2171")
		ON DUPLICATE KEY UPDATE
		encounter_id = ob.encounter_id,
		last_updated_date = NOW(),
		voided = ob.voided;
		
/*Update table patient_menstruation for having the 
	DDR (DATE de Derniere Regle) value date*/
	UPDATE patient_menstruation pm, openmrs.obs ob
	 SET pm.ddr=DATE(ob.value_datetime)
	 WHERE ob.concept_id=1427
	   AND pm.encounter_id=ob.encounter_id
	   AND pm.location_id=ob.location_id
	   AND ob.voided = 0;
	
/*Starting insertion for table vih_risk_factor*/
	
/*Insertion for risks factor*/
	INSERT INTO vih_risk_factor
		(
		 patient_id,
		 encounter_id,
		 location_id,
		 risk_factor,
		 encounter_date,
		 last_updated_date,
		 voided
		)
		SELECT DISTINCT ob.person_id,ob.encounter_id,
		ob.location_id,ob.value_coded,
		DATE(enc.encounter_datetime), NOW(), ob.voided
		FROM openmrs.obs ob, openmrs.encounter enc, 
		openmrs.encounter_type ent
		WHERE ob.encounter_id=enc.encounter_id
		AND enc.encounter_type=ent.encounter_type_id
                AND ob.concept_id IN(1061,160581)
		AND ob.value_coded IN (163290,163291,105,1063,163273,163274,163289,163275,5567,159218)
		AND ent.uuid IN('17536ba6-dd7c-4f58-8014-08c7cb798ac7',
		'349ae0b4-65c1-4122-aa06-480f186c8350')
		ON DUPLICATE KEY UPDATE
		encounter_id = ob.encounter_id,
		last_updated_date = NOW(),
		voided = ob.voided;
	
/*Insertion for risks factor for other risks*/
	INSERT INTO vih_risk_factor
		(
		 patient_id,
		 encounter_id,
		 location_id,
		 risk_factor,
		 encounter_date,
		 last_updated_date,
		 voided
		)
		SELECT DISTINCT ob.person_id,ob.encounter_id,
		ob.location_id,ob.concept_id,
		DATE(enc.encounter_datetime), NOW(), ob.voided
		FROM openmrs.obs ob, openmrs.encounter enc,
		openmrs.encounter_type ent
		WHERE ob.encounter_id=enc.encounter_id
		AND enc.encounter_type=ent.encounter_type_id
		AND ob.concept_id IN(123160,156660,163276,163278,160579,160580)
		AND ob.value_coded = 1065
		AND ent.uuid IN('17536ba6-dd7c-4f58-8014-08c7cb798ac7',
			'349ae0b4-65c1-4122-aa06-480f186c8350')
		ON DUPLICATE KEY UPDATE
		encounter_id = ob.encounter_id,
		last_updated_date = NOW(),
		voided = ob.voided;
						
/*End of insertion for vih_risk_factor*/
	
/*End of Insertion for table patient_menstruation*/


/*Starting insertion for table vaccination*/
      INSERT INTO vaccination(
        patient_id,
        encounter_id,
        encounter_date,
        location_id,
		voided
      )
      SELECT DISTINCT ob.person_id, ob.encounter_id, enc.encounter_datetime, ob.location_id, ob.voided
      FROM openmrs.obs ob, openmrs.encounter enc, openmrs.encounter_type ent
      WHERE ob.encounter_id=enc.encounter_id
        AND enc.encounter_type=ent.encounter_type_id
        AND ob.concept_id=984
		ON DUPLICATE KEY UPDATE
		encounter_id = ob.encounter_id,
		voided = ob.voided;

/*Create temporary table for query vaccination dates*/
      CREATE TABLE temp_vaccination (
        person_id INT(11),
        value_coded INT(11),
        dose INT(11),
        obs_group_id INT(11),
        obs_datetime DATETIME,
        encounter_id INT(11)
      );

/*Set age range (day)*/
      UPDATE isanteplus.vaccination v, isanteplus.patient p
      SET v.age_range=
        CASE
          WHEN (
          TIMESTAMPDIFF(DAY, p.birthdate, v.encounter_date) BETWEEN 0 AND 45
          ) THEN 45
          WHEN TIMESTAMPDIFF(DAY, p.birthdate, v.encounter_date) BETWEEN 46 AND 75
            THEN 75
          WHEN TIMESTAMPDIFF(DAY, p.birthdate, v.encounter_date) BETWEEN 76 AND 105
            THEN 105
          WHEN TIMESTAMPDIFF(DAY, p.birthdate, v.encounter_date) BETWEEN 106 AND 270
            THEN 270
          ELSE NULL
        END
      WHERE v.patient_id = p.patient_id;

/*Query for receive vaccination dates*/
      INSERT INTO temp_vaccination (person_id, value_coded, dose, obs_group_id, obs_datetime, encounter_id)
      SELECT ob.person_id, ob.value_coded, ob2.value_numeric, ob.obs_group_id, ob.obs_datetime, ob.encounter_id
      FROM openmrs.obs ob, openmrs.obs ob2
      WHERE ob2.obs_group_id = ob.obs_group_id
        AND ob2.concept_id=1418
        AND ob.concept_id=984
		AND ob.voided = 0;

/*Update vaccination table for children 0-45 days old*/
      UPDATE isanteplus.vaccination v
      SET v.vaccination_done = TRUE
      WHERE v.age_range=45
        AND (
          ( -- Scenario A 0-45
            3 = (SELECT COUNT(tv.person_id) FROM temp_vaccination tv WHERE tv.encounter_id=v.encounter_id AND tv.dose=1 AND tv.value_coded IN (783, 1423, 83531))
          )
          OR ( -- Scenario B 0-45
            5 = (SELECT COUNT(tv.person_id) FROM temp_vaccination tv WHERE tv.encounter_id=v.encounter_id AND tv.dose=1 AND tv.value_coded IN (781, 782, 783, 5261, 83531))
          )
        );

/*Update vaccination table for children 46-75 days old*/
      UPDATE isanteplus.vaccination v
      SET v.vaccination_done = TRUE
      WHERE v.age_range=75
        AND (
          ( -- Scenario A 46-75
            -- Dose 1
            3 = (SELECT COUNT(tv.person_id) FROM temp_vaccination tv WHERE tv.encounter_id=v.encounter_id AND tv.dose=1 AND tv.value_coded IN (783, 1423, 83531))
            -- Dose 2
            AND 3 = (SELECT COUNT(tv.person_id) FROM temp_vaccination tv WHERE tv.encounter_id=v.encounter_id AND tv.dose=2 AND tv.value_coded IN (783, 1423, 83531))
          )
          OR ( -- Scenario B 46-75
            -- Dose 1
            5 = (SELECT  COUNT(tv.person_id) FROM temp_vaccination tv WHERE tv.encounter_id=v.encounter_id AND tv.dose=1 AND tv.value_coded IN (781, 782, 783, 5261, 83531))
            -- Dose 2
            AND 5 = (SELECT  COUNT(tv.person_id) FROM temp_vaccination tv WHERE tv.encounter_id=v.encounter_id AND tv.dose=2 AND tv.value_coded IN (781, 782, 783, 5261, 83531))
          )
        );

/*Update vaccination table for children 76-105 days old*/
      UPDATE isanteplus.vaccination v
      SET v.vaccination_done = TRUE
      WHERE v.age_range=105
        AND (
          ( -- Scenario A 76-105
            -- Dose 1
            3 = (SELECT COUNT(tv.person_id) FROM temp_vaccination tv WHERE tv.encounter_id=v.encounter_id AND tv.dose=1 AND tv.value_coded IN (783, 1423, 83531))
            -- Dose 2
            AND 3 = (SELECT COUNT(tv.person_id) FROM temp_vaccination tv WHERE tv.encounter_id=v.encounter_id AND tv.dose=2 AND tv.value_coded IN (783, 1423, 83531))
            -- Dose 3
            AND 2 = (SELECT COUNT(tv.person_id) FROM temp_vaccination tv WHERE tv.encounter_id=v.encounter_id AND tv.dose=2 AND tv.value_coded IN (783, 1423))
          )
          OR ( -- Scenario B 76-105
            -- Dose 1
            5 = (SELECT  COUNT(tv.person_id) FROM temp_vaccination tv WHERE tv.encounter_id=v.encounter_id AND tv.dose=1 AND tv.value_coded IN (781, 782, 783, 5261, 83531))
            -- Dose 2
            AND 5 = (SELECT  COUNT(tv.person_id) FROM temp_vaccination tv WHERE tv.encounter_id=v.encounter_id AND tv.dose=2 AND tv.value_coded IN (781, 782, 783, 5261, 83531))
            -- Dose 3
            AND 4 = (SELECT  COUNT(tv.person_id) FROM temp_vaccination tv WHERE tv.encounter_id=v.encounter_id AND tv.dose=3 AND tv.value_coded IN (781, 782, 783, 5261))
          )
        );

/*Update vaccination table for children 106-270 days old*/
      UPDATE isanteplus.vaccination v
      SET v.vaccination_done = TRUE
      WHERE v.age_range=270
      AND (
        ( -- Scenario A 106-270
          -- Dose 1
          3 = (SELECT  COUNT(tv.person_id) FROM temp_vaccination tv WHERE tv.encounter_id=v.encounter_id AND tv.dose=1 AND tv.value_coded IN (783, 1423, 83531))
          AND (
            159701 IN (SELECT tv.value_coded FROM temp_vaccination tv WHERE tv.encounter_id=v.encounter_id AND tv.dose=1)
            OR 162586 IN (SELECT tv.value_coded FROM temp_vaccination tv WHERE tv.encounter_id=v.encounter_id AND tv.dose=1)
          )
          -- Dose 2
          AND 3 = (SELECT  COUNT(tv.person_id) FROM temp_vaccination tv WHERE tv.encounter_id=v.encounter_id AND tv.dose=2 AND tv.value_coded IN (783, 1423, 83531))
          AND ((
              159701 IN (SELECT tv.value_coded FROM temp_vaccination tv WHERE tv.encounter_id=v.encounter_id AND tv.dose=2)
              AND 159701 IN (SELECT tv.value_coded FROM temp_vaccination tv WHERE tv.encounter_id=v.encounter_id AND tv.dose=1)
            ) OR (
              162586 IN (SELECT tv.value_coded FROM temp_vaccination tv WHERE tv.encounter_id=v.encounter_id AND tv.dose=1)
            )
          )
          -- Dose 3
          AND 2 = (SELECT  COUNT(tv.person_id) FROM temp_vaccination tv WHERE tv.encounter_id=v.encounter_id AND tv.dose=3 AND tv.value_coded IN (783, 1423))
        )
        OR ( -- Scenario B 106-270
          -- Dose 1
          5 = (SELECT  COUNT(tv.person_id) FROM temp_vaccination tv WHERE tv.encounter_id=v.encounter_id AND tv.dose=1 AND tv.value_coded IN (781, 782, 783, 5261, 83531))
          AND (
            159701 IN (SELECT tv.value_coded FROM temp_vaccination tv WHERE tv.encounter_id=v.encounter_id AND tv.dose=1)
            OR 162586 IN (SELECT tv.value_coded FROM temp_vaccination tv WHERE tv.encounter_id=v.encounter_id AND tv.dose=1)
          )
          -- Dose 2
          AND 5 = (SELECT  COUNT(tv.person_id) FROM temp_vaccination tv WHERE tv.encounter_id=v.encounter_id AND tv.dose=2 AND tv.value_coded IN (781, 782, 783, 5261, 83531))
          AND ((
              159701 IN (SELECT tv.value_coded FROM temp_vaccination tv WHERE tv.encounter_id=v.encounter_id AND tv.dose=2)
              AND 159701 IN (SELECT tv.value_coded FROM temp_vaccination tv WHERE tv.encounter_id=v.encounter_id AND tv.dose=1)
            ) OR (
              162586 IN (SELECT tv.value_coded FROM temp_vaccination tv WHERE tv.encounter_id=v.encounter_id AND tv.dose=1)
            )
          )
          -- Dose 3
          AND 4 = (SELECT  COUNT(tv.person_id) FROM temp_vaccination tv WHERE tv.encounter_id=v.encounter_id AND tv.dose=3 AND tv.value_coded IN (781, 782, 783, 5261))
        )
        );
      DROP TABLE IF EXISTS `temp_vaccination`;
    

	
/*Part of serological tests*/
INSERT into serological_tests
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
	from openmrs.obs ob, openmrs.obs ob1, openmrs.concept c
	where ob.person_id=ob1.person_id
	AND ob.encounter_id=ob1.encounter_id
	AND ob.obs_group_id=ob1.obs_id
	AND ob1.concept_id = c.concept_id
	AND c.uuid IN ('28e8ffc8-1b65-484c-baa1-929f0b8901a6',
			'6e3aa01c-8a70-42b6-94fe-6ac465b620d9',
			'2a66236f-d84b-4cc8-a552-15b12238e7ea',
			'121d7ed6-c039-465d-9663-4ab631232ba9',
			'ec6e3a54-3e4b-4647-b9bd-baf0d06a98d2',
			'99f7b98e-8900-4898-9772-a88f4783babd'
		)
/*AND ob1.concept_id=1361*/
	AND ob.concept_id=162087
	AND ob.value_coded IN(163722,1042)
	on duplicate key update
	encounter_id = ob.encounter_id,
	last_updated_date = now(),
	voided = ob.voided;
	
/*Update for area test_result for tests serologiques*/
	UPDATE serological_tests stests, openmrs.obs ob
	 SET stests.test_result=ob.value_coded
	 WHERE ob.concept_id=163722
		   AND stests.obs_group_id=ob.obs_group_id
		   AND stests.encounter_id=ob.encounter_id
		   AND stests.location_id=ob.location_id
		   AND ob.voided = 0;
		   
/*Update for area age for tests serologiques*/
	UPDATE serological_tests stests, openmrs.obs ob
	 SET stests.age=ob.value_numeric
	 WHERE ob.concept_id=163540
		   AND stests.obs_group_id=ob.obs_group_id
		   AND stests.encounter_id=ob.encounter_id
		   AND stests.location_id=ob.location_id
		   AND ob.voided = 0;
		   
/*Update for age_unit for tests serologiques*/
	UPDATE serological_tests stests, openmrs.obs ob
	 SET stests.age_unit=ob.value_coded
	 WHERE ob.concept_id=163541
		   AND stests.obs_group_id=ob.obs_group_id
		   AND stests.encounter_id=ob.encounter_id
		   AND stests.location_id=ob.location_id
		   AND ob.voided = 0;
		   
/*Update encounter date for serological_tests*/	   
	UPDATE serological_tests stests, openmrs.encounter enc
    SET stests.encounter_date=DATE(enc.encounter_datetime)
    WHERE stests.location_id=enc.location_id
          AND stests.encounter_id=enc.encounter_id;
/*End serological tests*/
	
/*Update to fill test_date area*/
	UPDATE serological_tests stests, patient p 
	SET stests.test_date =
	CASE WHEN(stests.age_unit=1072 AND (ADDDATE(DATE(p.birthdate), INTERVAL stests.age DAY) < DATE(NOW()))) 
	THEN ADDDATE(DATE(p.birthdate), INTERVAL stests.age DAY)
	WHEN(stests.age_unit=1074
	AND (ADDDATE(DATE(p.birthdate), INTERVAL stests.age MONTH) < DATE(NOW()))) THEN ADDDATE(DATE(p.birthdate), INTERVAL stests.age MONTH)
	ELSE
		stests.encounter_date
	END
	WHERE stests.patient_id = p.patient_id
	AND stests.test_id = 162087
	AND answer_concept_id IN(163722,1042);
	
/*END of virological_tests table*/
/*Insert pcr on patient_pcr*/
	TRUNCATE TABLE patient_pcr;
	INSERT INTO patient_pcr(patient_id,encounter_id,location_id,visit_date,pcr_result, test_date)
	SELECT DISTINCT pl.patient_id,pl.encounter_id,pl.location_id,pl.visit_date,pl.test_result,pl.date_test_done 
	FROM isanteplus.patient_laboratory pl
	WHERE pl.test_id = 844
	AND pl.test_done = 1
	AND pl.test_result IN(1301,1302,1300,1304);
	
	INSERT INTO patient_pcr(patient_id,encounter_id,location_id,visit_date,pcr_result, test_date)
	SELECT DISTINCT vt.patient_id,vt.encounter_id, vt.location_id, 
	vt.encounter_date,vt.test_result,vt.test_date
	FROM isanteplus.virological_tests vt
	WHERE vt.test_id = 162087
	AND vt.answer_concept_id = 1030
	AND vt.test_result IN (664,703,1138);

	-- START TRANSACTION;
	INSERT INTO isanteplus.patient_malaria (patient_id, encounter_type_id, encounter_id, location_id, last_updated_date, visit_id, visit_date, voided)
	SELECT DISTINCT 
		enc.patient_id,
		enct.encounter_type_id,
		enc.encounter_id,
		enc.location_id, 
		NOW(), 
		enc.visit_id,
		CAST(enc.encounter_datetime AS DATE),
		enc.voided
	FROM openmrs.encounter enc, openmrs.encounter_type enct
	WHERE enc.encounter_type=enct.encounter_type_id
	AND enct.uuid IN (
		'12f4d7c3-e047-4455-a607-47a40fe32460', -- Soins de santé primaire--premiére consultation (Adult intital consultation)
		'a5600919-4dde-4eb8-a45b-05c204af8284', -- Soins de santé primaire--consultation (Adult followp consultation)
		'709610ff-5e39-4a47-9c27-a60e740b0944', -- Soins de santé primaire--premiére con. p (Paeditric initial consultation)
		'fdb5b14f-555f-4282-b4c1-9286addf0aae', -- Soins de santé primaire--con. pédiatrique (Paediatric followup consultation)
		'49592bec-dd22-4b6c-a97f-4dd2af6f2171', -- Ob/gyn Suivi
		'5c312603-25c1-4dbe-be18-1a167eb85f97', -- Saisie Première ob/gyn
		'17536ba6-dd7c-4f58-8014-08c7cb798ac7', -- Saisie Première
		'204ad066-c5c2-4229-9a62-644bc5617ca2', -- Suivi Visite
		'349ae0b4-65c1-4122-aa06-480f186c8350', -- Saisie Première pédiatrique
		'f037e97b-471e-4898-a07c-b8e169e0ddc4' -- Analyses de Lab.
	)
	ON DUPLICATE KEY UPDATE
	encounter_id = enc.encounter_id,
	visit_date=CAST(enc.encounter_datetime AS DATE),
	last_updated_date = NOW(),
	voided = enc.voided;
		
/*Fever < 2 weeks*/    
	UPDATE isanteplus.patient_malaria pat, openmrs.obs o
	 SET pat.fever_for_less_than_2wks=1
	 WHERE pat.encounter_id=o.encounter_id
	 AND o.concept_id=159614
	 AND o.value_coded=163740
	 AND o.voided = 0;
	 
/*Suspected Malaria*/    
	UPDATE isanteplus.patient_malaria pat, openmrs.obs o
	 SET pat.suspected_malaria=1
	 WHERE pat.encounter_id=o.encounter_id
	 AND o.concept_id=6042 OR o.concept_id=6097
	 AND o.value_coded=116128
	 AND o.voided = 0;
	 
/*Confirmed Malaria*/    
	UPDATE isanteplus.patient_malaria pat, openmrs.obs o
	 SET pat.confirmed_malaria=1
	 WHERE pat.encounter_id=o.encounter_id
	 AND (o.concept_id=6042 OR o.concept_id=6097)
	 AND o.value_coded=160148
	 AND o.voided = 0;
	 
/*Treated with chloroquine*/    
	UPDATE isanteplus.patient_malaria pat, openmrs.obs o
	 SET pat.treated_with_chloroquine=1
	 WHERE pat.encounter_id=o.encounter_id
	 AND o.concept_id=1282
	 AND o.value_coded=73300
	 AND o.voided = 0;
	 
/*Treated with primaquine*/    
	UPDATE isanteplus.patient_malaria pat, openmrs.obs o
	 SET pat.treated_with_primaquine=1
	 WHERE pat.encounter_id=o.encounter_id
	 AND o.concept_id=1282
	 AND o.value_coded=82521
	 AND o.voided = 0;
	 
/*Treated with quinine*/    
	UPDATE isanteplus.patient_malaria pat, openmrs.obs o
	 SET pat.treated_with_quinine=1
	 WHERE pat.encounter_id=o.encounter_id
	 AND o.concept_id=1282
	 AND o.value_coded=83023
	 AND o.voided = 0;
	 
/*Microscopic Test*/    
	UPDATE isanteplus.patient_malaria pat, openmrs.obs o
	 SET pat.microscopic_test=1
	 WHERE pat.encounter_id=o.encounter_id
	 AND o.concept_id=1271
	 AND o.value_coded=1366
	 AND o.voided = 0;
	 
/*Positive Microscopic Test*/    
	UPDATE isanteplus.patient_malaria pat, openmrs.obs o
	 SET pat.positive_microscopic_test_result=1
	 WHERE pat.encounter_id=o.encounter_id
	 AND o.concept_id=1366
	 AND o.value_coded IN (1365, 1364, 1362, 1363)
	 AND o.voided = 0;
	 
/*Negative Microscopic Test*/    
	UPDATE isanteplus.patient_malaria pat, openmrs.obs o
	 SET pat.negative_microscopic_test_result=1
	 WHERE pat.encounter_id=o.encounter_id
	 AND o.concept_id=1366
	 AND o.value_coded=664
	 AND o.voided = 0;
	 
/*Positive plasmodium falciparum*/    
	UPDATE isanteplus.patient_malaria pat, openmrs.obs o
	 SET pat.positive_plasmodium_falciparum_test_result=1
	 WHERE pat.encounter_id=o.encounter_id
	 AND o.concept_id=1643
	 AND o.value_coded=161246
	 AND o.voided = 0;
 
/*Mixed Positive Microscopic Test*/    
	UPDATE isanteplus.patient_malaria pat, openmrs.obs o
	 SET pat.mixed_positive_test_result=1
	 WHERE pat.encounter_id=o.encounter_id
	 AND o.concept_id=1643
	 AND o.value_coded=161248
	 AND o.voided = 0;
	 
/*Positive plasmodium vivax*/    
	UPDATE isanteplus.patient_malaria pat, openmrs.obs o
	 SET pat.positive_plasmodium_vivax_test_result=1
	 WHERE pat.encounter_id=o.encounter_id
	 AND o.concept_id=1643
	 AND o.value_coded=161247
	 AND o.voided = 0;
	 
/*Rapid Malaria Test*/    
	UPDATE isanteplus.patient_malaria pat, openmrs.obs o
	 SET pat.rapid_test=1
	 WHERE pat.encounter_id=o.encounter_id
	 AND o.concept_id=1271
	 AND o.value_coded=1643
	 AND o.voided = 0;
	 
/*Positive Rapid Malaria Test*/    
	UPDATE isanteplus.patient_malaria pat, openmrs.obs o
	 SET pat.positve_rapid_test_result=1
	 WHERE pat.encounter_id=o.encounter_id
	 AND o.concept_id=1643
	 AND o.value_coded=703
	 AND o.voided = 0;
	 
/*Severe Malaria*/    
	UPDATE isanteplus.patient_malaria pat, openmrs.obs o
	 SET pat.severe_malaria=1
	 WHERE pat.encounter_id=o.encounter_id
	 AND o.concept_id=6042
	 AND o.value_coded=160155
	 AND o.voided = 0;
	 
/*Hospitalized*/    
	UPDATE isanteplus.patient_malaria pat, openmrs.obs o
	 SET pat.hospitallized=1
	 WHERE pat.encounter_id=o.encounter_id
	 AND o.concept_id=1272
	 AND o.value_coded=5485
	 AND o.voided = 0;
	 
/*Confirmed Malaria with pregnancy*/    
	UPDATE isanteplus.patient_malaria pat, openmrs.obs o
	 SET pat.confirmed_malaria_preganancy=1
	 WHERE pat.encounter_id=o.encounter_id
	 AND o.concept_id=160168
	 AND o.value_coded=160152
	 AND o.voided = 0;
	
/*Starting insertion for patient_on_art table*/
	INSERT INTO isanteplus.patient_on_art(patient_id)
	SELECT DISTINCT
	 pa.patient_id
	 FROM isanteplus.patient_on_arv pa
	 ON DUPLICATE KEY UPDATE 
	 patient_id = pa.patient_id ;
	 
	UPDATE isanteplus.patient_on_art par ,openmrs.obs o
	 SET par.date_completed_preventive_tb_treatment  = DATE (o.value_datetime) 
	 WHERE par.patient_id = o.person_id  
	 AND o.concept_id = 163284
	 AND o.voided = 0;
	 
	 UPDATE isanteplus.patient_on_art par ,openmrs.encounter_type et ,openmrs.encounter e
	 SET par.first_vist_date = DATE(e.encounter_datetime) 
	 WHERE  et.uuid IN ('204ad066-c5c2-4229-9a62-644bc5617ca2' , '33491314-c352-42d0-bd5d-a9d0bffc9bf1' )	 
	 AND et.encounter_type_id = e.encounter_type
	 AND e.patient_id = par.patient_id 
	 AND e.voided = 0 ;
	 
/*  
   UPDATE isanteplus.patient_on_art pat	 	 
	 SET pat.last_folowup_vist_date = (SELECT MAX(e.encounter_datetime)  FROM  openmrs.encounter_type et , openmrs.encounter e
	  WHERE et.uuid IN ('17536ba6-dd7c-4f58-8014-08c7cb798ac7' , '349ae0b4-65c1-4122-aa06-480f186c8350') 
	  AND et.encounter_type_id = e.encounter_type
	  AND e.patient_id =pat.patient_id 
	  AND e.voided = 0
	 ) ; */
	 
	  UPDATE isanteplus.patient_on_art pat,
	  (SELECT e.patient_id, MAX(e.encounter_datetime) as encounter_datetime
	  FROM  openmrs.encounter_type et , openmrs.encounter e
	  WHERE et.uuid IN ('17536ba6-dd7c-4f58-8014-08c7cb798ac7',
	  '349ae0b4-65c1-4122-aa06-480f186c8350') 
	  AND et.encounter_type_id = e.encounter_type
	  AND e.voided = 0 GROUP BY 1) B
	 SET pat.last_folowup_vist_date = B.encounter_datetime 
	 WHERE pat.patient_id = B.patient_id;
	 
/* UPDATE isanteplus.patient_on_art pat	
	 SET pat.second_last_folowup_vist_date = (SELECT MAX(e.encounter_datetime) 
	 FROM  openmrs.encounter e ,openmrs.encounter_type et  
	 WHERE et.uuid IN ('17536ba6-dd7c-4f58-8014-08c7cb798ac7' , '349ae0b4-65c1-4122-aa06-480f186c8350') 
	 AND  e.patient_id =pat.patient_id
	 AND et.encounter_type_id = e.encounter_type
	  AND e.voided = 0
	 AND e.encounter_datetime NOT IN (SELECT MAX(e.encounter_datetime) FROM openmrs.encounter_type et , openmrs.encounter e	
	 WHERE et.uuid IN ('17536ba6-dd7c-4f58-8014-08c7cb798ac7' , '349ae0b4-65c1-4122-aa06-480f186c8350') 
	 AND et.encounter_type_id = e.encounter_type
	 AND e.patient_id =pat.patient_id 
	  AND e.voided = 0	 
	 ) ) ; */
	  
	  UPDATE isanteplus.patient_on_art pat,
	  (SELECT e.patient_id, MAX(e.encounter_datetime) as encounter_datetime
	 FROM  openmrs.encounter e ,openmrs.encounter_type et  
	 WHERE et.uuid IN ('17536ba6-dd7c-4f58-8014-08c7cb798ac7',
	 '349ae0b4-65c1-4122-aa06-480f186c8350') 
	 AND et.encounter_type_id = e.encounter_type
	  AND e.voided = 0
	 AND e.encounter_datetime NOT IN (SELECT MAX(e.encounter_datetime) 
	 FROM openmrs.encounter_type et , openmrs.encounter e	
	 WHERE et.uuid IN ('17536ba6-dd7c-4f58-8014-08c7cb798ac7' , '349ae0b4-65c1-4122-aa06-480f186c8350') 
	 AND et.encounter_type_id = e.encounter_type 
	  AND e.voided = 0) GROUP BY 1) B
	 SET pat.second_last_folowup_vist_date = B.encounter_datetime
	 WHERE pat.patient_id = B.patient_id;
	 
	 
	  UPDATE isanteplus.patient_on_art pt, openmrs.obs o ,openmrs.concept c ,openmrs.encounter e	,openmrs.encounter_type etyp
	  SET pt.date_started_arv_for_transfered = DATE(o.obs_datetime)
	  WHERE o.concept_id = 159599 
	  AND o.encounter_id = e.encounter_id
	  AND e.encounter_type = etyp.encounter_type_id 
	  AND etyp.uuid = "17536ba6-dd7c-4f58-8014-08c7cb798ac7"
	  AND o.person_id = pt.patient_id 
	  AND o.voided =0;
	 
	 UPDATE isanteplus.patient_on_art pt, openmrs.obs o
	 SET pt.screened_cervical_cancer = (CASE WHEN o.value_coded = 151185 THEN 1 ELSE 0 END)  ,
	     pt.date_screened_cervical_cancer = DATE(o.obs_datetime) 
	 WHERE o.obs_group_id = 160714
	 AND o.concept_id = 1651
	 AND o.value_coded = 151185 
	 AND o.person_id = pt.patient_id
	 AND o.value_coded = 0 
	 AND o.voided =0 ;
	 
	 UPDATE isanteplus.patient_on_art pt , openmrs.obs o
	 SET pt.cervical_cancer_status = (CASE WHEN o.value_coded = 1115 THEN 'NEGATIVE'
	                                       WHEN o.value_coded = 1116 THEN 'POSTIVE'
										   WHEN o.value_coded =1117 THEN 'UNKNOWN' END ) ,
		  pt.date_started_cervical_cancer_status = DATE(o.obs_datetime)  											     
	 WHERE o.concept_id = 160704 
	 AND o.person_id = pt.patient_id
	 AND o.voided =0 ;
	 
	 UPDATE isanteplus.patient_on_art pt , openmrs.obs o
	 SET pt.cervical_cancer_treatment  = (CASE WHEN o.value_coded = 162812 THEN 'CRYOTHERAPY'
	                                       WHEN o.value_coded = 162810 THEN 'LEEP'
										   WHEN o.value_coded =163408 THEN 'THERMOCOAGULATION' END ) ,
		  pt.date_cervical_cancer_treatment = DATE(o.obs_datetime)  											     
	 WHERE o.concept_id = 1651 
	 AND o.person_id = pt.patient_id
	 AND o.voided =0 ;
	
	 UPDATE isanteplus.patient_on_art pt, openmrs.obs o ,openmrs.concept c
	 SET pt.date_started_breast_feeding = DATE(o.obs_datetime)
	 WHERE o.concept_id = c.concept_id 
	 AND o.person_id = pt.patient_id
	 AND c.uuid = '7e0f24aa-4f8e-42d0-8649-282bc3c867e3'
	 AND o.voided =0 ;
	 
	 UPDATE isanteplus.patient_on_art pt , openmrs.obs o , openmrs.concept c
	 SET pt.key_population = (CASE WHEN o.value_coded = 160578 THEN 'MSM'
	                               WHEN o.value_coded = 160579 THEN 'SEX PROFESSIONAL'
	                               WHEN o.value_coded = 162277 THEN 'CAPTIVE'
	                               WHEN o.value_coded = 124275  THEN 'TRANSGENDER'
	                               WHEN o.value_coded = 105 THEN 'DRUG USER' END )
	 WHERE o.concept_id = c.concept_id
	 AND o.person_id = pt.patient_id
	 AND c.uuid = 'b2726cc7-df4b-463c-919d-1c7a600fef87'
	 AND o.voided = 0 ;
	 
	 UPDATE isanteplus.patient_on_art pt , openmrs.obs o 
	 SET pt.reason_non_enrollment = (CASE WHEN o.value_coded = 127750 THEN 'VOLUNTARY'
	                                      WHEN o.value_coded = 160432 THEN 'DIED'
	                                      WHEN o.value_coded = 160036 THEN 'REFERRED'
	                                      WHEN o.value_coded =162591 THEN 'MEDICAL'
										           WHEN o.value_coded = 155891 THEN 'DENIAL'
										           WHEN o.value_coded = 5622  THEN 'OTHER' END) ,
		  pt.date_non_enrollment = DATE(o.obs_datetime) 
	 WHERE o.concept_id = 1667
	 AND o.person_id = pt.patient_id
	 AND o.voided = 0 ;
								
	 UPDATE isanteplus.patient_on_art pt , openmrs.obs o
	 SET pt.breast_feeding = (CASE WHEN o.value_coded = 1065 THEN 1 ELSE 0 END),
	    pt.date_breast_feeding = DATE(o.obs_datetime)
	 WHERE o.concept_id = 5632
	 AND o.person_id = pt.patient_id
	 AND o.voided = 0 ;
	 
	 UPDATE isanteplus.patient_on_art pat ,openmrs.obs o , openmrs.concept c
	 SET pat.treatment_regime_lines = 'FIRST_LINE', pat.date_started_regime_treatment = DATE(o.obs_datetime) 
	 WHERE o.person_id = pat.patient_id
	 AND o.concept_id = 164432
	 AND o.value_coded = (SELECT c.concept_id FROM openmrs.concept c WHERE c.uuid = 'dd69cffe-d7b8-4cf1-bc11-3ac302763d48')
	 AND o.voided =0 ;
	 
	 
	 UPDATE isanteplus.patient_on_art pat ,openmrs.obs o , openmrs.concept c
	 SET pat.treatment_regime_lines = 'SECOND_LINE' ,
	     pat.date_started_regime_treatment = DATE(o.obs_datetime) 
	 WHERE o.person_id = pat.patient_id
	 AND o.concept_id = 164432
	 AND o.value_coded = (SELECT c.concept_id FROM openmrs.concept c WHERE c.uuid = '77488a7b-957f-4ebc-892a-e53e7c910363')
	 AND o.voided =0 ;
	 
	  
	 UPDATE isanteplus.patient_on_art pat ,openmrs.obs o , openmrs.concept c
	 SET pat.treatment_regime_lines = 'THIRD_LINE' ,
	     pat.date_started_regime_treatment = DATE(o.obs_datetime) 
	 WHERE o.person_id = pat.patient_id
	 AND o.concept_id = 164432
	 AND o.value_coded = (SELECT c.concept_id FROM openmrs.concept c WHERE c.uuid = '99d88c3e-00ad-4122-a300-a88ff5c125c9')
	 AND o.voided =0 ;
	 	   
	 UPDATE isanteplus.patient_on_art pat , openmrs.obs o  
	 SET pat.date_full_6_months_of_inh_has_px = DATE (o.value_datetime)
	 WHERE o.person_id = pat.patient_id
	 AND o.concept_id = 163284
	 AND o.voided = 0;
	 
	 UPDATE isanteplus.patient_on_art pat , openmrs.obs o  
	 SET pat.tb_screened = 1 ,
	     pat.date_tb_screened = DATE (o.obs_datetime)
	 WHERE o.person_id = pat.patient_id
	 AND o.concept_id = 1659
	 AND o.value_coded IN  (142177,1660) ;
	 
	 UPDATE isanteplus.patient_on_art pat , openmrs.obs o  
    SET pat.tb_status = (CASE WHEN o.value_coded =142177 THEN 'POSTIVE' 
	                       WHEN o.value_coded = 1660 THEN 'NEGATIVE' END )
    WHERE o.person_id = pat.patient_id
    AND o.concept_id = 1659 ;
    
    UPDATE isanteplus.patient_on_art pat , openmrs.obs o  
	 SET pat.date_enrolled_on_tb_treatment = DATE (o.value_datetime)
	 WHERE o.person_id = pat.patient_id
	 AND o.concept_id = 1113
	 AND o.voided = 0;
	 
	/*UPDATE isanteplus.patient_on_art pat , openmrs.encounter e, openmrs.encounter_type et 
	SET pat.date_tested_hiv_postive = 
	(SELECT MIN(e.encounter_datetime)  
	FROM openmrs.encounter e ,openmrs.encounter_type et 
	WHERE e.encounter_type = et.encounter_type_id 
	AND et.uuid IN ('204ad066-c5c2-4229-9a62-644bc5617ca2',
					'33491314-c352-42d0-bd5d-a9d0bffc9bf1', 
					'17536ba6-dd7c-4f58-8014-08c7cb798ac7',
					'349ae0b4-65c1-4122-aa06-480f186c8350')); */
					
	UPDATE isanteplus.patient_on_art pat,
	(SELECT e.patient_id, MIN(e.encounter_datetime) as min_encounter_date 
	FROM openmrs.encounter e ,openmrs.encounter_type et 
	WHERE e.encounter_type = et.encounter_type_id 
	AND et.uuid IN ('204ad066-c5c2-4229-9a62-644bc5617ca2',
					'33491314-c352-42d0-bd5d-a9d0bffc9bf1', 
					'17536ba6-dd7c-4f58-8014-08c7cb798ac7',
					'349ae0b4-65c1-4122-aa06-480f186c8350') GROUP BY 1) B 
	SET pat.date_tested_hiv_postive = B.min_encounter_date
	WHERE pat.patient_id = B.patient_id;
	 
	UPDATE isanteplus.patient_on_art pat  , openmrs.obs o , openmrs.concept c
	SET  pat.tb_genexpert_test = 1 ,
	     pat.date_sample_sent_for_diagnositic_tb = DATE (o.obs_datetime),
	     pat.tb_bacteriological_test_status = (CASE WHEN o.value_coded =1301 THEN 'POSTIVE' ELSE NULL END)
	WHERE pat.patient_id = o.person_id
	AND o.concept_id  = c.concept_id
	AND c.uuid = '4cbdc90a-e007-4a48-af54-5dd204edadd9'
	AND o.voided = 0 ;
	
	UPDATE isanteplus.patient_on_art pat  , openmrs.obs o 
	SET  pat.tb_crachat_test = 1 ,
	     pat.date_sample_sent_for_diagnositic_tb = DATE (o.obs_datetime) ,
	     pat.tb_bacteriological_test_status = (CASE WHEN o.value_coded IN (1362,1363,1364) THEN 'POSTIVE' ELSE NULL END)
	WHERE pat.patient_id = o.person_id
	AND o.concept_id  = 307
	AND o.voided = 0 ;
	
	
	UPDATE isanteplus.patient_on_art pat  , openmrs.obs o 
	SET  pat.tb_other_test = 1 ,
	     pat.date_sample_sent_for_diagnositic_tb = DATE (o.obs_datetime) 
	WHERE pat.patient_id = o.person_id
	AND o.concept_id  IN (159984 ,159982 )
	AND o.voided = 0 ;
	
	UPDATE isanteplus.patient_on_art pat  , openmrs.obs o 
	SET  pat.tb_bacteriological_test_status = 'POSTIVE'
	WHERE pat.patient_id = o.person_id
	AND o.concept_id = 159982 
	AND o.value_coded IN (SELECT c.concept_id FROM openmrs.concept c WHERE  c.uuid IN ('36d6616b-8c7c-4768-9f38-2be4b704fccd', 'f4ee3bcc-947c-4390-9190-a335c2cd5868'))
	AND o.voided = 0 ;
	
	UPDATE isanteplus.patient_on_art pat  , openmrs.obs o 
	SET  pat.tb_bacteriological_test_status = 'POSTIVE'
	WHERE pat.patient_id = o.person_id
	AND o.concept_id = 159984 
	AND o.value_coded IN (162204, 162203)
	AND o.voided = 0 ;
	
	
	UPDATE isanteplus.patient_on_art pat  , openmrs.obs o , openmrs.concept c
	SET  pat.viral_load_targeted = 1 
	WHERE pat.patient_id = o.person_id
	AND o.concept_id  = c.concept_id
	AND c.uuid = '6b41328f-48bc-497c-8977-283feaa9cea6'
	AND o.value_coded = (SELECT c.concept_id FROM openmrs.concept c WHERE  c.uuid ='5c4fb18a-70f1-4a0b-924c-0b595d7dbb90')
	AND o.voided = 0 ;
	
	UPDATE isanteplus.patient_on_art pat  , openmrs.obs o 
	SET  pat.accepted_family_planning_method = (CASE WHEN o.value_coded =780 THEN 'PILLS'
	                                                 WHEN o.value_coded =190  THEN 'CONDOM'
							   WHEN o.value_coded = 1359 THEN 'IMPLANTS'
							   WHEN o.value_coded = 5279 THEN 'INJECT'
							   WHEN o.value_coded = 163759 THEN 'NECKLACE' END) 																  
	WHERE pat.patient_id = o.person_id
	AND o.concept_id  = 374
	AND o.voided = 0 ;
	
	
	UPDATE isanteplus.patient_on_art pat  
      SET  pat.date_accepted_family_planning_method = (SELECT MIN(o.obs_datetime) FROM openmrs.obs o  WHERE pat.patient_id = o.person_id AND o.concept_id  = 374 	
      AND o.voided = 0 );	
	 
	UPDATE isanteplus.patient_on_art pat  , openmrs.obs o 
	SET  pat.using_family_planning_method = (CASE WHEN o.value_coded =780 THEN 'PILLS'
                                                WHEN o.value_coded =190  THEN 'CONDOM'
						  WHEN o.value_coded = 1359 THEN 'IMPLANTS'
						  WHEN o.value_coded = 5279 THEN 'INJECT'
						  WHEN o.value_coded = 163759 THEN 'NECKLACE' END) ,
	pat.date_using_family_planning_method = 								DATE(o.obs_datetime)																	  
	WHERE pat.patient_id = o.person_id
	AND o.concept_id  = 374
	AND o.voided = 0 ;
	
	UPDATE isanteplus.patient_on_art pat , openmrs.obs o  
    SET pat.migrated = (CASE WHEN o.value_coded =160415 THEN 1 ELSE 0 END )
    WHERE o.person_id = pat.patient_id
    AND o.concept_id = 161555 ;
	
/* Insertion for key_populations table */
	INSERT into key_populations
		(
		 patient_id,
		 encounter_id,
		 location_id,
		 key_population,
		 encounter_date,
		 voided,
		 last_updated_date
		)
		select distinct o.person_id,o.encounter_id,
		o.location_id,o.value_coded, o.value_datetime, o.voided, now()
		from openmrs.obs o, openmrs.concept c
		where o.concept_id = c.concept_id
		AND c.uuid = 'b2726cc7-df4b-463c-919d-1c7a600fef87'
		AND o.value_coded IS NOT NULL
		on duplicate key update
		voided = o.voided,
		last_updated_date = now();
					
/*Insertion for Planning Familial */
		INSERT into family_planning
		(
		    patient_id,
			encounter_id,
			location_id,
			planning,
			encounter_date,
			voided,
			last_updated_date
		)
		select distinct o.person_id,o.encounter_id,
		o.location_id,o.value_coded, o.obs_datetime, o.voided, now()
		from openmrs.obs o
		where o.concept_id = 374
		AND o.value_coded IN (780,190, 1359, 5279, 163759)
		AND o.voided = 0
		on duplicate key update
		voided = o.voided,
		last_updated_date = now();
					
/*Update for planning familial*/
	UPDATE isanteplus.family_planning fp 
	SET  fp.family_planning_method_name = (CASE WHEN fp.planning = 780 THEN 'PILLS'
                                             WHEN fp.planning = 190  THEN 'CONDOM'
						WHEN fp.planning = 1359 THEN 'IMPLANTS'
						WHEN fp.planning = 5279 THEN 'INJECT'
						WHEN fp.planning = 163759 THEN 'NECKLACE' END)										  
	WHERE fp.planning IN (780,190, 1359, 5279, 163759)
	AND fp.voided = 0;
	
/*Update for Accepting or using Family Planning : Accepting = 1, Using = 2*/
	UPDATE isanteplus.family_planning fp, (SELECT fpl.patient_id, 
		MIN(fpl.encounter_date) AS encounter_date
	FROM family_planning fpl GROUP BY 1) B
	SET fp.accepting_or_using_fp = 1
	WHERE fp.patient_id = B.patient_id
	AND DATE(fp.encounter_date) = DATE(B.encounter_date);
	
	UPDATE isanteplus.family_planning fp SET fp.accepting_or_using_fp = 2
	WHERE fp.accepting_or_using_fp IS NULL;
	
/* viral load routine = 1, viral load target = 2 */
	
	UPDATE isanteplus.patient_laboratory pl SET pl.viral_load_target_or_routine = 1
	WHERE pl.test_id IN (856,1305)
	AND (pl.viral_load_target_or_routine IS NULL OR pl.viral_load_target_or_routine <> 2);
	
	UPDATE isanteplus.patient_laboratory pl, openmrs.obs o, openmrs.concept c 
	SET pl.viral_load_target_or_routine = 
	CASE WHEN (c.uuid = "5c4fb18a-70f1-4a0b-924c-0b595d7dbb90") THEN 2
	ELSE 1 END
	WHERE pl.patient_id = o.person_id
	AND pl.encounter_id = o.encounter_id
	AND o.value_coded = c.concept_id
	AND o.concept_id = (SELECT co.concept_id from openmrs.concept co 
						where co.uuid = '6b41328f-48bc-497c-8977-283feaa9cea6')
	AND c.uuid IN ("71e6fd5c-1544-4c9d-a452-32fdba8efc82","5c4fb18a-70f1-4a0b-924c-0b595d7dbb90")
	AND pl.test_id IN (856,1305);
	
	
	
/*Update for regimen First line, second line, third line*/
	UPDATE isanteplus.patient_dispensing pdi, openmrs.obs o, openmrs.concept c
	SET treatment_regime_lines = 
	CASE WHEN (c.uuid = 'dd69cffe-d7b8-4cf1-bc11-3ac302763d48') THEN 'FIRST_LINE'
        WHEN (c.uuid = '77488a7b-957f-4ebc-892a-e53e7c910363')	THEN 'SECOND_LINE'
	 WHEN (c.uuid = '99d88c3e-00ad-4122-a300-a88ff5c125c9')	THEN 'THIRD_LINE'
	ELSE null END
	WHERE pdi.patient_id = o.person_id
	AND pdi.encounter_id = o.encounter_id
	AND o.value_coded = c.concept_id
	AND o.concept_id = 164432
	AND c.uuid IN ('dd69cffe-d7b8-4cf1-bc11-3ac302763d48',
			'77488a7b-957f-4ebc-892a-e53e7c910363',
			'99d88c3e-00ad-4122-a300-a88ff5c125c9')
	AND pdi.arv_drug = 1065;
	
	-- COMMIT
	


/*call calling_all_procedures();*/
	
	
/*Adding patient_status_arv iSante to iSantePlus*/
/*DELIMITER $$
	DROP PROCEDURE IF EXISTS isantepatientstatus$$
	CREATE PROCEDURE isantepatientstatus()
		BEGIN
		
		INSERT INTO patient_status_arv(patient_id,id_status,start_date,last_updated_date,
		date_started_status)
		SELECT p.patient_id, pst.patientStatus as id_status, pst.insertDate
		AS start_date, pst.insertDate, pst.insertDate
		FROM isanteplus.patient p, itech.patientStatusTemp pst
		WHERE p.isante_id = pst.patientID
		AND DATE(pst.insertDate) >= '2018-09-01'
		group by p.patient_id, pst.insertDate
		on duplicate key update
		last_updated_date = values(last_updated_date);
	END$$
	DELIMITER ;*/
	
/*call isantepatientstatus();*/
	
/*
	INSERT INTO patient_status_arv(patient_id,id_status,start_date,last_updated_date,
     date_started_status)
     SELECT p.patient_id, pst.patientStatus as id_status,
     MAX(DATE_FORMAT(concat(e.visitdateYy,"-",e.visitDateMm,"-",e.visitDateDd),"%Y-%m-%d"))
     AS start_date, pst.insertDate, pst.insertDate
     FROM isanteplus.patient p, itech.patientStatusTemp pst, itech.encounter e
     WHERE p.isante_id = pst.patientID
     AND pst.patientID = e.patientID
     AND DATE(pst.endDate) >= '2018-01-01'
     AND DATE_FORMAT(concat(e.visitdateYy,"-",e.visitDateMm,"-",e.visitDateDd),"%Y-%m-%d") <=
     DATE_FORMAT(pst.endDate,"%Y-%m-%d")
     GROUP BY 1,2,4
	 on duplicate key update
     last_updated_date = values(last_updated_date);
	*/
