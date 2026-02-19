"""Snakemake workflow for binding free energy calculations.

This workflow calculates binding free energies for multiple ligands targeting
multiple protein targets by running three separate components:
solvation (dg_solv), conformational (dg_conf), and interaction (dg_int)
free energies.
"""

import json
from pathlib import Path


# Configuration
configfile: "config.yaml"

# Extract targets and ligands from config
TARGETS = list(config["targets"].keys())


def get_ligands(target):
    """Get list of ligands for a given target."""
    return config["targets"][target]["ligands"]


rule all:
    """Specify final output targets."""
    input:
        results=expand(
            "output/{target}/results/{ligand}.json",
            target=TARGETS,
            ligand=[lig for t in TARGETS for lig in get_ligands(t)],
        ),


rule calculate_dg_solv:
    """Calculate solvation free energy component."""
    input:
        data="input/{target}/{ligand}.dat",
    output:
        result="output/{target}/dg_solv/{ligand}.json",
    shell:
        """
        python scripts/dg_solv.py \
            --input {input.data} \
            --output {output.result}
        """


rule calculate_dg_conf:
    """Calculate conformational free energy component."""
    input:
        data="input/{target}/{ligand}.dat",
    output:
        result="output/{target}/dg_conf/{ligand}.json",
    shell:
        """
        python scripts/dg_conf.py \
            --input {input.data} \
            --output {output.result}
        """


rule calculate_dg_int:
    """Calculate interaction free energy component."""
    input:
        data="input/{target}/{ligand}.dat",
    output:
        result="output/{target}/dg_int/{ligand}.json",
    shell:
        """
        python scripts/dg_int.py \
            --input {input.data} \
            --output {output.result}
        """


rule combine_results:
    """Combine all free energy components into final result."""
    input:
        solv="output/{target}/dg_solv/{ligand}.json",
        conf="output/{target}/dg_conf/{ligand}.json",
        interaction="output/{target}/dg_int/{ligand}.json",
    output:
        combined="output/{target}/results/{ligand}.json",
    run:
        # Load results from each component
        with open(input.solv) as f:
            solv_data = json.load(f)
        with open(input.conf) as f:
            conf_data = json.load(f)
        with open(input.interaction) as f:
            int_data = json.load(f)

        # Combine results
        combined = {
            "target": wildcards.target,
            "ligand": wildcards.ligand,
            "components": {
                "dg_solv": solv_data,
                "dg_conf": conf_data,
                "dg_int": int_data,
            },
        }

        # Calculate total binding free energy (if components are implemented)
        if (
            solv_data.get("status") != "not_implemented"
            and conf_data.get("status") != "not_implemented"
            and int_data.get("status") != "not_implemented"
        ):
            total_dg = (
                solv_data.get("value", 0.0)
                + conf_data.get("value", 0.0)
                + int_data.get("value", 0.0)
            )
            combined["total_dg_binding"] = {
                "value": total_dg,
                "unit": "kcal/mol",
            }

        # Write combined results
        Path(output.combined).parent.mkdir(parents=True, exist_ok=True)
        with open(output.combined, "w") as f:
            json.dump(combined, f, indent=2)
