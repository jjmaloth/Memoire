import {
    Controller,
    Post,
    UploadedFiles,
    UseInterceptors,
    Body,
  } from '@nestjs/common';
import { FilesInterceptor } from '@nestjs/platform-express';
import { UploadService } from './upload.service';
import { UploadRequestDto } from './dto/upload-request.dto';
import { multerConfig } from './utils/multer.config';
  
@Controller('upload')
export class UploadController {
    constructor(private readonly uploadService: UploadService) {}

    @Post()
    @UseInterceptors(FilesInterceptor('files', 5, multerConfig))
    async handleUpload(
      @UploadedFiles() files: Express.Multer.File[],
      @Body() body: UploadRequestDto,
    ) {
      return this.uploadService.processUpload(files, body.lockTime);
    }
  }
  