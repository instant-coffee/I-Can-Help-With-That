#!/usr/bin/env bash

# ─────────────────────────────────────────────
#  rename-product-images.sh
#  Batch rename product image files to:
#  [brand]--[model]-[options]__[size]-[resolution]
# ─────────────────────────────────────────────

set -euo pipefail

# ── Colours ──────────────────────────────────
BOLD='\033[1m'
DIM='\033[2m'
CYAN='\033[0;36m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
RESET='\033[0m'

# ── Helpers ───────────────────────────────────
print_header() {
  echo ""
  echo -e "${CYAN}${BOLD}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${RESET}"
  echo -e "${CYAN}${BOLD}  📷  Product Image Batch Renamer${RESET}"
  echo -e "${CYAN}${BOLD}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${RESET}"
  echo ""
}

print_step() {
  echo -e "\n${BOLD}▸ $1${RESET}"
}

print_info() {
  echo -e "  ${DIM}$1${RESET}"
}

print_success() {
  echo -e "  ${GREEN}✔ $1${RESET}"
}

print_warn() {
  echo -e "  ${YELLOW}⚠ $1${RESET}"
}

print_error() {
  echo -e "  ${RED}✖ $1${RESET}"
}

# Prompt with a default value shown
prompt() {
  local label="$1"
  local var_name="$2"
  local default="${3:-}"

  if [[ -n "$default" ]]; then
    echo -ne "  ${label} ${DIM}[${default}]${RESET}: "
  else
    echo -ne "  ${label}: "
  fi

  read -r input
  if [[ -z "$input" && -n "$default" ]]; then
    eval "$var_name='$default'"
  else
    eval "$var_name='$input'"
  fi
}

# Slugify: lowercase, spaces → hyphens, strip unsafe chars
slugify() {
  echo "$1" \
    | tr '[:upper:]' '[:lower:]' \
    | sed 's/[[:space:]]/-/g' \
    | sed 's/[^a-z0-9._-]//g'
}

# Build the final filename segment (no extension)
build_name() {
  local brand="$1"
  local model="$2"
  local options="$3"
  local size="$4"
  local resolution="$5"

  local model_part
  if [[ -n "$options" ]]; then
    model_part="${model}-${options}"
  else
    model_part="${model}"
  fi

  echo "[${brand}]--[${model_part}]__[${size}]-[${resolution}]"
}

# ── Main ──────────────────────────────────────
print_header

# ── 1. Folder ─────────────────────────────────
print_step "Folder"
print_info "Paste the folder path or drag & drop the folder here, then press Enter"
echo -ne "  ${BOLD}Folder:${RESET} "
read -r RAW_FOLDER

# Strip quotes and trailing slashes that drag-and-drop sometimes adds
FOLDER="${RAW_FOLDER//\'/}"
FOLDER="${FOLDER//\"/}"
FOLDER="${FOLDER%/}"

if [[ ! -d "$FOLDER" ]]; then
  print_error "Folder not found: $FOLDER"
  exit 1
fi

# Count image files
IMAGE_FILES=()
while IFS= read -r -d '' f; do
  IMAGE_FILES+=("$f")
done < <(find "$FOLDER" -maxdepth 1 -type f \
  \( -iname "*.jpg" -o -iname "*.jpeg" -o -iname "*.png" \
     -o -iname "*.webp" -o -iname "*.gif" -o -iname "*.avif" \) \
  -print0 | sort -z)

FILE_COUNT="${#IMAGE_FILES[@]}"

if [[ "$FILE_COUNT" -eq 0 ]]; then
  print_warn "No image files found in: $FOLDER"
  print_info "Supported: jpg, jpeg, png, webp, gif, avif"
  exit 1
fi

print_success "Found ${FILE_COUNT} image file(s) in: $FOLDER"

# ── 2. Global fields ──────────────────────────
print_step "Naming Fields"
print_info "These apply to every file (you can override per-file later)"
echo ""

prompt "Brand      e.g. project-321" BRAND
prompt "Model      e.g. RG3"         MODEL
prompt "Options    e.g. centerlock (leave blank to omit)" OPTIONS
prompt "Size       e.g. large | thumbnail" SIZE "large"
prompt "Resolution e.g. 1200x1200" RESOLUTION "1200x1200"

BRAND=$(slugify "$BRAND")
MODEL=$(slugify "$MODEL")
OPTIONS=$(slugify "$OPTIONS")
SIZE=$(slugify "$SIZE")
RESOLUTION=$(slugify "$RESOLUTION")

# ── 3. Per-file mode ──────────────────────────
print_step "Per-file mode"
echo -e "  ${BOLD}a)${RESET} Auto-index  — files become: name__[large]-[1200x1200]__001.jpg, __002.jpg …"
echo -e "  ${BOLD}b)${RESET} Custom      — you type a suffix for each file (e.g. front, back, detail)"
echo -ne "\n  Choose [a/b]: "
read -r MODE_CHOICE

case "$(echo "$MODE_CHOICE" | tr '[:upper:]' '[:lower:]')" in
  b|custom) MODE="custom" ;;
  *)        MODE="index"  ;;
esac

# ── 4. Preview & confirm ──────────────────────
print_step "Preview"
print_info "Here is how the files will be renamed:\n"

PREVIEW_BASE=$(build_name "$BRAND" "$MODEL" "$OPTIONS" "$SIZE" "$RESOLUTION")

RENAME_MAP=()   # pairs: "old_path:::new_path"

INDEX=1
for FILE in "${IMAGE_FILES[@]}"; do
  BASENAME=$(basename "$FILE")
  EXT="${BASENAME##*.}"
  EXT_LOWER=$(echo "$EXT" | tr '[:upper:]' '[:lower:]')

  if [[ "$MODE" == "custom" ]]; then
    echo -e "  ${DIM}${BASENAME}${RESET}"
    echo -ne "    Suffix for this file (leave blank to skip): "
    read -r SUFFIX
    if [[ -z "$SUFFIX" ]]; then
      printf "  ${YELLOW}  ⟶  skipped${RESET}\n"
      continue
    fi
    SUFFIX_SLUG=$(slugify "$SUFFIX")
    NEW_NAME="${PREVIEW_BASE}--${SUFFIX_SLUG}.${EXT_LOWER}"
  else
    PADDED=$(printf "%03d" "$INDEX")
    NEW_NAME="${PREVIEW_BASE}--${PADDED}.${EXT_LOWER}"
  fi

  NEW_PATH="${FOLDER}/${NEW_NAME}"
  printf "  ${DIM}%-40s${RESET}  ${GREEN}⟶${RESET}  %s\n" "$BASENAME" "$NEW_NAME"
  RENAME_MAP+=("${FILE}:::${NEW_PATH}")
  ((INDEX++)) || true
done

echo ""
if [[ "${#RENAME_MAP[@]}" -eq 0 ]]; then
  print_warn "No files queued for renaming. Exiting."
  exit 0
fi

echo -ne "\n  ${BOLD}Rename ${#RENAME_MAP[@]} file(s)? [y/N]:${RESET} "
read -r CONFIRM

if [[ "$(echo "$CONFIRM" | tr '[:upper:]' '[:lower:]')" != "y" ]]; then
  print_warn "Aborted — no files were renamed."
  exit 0
fi

# ── 5. Execute ────────────────────────────────
print_step "Renaming"

ERRORS=0
for PAIR in "${RENAME_MAP[@]}"; do
  OLD="${PAIR%%:::*}"
  NEW="${PAIR##*:::}"

  if [[ -e "$NEW" ]]; then
    print_warn "Skipped (target already exists): $(basename "$NEW")"
    ((ERRORS++)) || true
    continue
  fi

  if mv "$OLD" "$NEW" 2>/dev/null; then
    print_success "$(basename "$OLD")  →  $(basename "$NEW")"
  else
    print_error "Failed: $(basename "$OLD")"
    ((ERRORS++)) || true
  fi
done

echo ""
echo -e "${CYAN}${BOLD}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${RESET}"
DONE_COUNT=$(( ${#RENAME_MAP[@]} - ERRORS ))
echo -e "${GREEN}${BOLD}  Done!${RESET}  ${DONE_COUNT} renamed, ${ERRORS} skipped/failed"
echo -e "${CYAN}${BOLD}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${RESET}"
echo ""