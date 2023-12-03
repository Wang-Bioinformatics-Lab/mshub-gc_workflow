#!/usr/bin/env nextflow
nextflow.enable.dsl=2

TOOL_FOLDER = "$baseDir/bin"

process mshub_gc {
    publishDir "./nf_output", mode: 'copy'

    conda "$TOOL_FOLDER/conda_env.yml"

    input:
    path raw_peaks_path
    val time_unit

    output:
    path "clustered_mgf.mgf"
    path "clusteredinfo.tsv"
    path "clustersummary.tsv"
    path "filesummary.tsv"
    path "scratch/data_integrals.csv", emit: integrals
    path "scratch/data_ms_peaks.txt"

    """
    python $TOOL_FOLDER/process_gc.py $raw_peaks_path $time_unit clustered_mgf.mgf clusteredinfo.tsv clustersummary.tsv \
    -import_script "$TOOL_FOLDER/proc/io/importmsdata.py" -align_script "$TOOL_FOLDER/proc/preproc/intrapalign.py" \
    -noise_script "$TOOL_FOLDER/proc/preproc/noisefilter.py" -interalign_script "$TOOL_FOLDER/proc/preproc/interpalign.py" \
    -peakdetect_script "$TOOL_FOLDER/proc/preproc/peakdetect.py" -export_script "$TOOL_FOLDER/proc/io/export.py" \
    -report_script "$TOOL_FOLDER/proc/io/report.py" -vistic_script "$TOOL_FOLDER/proc/vis/vistic.py" 
    """
}

process quantification {
    publishDir "./nf_output", mode: 'copy'

    conda "$TOOL_FOLDER/conda_env.yml"

    input:
    path integral_table
    path path_to_spectra
    
    

    output:
    path "quantification.csv"

    """
    python $TOOL_FOLDER/create_quantification.py $integral_table $path_to_spectra "quantification.csv"
    """

}


workflow {

    
    raw_peaks_ch = Channel.fromPath(params.raw_peaks_path)
    mshub_gc(raw_peaks_ch, params.time_unit)
    quantification(mshub_gc.out.integrals,raw_peaks_ch)

}