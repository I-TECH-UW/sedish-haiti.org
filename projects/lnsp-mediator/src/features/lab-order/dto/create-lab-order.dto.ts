import { IsString } from 'class-validator';

export class CreateLabOrderDto {
  @IsString()
  documentId: string;

  @IsString()
  labOrderId: string;

  @IsString()
  facilityId: string;

  @IsString()
  documentContents: string;
}
