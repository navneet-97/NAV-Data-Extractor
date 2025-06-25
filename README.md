# AMFI NAV Data Extractor

This is a lightweight Bash script to extract mutual fund NAV (Net Asset Value) data from the [AMFI India](https://www.amfiindia.com/) website.

## 🔧 Features

- Fetches the latest NAV data directly from AMFI.
- Supports both **TSV** and **JSON** output formats.
- Automatically handles formatting and data cleanup.
- Outputs a summary and sample preview.
- Optional `jq` formatting for readable JSON.
- Cleans up temporary files automatically.

## 📦 Requirements

- Bash
- `curl`
- `awk`
- Optional: `jq` (for formatted JSON output)

## 🚀 Usage

Run the script from a terminal:

```bash
# Default (TSV output)
./amfi_extractor.sh

# JSON output
./amfi_extractor.sh json
```

### Help

```bash
./amfi_extractor.sh --help
```

## 📁 Output

- `amfi_nav_data.tsv` – Tab-separated format
- `amfi_nav_data.json` – JSON format
- Output files are automatically ignored by Git

## 🗂 Project Structure

```
.
├── amfi_extractor.sh        # Main script
├── amfi_nav_data.tsv        # Output (TSV)
├── amfi_nav_data.json       # Output (JSON)
├── README.md                # This file
└── .gitignore               # Ignore rules
```

## ❌ Ignored Files

This project automatically excludes:
- `.tsv`, `.json` outputs
- Any intermediate `.txt` temp files

## 📝 Example TSV Output

```
Scheme_Name                          Asset_Value
Axis Bluechip Fund - Growth         59.1234
SBI Equity Hybrid Fund - Direct     83.9812
...
```

## 📄 License

MIT License. Free to use, modify, and distribute.