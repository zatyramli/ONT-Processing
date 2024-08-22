params.fastq = "${params.fastq}/*.fastq"
params.medaka_model = null
params.references = "${params.references}/*.fasta"
params.outdir = "${params.outdir ?: 'output'}"

process concatenate_fastq {
  input:
    path fastq_files

  output:
    path "combined.fastq"

  script:
  """
  find ${params.fastq} -name '*.fastq' -exec cat {} + > combined.fastq
  """
}

process nanoplot {
  publishDir "${params.outdir}", mode: 'copy'

  input:
    path combined_fastq

  output:
    path "*"

  script:
  """
  nanoplot --fastq ${combined_fastq} -o Nanoplot
  """
}

process assembly {
  publishDir "${params.outdir}", mode: 'copy'

  input:
    path combined_fastq

  output:
    path "*"

  script:
  """
  flye --nano-hq ${combined_fastq} -o Flye_Assembly
  """
}

process filter_assembly_fasta {
  input:
    path assembly_dir

  output:
    path "assembly.fasta"

  script:
  """
  echo "Listing contents of ${assembly_dir}:"
  ls -l ${assembly_dir}
  if [ -f ${assembly_dir}/assembly.fasta ]; then
    echo "Copying ${assembly_dir}/assembly.fasta to current directory."
    cp ${assembly_dir}/assembly.fasta ./
  else
    echo "assembly.fasta not found in ${assembly_dir}" >&2
    exit 1
  fi
  """
}

process alignment {
  input:
    path combined_fastq
    path assembly_fasta

  output:
    path "alignment.sam"

  script:
  """
  minimap2 -a ${assembly_fasta} ${combined_fastq} > alignment.sam
  """
}

process polish_racon {  
  input:
    path combined_fastq
    path alignment_sam
    path assembly_fasta

  output:
    path "Racon.fasta"

  script:
  """
  racon -m 8 -x -6 -g -8 -w 500 ${combined_fastq} ${alignment_sam} ${assembly_fasta} > Racon.fasta
  """
}

process polish_medaka {
  publishDir "${params.outdir}", mode: 'copy'
  input:
    path combined_fastq
    path racon_fasta
    val medaka_model

  output:
    path "*"

  script:
  """
  medaka_consensus -m ${medaka_model} -i ${combined_fastq} -d ${racon_fasta} -o Polishing
  """
}

process filter_consensus_fasta {
  input:
    path polishing_dir

  output:
    path "consensus.fasta"

  script:
  """
  cp ${polishing_dir}/consensus.fasta ./
  """
}

process concatenate_references {
  input:
    path reference_files

  output:
    path "compiled_reference.fasta"

  script:
  """
  find ${params.references} -name '*.fasta' -exec cat {} + > compiled_reference.fasta
  """
}


process minimap2_alignment {
  publishDir "${params.outdir}/Alignment", mode: 'copy'
  input:
    path compiled_reference
    path consensus_fasta

  output:
    path "Alignment.paf"
    path "Alignment.bam"

  script:
  """
  minimap2 -x map-ont ${compiled_reference} ${consensus_fasta} > Alignment.paf
  minimap2 -a ${compiled_reference} ${consensus_fasta}| samtools view -Sb - > Alignment.bam
  """
}

process depth_coverage {
  publishDir "${params.outdir}/Alignment", mode: 'copy'
  input:
    path bam_file

  output:
    path "Alignment_sorted.bam"
    path "Alignment_sorted.bam.bai"
    path "*"

  script:
  """
  samtools sort -o Alignment_sorted.bam ${bam_file}
  samtools index Alignment_sorted.bam
  mosdepth coverage Alignment_sorted.bam
  """
}

workflow {
  fastq_files = Channel.fromPath(params.fastq)
  reference_files = Channel.fromPath(params.references)
  combined_fastq = concatenate_fastq(fastq_files)
  nanoplot(combined_fastq)
  assembly_output = assembly(combined_fastq)
  filtered_assembly = filter_assembly_fasta(assembly_output)
  alignment_sam = alignment(combined_fastq, filtered_assembly)
  racon_fasta = polish_racon(combined_fastq, alignment_sam, filtered_assembly)
  medaka_outputs = polish_medaka(combined_fastq, racon_fasta, params.medaka_model)
  consensus_fasta = filter_consensus_fasta(medaka_outputs)
  compiled_reference = concatenate_references(reference_files)
  minimap2_results = minimap2_alignment(compiled_reference, consensus_fasta)
  depth_coverage(minimap2_results[1])
}
