import { IsString, Matches, MinLength } from 'class-validator';

export class SearchQueryDto {
  @IsString()
  @MinLength(1)
  @Matches(/^[a-zA-Z0-9\s.\-]+$/, {
    message: 'Search query contains invalid characters. Only alphanumeric, spaces, dots, and hyphens are allowed.',
  })
  query: string;
}
