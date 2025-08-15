# SHOVILL TMPDIR Fix - Summary

## Problem Solved
Fixed the error: `.command.sh: line 3: TMPDIR: unbound variable` in the SHOVILL process and eliminated the Singularity cache directory warning.

## Root Cause
The SHOVILL process was trying to use `$TMPDIR` in the command line, but this environment variable was not set in the container environment, causing the bash script to fail.

## Solutions Applied

### Files Modified:
1. **`modules/local/shovill.nf`** - Added TMPDIR initialization to both downsample and non-downsample code paths
2. **`modules/local/snippy.nf`** - Added TMPDIR initialization to FASTA input path (FASTQ path already had it)
3. **`nextflow.config`** - Added Singularity cache directory to both singularity and local profiles

### Code Added:
```bash
# Set TMPDIR if not defined
export TMPDIR=${TMPDIR:-$PWD/tmp}
mkdir -p $TMPDIR
```

### Cache Directory Added:
```nextflow
singularity.cacheDir = "${HOME}/.singularity/cache"
```

## How It Works
- If `TMPDIR` is already set → use the existing value
- If `TMPDIR` is not set → default to `$PWD/tmp` (work directory + tmp)
- Always create the directory to ensure it exists
- Singularity images are cached in `~/.singularity/cache` for reuse

## Testing
The pipeline should now run successfully without the TMPDIR error or cache warnings:

```bash
# Create the cache directory
mkdir -p ~/.singularity/cache

# Run the pipeline
nextflow run main.nf -profile singularity,all --input samplesheet.csv --outdir results --only_fastq
```

## Files Available
- `neissflow-kornthara-tmpdir-fixed/` - Updated repository with all fixes
- `SHOVILL_TMPDIR_FIX.md` - Detailed technical documentation

The fixes maintain the original codebase structure while resolving both the TMPDIR unbound variable error and the Singularity cache directory warning that were preventing the SHOVILL assembly process from running.