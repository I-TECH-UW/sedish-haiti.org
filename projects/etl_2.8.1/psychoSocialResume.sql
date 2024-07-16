 /*Resume iSante PsychoSocial forms*/
	USE isanteplus;  

CREATE TABLE IF NOT EXISTS comprehension(
comprehension_id INT(11) AUTO_INCREMENT,
patient_id INT(11),
isante_id VARCHAR(11),
visitDate VARCHAR(10),
visit_date DATE,
compRemarks LONGTEXT,
obstaclesRemarks LONGTEXT,
barriersToApptsText VARCHAR(255),
barriersToHomeVisitsText VARCHAR(255),
CONSTRAINT pk_comprehension_isanteplus PRIMARY KEY (comprehension_id)
)ENGINE=InnoDB DEFAULT CHARSET=utf8;
	  
INSERT INTO comprehension(patient_id,isante_id,visitDate,compRemarks,
obstaclesRemarks,barriersToApptsText,barriersToHomeVisitsText)
SELECT p.patient_id, c.patientID, 
concat(c.visitDateDd,'-',c.visitDateMm,'-',c.visitDateYy),c.compRemarks,
c.obstaclesRemarks,c.barriersToApptsText, c.barriersToHomeVisitsText
FROM isanteplus.patient p, itech.comprehension c
WHERE p.isante_id = c.patientID
AND ((c.compRemarks IS NOT NULL OR c.compRemarks <> '')
OR (c.obstaclesRemarks IS NOT NULL OR c.obstaclesRemarks <> '')
OR (c.barriersToApptsText IS NOT NULL OR c.barriersToApptsText <> '')
OR (c.barriersToHomeVisitsText IS NOT NULL OR c.barriersToHomeVisitsText <> '')
)
