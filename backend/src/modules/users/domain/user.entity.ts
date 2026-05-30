import { Entity, PrimaryColumn, Column } from 'typeorm';

@Entity('users')
export class User {
  @PrimaryColumn('uuid')
  id: string;

  @Column({ unique: true })
  email: string;

  @Column()
  passwordHash: string;

  @Column({ nullable: true, type: 'text' })
  refreshToken: string | null;

  @Column({ default: false })
  entrevistaConcluida: boolean;

  @Column({ nullable: true, type: 'varchar' })
  perfilInvestidor: string | null;

  @Column({ nullable: true, type: 'int' })
  pontuacaoPerfil: number | null;
}
