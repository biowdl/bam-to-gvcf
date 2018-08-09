version 1.0

import "tasks/gatk.wdl" as gatk
import "tasks/biopet.wdl" as biopet
import "tasks/picard.wdl" as picard

workflow Gvcf {
    input {
        Array[File] bamFiles
        Array[File] bamIndexes
        String gvcfPath
        File refFasta
        File refDict
        File refFastaIndex
        File dbsnpVCF
        File dbsnpVCFindex
    }

    String scatterDir = sub(gvcfPath, basename(gvcfPath), "/scatters/")

    call biopet.ScatterRegions as scatterList {
        input:
            refFasta = refFasta,
            refDict = refDict,
            outputDirPath = scatterDir
    }

    scatter (bed in scatterList.scatters) {
        call gatk.HaplotypeCallerGvcf as haplotypeCallerGvcf {
            input:
                gvcfPath = scatterDir + "/" + basename(bed) + ".vcf.gz",
                intervalList = [bed],
                refFasta = refFasta,
                refDict = refDict,
                refFastaIndex = refFastaIndex,
                inputBams = bamFiles,
                inputBamsIndex = bamIndexes,
                dbsnpVCF = dbsnpVCF,
                dbsnpVCFindex = dbsnpVCFindex
        }
    }

    call picard.MergeVCFs as gatherGvcfs {
        input:
            inputVCFs = haplotypeCallerGvcf.outputGVCF,
            inputVCFsIndexes = haplotypeCallerGvcf.outputGVCFindex,
            outputVCFpath = gvcfPath
    }

    output {
        File outputGVCF = gatherGvcfs.outputVCF
        File outputGVCFindex = gatherGvcfs.outputVCFindex
    }
}