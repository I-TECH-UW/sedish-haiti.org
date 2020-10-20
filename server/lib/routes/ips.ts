"use strict";
import express, {Request, Response} from "express";
import logger from '../winston';
import fhirClient from 'fhirclient';
import { R4 } from '@ahryman40k/ts-fhir-types';
import config from '../config';

export const router = express.Router();

var sprintf = require('sprintf-js').sprintf;

router.get('/Patient/:id/:lastUpdated?', (req: Request, res: Response) => {
  const id = req.params.id;
  const lastUpdated = req.params.lastUpdated;
  logger.info(sprintf('Received a request for an ISP with a bundle of resources\npatient id: %s | lastUpdagted: %s', id, lastUpdated));

  res.status(200).send("Temporary");

});
router.get('/:location?/:lastUpdated?', (req: Request, res: Response) => {
    const location = req.params.location;
    const lastUpdated = req.params.lastUpdated;
    const query = new URLSearchParams();
    const obsQuery = new URLSearchParams();
    
    
    if(lastUpdated) {
      query.set("_lastUpdated", lastUpdated);
      obsQuery.set("_lastUpdated", lastUpdated);
    }

    // Generating an IPS Bundle (https://build.fhir.org/ig/HL7/fhir-ips/)
    // List of Resources: 
    /*
      Medication Summary (R)
      Allergies and Intolerances (R)
      Problem List (R)
      Immunizations (S)
      History of Procedures (S)
      Medical Devices (S)
      Diagnostic Results (S)
      Laboratory results
      Pathology results
      Past history of illnesses
      Pregnancy (status and history summary)
      Social History
      Functional Status (Autonomy / Invalidity)
      Plan of care
      Advance Directives
    */
    logger.info(sprintf('Received a request for an ISP with a bundle of resources\nlocation: %s | lastUpdagted: %s', location, lastUpdated));
    
    // Create Client
    // TODO: parameterize url
    const client = fhirClient(req, res).client({
        serverUrl: config.get('fhirServer:baseURL')
    });

    /**
     * For now:
     * 1. Set lastUpdated and location based on parameters
     * 2. Get all Patients that were lastUpdated and from a given location
     * 3. Get all Encounters that were lastUpdated and from a given location
     * 4. Get all Observations that were lastUpdated and from a given location
     * 5. Combine them into a single bundle w/ composition
     *
     */

    let patientP = client.request(`Patient?${query}`, {flat: true});

    if(location) {
      query.set("location", location);
      obsQuery.set("encounter.location", location);
    }
    let encounterP = client.request(`Encounter?${query}`, {flat: true});
    let obsP = client.request(`Observation?${obsQuery}`, {flat: true});
    
    Promise.all([patientP,encounterP,obsP])
    .then(values => {
      let patients: R4.IPatient[] = values[0];
      let encounters: R4.IEncounter[] = values[1];
      let observations: R4.IObservation[] = values[2];

      // Since patient location is not queryable...
      if(patients.length > 0 && location) {
        patients = patients.filter((p: R4.IPatient) => { 
          if(p.identifier && p.identifier.length > 0 && p.identifier[0].extension) {
            return p.identifier[0].extension[0].valueReference!.reference!.includes(location);
          } else {
            return false;
          }
        });
      }

      let ipsBundle: R4.IBundle = {
        resourceType: "Bundle"
      };

      let ipsCompositionType: R4.ICodeableConcept = {
        coding: [{system: "http://loinc.org", code: "60591-5", display: "Patient summary Document"}]
      };

      let ipsComposition: R4.IComposition = {
        resourceType: "Composition",
        type: ipsCompositionType,
        author: [{display: "SHR System"}],
        section: [
          {
            title: "Patients",
            entry: patients.map((p: R4.IPatient) => { return {reference: `Patient/${p.id!}`}})
          },
          {
            title: "Encounters",
            entry: encounters.map((e: R4.IEncounter) => { return {reference: `Encounter/${e.id!}`}})
          },
          {
            title: "Observations",
            entry: observations.map((o: R4.IObservation) => { return {reference: `Observation/${o.id!}`}})
          }

        ]
      }

      // Create Document Bundle
      ipsBundle.type = R4.BundleTypeKind._document
      ipsBundle.entry = [];
      ipsBundle.entry.push(ipsComposition);
      ipsBundle.entry = ipsBundle.entry.concat(patients);
      ipsBundle.entry = ipsBundle.entry.concat(encounters);
      ipsBundle.entry = ipsBundle.entry.concat(observations);

      res.status(200).json(ipsBundle);
    })
    .catch(e => {
      res.status(500).render('error', {error: e})
    })

});


export default router;