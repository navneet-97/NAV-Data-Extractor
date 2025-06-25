# AMFI NAV Data Extractor

This is a lightweight Bash script to extract mutual fund NAV (Net Asset Value) data from the [AMFI India](https://www.amfiindia.com/) website.

## 🔧 Features

- Fetches the latest NAV data directly from AMFI.
- Supports both **TSV** and **JSON** output formats.
- Automatically handles formatting and data cleanup.
- Outputs a summary and sample preview.
- Optional `jq` formatting for readable JSON.
- Cleans up temporary files automatically.


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


## 📝 Example TSV Output

```
Scheme_Name                          Asset_Value
Axis Bluechip Fund - Growth         59.1234
SBI Equity Hybrid Fund - Direct     83.9812
...
```

## 📄 License

MIT License. Free to use, modify, and distribute.
