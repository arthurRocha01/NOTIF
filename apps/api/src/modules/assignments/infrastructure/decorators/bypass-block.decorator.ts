import { SetMetadata } from '@nestjs/common';

export const BYPASS_BLOCK_KEY = 'bypassBlock';
export const BypassBlock = () => SetMetadata(BYPASS_BLOCK_KEY, true);
