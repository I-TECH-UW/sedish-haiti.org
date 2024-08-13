import { Model } from 'mongoose';
import { LabResult } from './schemas/lab-result.schema';
import { CreateLabResultDto } from './dto/create-lab-result.dto';
export declare class LabResultService {
    private labResultModel;
    constructor(labResultModel: Model<LabResult>);
    create(createLabResultDto: CreateLabResultDto): Promise<LabResult>;
    findByLabOrderId(labOrderId: string): Promise<LabResult>;
}
