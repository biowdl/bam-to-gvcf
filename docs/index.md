---
layout: default
title: Home
version: develop
latest: false
---

This workflow can be used to generate a GVCF file from BAM files using
GATK HaplotypeCaller.

This workflow is part of [BioWDL](https://biowdl.github.io/)
developed by the SASC team at [Leiden University Medical Center](https://www.lumc.nl/).

## Usage
This workflow can be run using
[Cromwell](http://cromwell.readthedocs.io/en/stable/):
```
java -jar cromwell-<version>.jar run -i inputs.json gvcf.wdl
```

### Inputs
Inputs are provided through a JSON file. The minimally required inputs are
described below and a template containing all possible inputs can be generated
using Womtool as described in the
[WOMtool documentation](http://cromwell.readthedocs.io/en/stable/WOMtool/).

```json
{
  "Gvcf.referenceFasta": "A reference fasta file",
  "Gvcf.referenceFastaFai": "The index for the reference fasta",
  "Gvcf.referenceFastaDict": "The dict file for the reference fasta",
  "Gvcf.dbsnpVCF": "A dbSNP VCF file",
  "Gvcf.dbsnpVCFIndex": "The index (.tbi) for the dbSNP VCF file",
  "Gvcf.bamFiles": "A list of input BAM files and their associated indexes"
}
```

Some additional inputs which may be of interest are:
```json
{
  "Gvcf.scatterList.regions": "The path to a bed file containing the regions for which variant calling will be performed",
  "Gvcf.scatterSize": "The size of scatter regions (see explanation of scattering below), defaults to 10,000,000",
  "Gvcf.gvcfName": "The name of the output GVCF file"
}

```
An output directory can be set using an `options.json` file. See [the
cromwell documentation](
https://cromwell.readthedocs.io/en/stable/wf_options/Overview/) for more
information.

Example `options.json` file:
```JSON
{
"final_workflow_outputs_dir": "my-analysis-output",
"use_relative_output_paths": true,
"default_runtime_attributes": {
  "docker_user": "$EUID"
  }
}
```
Alternatively an output directory can be set with `Gvcf.outputDir`.
`Gvcf.outputDir` must be mounted in the docker container. Cromwell will
need a custom configuration to allow this.

#### Example
```json
{
  "Gvcf.dbsnpVCF": "/home/user/genomes/human/dbsnp/dbsnp-151.vcf.gz",
  "Gvcf.dbsnpVCFIndex": "/home/user/genomes/human/dbsnp/dbsnp-151.vcf.gz.tbi",
  "Gvcf.referenceFasta": "/home/user/genomes/human/GRCh38.fasta",
  "Gvcf.referenceFastaFai": "/home/user/genomes/human/GRCh38.fasta.fai",
  "Gvcf.referenceFastaDict": "/home/user/genomes/human/GRCh38.dict",
  "Gvcf.gvcfName": "s1.vcf.gz",
  "Gvcf.outputDir": "/home/user/analysis/results/",
  "Gvcf.bamFiles": [
    {
      "file": "/home/user/mapping/results/s1_1.bam",
      "index": "/home/user/mapping/results/s1_1.bai"
    },
    {
      "file": "/home/user/mapping/results/s1_2.bam",
      "index": "/home/user/mapping/results/s1_2.bai"
    },
  ]
}
```

### Dependency requirements and tool versions
Biowdl pipelines use docker images to ensure  reproducibility. This
means that biowdl pipelines will run on any system that has docker
installed. Alternatively they can be run with singularity.

For more advanced configuration of docker or singularity please check
the [cromwell documentation on containers](
https://cromwell.readthedocs.io/en/stable/tutorials/Containers/).

Images from [biocontainers](https://biocontainers.pro) are preferred for
biowdl pipelines. The list of default images for this pipeline can be
found in the default for the `dockerImages` input.

### output
A GVCF file at the specified location and its index.

## Scattering
This pipeline performs scattering to speed up analysis on grid computing
clusters. This is done by splitting the reference genome into regions of
roughly equal size (see the `scatterSize` input). Each of these regions will be
analyzed in separate jobs, allowing them to be processed in parallel.

## Contact
<p>
  <!-- Obscure e-mail address for spammers -->
For any question related to this workflow, please use the
<a href='https://github.com/biowdl/bam-to-gvcf/issues'>github issue tracker</a>
or contact the SASC team directly at: 
<a href='&#109;&#97;&#105;&#108;&#116;&#111;&#58;&#115;&#97;&#115;&#99;&#64;&#108;&#117;&#109;&#99;&#46;&#110;&#108;'>
&#115;&#97;&#115;&#99;&#64;&#108;&#117;&#109;&#99;&#46;&#110;&#108;</a>.
</p>
