# 📷 Product Image Batch Renamer

Tired of digging through folders named `IMG_4823.jpg` trying to figure out which wheel size that is? This tool renames your product images into clean, consistent filenames — in one full-send, no manual renaming required.

**Output format:**
```
[brand]--[model]-[options]__[size]-[resolution]--[label].jpg
```

**Real example:**
```
project-321--rg3-centerlock__large-1200x1200--front.jpg
```

---

## Before You Start (One-Time Setup)

You only need to do this once. After that, skip straight to **Running the Script**.

### Step 1 — Open Terminal

- On Mac: press **⌘ + Space**, type `Terminal`, hit Enter
- You should see a window with a blinking cursor — you're in

### Step 2 — Give the script permission to run

In Terminal, type this exactly and press Enter:

```bash
chmod +x /path/to/rename-product-images.sh
```

> **Tip:** Instead of typing the path, you can drag the `rename-product-images.sh` file from Finder straight into the Terminal window and it'll fill in the path for you 🤙.

---

## Running the Script

Every time you want to rename a batch of images, do this:

### Step 1 — Open Terminal

Same as above — **⌘ + Space**, type `Terminal`, Enter.

### Step 2 — Run the script

Type this and press Enter:

```bash
bash /path/to/rename-product-images.sh
```

> Again, you can drag the script file into Terminal instead of typing the path.

---

## What Happens Next (Step by Step)

The script will guide you through everything. Here's what to expect:

---

### 📁 Step 1: Point it to your images

```
Folder: 
```

Paste the path to the folder containing your images, or **drag the folder** straight from Finder into the Terminal window — it fills in the path automatically. Press Enter.

The script will tell you how many images it found. It supports: `.jpg`, `.jpeg`, `.png`, `.webp`, `.gif`, `.avif`

> If it says "No image files found" — double-check you're pointing at the right folder. The folder needs to have images directly inside it (not in sub-folders).

---

### ✏️ Step 2: Fill in the naming fields

```
Brand       e.g. project-321
Model       e.g. RG3
Options     e.g. centerlock (leave blank to omit)
Size        [large]
Resolution  [1200x1200]
```

- **Brand** — your brand name (e.g. `project-321`)
- **Model** — the product model (e.g. `rg3`)
- **Options** — any variant info like `centerlock` or `6-bolt`. Leave blank if not needed
- **Size** — image size descriptor like `large`, `thumbnail`, `zoom`. Defaults to `large` if you just hit Enter
- **Resolution** — image dimensions like `1200x1200`. Defaults to `1200x1200` if you just hit Enter

> Fields with `[default values]` shown in brackets — just press Enter to use them.

---

### 🔀 Step 3: Choose auto or custom mode

```
a) Auto-index  — files become: [brand]--[model]__[size]-[res]--001.jpg …
b) Custom      — you type a label for each file, and choose where it sits

Choose [a/b]:
```

**Type `a` or `b` and press Enter.**

---

#### Option A — Auto-index (the easy one)

The script numbers your files automatically: `001`, `002`, `003`...

Files are sorted alphabetically before numbering, so the order is predictable.

**Example output:**
```
project-321--rg3-centerlock__large-1200x1200--001.jpg
project-321--rg3-centerlock__large-1200x1200--002.jpg
project-321--rg3-centerlock__large-1200x1200--003.jpg
```

---

#### Option B — Custom labels (more control)

You type a label for each file — great for naming angles like `front`, `side`, `detail`.

**First, pick where the label sits in the filename:**

```
0) prepend    [label]--[brand]--[model]__[size]-[res].jpg
1) brand+1    [brand]-[label]--[model]__[size]-[res].jpg
2) model+1    [brand]--[model]-[label]__[size]-[res].jpg
3) size+1     [brand]--[model]__[size]-[label]-[res].jpg
4) append     [brand]--[model]__[size]-[res]--[label].jpg  ← default

Choose position [0-4, default 4]:
```

Type a number (0–4) and press Enter. When in doubt, just press Enter to use the default (append).

**Then, for each file, you'll see:**

```
  IMG_4823.jpg
    Label for this file (leave blank to skip): 
```

Type your label (e.g. `front`, `side`, `hero`) and press Enter. If you want to skip a file and leave it as-is, just press Enter with no label.

---

### 👀 Step 4: Check the preview

Before anything is changed, the script shows you exactly what will happen:

```
IMG_4823.jpg          ⟶  project-321--rg3-centerlock__large-1200x1200--front.jpg
IMG_4824.jpg          ⟶  project-321--rg3-centerlock__large-1200x1200--side.jpg
```

Take a good look — this is your last chance to bail if something looks off.

---

### ✅ Step 5: Confirm and send it

```
Rename 6 file(s)? [y/N]:
```

- Type `y` and press Enter to rename everything
- Type `n` (or just press Enter) to abort — no files will be touched

Once you confirm, the script renames every file and shows a tick next to each success. Done!

---

## Helpful Tips

- **Drag and drop** — you can drag folders and files from Finder directly into Terminal instead of typing paths. Works everywhere the script asks for a path.
- **Spaces in folder names** — no worries, the script handles them automatically.
- **Nothing is permanent until you type `y`** — the preview step means you always get to see what's coming before it commits.
- **Already got a file with that name?** — the script skips it rather than overwriting, so you won't accidentally lose anything.
- **Capitalisation doesn't matter** — `Brand`, `BRAND`, and `brand` all work the same.

---

## Filename Format Reference

```
[brand]--[model]-[options]__[size]-[resolution]--[label].ext
```

| Segment | Example | Separator |
|---|---|---|
| Brand | `project-321` | `--` before model |
| Model | `rg3` | `-` before options |
| Options | `centerlock` | `__` before size |
| Size | `large` | `-` before resolution |
| Resolution | `1200x1200` | `--` before label |
| Label / Index | `front` or `001` | end of filename |

---

## Something Went Wrong?

| Problem | Fix |
|---|---|
| `command not found` | Make sure you're running `bash rename-product-images.sh`, not just the filename alone |
| `Permission denied` | Run the one-time setup step (`chmod +x ...`) again |
| `Folder not found` | Try dragging the folder into Terminal instead of typing the path |
| `No image files found` | Check the images are directly in the folder, not inside sub-folders |
| A file wasn't renamed | It was probably skipped because a file with the new name already existed |
