import { Injectable } from '@nestjs/common';
import { create } from 'ipfs-http-client';
import { readFile } from 'fs/promises';
import * as path from 'path';

@Injectable()
export class UploadService {
  private ipfs = create({
    host: 'ipfs.infura.io',
    port: 5001,
    protocol: 'https',
  });

  async processUpload(files: Express.Multer.File[], lockTime: string) {
    const uploadedHashes: { cid: string; originalName: string }[] = [];

    for (const file of files) {
      const filePath = path.join(process.cwd(), 'temp', file.filename);
      const buffer = await readFile(filePath);

      const result = await this.ipfs.add(buffer);
      uploadedHashes.push({
        cid: result.cid.toString(),
        originalName: file.originalname,
      });
    }

    return {
      lockTime,
      files: uploadedHashes,
    };
  }
}
