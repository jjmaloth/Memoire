import { Module } from '@nestjs/common';
import { UploadModule } from './upload/upload.module';
import { AppController } from './app.controller';

@Module({
  imports: [UploadModule],
  controllers: [AppController],
})
export class AppModule {}
