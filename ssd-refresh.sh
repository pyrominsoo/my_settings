#!/usr/bin/env bash
# SSD Periodic Maintenance Script (Read-Refresh & TRIM)

set -euo pipefail

if [ "$EUID" -ne 0 ]; then
  echo "Error: Please run this script with sudo." >&2
  exit 1
fi

echo "=========================================="
echo "    SSD Maintenance & Refresh Tool       "
echo "=========================================="
echo ""

# List block devices for user reference
lsblk -d -o NAME,SIZE,MODEL,ROTA | grep -v "1$" || true
echo ""

read -rp "Enter the raw target drive device (e.g., nvme0n1 or sdb): " DEV_NAME
DEV_PATH="/dev/${DEV_NAME}"

if [ ! -b "$DEV_PATH" ]; then
  echo "Error: Device ${DEV_PATH} does not exist." >&2
  exit 1
fi

echo ""
echo "Target selected: ${DEV_PATH}"
read -rp "Proceed with maintenance on ${DEV_PATH}? [y/N]: " CONFIRM
if [[ ! "$CONFIRM" =~ ^[Yy]$ ]]; then
  echo "Operation canceled."
  exit 0
fi

echo ""
echo "------------------------------------------"
echo "Step 1/2: Running Full Read-Refresh Sweep..."
echo "------------------------------------------"
echo "Reading all NAND blocks to refresh charge states. This may take a few minutes."
echo ""

# Using iflag=direct bypasses OS RAM cache to directly touch physical NAND cells
ionice -c3 dd if="${DEV_PATH}" of=/dev/null status=progress bs=1M iflag=direct 2>/dev/null || \
ionice -c3 dd if="${DEV_PATH}" of=/dev/null status=progress bs=1M

echo ""
echo "Read-refresh pass complete!"
echo ""

echo "------------------------------------------"
echo "Step 2/2: Executing TRIM Operation..."
echo "------------------------------------------"

# Find mounted mountpoints associated with this block device
MOUNT_POINTS=$(lsblk -no MOUNTPOINT "${DEV_PATH}" | grep -v '^$' || true)

if [ -n "${MOUNT_POINTS}" ]; then
  echo "Found mounted partition(s):"
  echo "${MOUNT_POINTS}"
  echo ""
  for MP in ${MOUNT_POINTS}; do
    echo "Running fstrim on ${MP}..."
    fstrim -v "${MP}" || echo "Warning: TRIM failed on ${MP}"
  done
else
  echo "No mounted file system detected for ${DEV_PATH}."
  echo "TRIM skipped. (If this is an external drive, mount it temporarily to run TRIM)."
fi

echo ""
echo "=========================================="
echo "Maintenance Complete for ${DEV_PATH}!"
echo "=========================================="
