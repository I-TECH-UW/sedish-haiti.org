import { LabResultService } from './lab-result.service';
export declare class LabResultController {
    private readonly labResultService;
    constructor(labResultService: LabResultService);
    create(xmlPayload: string): Promise<LabResult>;
    findAll(xmlPayload: string): any;
}
