-- Add DENIED value to AssignmentStatus enum
ALTER TYPE "AssignmentStatus" ADD VALUE IF NOT EXISTS 'DENIED';

-- Add deniedAt column to notification_assignments
ALTER TABLE "notification_assignments"
  ADD COLUMN IF NOT EXISTS "deniedAt" TIMESTAMP(3);
