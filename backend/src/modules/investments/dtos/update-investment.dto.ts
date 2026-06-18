import { IsString, IsNumber, IsPositive, Min, MaxLength, IsDateString, IsOptional, IsUUID } from 'class-validator';

export class UpdateInvestmentDto {
  @IsString()
  @MaxLength(100)
  @IsOptional()
  name?: string;

  @IsString()
  @IsOptional()
  assetType?: string;

  @IsNumber()
  @IsPositive({ message: 'A quantidade deve ser maior que zero' })
  @IsOptional()
  quantity?: number;

  @IsNumber()
  @Min(0, { message: 'O preço de compra não pode ser negativo' })
  @IsOptional()
  purchasePrice?: number;

  @IsDateString()
  @IsOptional()
  purchaseDate?: string;

  @IsUUID()
  @IsOptional()
  portfolioId?: string;
}
