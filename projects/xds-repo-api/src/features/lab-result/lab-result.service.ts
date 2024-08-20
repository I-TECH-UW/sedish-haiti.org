import { Injectable } from '@nestjs/common';
import { LabResult } from './lab-result.schema';
import { parseStringPromise } from 'xml2js';
import * as xpath from 'xml2js-xpath';
import { Hl7Service } from 'src/core/hl7/hl7.service';
import { LabResultDAO } from './lab-result.dao';

@Injectable()
export class LabResultService {
  constructor(
    private readonly hl7Service: Hl7Service,
    private readonly labResultDAO: LabResultDAO,
  ) {}

  async create(labResult: LabResult) {
    // Create lab result and connect with lab order

    return this.labResultDAO.create(labResult);
  }

  async findByLabOrderId(labOrderId: string) {
    return this.labResultDAO.findOne({ labOrderId });
  }

  async findAllByFacilityId(facilityId: string): Promise<LabResult[]> {
    return this.labResultDAO.findByFacilityId(facilityId);
  }

  async parseLabResultDocument(xmlPayload: any): Promise<LabResult> {
    // Extract soap envelope section from xmlPayload and parse xml
    // Grab everything between <soap:Envelope  and </soap:Envelope>

    const soapEnvelope = xmlPayload.match(
      /<soap:Envelope.*<\/soap:Envelope>/s,
    )[0];
    const parsedXml = await parseStringPromise(soapEnvelope, {
      explicitArray: false,
    });

    const xdsDocumentEntryUniqueId = xpath.find(
      parsedXml,
      "//rim:ExternalIdentifier[@id='ei9']",
    );
    const xdsSubmissionSetUniqueId = xpath.find(
      parsedXml,
      "//rim:ExternalIdentifier[@id='ei11']",
    );
    const xdsSubmissionSetSourceId = xpath.find(
      parsedXml,
      "//rim:ExternalIdentifier[@id='ei12']",
    );

    // Grab everything between Content-ID: <Payload> and --uuid excluding both patterns:
    const hl7ContentsMatch = xmlPayload.match(
      /Content-ID: <Payload>(.*?)--uuid/s,
    );

    let hl7Contents = '';
    if (hl7ContentsMatch && hl7ContentsMatch[1])
      hl7Contents = hl7ContentsMatch[1];
    else throw new Error('HL7 contents not found in payload');

    const parsedHl7Message = await this.hl7Service.parseMessageContent(
      hl7Contents.replaceAll('\n', '\r'),
      'incoming-result-message',
    );

    const newLabResult = new LabResult();

    // 6. Get the Lab Order ID from the HL7 message ORC-2
    const orc2Field = parsedHl7Message.get('ORC', 'Placer Order Number')
    if (orc2Field) newLabResult.labOrderId = orc2Field;
    else throw new Error('Lab Order ID not found in HL7 message');

    // 7. Get the Facility ID from the HL7 message PV1-3 (assigned patient location)
    const pv13Field = parsedHl7Message.get('PV1', 'Assigned Patient Location');
    if (pv13Field) newLabResult.facilityId = pv13Field;
    else throw new Error('Facility ID not found in HL7 message');

    // 8. Save the Alternate Visit Id
    const altVisitId = parsedHl7Message.get('PV1', 'Alternate Visit')[0];
    if (altVisitId) newLabResult.alternateVisitId = altVisitId;
    else throw new Error('Alternate Visit ID not found in HL7 message');
    
    // 9. Save the Patient ID
    const patientId = parsedHl7Message.get('PID', 'Patient ID')[0];
    if (patientId) newLabResult.patientId = patientId;
    else throw new Error('Patient ID not found in HL7 message');    

    newLabResult.documentId = xdsDocumentEntryUniqueId[0];
    newLabResult.hl7Contents = hl7Contents;
    newLabResult.documentContents = xmlPayload;

    return newLabResult;
  }

  parseLabResultRequest(xmlPayload: any): {
    facilityId: string;
    maxNumber: string;
  } {
    try {
      const facilityId =
        xmlPayload['soap-env:envelope']['soap-env:body'][0][
          'ns2:getmessages'
        ][0].$.facility;
      const maxNumber =
        xmlPayload['soap-env:envelope']['soap-env:body'][0][
          'ns2:getmessages'
        ][0]['ns2:maximumnumber'][0];

      return { facilityId, maxNumber };
    } catch (error) {
      throw new Error(
        'Could not parse facility ID and maximum number from request',
      );
    }
  }
}
