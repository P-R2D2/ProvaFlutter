-- AlterTable
ALTER TABLE "users" ADD COLUMN     "entrevistaConcluida" BOOLEAN NOT NULL DEFAULT false,
ADD COLUMN     "perfilInvestidor" TEXT,
ADD COLUMN     "pontuacaoPerfil" INTEGER;
