// eslint-disable-next-line @typescript-eslint/no-var-requires
const PdfPrinter = require('pdfmake');
import { Injectable } from '@nestjs/common';

@Injectable()
export class PdfService {
  private fonts = {
    Roboto: {
      normal: 'node_modules/pdfmake/fonts/Roboto-Regular.ttf',
      bold: 'node_modules/pdfmake/fonts/Roboto-Medium.ttf',
    },
  };

  generate(docDefinition: Record<string, unknown>): Buffer {
    const printer = new PdfPrinter(this.fonts);
    const pdfDoc = printer.createPdfKitDocument(docDefinition);
    const chunks: Buffer[] = [];
    pdfDoc.on('data', chunk => chunks.push(chunk));
    pdfDoc.end();
    return Buffer.concat(chunks);
  }
}
