-- CreateEnum
CREATE TYPE "OrderType" AS ENUM ('DELIVERY', 'PICKUP');

-- CreateEnum
CREATE TYPE "PaymentMode" AS ENUM ('PRE_PAYMENT', 'ON_DELIVERY');

-- AlterTable
ALTER TABLE "orders" ADD COLUMN     "orderType" "OrderType" NOT NULL DEFAULT 'PICKUP',
ADD COLUMN     "paymentMode" "PaymentMode";
