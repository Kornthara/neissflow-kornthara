# Singularity Pull Timeout Fix

## Problem
The pipeline was failing with a Singularity pull timeout error:
```
Failed to pull singularity image
command: singularity pull --name depot.galaxyproject.org-singularity-snippy-4.6.0--0.img.pulling.1755258939647 https://depot.galaxyproject.org/singularity/snippy:4.6.0--0 > /dev/null
status : 143
hint   : Try and increase singularity.pullTimeout in the config (current is "20m")
```

## Root Cause
- The default Singularity pull timeout is 20 minutes
- Large container images (like snippy:4.6.0--0) can take longer to download
- Network conditions or server load can cause slower downloads
- The pipeline was terminating before the download could complete

## Solution Applied

### Enhanced Singularity Configuration
Updated both `singularity` and `local` profiles in `nextflow.config` with optimized settings:

```nextflow
singularity {
    singularity.enabled     = true
    singularity.autoMounts  = true
    singularity.cacheDir    = "${HOME}/.singularity/cache"
    singularity.pullTimeout = '60.min'
    singularity.runOptions  = '--cleanenv'
    // ... other settings
}
```

### Key Improvements:

1. **Increased Pull Timeout**: `singularity.pullTimeout = '60.min'`
   - Changed from default 20 minutes to 60 minutes
   - Allows sufficient time for large container downloads
   - Accommodates slower network conditions

2. **Added Cache Directory**: `singularity.cacheDir = "${HOME}/.singularity/cache"`
   - Prevents re-downloading containers on subsequent runs
   - Organizes container storage in a dedicated location
   - Improves pipeline performance and reliability

3. **Added Run Options**: `singularity.runOptions = '--cleanenv'`
   - Ensures clean environment for container execution
   - Prevents environment variable conflicts
   - Improves container isolation and reproducibility

## Benefits of These Changes

1. **Reliability**: Eliminates timeout failures for large container downloads
2. **Performance**: Cached containers speed up subsequent pipeline runs
3. **Organization**: Dedicated cache directory for better file management
4. **Robustness**: Clean environment prevents execution conflicts
5. **Scalability**: Better handling of multiple container downloads

## Testing the Fix

After applying these changes, the pipeline should handle container downloads successfully:

```bash
# Create the cache directory
mkdir -p ~/.singularity/cache

# Run the pipeline - containers will now have 60 minutes to download
nextflow run main.nf -profile singularity,all --input samplesheet.csv --outdir results --only_fastq
```

## Alternative Solutions (If Still Having Issues)

### 1. Pre-download Containers
If you continue to have network issues, you can pre-download containers:

```bash
# Pre-download the problematic container
singularity pull docker://depot.galaxyproject.org/singularity/snippy:4.6.0--0

# Move to cache directory
mkdir -p ~/.singularity/cache
mv snippy_4.6.0--0.sif ~/.singularity/cache/
```

### 2. Increase Timeout Further
For very slow networks, you can increase the timeout even more:

```nextflow
singularity.pullTimeout = '120.min'  // 2 hours
```

### 3. Use Local Registry
Set up a local container registry if you have multiple machines:

```nextflow
singularity.registry = 'your-local-registry.com'
```

## Files Modified

- `nextflow.config` - Enhanced Singularity configuration for both profiles

## Usage Instructions

1. **Create cache directory:**
   ```bash
   mkdir -p ~/.singularity/cache
   ```

2. **Run the pipeline:**
   ```bash
   nextflow run main.nf -profile singularity,all --input samplesheet.csv --outdir results --only_fastq
   ```

3. **Monitor progress:**
   - Container downloads will now have up to 60 minutes to complete
   - Subsequent runs will use cached containers for faster startup

The pipeline should now successfully download and cache all required containers without timeout errors!

## Troubleshooting

If you still encounter issues:

1. **Check network connectivity**: `ping depot.galaxyproject.org`
2. **Verify disk space**: `df -h ~/.singularity/cache`
3. **Check Singularity version**: `singularity --version`
4. **Monitor download progress**: Remove `> /dev/null` from pull command to see progress