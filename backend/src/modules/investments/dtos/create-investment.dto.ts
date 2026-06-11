import { IsNotEmpty, IsNumber, IsPositive, IsString } from 'class-validator';

export class CreateInvestmentDto {
  @IsString({ message: 'assetSymbol must be a string' })
  @IsNotEmpty({ message: 'assetSymbol is required' })
  assetSymbol: string;

  @IsString({ message: 'assetName must be a string' })
  @IsNotEmpty({ message: 'assetName is required' })
  assetName: string;

  @IsNumber({}, { message: 'quantity must be a number' })
  @IsPositive({ message: 'quantity must be a positive number' })
  quantity: number;

  @IsNumber({}, { message: 'averagePurchasePrice must be a number' })
  @IsPositive({ message: 'averagePurchasePrice must be a positive number' })
  averagePurchasePrice: number;
}
