import { IsString, IsNumber, IsPositive, Min, MaxLength, IsDateString, IsUUID } from 'class-validator';

export class CreateInvestmentDto {
  @IsString()
  @MaxLength(100)
  name: string;

  @IsString()
  assetType: string;

  @IsNumber()
  @IsPositive({ message: 'A quantidade deve ser maior que zero' })
  quantity: number;

  @IsNumber()
  @Min(0, { message: 'O preço de compra não pode ser negativo' })
  purchasePrice: number;

  @IsDateString()
  purchaseDate: string;

  @IsUUID()
  portfolioId: string;
}
