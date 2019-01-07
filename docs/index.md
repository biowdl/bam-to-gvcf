---
layout: default
title: Home
version: develop
latest: false
---

This workflow can be used to generate a GVCF file from BAM files using
GATK HaplotypeCaller.

This workflow is part of [BioWDL](https://biowdl.github.io/)
developed by [the SASC team](http://sasc.lumc.nl/).

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
See [this page](/inputs.html) for some additional general notes and information
about pipeline inputs.

```json
{
  "Gvcf.dbsnpVCF": {
    "file": "A dbSNP VCF file",
    "index": "The index (.tbi) for the dbSNP VCF file"
  },
  "Gvcf.reference": {
    "fasta": "A reference fasta file",
    "fai": "The index for the reference fasta",
    "dict": "The dict file for the reference fasta"
  },
  "Gvcf.gvcfPath": "The path the output GVCF file will be written to",
  "Gvcf.bamFiles": "A list of input BAM files and their associated indexes"
}
```

Some additional inputs which may be of interest are:
```json
{
  "Gvcf.scatterList.regions": "The path to a bed file containing the regions for which variant calling will be performed",
  "Gvcf.scatterSize": "The size of scatter regions (see explanation of scattering below), defaults to 10,000,000",
}

```

#### Example
```json
{
  "Gvcf.dbsnpVCF": {
    "file": "/home/user/genomes/human/dbsnp/dbsnp-151.vcf.gz",
    "index": "/home/user/genomes/human/dbsnp/dbsnp-151.vcf.gz.tbi"
  },
  "Gvcf.reference": {
    "fasta": "/home/user/genomes/human/GRCh38.fasta",
    "fai": "/home/user/genomes/human/GRCh38.fasta.fai",
    "dict": "/home/user/genomes/human/GRCh38.dict"
  },
  "Gvcf.gvcfPath": "/home/user/analysis/results/s1.vcf.gz",
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
Included in the repository is an `environment.yml` file. This file includes
all the tool version on which the workflow was tested. You can use conda and
this file to create an environment with all the correct tools.

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
or contact
 <a href='http://sasc.lumc.nl/'>the SASC team</a> directly at: <a href='&#109;&#97;&#105;&#108;&#116;&#111;&#58;&#115;&#97;&#115;&#99;&#64;&#108;&#117;&#109;&#99;&#46;&#110;&#108;'>
&#115;&#97;&#115;&#99;&#64;&#108;&#117;&#109;&#99;&#46;&#110;&#108;</a>.
</p>
