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
    }

    String scatterDir = sub(gvcfPath, basename(gvcfPath), "/scatters/")

    call biopet.ScatterRegions as scatterList {
        input:
            reference = reference,
            outputDirPath = scatterDir,
            scatterSize = scatterSize,
            regions = regions
    }

    # Glob messes with order of scatters (10 comes before 1), which causes problems at gatherGvcfs
    call biopet.ReorderGlobbedScatters as orderedScatters {
        input:
            scatters = scatterList.scatters,
            scatterDir = scatterDir
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
                dbsnpVCF = dbsnpVCF
        }

        File gvcfFiles = haplotypeCallerGvcf.outputGVCF.file
        File gvcfIndex = haplotypeCallerGvcf.outputGVCF.index
    }

    call picard.GatherVcfs as gatherGvcfs {
        input:
            inputVcfs = gvcfFiles,
            inputVcfIndexes = gvcfIndex,
            outputVcfPath = gvcfPath
    }

    call samtools.Tabix as indexGatheredGvcfs {
        input:
            inputFile = gatherGvcfs.outputVcf
    }

    output {
        IndexedVcfFile outputGVcf = object {
            file: gatherGvcfs.outputVcf,
            index: indexGatheredGvcfs.index
        }
    }
}