import { Controller, Get } from '@nestjs/common';
import { I18n, I18nContext } from 'nestjs-i18n';

@Controller()
export class HelloController {
  @Get('hello')
  hello(@I18n() i18n: I18nContext) {
    return { message: i18n.t('common.HELLO_MESSAGE') };
  }
}
