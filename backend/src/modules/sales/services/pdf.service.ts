import PdfPrinter from 'pdfmake';
import { TDocumentDefinitions } from 'pdfmake/interfaces';
import { Injectable } from '@nestjs/common';

@Injectable()
export class PdfService {
  private fonts = {
    Roboto: {
      normal: 'node_modules/pdfmake/fonts/Roboto-Regular.ttf',
      bold: 'node_modules/pdfmake/fonts/Roboto-Medium.ttf',
    },
  };

  generate(docDefinition: TDocumentDefinitions): Buffer {
    const printer = new PdfPrinter(this.fonts);
    const pdfDoc = printer.createPdfKitDocument(docDefinition);
    const chunks: Buffer[] = [];
    pdfDoc.on('data', chunk => chunks.push(chunk));
    pdfDoc.end();
    return Buffer.concat(chunks);
  }
}
