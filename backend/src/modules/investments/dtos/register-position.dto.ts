import { IsNotEmpty, IsNumber, IsPositive, IsString } from 'class-validator';

export class RegisterPositionDto {
  @IsString()
  @IsNotEmpty()
  symbol: string;

  @IsNumber()
  @IsPositive()
  quantity: number;

  @IsNumber()
  @IsPositive()
  averagePurchasePrice: number;
}
