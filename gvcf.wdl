import "tasks/gatk.wdl" as gatk
import "tasks/biopet.wdl" as biopet
import "tasks/picard.wdl" as picard

workflow Gvcf {
    Array[File] bamFiles
    Array[File] bamIndexes
    String gvcf_basename
    File ref_fasta
    File ref_dict
    File ref_fasta_index

    call biopet.ScatterRegions as scatterList {
        input:
            ref_fasta = ref_fasta,
            ref_dict = ref_dict,
            outputDirPath = "."
    }

    scatter (bed in scatterList.scatters) {
        call gatk.HaplotypeCallerGvcf as haplotypeCallerGvcf {
            input:
                gvcf_basename = basename(gvcf_basename),
                interval_list = [bed],
                ref_fasta = ref_fasta,
                ref_dict = ref_dict,
                ref_fasta_index = ref_fasta_index,
                input_bams = bamFiles,
                input_bams_index = bamIndexes
        }
    }

    call picard.MergeVCFs as gatherGvcfs {
        input:
            input_vcfs = haplotypeCallerGvcf.output_gvcf,
            input_vcfs_indexes = haplotypeCallerGvcf.output_gvcf_index,
            output_vcf_path = gvcf_basename + ".vcf.gz"
    }

    output {
        File output_gvcf = gatherGvcfs.output_vcf
        File output_gvcf_index = gatherGvcfs.output_vcf_index
    }
}