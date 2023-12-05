#!/usr/bin/env nextflow
nextflow.enable.dsl=2

TOOL_FOLDER = "$baseDir/bin"

process mshub_gc {
    publishDir "./nf_output", mode: 'copy'

    conda "$TOOL_FOLDER/conda_env.yml"

    input:
    path input_spectra_path
    val time_unit

    output:
    path "clustered_mgf.mgf"
    path "clusteredinfo.tsv"
    path "clustersummary.tsv"
    path "scratch/data_integrals.csv", emit: integrals

    """
    python $TOOL_FOLDER/process_gc.py $input_spectra_path $time_unit clustered_mgf.mgf clusteredinfo.tsv clustersummary.tsv \
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

    
    input_spectra_folder_ch = Channel.fromPath(params.input_spectra_folder)
    mshub_gc(input_spectra_folder_ch, params.time_unit)
    quantification(mshub_gc.out.integrals,input_spectra_folder_ch)

}