# SHOVILL TMPDIR Fix - Complete Solution

## Problem
The SHOVILL process was failing with the error:
```
.command.sh: line 3: TMPDIR: unbound variable
```

This occurred because the `TMPDIR` environment variable was not set in the container environment, causing the bash script to fail when using `set -u` (which treats unset variables as errors).

## Root Cause
- The SHOVILL process uses `--tmpdir $TMPDIR` in its command
- In some container environments, `TMPDIR` is not automatically set
- When bash runs with strict error checking, unbound variables cause script termination

## Solutions Applied

### 1. Fixed SHOVILL Module (`modules/local/shovill.nf`)
Added TMPDIR initialization in both downsample and non-downsample code paths:

```bash
# Set TMPDIR if not defined
export TMPDIR=${TMPDIR:-$PWD/tmp}
mkdir -p $TMPDIR
```

This ensures:
- If `TMPDIR` is already set, use it
- If `TMPDIR` is not set, default to `$PWD/tmp` (current working directory + tmp)
- Create the directory if it doesn't exist

### 2. Enhanced SNIPPY Module (`modules/local/snippy.nf`)
Added TMPDIR initialization to the FASTA input path (FASTQ path already had it):

```bash
# Set TMPDIR if not defined
export TMPDIR=${TMPDIR:-$PWD/tmp}
mkdir -p $TMPDIR
```

## Benefits of These Fixes

1. **Robust**: Works in any container environment regardless of TMPDIR being pre-set
2. **Safe**: Uses a sensible default location within the work directory
3. **Compatible**: Maintains existing behavior when TMPDIR is already set
4. **Clean**: Temporary files are created in a predictable location

## Testing the Fix

After applying these fixes, the SHOVILL process should run successfully:

```bash
# Run the pipeline
nextflow run main.nf -profile singularity,all --input samplesheet.csv --outdir results --only_fastq
```

## Alternative Solutions (Not Implemented)

1. **Global TMPDIR in nextflow.config**: Could set TMPDIR globally, but this is less flexible
2. **Container-specific TMPDIR**: Could modify container environment, but this fix is more portable
3. **Remove --tmpdir parameter**: Could remove the parameter entirely, but this reduces control over temp file location

## Files Modified

- `modules/local/shovill.nf` - Added TMPDIR initialization to both code paths
- `modules/local/snippy.nf` - Added TMPDIR initialization to FASTA input path

The fixes maintain the original structure and style of the codebase while resolving the TMPDIR unbound variable error.

## Usage Instructions

1. **Run the pipeline:**
   ```bash
   nextflow run main.nf -profile singularity,all --input samplesheet.csv --outdir results --only_fastq
   ```

The pipeline should now run without the TMPDIR error!

## How the Fix Works

The bash parameter expansion `${TMPDIR:-$PWD/tmp}` means:
- If `TMPDIR` is set and not empty, use its value
- If `TMPDIR` is unset or empty, use `$PWD/tmp` as the default
- The `mkdir -p $TMPDIR` ensures the directory exists before shovill tries to use it

This approach is robust and works across different container environments and systems.