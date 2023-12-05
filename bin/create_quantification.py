#!/usr/bin/python

import pandas as pd
import os
import argparse

def load_feature_to_rt_mapping(integrals_filename):
    mapping = {}

    df = pd.read_csv(integrals_filename)
    print(df)
    mapping_record = df.to_dict(orient="records")[0]
    print(mapping_record)
    for key in mapping_record:
        if key == "No:":
            continue
        mapping[key] = mapping_record[key].split(" ")[0]

    return mapping

def convert_quantification(input_integrals_filename, spectra_path, output_filename):
    all_input_filenames = [filename for filename in os.listdir(spectra_path) if os.path.isfile(filename)]
    filename_mapping = {}
    for filename in all_input_filenames:
        removed_extension = os.path.splitext(filename)[0]
        filename_mapping[removed_extension] = filename    


    integrals_df = pd.read_csv(input_integrals_filename, skiprows=[1,2,3])
    feature_to_rt_mapping = load_feature_to_rt_mapping(input_integrals_filename)

    all_molecules = list(integrals_df.keys())
    all_molecules.remove("No:")

    output_list = []
    for molecule in all_molecules:
        output_dict = {}
        output_dict["row ID"] = molecule
        output_dict["row m/z"] = "0"
        output_dict["row retention time"] = feature_to_rt_mapping[molecule]
        for record in integrals_df.to_dict(orient="records"):
            sample_name = record["No:"]
            abundance = record[molecule]

            if sample_name in filename_mapping:
                sample_name = filename_mapping[sample_name]
            output_dict[str(sample_name) + " Peak area"] = abundance

        output_list.append(output_dict)

    pd.DataFrame(output_list).to_csv(output_filename, sep=",", index=False)

def main():
    parser = argparse.ArgumentParser(description='Processing and feature detecting all gc files')
    parser.add_argument('integrals_filename', help='integrals_filename')
    parser.add_argument('spectra_path', help='spectra_path')
    parser.add_argument('quantification_output', help='quantification_output')
    args = parser.parse_args()
    convert_quantification(args.integrals_filename, args.spectra_path, args.quantification_output)
    



if __name__ == "__main__":
    main()
