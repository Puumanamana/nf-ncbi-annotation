nextflow.enable.dsl = 2

process TO_GENBANK {
    input:
    val ids

    output:
    path "*.gbk"

    script:
    """
    #!/usr/bin/env bash

    esearch -db protein -query "${ids.replaceAll('\n', ' ')}" | efetch -format gb > proteins.gbk
    """
}

process TO_LINEAGE {
    input:
    val ids

    output:
    path "lineage.tsv"

    script:
    """
    #!/usr/bin/env bash

    esearch -db protein -query "${ids.replaceAll('\n', ' ')}" \
        | elink -target taxonomy \
        | efetch -format xml |xtract -pattern TaxaSet -element Lineage,TaxID \
        > lineage.tsv
    """    
}

workflow genbank {
    ids_split = Channel.fromPath(params.accessions).splitText( by: params.chunks )
    ids_split | TO_GENBANK | collectFile(name: "proteins.gbk", storeDir: params.outdir)
}

workflow lineage {
    ids_split = Channel.fromPath(params.accessions).splitText( by: params.chunks )
    ids_split | TO_LINEAGE | collectFile(name: "lineages.tv", storeDir: params.outdir)
}

workflow {
    genbank()
    lineage()
}
