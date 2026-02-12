/*
  Warnings:

  - Made the column `targetSectorId` on table `Notification` required. This step will fail if there are existing NULL values in that column.
  - Made the column `readAt` on table `ReadReceipt` required. This step will fail if there are existing NULL values in that column.

*/
-- DropForeignKey
ALTER TABLE `Notification` DROP FOREIGN KEY `Notification_targetSectorId_fkey`;

-- DropIndex
DROP INDEX `Notification_targetSectorId_fkey` ON `Notification`;

-- AlterTable
ALTER TABLE `Notification` MODIFY `targetSectorId` VARCHAR(191) NOT NULL;

-- AlterTable
ALTER TABLE `ReadReceipt` MODIFY `readAt` DATETIME(3) NOT NULL;

-- AddForeignKey
ALTER TABLE `Notification` ADD CONSTRAINT `Notification_targetSectorId_fkey` FOREIGN KEY (`targetSectorId`) REFERENCES `Sector`(`id`) ON DELETE RESTRICT ON UPDATE CASCADE;
