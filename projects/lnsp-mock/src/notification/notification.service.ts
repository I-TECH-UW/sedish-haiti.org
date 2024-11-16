// src/notification/notification.service.ts

import { Injectable } from '@nestjs/common';
import * as xml2js from 'xml2js';
import axios from 'axios';
import * as hl7 from 'hl7';
import { ConfigService } from '@nestjs/config';

const oruWrapper = `--uuid:4574f962-5ee0-45ff-9a0e-cb24c8d917de
Content-Type: application/xop+xml; charset=UTF-8; type="application/soap+xml"
Content-Transfer-Encoding: binary
Content-ID: <root.message@cxf.apache.org>

<soap:Envelope xmlns:soap="http://www.w3.org/2003/05/soap-envelope"><soap:Header><wsa:MessageID xmlns:wsa="http://www.w3.org/2005/08/addressing" xmlns:soapenv="http://www.w3.org/2003/05/soap-envelope" soapenv:mustUnderstand="true">urn:uuid:926ea614-037c-4f69-ac1b-61fa451b71d5</wsa:MessageID><wsa:Action xmlns:wsa="http://www.w3.org/2005/08/addressing" xmlns:soapenv="http://www.w3.org/2003/05/soap-envelope" soapenv:mustUnderstand="true">urn:ihe:iti:2007:ProvideAndRegisterDocumentSet-b</wsa:Action><wsa:To xmlns:wsa="http://www.w3.org/2005/08/addressing" xmlns:soapenv="http://www.w3.org/2003/05/soap-envelope" soapenv:mustUnderstand="true">https://openhim.sedish-haiti.org/xdsbrepository</wsa:To></soap:Header><soap:Body><xdsb:ProvideAndRegisterDocumentSetRequest xmlns:xdsb="urn:ihe:iti:xds-b:2007" xmlns:wsa="http://www.w3.org/2005/08/addressing" xmlns:rim="urn:oasis:names:tc:ebxml-regrep:xsd:rim:3.0" xmlns:lcm="urn:oasis:names:tc:ebxml-regrep:xsd:lcm:3.0">
               <lcm:SubmitObjectsRequest>
                  <rim:RegistryObjectList>
                     <rim:ExtrinsicObject id="699866eb-c6da-42f3-a09e-e2f652d73bf6/8ec96629-c2d8-4f78-b1c7-2b627a3e066d/f037e97b-471e-4898-a07c-b8e169e0ddc4/e583ab03-150b-4752-bbcd-0f636e2fc343/2023-03-29/2.25.6879235708703285157" mimeType="text/plain" objectType="urn:uuid:7edca82f-054d-47f2-a032-9b2a5b5186c1">
                        <rim:Slot name="serviceStartTime">
                           <rim:ValueList>
                              <rim:Value>20230329142351</rim:Value>
                           </rim:ValueList>
                        </rim:Slot>
                        <rim:Slot name="creationTime">
                           <rim:ValueList>
                              <rim:Value>20230329142351</rim:Value>
                           </rim:ValueList>
                        </rim:Slot>
                        <rim:Slot name="languageCode">
                           <rim:ValueList>
                              <rim:Value>fr</rim:Value>
                           </rim:ValueList>
                        </rim:Slot>
                        <rim:Slot name="sourcePatientId">
                           <rim:ValueList>
                              <rim:Value>8ec96629-c2d8-4f78-b1c7-2b627a3e066d^^^&amp;2.16.840.1.113883.4.56&amp;ISO</rim:Value>
                           </rim:ValueList>
                        </rim:Slot>
                        <rim:Classification classificationScheme="urn:uuid:41a5887f-8865-4c09-adf7-e362475b143a" classifiedObject="699866eb-c6da-42f3-a09e-e2f652d73bf6/8ec96629-c2d8-4f78-b1c7-2b627a3e066d/f037e97b-471e-4898-a07c-b8e169e0ddc4/e583ab03-150b-4752-bbcd-0f636e2fc343/2023-03-29/2.25.6879235708703285157" id="cl1" nodeRepresentation="34133-9">
                           <rim:Slot name="codingScheme">
                              <rim:ValueList>
                                 <rim:Value>LOINC</rim:Value>
                              </rim:ValueList>
                           </rim:Slot>
                           <rim:Name>
                              <rim:LocalizedString value="XDSDocumentEntry.classCode"/>
                           </rim:Name>
                        </rim:Classification>
                        <rim:Classification classificationScheme="urn:uuid:f4f85eac-e6cb-4883-b524-f2705394840f" classifiedObject="699866eb-c6da-42f3-a09e-e2f652d73bf6/8ec96629-c2d8-4f78-b1c7-2b627a3e066d/f037e97b-471e-4898-a07c-b8e169e0ddc4/e583ab03-150b-4752-bbcd-0f636e2fc343/2023-03-29/2.25.6879235708703285157" id="cl2" nodeRepresentation="1.3.6.1.4.1.21367.2006.7.101">
                           <rim:Slot name="codingScheme">
                              <rim:ValueList>
                                 <rim:Value>Connect-a-thon confidentialityCodes</rim:Value>
                              </rim:ValueList>
                           </rim:Slot>
                           <rim:Name>
                              <rim:LocalizedString value="XDSDocumentEntry.confidentialityCode"/>
                           </rim:Name>
                        </rim:Classification>
                        <rim:Classification classificationScheme="urn:uuid:a09d5840-386c-46f2-b5ad-9c3699a4309d" classifiedObject="699866eb-c6da-42f3-a09e-e2f652d73bf6/8ec96629-c2d8-4f78-b1c7-2b627a3e066d/f037e97b-471e-4898-a07c-b8e169e0ddc4/e583ab03-150b-4752-bbcd-0f636e2fc343/2023-03-29/2.25.6879235708703285157" id="cl3" nodeRepresentation="HL7/Lab 2.5">
                           <rim:Slot name="codingScheme">
                              <rim:ValueList>
                                 <rim:Value>Connect-a-thon formatCodes</rim:Value>
                              </rim:ValueList>
                           </rim:Slot>
                           <rim:Name>
                              <rim:LocalizedString value="XDSDocumentEntry.formatCode"/>
                           </rim:Name>
                        </rim:Classification>
                        <rim:Classification classificationScheme="urn:uuid:f33fb8ac-18af-42cc-ae0e-ed0b0bdb91e1" classifiedObject="699866eb-c6da-42f3-a09e-e2f652d73bf6/8ec96629-c2d8-4f78-b1c7-2b627a3e066d/f037e97b-471e-4898-a07c-b8e169e0ddc4/e583ab03-150b-4752-bbcd-0f636e2fc343/2023-03-29/2.25.6879235708703285157" id="cl4" nodeRepresentation="Outpatient">
                           <rim:Slot name="codingScheme">
                              <rim:ValueList>
                                 <rim:Value>Connect-a-thon healthcareFacilityTypeCodes</rim:Value>
                              </rim:ValueList>
                           </rim:Slot>
                           <rim:Name>
                              <rim:LocalizedString value="XDSDocumentEntry.healthCareFacilityTypeCode"/>
                           </rim:Name>
                        </rim:Classification>
                        <rim:Classification classificationScheme="urn:uuid:cccf5598-8b07-4b77-a05e-ae952c785ead" classifiedObject="699866eb-c6da-42f3-a09e-e2f652d73bf6/8ec96629-c2d8-4f78-b1c7-2b627a3e066d/f037e97b-471e-4898-a07c-b8e169e0ddc4/e583ab03-150b-4752-bbcd-0f636e2fc343/2023-03-29/2.25.6879235708703285157" id="cl5" nodeRepresentation="General Medicine">
                           <rim:Slot name="codingScheme">
                              <rim:ValueList>
                                 <rim:Value>Connect-a-thon practiceSettingCodes</rim:Value>
                              </rim:ValueList>
                           </rim:Slot>
                           <rim:Name>
                              <rim:LocalizedString value="UUID_XDSDocumentEntry.practiceSettingCode"/>
                           </rim:Name>
                        </rim:Classification>
                        <rim:Classification classificationScheme="urn:uuid:f0306f51-975f-434e-a61c-c59651d33983" classifiedObject="699866eb-c6da-42f3-a09e-e2f652d73bf6/8ec96629-c2d8-4f78-b1c7-2b627a3e066d/f037e97b-471e-4898-a07c-b8e169e0ddc4/e583ab03-150b-4752-bbcd-0f636e2fc343/2023-03-29/2.25.6879235708703285157" id="cl6" nodeRepresentation="34108-1">
                           <rim:Slot name="codingScheme">
                              <rim:ValueList>
                                 <rim:Value>LOINC</rim:Value>
                              </rim:ValueList>
                           </rim:Slot>
                           <rim:Name>
                              <rim:LocalizedString value="XDSDocumentEntry.typeCode"/>
                           </rim:Name>
                        </rim:Classification>
                        <rim:Classification classificationScheme="urn:uuid:93606bcf-9494-43ec-9b4e-a7748d1a838d" classifiedObject="699866eb-c6da-42f3-a09e-e2f652d73bf6/8ec96629-c2d8-4f78-b1c7-2b627a3e066d/f037e97b-471e-4898-a07c-b8e169e0ddc4/e583ab03-150b-4752-bbcd-0f636e2fc343/2023-03-29/2.25.6879235708703285157" id="cl7" nodeRepresentation="">
                           <rim:Slot name="authorPerson">
                              <rim:ValueList>
                                 <rim:Value>M5zQapPyTZI^User^Super^^^^^^&amp;http://ohie-fr:8080/api/users&amp;ISO</rim:Value>
                              </rim:ValueList>
                           </rim:Slot>
                           <rim:Slot name="authorInstitution">
                              <rim:ValueList>
                                 <rim:Value>^^^^^&amp;http://ohie-fr:8080/api/organisationUnits&amp;ISO^^^^114412</rim:Value>
                              </rim:ValueList>
                           </rim:Slot>
                        </rim:Classification>
                        <rim:ExternalIdentifier id="ei8" identificationScheme="urn:uuid:2e82c1f6-a085-4c72-9da3-8640a32e42ab" registryObject="699866eb-c6da-42f3-a09e-e2f652d73bf6/8ec96629-c2d8-4f78-b1c7-2b627a3e066d/f037e97b-471e-4898-a07c-b8e169e0ddc4/e583ab03-150b-4752-bbcd-0f636e2fc343/2023-03-29/2.25.6879235708703285157" value="2.25.9798696379623523800">
                           <rim:Name>
                              <rim:LocalizedString value="XDSDocumentEntry.uniqueId"/>
                           </rim:Name>
                        </rim:ExternalIdentifier>
                        <rim:ExternalIdentifier id="ei9" identificationScheme="urn:uuid:58a6f841-87b3-4a3e-92fd-a8ffeff98427" registryObject="699866eb-c6da-42f3-a09e-e2f652d73bf6/8ec96629-c2d8-4f78-b1c7-2b627a3e066d/f037e97b-471e-4898-a07c-b8e169e0ddc4/e583ab03-150b-4752-bbcd-0f636e2fc343/2023-03-29/2.25.6879235708703285157" value="8ec96629-c2d8-4f78-b1c7-2b627a3e066d^^^&amp;2.16.840.1.113883.4.56&amp;ISO">
                           <rim:Name>
                              <rim:LocalizedString value="XDSDocumentEntry.patientId"/>
                           </rim:Name>
                        </rim:ExternalIdentifier>
                     </rim:ExtrinsicObject>
                     <rim:RegistryPackage id="SubmissionSet01">
                        <rim:Slot name="submissionTime">
                           <rim:ValueList>
                              <rim:Value>20230329142351</rim:Value>
                           </rim:ValueList>
                        </rim:Slot>
                        <rim:Classification classificationScheme="urn:uuid:aa543740-bdda-424e-8c96-df4873be8500" classifiedObject="SubmissionSet01" id="cl10" nodeRepresentation="34133-9">
                           <rim:Slot name="codingScheme">
                              <rim:ValueList>
                                 <rim:Value>LOINC</rim:Value>
                              </rim:ValueList>
                           </rim:Slot>
                           <rim:Name>
                              <rim:LocalizedString value="XDSSubmissionSet.contentTypeCode"/>
                           </rim:Name>
                        </rim:Classification>
                        <rim:ExternalIdentifier id="ei11" identificationScheme="urn:uuid:96fdda7c-d067-4183-912e-bf5ee74998a8" registryObject="SubmissionSet01" value="2.25.8041459776415300631">
                           <rim:Name>
                              <rim:LocalizedString value="XDSSubmissionSet.uniqueId"/>
                           </rim:Name>
                        </rim:ExternalIdentifier>
                        <rim:ExternalIdentifier id="ei12" identificationScheme="urn:uuid:554ac39e-e3fe-47fe-b233-965d2a147832" registryObject="SubmissionSet01" value="2.25.2357008126931787739">
                           <rim:Name>
                              <rim:LocalizedString value="XDSSubmissionSet.sourceId"/>
                           </rim:Name>
                        </rim:ExternalIdentifier>
                        <rim:ExternalIdentifier id="ei13" identificationScheme="urn:uuid:6b5aea1a-874d-4603-a4bc-96a0a7b38446" registryObject="SubmissionSet01" value="8ec96629-c2d8-4f78-b1c7-2b627a3e066d^^^&amp;2.16.840.1.113883.4.56&amp;ISO">
                           <rim:Name>
                              <rim:LocalizedString value="XDSSubmissionSet.patientId"/>
                           </rim:Name>
                        </rim:ExternalIdentifier>
                     </rim:RegistryPackage>
                     <rim:Classification classificationNode="urn:uuid:a54d6aa5-d40d-43f9-88c5-b4633d873bdd" classifiedObject="SubmissionSet01" id="cl_123"/>
                     <rim:Association associationType="urn:oasis:names:tc:ebxml-regrep:AssociationType:HasMember" id="as01" sourceObject="SubmissionSet01" targetObject="699866eb-c6da-42f3-a09e-e2f652d73bf6/8ec96629-c2d8-4f78-b1c7-2b627a3e066d/f037e97b-471e-4898-a07c-b8e169e0ddc4/e583ab03-150b-4752-bbcd-0f636e2fc343/2023-03-29/2.25.6879235708703285157">
                        <rim:Slot name="SubmissionSetStatus">
                           <rim:ValueList>
                              <rim:Value>Original</rim:Value>
                           </rim:ValueList>
                        </rim:Slot>
                     </rim:Association>
                  </rim:RegistryObjectList>
               </lcm:SubmitObjectsRequest>
               <xdsb:Document id="699866eb-c6da-42f3-a09e-e2f652d73bf6/8ec96629-c2d8-4f78-b1c7-2b627a3e066d/f037e97b-471e-4898-a07c-b8e169e0ddc4/e583ab03-150b-4752-bbcd-0f636e2fc343/2023-03-29/2.25.6879235708703285157">
                  <xop:Include xmlns:xop="http://www.w3.org/2004/08/xop/include" href="cid:Payload"/>
               </xdsb:Document>
            </xdsb:ProvideAndRegisterDocumentSetRequest></soap:Body></soap:Envelope>
--uuid:4574f962-5ee0-45ff-9a0e-cb24c8d917de
Content-Type: null
Content-Transfer-Encoding: binary
Content-ID: <Payload>

{{oruMessage}}

--uuid:4574f962-5ee0-45ff-9a0e-cb24c8d917de--
`

@Injectable()
export class NotificationService {

  private parser = new xml2js.Parser({ explicitArray: false });

  constructor(private configService: ConfigService) {}

  // Existing method to extract the document ID from the SOAP message
  async extractDocumentId(soapMessage: string): Promise<string> {
    const parsedSoap = await this.parser.parseStringPromise(soapMessage);
    const documentId =
      parsedSoap['s:Envelope']['s:Body']['wsnt:Notify']['wsnt:NotificationMessage']['wsnt:Message']['lcm:SubmitObjectsRequest']['rim:RegistryObjectList']['rim:ObjectRef']['$']['id'];
    return documentId;
  }

  // Existing method to retrieve the HL7 message using the document ID
  async retrieveORMMessage(documentId: string): Promise<string> {
    const repoId = this.configService.get<string>('REPO_ID');
    const xdsRepositoryUrl = this.configService.get<string>('HIE_URL');
    const username = this.configService.get<string>('HIE_CLIENT');
    const password = this.configService.get<string>('HIE_PW');

    const soapRequest = this.buildRetrieveDocumentSetRequest(repoId, documentId);

    const response = await axios.post(xdsRepositoryUrl, soapRequest, {
      headers: { 'Content-Type': 'application/soap+xml' },
      auth: {
        username: username,
        password: password,
      },

    });

    const hl7Message = this.extractHL7FromResponse(response.data);
    return hl7Message;
  }

  // Existing method to build the SOAP request
  buildRetrieveDocumentSetRequest(repoId: string, documentId: string): string {
    const soapActionUrl = this.configService.get<string>('SOAP_ACTION_URL');
    const uuid = this.generateUUID();

    const soapEnvelope = `<?xml version="1.0" encoding="UTF-8"?>
<soap:Envelope
  xmlns:soap="http://www.w3.org/2003/05/soap-envelope">
  <soap:Header>
    <wsa:MessageID
      xmlns:wsa="http://www.w3.org/2005/08/addressing"
      xmlns:soapenv="http://www.w3.org/2003/05/soap-envelope" soapenv:mustUnderstand="false">urn:uuid:${uuid}
    </wsa:MessageID>
    <wsa:Action
      xmlns:wsa="http://www.w3.org/2005/08/addressing">urn:ihe:iti:2007:RetrieveDocumentSet
    </wsa:Action>
    <wsa:To
      xmlns:wsa="http://www.w3.org/2005/08/addressing"
      xmlns:soapenv="http://www.w3.org/2003/05/soap-envelope" soapenv:mustUnderstand="false">${soapActionUrl}
    </wsa:To>
  </soap:Header>
  <soap:Body>
    <xdsb:RetrieveDocumentSetRequest
      xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
      xmlns:xdsb="urn:ihe:iti:xds-b:2007">
      <xdsb:DocumentRequest>
        <xdsb:RepositoryUniqueId>${repoId}</xdsb:RepositoryUniqueId>
        <xdsb:DocumentUniqueId>${documentId}</xdsb:DocumentUniqueId>
      </xdsb:DocumentRequest>
    </xdsb:RetrieveDocumentSetRequest>
  </soap:Body>
</soap:Envelope>`;
    return soapEnvelope;
  }

  extractHL7FromResponse(responseData: string): string {
    let lines = responseData.split('\r\n');

    // Handle postman vs. isanteplus eol encodings
    if (lines.length === 1) {
      lines = responseData.split('\n');
    }

    let hl7Message = '';

    // Find line that starts HL7 message
    const firstHl7LineI = lines.findIndex((line: string) =>
      line.startsWith('MSH|^~\\&|'),
    );
    const lastHl7LineI = lines.findIndex((line: string) =>
      line.startsWith('OBR|'),
    );

    if (firstHl7LineI === -1) throw new Error('HL7 message not found in XML');
    
    const firstHl7Line = lines[firstHl7LineI];

    if (lastHl7LineI === -1) {
      if (firstHl7Line.includes('\r')) {
        hl7Message = firstHl7Line;
      } else {
        throw new Error('HL7 message not found in XML');
      }
    } else {
      hl7Message = lines.slice(firstHl7LineI, lastHl7LineI).join('\r');
    }

    hl7Message = hl7Message.trim();

    return hl7Message;
  }

  parseORMMessage(hl7Message: string): any {
    const parsedHL7 = hl7.parseString(hl7Message);
    return parsedHL7;
  }

  generateORUMessage(parsedORM: any): string {
    // Initialize a new ORU message as an array of segments
    const oruMessage = [];

    // Create MSH segment
    const mshSegment = this.createMSHSegment(parsedORM);
    oruMessage.push(mshSegment);

    // Copy PID segment from ORM to ORU
    const pidSegment = parsedORM.find((segment) => segment[0] === 'PID');
    oruMessage.push(pidSegment);

    // Create PV1 segment
    const pv1Segment = this.createPV1Segment(parsedORM);
    oruMessage.push(pv1Segment);

    // Create ORC segment
    const orcSegment = this.createORCSegment(parsedORM);
    oruMessage.push(orcSegment);

    // Create OBR segment
    const obrSegment = this.createOBRSegment(parsedORM);
    oruMessage.push(obrSegment);

    // Create OBX segments
    const obxSegments = this.createOBXSegments(parsedORM);
    oruMessage.push(...obxSegments);

    // Serialize the ORU message to a string
    const oruMessageString = hl7.serializeJSON(oruMessage);

    return oruMessageString;
  }

  async sendOruMessage(oruMessage: string) {
    // Send the generated ORU message to the HIE
    const hieUrl = this.configService.get<string>('HIE_URL');
    const client = this.configService.get<string>('HIE_CLIENT');
    const pw = this.configService.get<string>('HIE_PW');
    const header = `multipart/related;start="<rootpart*4574f962-5ee0-45ff-9a0e-cb24c8d917de@example.jaxws.sun.com>";type="application/xop+xml";boundary="uuid:4574f962-5ee0-45ff-9a0e-cb24c8d917de";start-info="application/soap+xml;action=\"urn:ihe:iti:2007:ProvideAndRegisterDocumentSet-b\""`
    const oruMessageWithWrapper = oruWrapper.replace('{{oruMessage}}', oruMessage);

    const response = await axios.post(hieUrl, oruMessageWithWrapper, {
      headers: {
        'Content-Type': header,
        'Authorization': `Basic ${Buffer.from(`${client}:${pw}`).toString('base64')}`
      }
    });

    return response;
  }

  private createMSHSegment(parsedORM: any): any[] {
    const mshSegment = parsedORM.find((segment) => segment[0] === 'MSH');
    // Modify necessary MSH fields for ORU message
    mshSegment[8] = ['ORU^R01']; // Message Type
    mshSegment[9] = [this.generateMessageControlId()]; // Message Control ID
    mshSegment[11] = ['P']; // Processing ID
    mshSegment[12] = ['2.5.1']; // Version ID
    return mshSegment;
  }

  private createPV1Segment(parsedORM: any): any[] {
    const pv1Segment = parsedORM.find((segment) => segment[0] === 'PV1');

    // Ensure PV1-50 has patient UUID in position 1 and encounter ID in position 5
    // PV1-50 is at index 50
    if (!pv1Segment[50]) {
      pv1Segment[50] = [''];
    }
    const pv1_50_components = pv1Segment[50];

    // Ensure there are at least 5 components. We can use the other uuids if necessary later
    while (pv1_50_components.length < 5) {
      pv1_50_components.push('');
    }

    const patientUUID = pv1_50_components[0];
    const encounterID = pv1_50_components[4];

    // Set PV1-50 in ORU message
    // pv1Segment[50][0] = `${patientUUID}^^^^${encounterID}`;

    return pv1Segment;
  }

  private createORCSegment(parsedORM: any): any[] {
    const orcSegment = parsedORM.find((segment) => segment[0] === 'ORC');

    // Modify necessary ORC fields
    orcSegment[1] = ['RE']; // Order Control (Result)
    orcSegment[9] = [this.getCurrentTimestamp()]; // Date/Time of Transaction
    orcSegment[12] = ['HISTC']; // Ordering Provider (Example)

    return orcSegment;
  }

  private createOBRSegment(parsedORM: any): any[] {
    const obrSegment = parsedORM.find((segment) => segment[0] === 'OBR');

    // Modify necessary OBR fields
    obrSegment[22] = [this.getCurrentTimestamp()]; // Results Rpt/Status Chng - Date/Time
    obrSegment[25] = ['F']; // Result Status (Final)

    return obrSegment;
  }

  private createOBXSegments(parsedORM: any): any[] {
    const obxSegments = [];

    // Extract Order Type from ORC-29 in ORM
    const orcSegment = parsedORM.find((segment) => segment[0] === 'ORC');
    const orderType = orcSegment[29] ? orcSegment[29][0] : '25836-8';

    // Create OBX segment
    const obxSegment = [];
    obxSegment[0] = 'OBX';
    obxSegment[1] = ['1']; // Set ID
    obxSegment[2] = ['ST']; // Value Type (String)
    obxSegment[3] = [`${orderType}^^LN`]; // Observation Identifier
    obxSegment[5] = ['voir ci-dessous']; // Observation Value
    obxSegment[11] = ['F']; // Observation Result Status
    obxSegment[14] = [this.getCurrentTimestamp()]; // Date/Time of the Observation

    obxSegments.push(obxSegment);

    // Create NTE segment associated with OBX
    const nteSegment = [];
    nteSegment[0] = 'NTE';
    nteSegment[1] = ['1']; // Set ID
    nteSegment[3] = ['Indétectable'];

    obxSegments.push(nteSegment);

    return obxSegments;
  }

  private generateMessageControlId(): string {
    return this.generateUUID();
  }

  private getCurrentTimestamp(): string {
    const now = new Date();
    const yyyy = now.getFullYear().toString();
    const MM = (now.getMonth() + 1).toString().padStart(2, '0');
    const dd = now.getDate().toString().padStart(2, '0');
    const HH = now.getHours().toString().padStart(2, '0');
    const mm = now.getMinutes().toString().padStart(2, '0');
    const ss = now.getSeconds().toString().padStart(2, '0');
    return `${yyyy}${MM}${dd}${HH}${mm}${ss}`;
  }

  // Utility method to generate a UUID
  private generateUUID(): string {
    return 'xxxxxxxx-xxxx-4xxx-yxxx-xxxxxxxxxxxx'.replace(/[xy]/g, function (c) {
      /* eslint-disable */
      const r = (Math.random() * 16) | 0,
        v = c === 'x' ? r : (r & 0x3) | 0x8;
      /* eslint-enable */
      return v.toString(16);
    });
  }
}
