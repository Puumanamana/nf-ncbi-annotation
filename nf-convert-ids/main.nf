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

    esearch -db protein -query "${ids.replaceAll('\n', ' ')}" | esummary \
        | xtract -pattern DocumentSummary -element Caption,TaxId \
        > taxids.tsv

    efetch -db taxonomy -id "\$(cut -f2 taxids.tsv| tr '\\n' ' ')" -format xml \
        | xtract -pattern Taxon -element TaxId,Lineage \
        > lineages_no_acc.tsv

    n1=\$(cat taxids.tsv | wc -l)
    n2=\$(cat lineages_no_acc.tsv | wc -l)

    [ \$n1 = \$n2 ] && paste -d '\\t' taxids.tsv lineages_no_acc.tsv | cut -f2 --complement > lineage.tsv || exit 1
    """
}

workflow genbank {
    ids_split = Channel.fromPath(params.accessions).splitText( by: params.chunks )
    ids_split | TO_GENBANK | collectFile(name: "proteins.gbk", storeDir: params.outdir)
}

workflow lineage {
    ids_split = Channel.fromPath(params.accessions).splitText( by: params.chunks )
    ids_split | TO_LINEAGE | collectFile(name: "lineages.tsv", storeDir: params.outdir)
}

workflow {
    genbank()
    lineage()
}
