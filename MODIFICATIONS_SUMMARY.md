# Neissflow Pipeline Modifications

## Changes Made

### 1. Fixed YAML Parsing Issues and Groovy Syntax Errors
Fixed tool version strings that contained problematic characters (colons and commas) that were breaking YAML parsing, and fixed Groovy lexer errors:

**Files Modified:**
- `modules/nf-core/multiqc/main.nf` - Fixed multiqc version string with comma (properly quoted)
- `modules/local/stats/coverage.nf` - Fixed awk version string with comma + Groovy syntax error (escaped `$`)
- `modules/local/fastp/combine_reports.nf` - Fixed awk version string with comma + Groovy syntax error (escaped `$`)
- `modules/local/variant_analysis.nf` - Quoted Python version string
- `modules/local/spades/assembly_stats.nf` - Quoted Python version string
- `modules/local/fastp/parse_fastp.nf` - Quoted Python version string + Fixed URL encoding
- `modules/local/outbreak_detection.nf` - Quoted Python version string

**Container URL Fixes:**
- `modules/local/fastp/parse_fastp.nf` - Fixed `python%3A3.7` to `python:3.7`
- `modules/local/count_mono.nf` - Fixed `datamash%3A1.8` to `datamash:1.8`

**Specific Groovy Syntax Fix:**
- Fixed `LexerNoViableAltException` error caused by unescaped `$` in sed commands
- Changed `s/,.*$/` to `s/,.*\$/` in awk version extraction commands

### 2. Fixed Container Engine Configuration
- Set Singularity as the default container engine in `nextflow.config`
- Updated local profile to use Singularity instead of Docker
- Conservative resource allocation (10 cores, 56GB RAM - leaving overhead for 12-core/64GB system)
- Process-specific resource limits
- Fixed Docker container reference format errors by using Singularity as default

## Usage

Run the pipeline with any of these commands:
```bash
# Using the local profile (recommended for local systems)
nextflow run . -profile local --input samplesheet.csv --outdir results --only_fastq

# Using default configuration (now uses Singularity by default)
nextflow run . --input samplesheet.csv --outdir results --only_fastq

# Using explicit singularity profile
nextflow run . -profile singularity --input samplesheet.csv --outdir results --only_fastq
```

If you have a previous failed run, resume with:
```bash
nextflow run . -profile local --input samplesheet.csv --outdir results --only_fastq -resume
```

## Troubleshooting

### Docker Container Reference Format Error
**Error**: `docker: invalid reference format` or `repository name must be lowercase`
**Root Cause**: Pipeline was trying to use Docker with Singularity container URLs
**Solution**: 
1. Fixed URL encoding issues (`python%3A3.7` → `python:3.7`)
2. Set Singularity as the default container engine
3. Updated local profile to use Singularity instead of Docker
4. Pipeline now works without requiring specific profile flags

**Requirements**: Make sure Singularity is installed on your system:
- Ubuntu/Debian: `sudo apt install singularity-container`
- CentOS/RHEL: `sudo yum install singularity`
- Or follow installation guide: https://docs.sylabs.io/guides/latest/user-guide/quick_start.html

## Cleanup Notes
- Removed large test samples (538MB) - can be re-downloaded if needed
- Removed git history to reduce size
- Removed development files (.github, .vscode, etc.)
- Pipeline reduced from ~650MB to ~57MB for efficient download

## Original Repository
https://github.com/CDCgov/neissflow