import { IsString, IsNumber, IsPositive, IsOptional, MaxLength } from 'class-validator';

export class RegisterPositionDto {
  @IsString()
  @MaxLength(100)
  name: string;

  @IsNumber()
  @IsPositive()
  quantity: number;

  @IsNumber()
  @IsPositive()
  purchasePrice: number;
}
