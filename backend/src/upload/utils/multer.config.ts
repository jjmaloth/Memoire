import { diskStorage } from 'multer';
import { v4 as uuid } from 'uuid';
import * as path from 'path';

export const multerConfig = {
  storage: diskStorage({
    destination: './temp',
    filename: (_req, file, cb) => {
      const ext = path.extname(file.originalname);
      const filename = `${uuid()}${ext}`;
      cb(null, filename);
    },
  }),
};
