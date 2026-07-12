---
name: feko
description: Automate Altair FEKO modelling, meshing, solver configuration, batch execution, monitoring, and result validation through CADFEKO/POSTFEKO Lua APIs and FEKO command-line tools. Use for .cfx, .pre, .fek, .out, .ffe, .bof, CADFEKO geometry and source creation, parameter sweeps, RCS or antenna simulations, MLFMM/MoM/PO solver setup, runfeko queues, and diagnosing FEKO failures.
---

# FEKO Automation

Prefer CADFEKO Lua and FEKO command-line tools for repeatability. Use GUI interaction only when an API setting cannot be established or the user explicitly requests it.

## Workflow

1. Discover the installed FEKO version and executable paths. Inspect existing models and scripts without assuming they are correct.
2. Translate the request into explicit geometry, units, materials, frequency, sources, polarisation, angular conventions, solver, mesh, requests, export formats, and parallelism. State any consequential assumptions.
3. Create a separate work directory. Preserve source Lua, generated `.cfx`, and logs. Never overwrite an original model unless explicitly requested.
4. Use a CADFEKO Lua script to build or modify the model. For FEKO 2021 patterns and known compatibility details, read [references/cadfeko-2021.md](references/cadfeko-2021.md).
5. Run CADFEKO non-interactively and verify that `.cfx`, `.cfm`, and `.pre` exist. Do not trust exit code 0 alone.
6. Launch `runfeko` from the model directory using only the basename; FEKO 2021 PREFEKO may reject a path with error 30005.
7. Monitor the relevant process group and `.out` file. Do not start a duplicate solve when `runfeko`, `mpiexec`, or FEKO MPI workers for the model are alive.
8. Validate completion from `.out` and expected exports. Treat process exit without `.ffe` or the requested artifact as incomplete.
9. After successful completion, verify the expected result files structurally, not only by existence. For `.ffe`, require a non-zero size and the expected request/data-block count. Then delete only the completed job's matching `.str` recovery file to reclaim disk space. Preserve `.str` whenever the solve is active, interrupted, failed, or the requested results are missing or incomplete.
10. Report exact model assumptions, output paths, solver state, warnings, result validation, `.str` cleanup, and whether results are complete or still running.

## Reusable resources

- Start new PEC-cylinder monostatic RCS jobs from [scripts/cylinder_rcs.lua](scripts/cylinder_rcs.lua); copy it into the job directory and edit the parameter block.
- Check a running or completed job with `scripts/Get-FekoJobStatus.ps1 -ModelBase <path-without-extension>`.
- Read [references/cadfeko-2021.md](references/cadfeko-2021.md) when targeting FEKO 2021.x or diagnosing API/version differences.

## Safety and execution rules

- Never uninstall FEKO, modify its installation tree, remove licence files, or recursively delete FEKO data.
- Keep `FEKO_USER_HOME` unchanged when writable. If a restricted environment blocks it, point it to a per-job writable directory and disclose this.
- Request approval before launching a resource-intensive solve when cost, licence use, runtime, or machine responsiveness is uncertain.
- Use a conservative core count unless the user requests all cores. Record the chosen count.
- Avoid embedding usernames, licence server values, proprietary geometry, or local absolute paths in publishable resources.
- Prefer official Altair documentation for API facts. Do not copy substantial proprietary documentation into the skill.
- Treat `.str` as recoverable solver state. Never delete it before proving normal completion and complete result exports. Resolve and verify the exact job-directory path before deleting; never remove `.str` files by a broad wildcard or recursive operation.

## Validation checklist

- Confirm dimensions and units numerically.
- Confirm frequency and angular start/end/increment values.
- Confirm polarisation count; for dual plane-wave polarisation set `CalculateOrthogonalPolarisationsEnabled = true`.
- Confirm requested calculation direction, such as `FromPlaneWave` for monostatic RCS.
- Confirm the selected solver in `.out`, not only in Lua.
- Confirm expected result files are non-empty and newer than the model.
- Search `.out` for `ERROR`, `WARNING`, convergence failures, licence failures, and normal completion.
- Compare expected and actual request/data-block counts in exported results. Only after all checks pass, delete the same job's `.str` and report the reclaimed size.
