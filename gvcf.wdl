version 1.0

import "tasks/gatk.wdl" as gatk
import "tasks/biopet/biopet.wdl" as biopet
import "tasks/picard.wdl" as picard
import "tasks/common.wdl" as common

workflow Gvcf {
    input {
        Array[IndexedBamFile] bamFiles
        String gvcfPath
        Reference reference
        IndexedVcfFile dbsnpVCF
    }

    String scatterDir = sub(gvcfPath, basename(gvcfPath), "/scatters/")

    call biopet.ScatterRegions as scatterList {
        input:
            reference = reference,
            outputDirPath = scatterDir
    }

    scatter (f in bamFiles) {
        File files = f.file
        File indexes = f.index
    }

    scatter (bed in scatterList.scatters) {
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

    call picard.MergeVCFs as gatherGvcfs {
        input:
            inputVCFs = gvcfFiles,
            inputVCFsIndexes = gvcfIndex,
            outputVcfPath = gvcfPath
    }

    output {
        IndexedVcfFile outputGVcf = gatherGvcfs.outputVcf
    }
}