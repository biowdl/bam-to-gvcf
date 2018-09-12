/*
 * Copyright (c) 2018 Biowdl
 *
 * Permission is hereby granted, free of charge, to any person obtaining a copy of
 * this software and associated documentation files (the "Software"), to deal in
 * the Software without restriction, including without limitation the rights to
 * use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of
 * the Software, and to permit persons to whom the Software is furnished to do so,
 * subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be included in all
 * copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS
 * FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR
 * COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER
 * IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN
 * CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
 */

package biowdl.test

import java.io.File

import nl.biopet.utils.biowdl.Pipeline
import nl.biopet.utils.biowdl.references.Reference
import nl.biopet.utils.ngs.vcf.getVcfIndexFile

trait BamToGvcf extends Pipeline with Reference {

  def outputFile: Option[File]
  def bamFiles: List[File]
  def dbsnpFile: Option[File]

  def bamIndexFiles: List[File] = bamFiles.map { bamFile =>
    val index1 = new File(bamFile.getAbsolutePath + ".bai")
    val index2 = new File(bamFile.getAbsolutePath.stripSuffix(".bam") + ".bai")
    (index1.exists(), index2.exists()) match {
      case (true, _) => index1
      case (_, true) => index2
      case _         => throw new IllegalStateException("No index found")
    }
  }

  override def inputs: Map[String, Any] =
    super.inputs ++
      Map(
        "reference" -> Map("fasta" -> referenceFasta.getAbsolutePath,
                           "fai" -> referenceFastaIndexFile.getAbsolutePath,
                           "dict" -> referenceFastaDictFile.getAbsolutePath),
        "Gvcf.bamFiles" -> bamFiles.zip(bamIndexFiles).map {
          case (b, i) =>
            Map("file" -> b.getAbsolutePath, "index" -> i.getAbsolutePath)
        }
      ) ++
      outputFile.map("Gvcf.gvcfPath" -> _.getAbsolutePath) ++
      dbsnpFile.map(
        f =>
          "Gvcf.dbsnpVCF" -> Map("file" -> f.getAbsolutePath,
                                 "index" -> getVcfIndexFile(f).getAbsolutePath))

  def startFile: File = new File("./gvcf.wdl")
}
