process MAKE_PARTITION_GUIDE {
    label 'process_single' 

    container "https://depot.galaxyproject.org/singularity/centos:7.9.2009"

    input:
    path(phylip)
    path(monomorphic_nuc_vals)

    output:
    path '*_partition.txt', emit: partition_guide
    path 'versions.yml'   , emit: versions

    when:
    task.ext.when == null || task.ext.when

    script:
    """
    file=$phylip
    path=\$(realpath $monomorphic_nuc_vals)
    name=\${file%%.filtered_polymorphic_sites.phylip}
    awk -v path=\$path -vFS=" " -vOFS="" 'NR==1 { print "[asc~",path,"], ASC_DNA, p1=1-",\$2 }' $phylip > \${name}_partition.txt

    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        Awk: \$(awk 'BEGIN{print PROCINFO["version"]}' 2>/dev/null || echo "unknown")
    END_VERSIONS
    
    """
}