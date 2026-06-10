# matts_tests

Notebooks for developing and testing the [ltu-cmass](https://github.com/maho3/ltu-cmass) pipeline.

_Last reorganized: 2026-06-10_

---

## Structure

```
matts_tests/
├── (top level)          active notebooks — currently being worked on
├── component_tests/     tests of individual pipeline components
│   ├── noising/
│   ├── charm/
│   ├── lightcone/
│   ├── hod/
│   ├── nbody/
│   ├── summaries/
│   └── inference/
├── science_validation/  end-to-end validation against benchmarks or literature
├── fixes/               debugging specific known issues
├── dev/                 feature development and refactoring work
├── sharing/             notebooks made for collaborators or presentations
└── archive/             superseded or completed one-off notebooks
```

---

## Active (top level)

| Notebook | Last modified | Description |
|---|---|---|
| `charm4_halo_validation.ipynb` | 2026-05-28 | Validates CHARM v4 halo outputs against Quijote ground truth; compares positions and mass distributions across old fastpm and new fastpm_charm4 |
| `nle_emulations.ipynb` | 2026-04-23 | Validates neural likelihood emulation outputs against test simulation data |
| `sanity_check_fastpm_2000.ipynb` | 2026-06-03 | Sanity check of FastPM N-body outputs at 2000 Mpc/h scale |
| `test_noise_calibration.ipynb` | 2026-06-04 | Tests noise calibration procedures applied to simulated galaxy catalogs |
| `test_toy_noised.ipynb` | 2026-06-05 | Tests a toy noised simulation end-to-end |

---

## component_tests/

### noising/
| Notebook | Description |
|---|---|
| `check_subgrid_noising.ipynb` | Measures data-space impact of devoxelization (subgrid noising) on CHARM halo and galaxy statistics across different parameterizations |
| `test_noising.ipynb` | Tests noise injection algorithms on simulated fields |

### charm/
| Notebook | Description |
|---|---|
| `charm_fastpm_vs_charm4.ipynb` | Compares FastPM density fields and halo catalogs before and after CHARM v4 update |
| `test_large_volume.ipynb` | Tests FastPM pipeline at large volume (3 Gpc/h) |
| `test_suite_charm.ipynb` | Checks run completeness and halo file integrity across a full CHARM simulation suite |

### lightcone/
| Notebook | Description |
|---|---|
| `check_footprint.ipynb` | Measures what fraction of simulated galaxies fall within the BOSS CMASS survey footprint using convex hulls and bounding boxes |
| `lightcone_cosmology_animation.ipynb` | Creates an animation of the galaxy lightcone as a function of cosmological parameters (Omega_m sweep) |
| `lightcone_hod_callback_example.ipynb` | Reference example for the new lightcone API using an HOD callback function |
| `mtng_galaxy_magnitude_selection.ipynb` | Tests magnitude-based galaxy selection cuts on MTNG simulation data |
| `mtng_lightcone_frame_alignment.ipynb` | Constructs and rotates MTNG and FastPM lightcones to align coordinate frames; compares power spectra against MTNG ground truth |
| `test_lc_outputs.ipynb` | Tests lightcone output file structure and formats |
| `test_lightcone.ipynb` | Tests lightcone generation and redshift distributions |
| `test_sgc.ipynb` | Tests southern galactic cap (SGC) survey selection |

### hod/
| Notebook | Description |
|---|---|
| `test_alternative_hod.ipynb` | Tests alternative HOD model implementations |
| `test_constrained_HOD.ipynb` | Tests constrained HOD modeling |
| `test_hod.ipynb` | Tests standard HOD galaxy assignment pipeline |
| `test_new_mtnglike.ipynb` | Tests the MTNG-like simulation suite configuration |

### nbody/
| Notebook | Description |
|---|---|
| `pmwd_quijote_1gpch_comparison.ipynb` | Compares pmwd (BORG-PM) vs Quijote at 1 Gpc/h across comoving halos, cuboid halos, galaxies, and survey outputs |
| `test_abacus.ipynb` | Tests Abacus N-body simulation outputs |
| `test_fastpm.ipynb` | Tests FastPM N-body simulation outputs |
| `test_mtng.ipynb` | Tests MTNG simulation data loading and formatting |
| `test_nbody.ipynb` | Tests generic N-body simulation outputs |
| `test_pmwd.ipynb` | Tests PMWD (differentiable PM) simulation code |
| `test_quijote3gpch.ipynb` | Tests Quijote simulations at 3 Gpc/h scale |
| `test_quijotelike.ipynb` | Tests the Quijote-like simulation suite |

### summaries/
Statistical summaries of simulation outputs (power spectra, bispectra, etc.).

| Notebook | Description |
|---|---|
| `check_Bk_runs.ipynb` | Monitors and validates bispectrum (Bk, Pk, Qk) diagnostic run completeness across simulation suites |
| `FiberCollision.ipynb` | Detects and removes fiber collision effects from galaxy survey catalogs; checks impact on power spectrum |
| `test_Bk.ipynb` | Tests bispectrum measurement on an HOD lightcone |
| `test_Bkfast.ipynb` | Tests bispectrum measurement on a FastPM output |
| `test_bias.ipynb` | Tests galaxy bias measurement |
| `test_pypower.ipynb` | Tests pypower power spectrum measurement tools |

### inference/
| Notebook | Description |
|---|---|
| `check_HOD_data_new.ipynb` | Trains NPE/MAF neural density estimators to infer HOD parameters from n(z); applies posterior to MTNG data |
| `check_vfield.ipynb` | Compares velocity field interpolation schemes (BORG CIC/SIC, kNN, NGP) and their sensitivity to cosmological parameters |
| `test_hyperparam.ipynb` | Tests hyperparameter sensitivity in inference network training |
| `test_inference.ipynb` | Tests inference pipeline components end-to-end |
| `test_losses.ipynb` | Tests loss functions used in network training |

---

## science_validation/

End-to-end validation of the pipeline against known benchmarks or literature.

| Notebook | Description |
|---|---|
| `compare_charm_pinocchio.ipynb` | Compares halo catalogs from FastPM+CHARM vs Pinocchio; checks mass distributions and density fields at matching resolution |
| `compare_literature.ipynb` | Harmonizes cosmological constraints from published analyses (Ivanov, SIMBIG) into LTU-CMASS parameter format for comparison |
| `toy_gaussian.ipynb` | Validates inference pipeline on a toy Gaussian problem (known ground truth) |
| `validation.ipynb` | Systematic validation of simulation suite outputs and statistical properties |

---

## fixes/

Debugging notebooks targeting specific known issues.

| Notebook | Description |
|---|---|
| `debug_ns_bias.ipynb` | Investigates and diagnoses overprediction of n_s in lightcone summaries across simulation configurations |
| `debug_volume_scaling.ipynb` | Investigates why constraining power does not improve as expected when going to larger simulation volumes |
| `inference_prior_exploration.ipynb` | Visualizes prior distributions of cosmological and HOD parameters; searches for anomalous model realizations |
| `inspect_survey_outputs.ipynb` | Visualizes full pipeline outputs (density field, velocity field, halos, galaxies) for a 3 Gpc/h survey realization |

---

## dev/

Feature development and non-trivial refactoring work.

| Notebook | Description |
|---|---|
| `implement_polybin.ipynb` | Implements PolyBin power spectrum and bispectrum measurement as a pipeline component |

---

## sharing/

Notebooks created for specific collaborators or presentations.

| Notebook | Description |
|---|---|
| `for_chaipat.ipynb` | Exploratory ML analysis shared with Chaipat |
| `for_pres_91724.ipynb` | Pipeline visualization figures for September 2024 presentation |
| `for_scoggins/` | Notebook, job script, and shell script prepared for Scoggins |

---

## archive/

Superseded, completed, or one-off notebooks kept for reference.

| Notebook | Reason archived |
|---|---|
| `check_globus.ipynb` | One-off file sync check between Anvil and Bridges2 clusters |
| `hod_and_lightcone.ipynb` | Old HOD+lightcone pipeline; superseded by callback-based lightcone API |
| `hod_z.ipynb` | Old redshift-dependent HOD exploration; same vintage as `hod_and_lightcone` |
| `remove_nbkit.ipynb` | Completed refactoring: nbodykit → astropy coordinate transforms |
| `scratch.ipynb` | Miscellaneous pmwd experiments with no clear purpose |
| `suite_inference_old.ipynb` | Old inference validation suite; superseded |
| `suite_validation_old.ipynb` | Old pipeline validation suite; superseded |
| `test_charm.ipynb` | Original BORG-PM/pmwd vs Quijote test; uses old `/home/mattho/` file paths |
| `test_remove_cuboid.ipynb` | Testing after completed cuboid removal refactoring |
