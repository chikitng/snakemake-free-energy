# Contributing Guide

This guide helps collaborators implement their own free energy calculation scripts in this workflow.

## Quick Start

1. **Clone the repository:**
   ```bash
   git clone <repository-url>
   cd snakemake-free-energy
   ```

2. **Set up your environment:**
   ```bash
   pixi install
   pixi run install-hooks
   ```

3. **Organise input data:**
   ```bash
   mkdir -p input/target_A input/target_B
   # Place ligand files in the appropriate directories
   ```

4. **Update config.yaml with your targets and ligands**

5. **Implement your scripts** (see below)

6. **Test your implementation:**
   ```bash
   pixi run snakemake --cores all --dry-run  # Preview the workflow
   pixi run snakemake --cores all            # Execute the workflow
   ```

## Implementing Calculation Scripts

Each of the three free energy components has a template script in the `scripts/` directory. Follow the guidelines below to implement your own methods.

### Script Structure

Each script follows this basic structure:

```python
import argparse
from pathlib import Path

def calculate_component(input_file: str, output_file: str) -> None:
    """Calculate free energy component.

    Parameters
    ----------
    input_file : str
        Path to input data file.
    output_file : str
        Path to output results file.
    """
    # 1. Load input data
    # 2. Perform calculation
    # 3. Save results as JSON

def main():
    parser = argparse.ArgumentParser(description="...")
    parser.add_argument("--input", required=True, help="...")
    parser.add_argument("--output", required=True, help="...")
    args = parser.parse_args()
    calculate_component(args.input, args.output)

if __name__ == "__main__":
    main()
```

### Output Format

All scripts must output JSON with this structure:

```json
{
  "component": "dg_solv",
  "value": -10.5,
  "unit": "kcal/mol",
  "status": "success"
}
```

**Required fields:**
- `component`: Name of the component (dg_solv, dg_conf, or dg_int)
- `unit`: Unit of the calculated value (e.g., "kcal/mol")
- `status`: Status of calculation ("success" or "not_implemented")

**Optional fields:**
- `value`: The calculated value (can be omitted if status is "not_implemented")
- Any additional metadata you want to include

### 1. Implementing dg_solv.py (Solvation Free Energy)

Edit [scripts/dg_solv.py](scripts/dg_solv.py):

```python
def calculate_dg_solv(input_file: str, output_file: str) -> None:
    """Calculate solvation free energy."""
    import json
    from pathlib import Path

    # Load your input data
    # data = pd.read_csv(input_file)  # or your preferred method

    # Perform your calculation
    # dg_solv_value = your_calculation_function(data)

    results = {
        "component": "dg_solv",
        "value": dg_solv_value,  # Replace with actual value
        "unit": "kcal/mol",
        "status": "success",
    }

    Path(output_file).parent.mkdir(parents=True, exist_ok=True)
    with open(output_file, "w") as f:
        json.dump(results, f, indent=2)
```

### 2. Implementing dg_conf.py (Conformational Free Energy)

Edit [scripts/dg_conf.py](scripts/dg_conf.py):

Follow the same pattern as dg_solv.py, but implement conformational free energy calculation.

### 3. Implementing dg_int.py (Interaction Free Energy)

Edit [scripts/dg_int.py](scripts/dg_int.py):

Follow the same pattern as dg_solv.py, but implement interaction free energy calculation.

## Adding Dependencies

If your scripts need additional packages, use `pixi add`:

```bash
pixi add numpy scipy pandas
```

This will automatically update `pixi.toml` and your environment.

## Code Quality

### Running Code Checks

Before committing, ensure your code passes all checks:

```bash
# Format code
pixi run format

# Check for issues (lint + format check)
pixi run lint
```

### Pre-commit Hooks

Pre-commit hooks will automatically check your code before each commit. If they fail:

```bash
# Run the hooks to see what needs fixing
pixi run run-hooks

# Format and fix issues
pixi run format

# Try committing again
git add .
git commit -m "your message"
```

## Testing Your Implementation

### 1. Prepare Test Data

Create sample input files organised by target:

```bash
# Create target and ligand directories
mkdir -p input/test_target

# Create test input files
echo "test_data" > input/test_target/test_ligand.dat
```

### 2. Update config.yaml

Edit the targets and ligands in `config.yaml`:

```yaml
targets:
  test_target:
    ligands: [test_ligand]
```

### 3. Run Workflow

```bash
# Dry run (shows what will happen)
pixi run snakemake --cores all --dry-run

# Execute workflow
pixi run snakemake --cores all

# Find your results
ls -la output/test_target/results/
```

## Input/Output Format Guidelines

### Input Files

Place your input data in the `input/` directory, organised by target:

```
input/
├── target_A/
│   ├── ligand_1.dat
│   ├── ligand_2.dat
│   └── ligand_3.dat
└── target_B/
    └── ligand_4.dat
```

You can modify the input file extension in the Snakefile if needed:

```smk
rule calculate_dg_solv:
    input:
        data="input/{target}/{ligand}.dat",  # Change extension here
```

### Output Files

The workflow automatically creates these output files organised by target:

```
output/
├── target_A/
│   ├── dg_solv/
│   │   ├── ligand_1.json       # Your solvation results
│   │   └── ligand_2.json
│   ├── dg_conf/
│   │   ├── ligand_1.json       # Your conformational results
│   │   └── ligand_2.json
│   ├── dg_int/
│   │   ├── ligand_1.json       # Your interaction results
│   │   └── ligand_2.json
│   └── results/
│       ├── ligand_1.json       # Combined results
│       └── ligand_2.json       # Combined results
└── target_B/
    └── ...
```

## Workflow Configuration

Customise workflow behaviour in `config.yaml`:

```yaml
project_name: "My Binding Free Energy Study"
description: "Calculating BFE for protein-ligand complexes"

targets:
  protein_A:
    ligands: [compound_1, compound_2, compound_3]
  protein_B:
    ligands: [compound_4, compound_5]

# Add your own parameters:
# temperature: 298.15
# methodology: "MM-PBSA"
```

Access config values in the Snakefile:

```python
config_value = config["temperature"]
```

## Documentation

### Docstring Requirements

All functions should have clear docstrings:

```python
def calculate_dg_solv(input_file: str, output_file: str) -> None:
    """Calculate solvation free energy using [your method].

    This function implements [brief description of methodology].

    Parameters
    ----------
    input_file : str
        Path to input PDB file or structure file.
    output_file : str
        Path to output JSON results file.

    Notes
    -----
    The calculation uses the following parameters:
    - Temperature: 298.15 K
    - Dielectric constant: 80.0
    """
```

### Script Comments

Add comments explaining complex calculations:

```python
# Apply implicit solvent model
# Using Poisson-Boltzmann equation with dielectric screening
solvation_energy = pb_solver(structure, dielectric=80.0)
```

## Troubleshooting

### "Python: not found"

Activate your environment:
```bash
pixi shell
```

### "Module not found"

Install missing dependencies:
```bash
pixi install
# or
pip install package_name
```

### Script syntax errors

Check with ruff:
```bash
pixi run lint
```

### Pre-commit hooks fail

Run formatting:
```bash
pixi run format
pixi run run-hooks
```

## Best Practices

1. **Keep calculations independent** – Each component (dg_solv, dg_conf, dg_int) should be independently validated
2. **Document your methodology** – Add comments and docstrings explaining your calculation
3. **Validate results** – Test with known systems before running on your data
4. **Use consistent units** – All output should use kcal/mol (update if using different units)
5. **Handle errors gracefully** – Provide informative error messages if calculations fail
6. **Log progress** – Add print statements or logging to track calculation progress
7. **Optimise for different targets** – Consider that different protein targets may require different parameters

## Getting Help

- Check the main [README.md](README.md) for workflow overview
- See [Snakemake documentation](https://snakemake.readthedocs.io/)
- See [Pixi documentation](https://pixi.sh/)
