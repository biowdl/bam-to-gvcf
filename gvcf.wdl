version 1.0

import "tasks/biopet/biopet.wdl" as biopet
import "tasks/common.wdl" as common
import "tasks/gatk.wdl" as gatk
import "tasks/picard.wdl" as picard
import "tasks/samtools.wdl" as samtools

workflow Gvcf {
    input {
        Array[IndexedBamFile] bamFiles
        String gvcfPath
        Reference reference
        IndexedVcfFile dbsnpVCF

        File? regions
        Int scatterSize = 10000000
        Map[String, String] dockerTags = {
          "samtools":"1.8--h46bd0b3_5",
          "picard":"2.18.26--0",
          "gatk":"3.8--5",
          "biopet-scatterregions": "0.2--0"
        }
    }

    String scatterDir = sub(gvcfPath, basename(gvcfPath), "/scatters/")

    call biopet.ScatterRegions as scatterList {
        input:
            reference = reference,
            scatterSize = scatterSize,
            regions = regions,
            dockerTag = dockerTags["biopet-scatterregions"]
    }

    # Glob messes with order of scatters (10 comes before 1), which causes problems at gatherGvcfs
    call biopet.ReorderGlobbedScatters as orderedScatters {
        input:
            scatters = scatterList.scatters,
            scatterDir = scatterList.scatterDir
            # Dockertag not relevant here. Python script always runs in the same
            # python container.
    }

    scatter (f in bamFiles) {
        File files = f.file
        File indexes = f.index
    }

    scatter (bed in orderedScatters.reorderedScatters) {
        call gatk.HaplotypeCallerGvcf as haplotypeCallerGvcf {
            input:
                gvcfPath = scatterDir + "/" + basename(bed) + ".vcf.gz",
                intervalList = [bed],
                reference = reference,
                inputBams = files,
                inputBamsIndex = indexes,
                dbsnpVCF = dbsnpVCF,
                dockerTag = dockerTags["gatk"]
        }

        File gvcfFiles = haplotypeCallerGvcf.outputGVCF.file
        File gvcfIndex = haplotypeCallerGvcf.outputGVCF.index
    }

    call picard.GatherVcfs as gatherGvcfs {
        input:
            inputVcfs = gvcfFiles,
            inputVcfIndexes = gvcfIndex,
            outputVcfPath = gvcfPath,
            dockerTag = dockerTags["picard"]
    }

    call samtools.Tabix as indexGatheredGvcfs {
        input:
            inputFile = gatherGvcfs.outputVcf,
            dockerTag = dockerTags["samtools"]
    }

    output {
        IndexedVcfFile outputGVcf = object {
            file: gatherGvcfs.outputVcf,
            index: indexGatheredGvcfs.index
        }
    }
}