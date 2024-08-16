import { Injectable } from '@nestjs/common';
import { InjectModel } from '@nestjs/mongoose';
import { Model } from 'mongoose';
import { LabResult } from './lab-result.schema';
import { CreateLabResultDto } from './dto/create-lab-result.dto';
import { parseStringPromise } from 'xml2js';
import * as xpath from 'xml2js-xpath';

@Injectable()
export class LabResultService {
  constructor(@InjectModel(LabResult.name) private labResultModel: Model<LabResult>) {}

  async create(createLabResultDto: CreateLabResultDto): Promise<LabResult> {
    // Create lab result and connect with lab order
    
    const labResult = new this.labResultModel(createLabResultDto);
    return labResult.save();
  }

  async findByLabOrderId(labOrderId: string): Promise<LabResult | null> {
    return this.labResultModel.findOne({ labOrderId }).exec();
  }

  async findAllByFacilityId(facilityId: string): Promise<LabResult[]> {
      return this.labResultModel.find({ facilityId }).exec();
  }

  async parseLabResultDocument(xmlPayload: any): Promise<LabResult> {
    // Extract soap envelope section from xmlPayload and parse xml
    // Grab everything between <soap:Envelope  and </soap:Envelope>

    const soapEnvelope = xmlPayload.match(/<soap:Envelope.*<\/soap:Envelope>/s)[0];
    const parsedXml = await parseStringPromise(soapEnvelope, { explicitArray: false });
    
    const xdsDocumentEntryUniqueId = xpath.find(parsedXml, "//rim:ExternalIdentifier[@id='ei9']");
    const xdsSubmissionSetUniqueId = xpath.find(parsedXml, "//rim:ExternalIdentifier[@id='ei11']");
    const xdsSubmissionSetSourceId = xpath.find(parsedXml, "//rim:ExternalIdentifier[@id='ei12']");

    // Grab everything between Content-ID: <Payload> and --uuid excluding both patterns:
    const hl7ContentsMatch = xmlPayload.match(/Content-ID: <Payload>(.*?)--uuid/s);
    
    let hl7Contents = '';
    if(hl7ContentsMatch && hl7ContentsMatch[1])
      hl7Contents = hl7ContentsMatch[1];
    else
      throw new Error('HL7 contents not found in payload');

    const labOrderIdMatch = hl7Contents.match(/OBR\|[^|]+\|([^|]+)/);
    if(!labOrderIdMatch || !labOrderIdMatch[1])
      throw new Error('Lab Order ID not found in HL7 message');
    const labOrderId = labOrderIdMatch[1];

    const facilityIdMatch = hl7Contents.match(/PV1\|[^|]*\|[^|]*\|([^|]+)/);
    if(!facilityIdMatch || !facilityIdMatch[1])
      throw new Error('Facility ID not found in HL7 message');
    const facilityId = facilityIdMatch[1];

    return new LabResult({
      documentId: xdsDocumentEntryUniqueId[0],
      labOrderId: labOrderId,
      facilityId: facilityId,
      hl7Contents: hl7Contents,
      documentContents: xmlPayload
    });

  }

  async parseLabResultRequest(xmlPayload: any): Promise<any> {
    
  }
}