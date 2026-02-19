# Snakemake Binding Free Energy Workflow

A Snakemake workflow for calculating binding free energies by decomposing them into individual components: solvation (dg_solv), conformational (dg_conf), and interaction (dg_int) free energies. The workflow is designed to process multiple ligands against multiple protein targets efficiently.

## Overview

This workflow is designed as a modular template that you can customise with your own free energy calculation methods. Each target can have multiple ligands, and each component (dg_solv, dg_conf, dg_int) runs as a separate Python script for each target-ligand pair, allowing for flexible implementation and independent validation.

### Workflow Structure

```
├── input/                       # Input data directory
│   ├── target_A/               # Ligands for target A
│   │   ├── ligand_1.dat
│   │   └── ligand_2.dat
│   └── target_B/               # Ligands for target B
│       └── ligand_3.dat
├── output/                      # Output results directory
│   ├── target_A/
│   │   ├── dg_solv/
│   │   ├── dg_conf/
│   │   ├── dg_int/
│   │   └── results/
│   └── target_B/
│       ├── dg_solv/
│       ├── dg_conf/
│       ├── dg_int/
│       └── results/
├── scripts/                     # Python scripts for calculations
│   ├── dg_solv.py      # Solvation free energy
│   ├── dg_conf.py      # Conformational free energy
│   └── dg_int.py       # Interaction free energy
├── Snakefile           # Workflow definition
├── config.yaml         # Targets, ligands, and parameters
├── pixi.toml           # Environment and task management
├── .pre-commit-config.yaml  # Pre-commit hooks
└── README.md           # This file
```

## Installation

### Prerequisites

- [Pixi](https://pixi.sh/latest/)

### Setup with Pixi

1. **Clone or download this repository:**
   ```bash
   git clone <repository-url>
   cd snakemake-free-energy
   ```

2. **Install the environment:**
   ```bash
   pixi install
   ```

3. **Set up pre-commit hooks (recommended for development):**
   ```bash
   pixi run install-hooks
   ```

## Usage

### Preparing Input Data and Configuration

1. **Organise input files by target:**
   ```bash
   mkdir -p input/target_A input/target_B
   ```

2. **Place ligand data files:**
   ```bash
   cp ligand_data/* input/target_A/
   ```

3. **Update `config.yaml`** to define your targets and ligands:
   ```yaml
   targets:
     target_A:
       ligands: [ligand_1, ligand_2, ligand_3]
     target_B:
       ligands: [ligand_4, ligand_5]
   ```

4. **Ensure input filenames match the pattern:** `input/{target}/{ligand}.dat`

### Running the Workflow

```bash
# Dry run (see what will be executed)
pixi run snakemake --cores all --dry-run

# Execute the workflow
pixi run snakemake --cores all
```

### Configuration

Edit `config.yaml` to customise workflow parameters and define your targets and ligands:

```yaml
project_name: "Your Project Name"
description: "Your project description"

targets:
  my_target_1:
    ligands: [ligand_a, ligand_b, ligand_c]
  my_target_2:
    ligands: [ligand_d, ligand_e]

# Add any project-specific configuration:
# calculation_method: "your_method"
# temperature: 298.15  # in Kelvin
```

## Implementing Your Scripts

Each component script is a template. Implement your calculation logic in:

### `scripts/dg_solv.py` – Solvation Free Energy

```python
def calculate_dg_solv(input_file: str, output_file: str) -> None:
    """Calculate solvation free energy."""
    # TODO: Implement your calculation here
    # Load data from input_file
    # Perform calculation
    # Save results to output_file as JSON
    pass
```

### `scripts/dg_conf.py` – Conformational Free Energy

```python
def calculate_dg_conf(input_file: str, output_file: str) -> None:
    """Calculate conformational free energy."""
    # TODO: Implement your calculation here
    pass
```

### `scripts/dg_int.py` – Interaction Free Energy

```python
def calculate_dg_int(input_file: str, output_file: str) -> None:
    """Calculate interaction free energy."""
    # TODO: Implement your calculation here
    pass
```

### Expected Output Format

Each script should output JSON with this structure:

```json
{
  "component": "dg_solv",
  "value": -10.5,
  "unit": "kcal/mol",
  "status": "success"
}
```

### Adding Dependencies

If your scripts require additional packages, use `pixi add`:

```bash
pixi add numpy scipy
```

This will automatically update `pixi.toml` and your environment.

## Workflow Description

The workflow consists of these steps for each target-ligand pair:

1. **calculate_dg_solv** – Calculates solvation free energy
2. **calculate_dg_conf** – Calculates conformational free energy
3. **calculate_dg_int** – Calculates interaction free energy
4. **combine_results** – Combines all three components into a final result

### Output Files

After running the workflow, you'll find:

```
output/
├── target_A/
│   ├── dg_solv/
│   │   ├── ligand_1.json
│   │   └── ligand_2.json
│   ├── dg_conf/
│   │   ├── ligand_1.json
│   │   └── ligand_2.json
│   ├── dg_int/
│   │   ├── ligand_1.json
│   │   └── ligand_2.json
│   └── results/
│       ├── ligand_1.json      # Combined results
│       └── ligand_2.json      # Combined results
└── target_B/
    └── ...
```

The final combined result includes:
- Target and ligand identifiers
- Individual component values
- Total binding free energy (sum of components) if all are implemented

Example combined output:
```json
{
  "target": "target_A",
  "ligand": "ligand_1",
  "components": {
    "dg_solv": {"component": "dg_solv", "value": -5.2, "unit": "kcal/mol"},
    "dg_conf": {"component": "dg_conf", "value": 2.1, "unit": "kcal/mol"},
    "dg_int": {"component": "dg_int", "value": -8.3, "unit": "kcal/mol"}
  },
  "total_dg_binding": {"value": -11.4, "unit": "kcal/mol"}
}
```

## Development

### Code Style and Formatting

This project enforces consistent code style using:
- **[Ruff](https://github.com/astral-sh/ruff)** – Fast Python linter and code formatter

### Formatting Commands (using Pixi)

```bash
# Format all scripts
pixi run format

# Check formatting without modifying
pixi run format-check

# Run linter and fixer
pixi run lint
```

### Pre-commit Hooks

Pre-commit hooks automatically run formatting and linting checks before each commit. They're configured in `.pre-commit-config.yaml` and include:

- Trailing whitespace removal
- End-of-file fixer
- YAML validation
- Ruff linting and formatting

**Install hooks after cloning (one-time setup):**
```bash
pixi run install-hooks
```

## Additional Resources

- [Snakemake Documentation](https://snakemake.readthedocs.io/)
- [Pixi Documentation](https://pixi.sh/)
- [Ruff Documentation](https://docs.astral.sh/ruff/)
