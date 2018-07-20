---
layout: default
title: Home
version: develop
latest: true
---

This workflow can be used to generate a GVCF file from BAM files using
GATK HaplotypeCaller.

## Usage
`gvcf.wdl` can be run using
[Cromwell](http://cromwell.readthedocs.io/en/stable/):
```
java -jar cromwell-<version>.jar run -i inputs.json gvcf.wdl
```

The inputs JSON can be generated using WOMtools as described in the [WOMtools
documentation](http://cromwell.readthedocs.io/en/stable/WOMtool/).

The primary inputs are described below, additional inputs (such as precommands
and JAR paths) are available. Please use the above mentioned WOMtools command
to see all available inputs.

| field | type | |
|-|-|-|
| bamFiles | `Array[File]` | Input BAM files. |
| bamIndexes | `Array[File]` | Indexes for the index BAM files. |
| gvcfPath | `String` | The location where the output GVCF file should be placed. |
| refFasta | `File` | Reference fasta. |
| refFastaIndex | `File` | Index for the reference fasta. |
| refDict | `File` | The dict file for the reference fasta. |
| dbsnpVCF | `File` | A reference dbSNP VCF. |
| dbsnpVCFindex | `File` | An index for the reference dbSNP vcf. |
| scatterList.scatterSize | `Int?` | The size of each region during scattering. |

>All inputs have to be preceded by with `Gvcf.`.
Type is indicated according to the WDL data types: `File` should be indicators
of file location (a string in JSON). Types ending in `?` indicate the input is
optional, types ending in `+` indicate they require at least one element.

## Tool versions
Included in the repository is an `environment.yml` file. This file includes
all the tool version on which the workflow was tested. You can use conda and
this file to create an environment with all the correct tools.

## output
A GVCF file at the specified location and its index.

## About
This workflow is part of [BioWDL](https://biowdl.github.io/)
developed by [the SASC team](http://sasc.lumc.nl/).

## Contact
<p>
  <!-- Obscure e-mail address for spammers -->
For any question related to this workflow, please use the
<a href='https://github.com/biowdl/bam-to-gvcf/issues'>github issue tracker</a>
or contact
 <a href='http://sasc.lumc.nl/'>the SASC team</a> directly at: <a href='&#109;&#97;&#105;&#108;&#116;&#111;&#58;&#115;&#97;&#115;&#99;&#64;&#108;&#117;&#109;&#99;&#46;&#110;&#108;'>
&#115;&#97;&#115;&#99;&#64;&#108;&#117;&#109;&#99;&#46;&#110;&#108;</a>.
</p>
