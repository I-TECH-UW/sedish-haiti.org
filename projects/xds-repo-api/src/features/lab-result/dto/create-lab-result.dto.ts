import { IsString } from 'class-validator';

export class CreateLabResultDto {
  @IsString()
  facilityId: string;

  @IsString()
  labOrderId: string;

  @IsString()
  documentId: string;

  @IsString()
  documentContents: string;
}
