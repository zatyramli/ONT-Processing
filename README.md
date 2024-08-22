## ONTPro: An Oxford Nanopore Sequencing Pipeline

Welcome to the ONTPro repository! This project is a comprehensive pipeline designed to process and analyze sequencing data generated using Oxford Nanopore Technologies (ONT). The pipeline is optimized for high-quality assembly and polishing of genomic sequences, incorporating multiple tools to ensure accuracy and efficiency in handling ONT data.ONTPro leverages several bioinformatics tools to assemble and polish genomic sequences. The script represents a complete pipeline: it takes raw ONT reads as input and outputs polished contigs, along with read quality statistics and depth coverage statistics.

The pipeline comprises several key processes:

Concatenation: Merges multiple FASTQ files into a single file for downstream analysis.

Assembly: Assembles the genome from ONT reads using Flye.

Polishing: Refines the assembly with Racon and Medaka to improve accuracy.

Alignment: Aligns assembled reads to generate a PAF file for further analysis.

Depth Coverage Analysis: Analyzes the depth of coverage across the assembled genome to assess the completeness and consistency of the assembly.

## Installation

To set up the ONTPro pipeline, you need to have [Miniconda](https://docs.anaconda.com/miniconda/miniconda-install/) installed. The following steps will guide you through the installation process:

1. **Clone this repository to your local machine:**

    ```bash
    git clone https://github.com/zatyramli/ONTPro.git
    cd ONTPro
    ```

2. **Create the Conda environment:**

    ```bash
    conda env create -f ONTPro.yml
    ```

3. **Activate the Conda environment:**

    ```bash
    source /opt/miniconda3/etc/profile.d/conda.sh
    conda activate ONTPro
    ```


## Usage

The pipeline can be executed using Nextflow, and the following command provides an example of how to run the pipeline:
```bash
nextflow run ONTPro.nf --fastq /path/to/fastq_files --medaka_model r941_min_high_g360 --references /path/to/reference_directory --outdir /path/to/output_directory
```

```markdown
## Parameters

- `--fastq_path` : Path to the input FASTQ files.
- `--ref_fasta` : Path to the reference FASTA file.
- `--medaka_model` : Specify the Medaka model to use (e.g., `r941_min_high_g360`).
```

Refer to the [Medaka documentation](https://github.com/nanoporetech/medaka) for details on each model.

## Contributing

Contributions to this project are welcome! Please fork the repository and submit a pull request with your proposed changes. Whether it’s bug fixes, feature enhancements, or documentation improvements, your input is highly valued.

**10. License**

This project is licensed under the MIT License. See the LICENSE file for more details.

## Acknowledgments

This pipeline was developed as part of a research initiative at Universiti Sains Malaysia, with support from the Emerging Infectious Disease (EID) research program. Special thanks to all contributors and collaborators who provided invaluable feedback during the development process.


