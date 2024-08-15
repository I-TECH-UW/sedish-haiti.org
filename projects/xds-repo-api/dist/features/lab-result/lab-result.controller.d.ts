import { LabResultService } from './lab-result.service';
export declare class LabResultController {
    private readonly labResultService;
    constructor(labResultService: LabResultService);
    create(xmlPayload: any): Promise<import("./lab-result.schema").LabResult>;
    findAll(xmlPayload: any): Promise<import("./lab-result.schema").LabResult[]>;
}
