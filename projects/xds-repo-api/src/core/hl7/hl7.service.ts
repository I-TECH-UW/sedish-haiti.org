import { Injectable, Inject } from '@nestjs/common';
import Hl7lib from 'nodehl7';

@Injectable()
export class Hl7Service {
  constructor(
    @Inject('HL7_PARSER') private hl7parser: Hl7lib,
  ) {}

  async parseMessageContent(messageContent: string, ID: string): Promise<any> {
    return new Promise((resolve, reject) => {
      this.hl7parser.parse(messageContent, ID, (err, message) => {
        if (err) {
          return reject(err);
        }
        resolve(message);
      });
    });
  }
}