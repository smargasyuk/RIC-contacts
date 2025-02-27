rule genomepy:
    output: multiext("resources/genomes/{assembly}/{assembly}", ".fa", ".fa.fai", ".fa.sizes", ".gaps.bed", ".annotation.gtf")
    params: 
        provider=lambda wildcards: config["genomes"][get_genome_by_assembly(wildcards["assembly"])]["provider"]
    cache: True 
    conda: "../envs/genomepy.yaml"
    shell: """
genomepy install -g resources/genomes/ -p {params.provider} --annotation {wildcards.assembly}
"""


rule get_genome_and_annotation:
    input: 
        fasta = lambda wildcards: f'resources/genomes/{get_assembly_by_genome(wildcards["genome"])}/{get_assembly_by_genome(wildcards["genome"])}.fa',
        annotation = lambda wildcards: f'resources/genomes/{get_assembly_by_genome(wildcards["genome"])}/{get_assembly_by_genome(wildcards["genome"])}.annotation.gtf',
    output:
        fasta = "resources/star_genome_input/{genome}/genome.fasta",
        gtf = "resources/star_genome_input/{genome}/genome.gtf"
    shell: """
mkdir -p $(dirname {output.fasta})   
cp {input.fasta} {output.fasta}
cp {input.annotation} {output.gtf}
"""


rule star_index:
    input:
        fasta="resources/star_genome_input/{genome}/genome.fasta",
        annotation="resources/star_genome_input/{genome}/genome.gtf",
    output:
        directory("resources/star_genome/{genome}/")
    params:
        extra = lambda wildcards, input: f"--sjdbGTFfile {input.annotation}"
    cache: True
    threads: 4
    log:
        "logs/{genome}/star_index_genome.log",
    wrapper:
        "0.84.0/bio/star/index"