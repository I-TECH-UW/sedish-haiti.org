import { Injectable } from '@nestjs/common';
import * as xml2js from 'xml2js';
import * as hl7 from 'hl7';
import axios from 'axios';

@Injectable()
export class NotificationService {
  private parser = new xml2js.Parser({ explicitArray: false });
  private builder = new xml2js.Builder();

  async extractDocumentId(soapMessage: string): Promise<string> {
    const parsedSoap = await this.parser.parseStringPromise(soapMessage);
    // Navigate through the parsed SOAP to find the document ID
    const documentId = parsedSoap['s:Envelope']['s:Body']['wsnt:Notify']['wsnt:NotificationMessage']['wsnt:Message']['lcm:SubmitObjectsRequest']['rim:RegistryObjectList']['rim:ObjectRef']['$']['id'];
    return documentId;
  }

  async retrieveHL7Message(documentId: string): Promise<string> {
    const repoId = 'YOUR_CONFIGURED_REPO_ID'; // Replace with your repo ID
    const soapRequest = this.buildRetrieveDocumentSetRequest(repoId, documentId);

    const response = await axios.post('https://openhimcore.sedish.live/xdsrepository', soapRequest, {
      headers: { 'Content-Type': 'application/soap+xml' },
    });

    // Extract HL7 message from the response
    // Assume the HL7 message is in the response body or a specific XML node
    const hl7Message = this.extractHL7FromResponse(response.data);
    return hl7Message;
  }

  buildRetrieveDocumentSetRequest(repoId: string, documentId: string): string {
    const soapEnvelope = `<?xml version="1.0" encoding="UTF-8"?>
<soap:Envelope
  xmlns:soap="http://www.w3.org/2003/05/soap-envelope">
  <soap:Header>
    <wsa:MessageID
      xmlns:wsa="http://www.w3.org/2005/08/addressing"
      xmlns:soapenv="http://www.w3.org/2003/05/soap-envelope" soapenv:mustUnderstand="false">urn:uuid:${this.generateUUID()}
    </wsa:MessageID>
    <wsa:Action
      xmlns:wsa="http://www.w3.org/2005/08/addressing">urn:ihe:iti:2007:RetrieveDocumentSet
    </wsa:Action>
    <wsa:To
      xmlns:wsa="http://www.w3.org/2005/08/addressing"
      xmlns:soapenv="http://www.w3.org/2003/05/soap-envelope" soapenv:mustUnderstand="false">https://sedish.net:5000/xdsbrepository
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
    // Parse the SOAP response to extract the HL7 message
    // This will depend on the structure of the response
    // For this example, we'll assume the HL7 message is in a specific node
    // Adjust the parsing logic as per actual response
    return responseData; // Placeholder
  }

  generateUUID(): string {
    // Generate a UUID for MessageID
    return 'xxxxxxxx-xxxx-4xxx-yxxx-xxxxxxxxxxxx'.replace(/[xy]/g, function(c) {
      /* eslint-disable */
      const r = (Math.random() * 16) | 0,
        v = c == 'x' ? r : (r & 0x3) | 0x8;
      /* eslint-enable */
      return v.toString(16);
    });
  }

  parseHL7Message(hl7Message: string): any {
    const parsedHL7 = hl7.parseString(hl7Message);
    return parsedHL7;
  }

  generateRandomHL7Result(parsedHL7: any): string {
    // Modify the parsed HL7 message to create a result message
    // For simplicity, we'll replace certain fields with random values

    // Example: Update OBX segment with random values
    const obxIndex = parsedHL7.findIndex((segment) => segment[0][0] === 'OBX');
    if (obxIndex !== -1) {
      parsedHL7[obxIndex][5][0] = Math.floor(Math.random() * 1000).toString(); // Random value
    }

    // Convert the modified parsed HL7 message back to string
    const resultHL7 = hl7.serializeJSON(parsedHL7);
    return resultHL7;
  }

  sendHL7Result(resultHL7: string): string {

    return resultHL7;
  }
}
