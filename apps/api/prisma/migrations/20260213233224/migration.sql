-- DropForeignKey
ALTER TABLE `notifications` DROP FOREIGN KEY `notifications_authorId_fkey`;

-- DropIndex
DROP INDEX `notifications_authorId_fkey` ON `notifications`;

-- AddForeignKey
ALTER TABLE `notifications` ADD CONSTRAINT `notifications_authorId_fkey` FOREIGN KEY (`authorId`) REFERENCES `users`(`id`) ON DELETE CASCADE ON UPDATE CASCADE;
