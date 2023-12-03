
clean:
	rm -Rf .nextflow* work bin/*__pycache__* nf_output/* scratch summary_temp summary.tar

run:
	nextflow run ./nf_workflow.nf --resume -c nextflow.config

run_hpcc:
	nextflow run ./nf_workflow.nf  --resume -c nextflow_hpcc.config


run_docker:
	nextflow run ./nf_workflow.nf  --resume -with-docker <CONTAINER NAME>
