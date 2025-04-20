import { IsString, IsNotEmpty } from 'class-validator';

export class UploadRequestDto {
  @IsString()
  @IsNotEmpty()
  lockTime: string; // ISO format or UNIX timestamp
}
