# Local Setup Instructions

## Running neissflow on a Local Computer

This pipeline has been configured to run on a local computer with 12 cores and 64 GB RAM using Singularity.

### Prerequisites

1. **Nextflow** (version ≥23.10.0)
2. **Singularity** (version ≥3.0)
3. **Java** (version ≥11)

### Resource Configuration

The `local` profile has been configured with the following resource limits:
- **CPUs**: 10 cores (leaving 2 cores for system overhead)
- **Memory**: 56 GB (leaving 8 GB for system overhead)
- **Queue Size**: 4 concurrent processes
- **Container Engine**: Singularity with auto-mounting enabled

### Running the Pipeline

To run the pipeline with the local profile, use:

```bash
nextflow run main.nf -profile local,singularity --input samplesheet.csv --outdir results --only_fastq
```

### Example Commands

1. **Test run with local profile:**
```bash
nextflow run main.nf -profile local,singularity,test --outdir test_results
```

2. **Full run with FASTQ input:**
```bash
nextflow run main.nf -profile local,singularity --input samplesheet.csv --outdir results --only_fastq --name my_run
```

3. **Run with FASTA assemblies only:**
```bash
nextflow run main.nf -profile local,singularity --input samplesheet.csv --outdir results --only_fasta --name my_run
```

### Profile Details

The local profile includes:
- Local executor (no job scheduler required)
- Singularity container engine
- Resource limits appropriate for your hardware
- Optimized polling interval for local execution

### Troubleshooting

- If you encounter memory issues, reduce the number of concurrent processes by modifying `executor.queueSize` in the local profile
- Monitor system resources during execution to ensure adequate overhead
- Singularity containers will be automatically downloaded and cached on first use

### Notes

- The pipeline has been updated to fix compatibility issues with `awk --version` on different systems
- All resource limits respect the `check_max()` function to prevent exceeding system capabilities
- The local profile automatically enables Singularity and disables other container engines