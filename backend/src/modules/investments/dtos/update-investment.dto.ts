import { IsNumber, IsOptional, IsPositive } from 'class-validator';

export class UpdateInvestmentDto {
  @IsNumber({}, { message: 'quantity must be a number' })
  @IsPositive({ message: 'quantity must be a positive number' })
  @IsOptional()
  quantity?: number;

  @IsNumber({}, { message: 'averagePurchasePrice must be a number' })
  @IsPositive({ message: 'averagePurchasePrice must be a positive number' })
  @IsOptional()
  averagePurchasePrice?: number;
}
