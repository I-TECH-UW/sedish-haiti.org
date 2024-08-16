import { Injectable } from '@nestjs/common';
import { InjectModel } from '@nestjs/mongoose';
import { Model } from 'mongoose';
import { LabOrder } from './lab-order.schema';
import { LabOrderDAO } from './lab-order.dao';
import { CreateLabOrderDto } from './dto/create-lab-order.dto';

@Injectable()
export class LabOrderService {
  constructor(private readonly labOrderDAO: LabOrderDAO) {}

  async create(labOrder: LabOrder) {
    return  this.labOrderDAO.create(labOrder);
  }

  async findById(documentId: string) {
    return this.labOrderDAO.findByDocumentId(documentId);
  }

  async findAll() {
    return this.labOrderDAO.find();
  }

  parseLabOrderDocument(xmlMultipart: any): LabOrder {
    // 1. Get Content-Id of the last document in multipart message
    // Content-Id: <780d4ac3-bf6e-48cc-acd4-b3208c65f974>
    const contentIdPattern = /Content-Id:\s*<([^>]+)>/g;
    let lastContentId: string | null = null;
    let contentMatch: RegExpExecArray | null;
    while ((contentMatch = contentIdPattern.exec(xmlMultipart))) {
      lastContentId = contentMatch[1];
    }

    // 2. Look up Document id of related Document tag in the XML
    /* 
    <Document id="699866eb-c6da-42f3-a09e-e2f652d73bf6/1accccd7-dc27-4ac8-bbf3-84c500130202/f037e97b-471e-4898-a07c-b8e169e0ddc4/56cf5b28-c0b5-4d57-8dde-a43e93e269d2/2023-03-24/2.25.7749110347209424508">
      <xop:Include xmlns:xop="http://www.w3.org/2004/08/xop/include" href="cid:780d4ac3-bf6e-48cc-acd4-b3208c65f974"></xop:Include>
    </Document>
    */
    const documentIdPattern = new RegExp(`<Document id="([^"]+)"[\\s\\S]*?<xop:Include[^>]+href="cid:${lastContentId}"[^>]*>`);
    const documentMatch = xmlMultipart.match(documentIdPattern);
    const documentId = documentMatch ? documentMatch[1] : null;

    // 3. Find ExternalIdentifier tag for this document ID:
    /*
    <ns2:ExternalIdentifier id="eid0" identificationScheme="urn:uuid:2e82c1f6-a085-4c72-9da3-8640a32e42ab" registryObject="699866eb-c6da-42f3-a09e-e2f652d73bf6/1accccd7-dc27-4ac8-bbf3-84c500130202/f037e97b-471e-4898-a07c-b8e169e0ddc4/56cf5b28-c0b5-4d57-8dde-a43e93e269d2/2023-03-24/2.25.7749110347209424508" value="2.25.{{documentId2}}">
      <ns2:Name>
        <ns2:LocalizedString value="XDSDocumentEntry.uniqueId"></ns2:LocalizedString>
      </ns2:Name>
    </ns2:ExternalIdentifier>
    */
    const externalIdentifierPattern = new RegExp(`<ns2:ExternalIdentifier id="eid0" identificationScheme="[^"]+" registryObject="${documentId}" value="([^"]+)">`);
    const externalIdentifierMatch = xmlMultipart.match(externalIdentifierPattern);
    const externalIdentifierValue = externalIdentifierMatch ? externalIdentifierMatch[1] : null;

    const newLabOrder = new LabOrder();

    // 4. Grab the value attribute to get the document ID to use as the documentId in the LabOrder objec
    newLabOrder.documentId = externalIdentifierValue;
    
    
    // 5. Get HL7 message from the XML
    const lines = xmlMultipart.split('\n');
    let hl7Message = '';
    let startParsing = false;

    for (const line of lines) {
      if (line.startsWith('MSH|^~\\&|')) {
        startParsing = true;
      }

      if (startParsing) {
        hl7Message += line + '\n';
      }

      if (line.startsWith('OBR|')) {
        break;
      }
    }

    newLabOrder.hl7Contents = hl7Message.trim();
    
    // 6. Get the Lab Order ID from the HL7 message ORC-2
    const orcPattern = /^ORC\|[^|]+\|([^|]+)/m;
    const orcMatch = hl7Message.match(orcPattern);
    const orc2Field = orcMatch ? orcMatch[1] : null;

    if(orc2Field != null)
      newLabOrder.labOrderId = orc2Field;
    else 
      // throw error
      throw new Error('Lab Order ID not found in HL7 message');

    // 7. Get the Facility ID from the HL7 message PV1-3
    const pv1Pattern = /^PV1\|[^|]*\|[^|]*\|([^|]+)/m;
    const pv1Match = hl7Message.match(pv1Pattern);
    const pv13Field = pv1Match ? pv1Match[1] : null;

    if(pv13Field != null)
      newLabOrder.facilityId = pv13Field;
    else 
      // throw error
      throw new Error('Facility ID not found in HL7 message');

    newLabOrder.documentContents = xmlMultipart;
    
    return newLabOrder
  }

  async parseLabOrderRequest(xmlPayload: any): Promise<any> {
  
    
  }
}
