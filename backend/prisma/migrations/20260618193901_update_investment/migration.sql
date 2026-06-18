/*
  Warnings:

  - You are about to drop the column `assetName` on the `investments` table. All the data in the column will be lost.
  - You are about to drop the column `assetSymbol` on the `investments` table. All the data in the column will be lost.
  - You are about to drop the column `averagePurchasePrice` on the `investments` table. All the data in the column will be lost.
  - Added the required column `assetType` to the `investments` table without a default value. This is not possible if the table is not empty.
  - Added the required column `name` to the `investments` table without a default value. This is not possible if the table is not empty.
  - Added the required column `purchaseDate` to the `investments` table without a default value. This is not possible if the table is not empty.
  - Added the required column `purchasePrice` to the `investments` table without a default value. This is not possible if the table is not empty.

*/
-- AlterTable
ALTER TABLE "investments" DROP COLUMN "assetName",
DROP COLUMN "assetSymbol",
DROP COLUMN "averagePurchasePrice",
ADD COLUMN     "assetType" TEXT NOT NULL,
ADD COLUMN     "name" TEXT NOT NULL,
ADD COLUMN     "purchaseDate" TIMESTAMP(3) NOT NULL,
ADD COLUMN     "purchasePrice" DOUBLE PRECISION NOT NULL;
