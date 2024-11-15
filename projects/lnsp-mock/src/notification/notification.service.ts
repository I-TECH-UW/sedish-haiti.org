// src/notification/notification.service.ts
import { Injectable } from '@nestjs/common';
import * as xml2js from 'xml2js';
import axios from 'axios';
import * as hl7 from 'hl7';
import { ConfigService } from '@nestjs/config';


const result_template = `MSH|^~\&|||||20240816150153-0400||ORU^R01|00000303|P|2.5.1
PID||1110012004^^^^MR^111600|1110012004^^^^MR^111600||Patient^Demo||19220411[0000]|M||U||||||||^85359815-dccd-4cde-a49a-301cbcf27a5b
PV1||R|11100||||11100^Provider^Demo^^^^^^^^^^L||||||||||^^^^^^^^^^^^L|||||||||||||||||||||||||||202408081056||||||d02d8a25-0b1e-4c8d-8437-1b0c8611c503^f037e97b-471e-4898-a07c-b8e169e0ddc4^ST-02924^3a2d07cd-fda4-4dfa-ac11-04579eae4dff^85359815-dccd-4cde-a49a-301cbcf27a5b
ORC|RE|11100695547|1|A0080176|||^^^202408081127-0400^^R||202408081127|HISTC||11100^HUEH^PRESTATAIRE^^^^^^^^^^L|11100
OBR|1|11100695547|1|f037e97b-471e-4898-a07c-b8e169e0ddc4|||202408081127|||HISTC|N|||202408091052||11100^HUEH^PRESTATAIRE^^^^^^^^^^L||||||202408161501-0400|||F||^^^202408081127-0400^^R|||||||I/AUT
OBX|1|ST|25836-8^^LN^LBCVR^Copies / ml (CVr)^L|0|voir ci-dessous||||||F|||202408150505||I/AUT|||202408161501
NTE|1||Indétectable
OBX|2|ST|25836-8^^LN^LBLOG^Log (Copies / ml)^L|1|voir ci-dessous||||||F|||202408150505||I/AUT|||202408161501
NTE|1||Indétectable
`
@Injectable()
export class NotificationService {
  private parser = new xml2js.Parser({ explicitArray: false });
  // No need to instantiate xml2js.Builder if not used

  constructor(private configService: ConfigService) {}

  async extractDocumentId(soapMessage: string): Promise<string> {
    const parsedSoap = await this.parser.parseStringPromise(soapMessage);
    const documentId =
      parsedSoap['s:Envelope']['s:Body']['wsnt:Notify']['wsnt:NotificationMessage']['wsnt:Message']['lcm:SubmitObjectsRequest']['rim:RegistryObjectList']['rim:ObjectRef']['$']['id'];
    return documentId;
  }

  async retrieveHL7Message(documentId: string): Promise<string> {
    const repoId = this.configService.get<string>('REPO_ID');
    const xdsRepositoryUrl = this.configService.get<string>('HIE_URL');
    const username = this.configService.get<string>('HIE_CLIENT');
    const password = this.configService.get<string>('HIE_PW');

    const soapRequest = this.buildRetrieveDocumentSetRequest(repoId, documentId);

    const response = await axios.post(xdsRepositoryUrl, soapRequest, {
      headers: { 'Content-Type': 'application/soap+xml; charset=UTF-8' },
      auth: {
        username: username,
        password: password,
      },
    });

    const hl7Message = this.extractHL7FromResponse(response.data);
    return hl7Message;
  }

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

  parseHL7Message(hl7Message: string): any {
    const parsedHL7 = hl7.parseString(hl7Message);
    return parsedHL7;
  }

  generateRandomHL7Result(parsedHL7: any): string {
    

    

    return resultHL7;
  }

  generateUUID(): string {
    return 'xxxxxxxx-xxxx-4xxx-yxxx-xxxxxxxxxxxx'.replace(/[xy]/g, function (c) {
      /* eslint-disable */
      const r = (Math.random() * 16) | 0,
        v = c === 'x' ? r : (r & 0x3) | 0x8;
      /* eslint-enable */
      return v.toString(16);
    });
  }

  sendHL7Result(resultHL7: string): string {

    return resultHL7;
  }
}
