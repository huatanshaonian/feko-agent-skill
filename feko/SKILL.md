---
name: feko
description: Automate Altair FEKO modelling, meshing, solver configuration, batch execution, monitoring, and result validation through CADFEKO/POSTFEKO Lua APIs and FEKO command-line tools. Use for .cfx, .pre, .fek, .out, .ffe, .bof, CADFEKO geometry and source creation, parameter sweeps, RCS or antenna simulations, MLFMM/MoM/PO solver setup, runfeko queues, and diagnosing FEKO failures.
---

# FEKO Automation

Prefer CADFEKO Lua and FEKO command-line tools for repeatability. Use GUI interaction only when an API setting cannot be established or the user explicitly requests it.

## Workflow

1. Discover FEKO rather than assuming an installation path. Run `scripts/Find-Feko.ps1` on Windows; prefer explicit environment variables and `PATH`, then inspect registered/common Altair installation roots. Verify that `cadfeko` and `runfeko` exist in the same `bin` directory and report the detected version. If discovery fails or multiple installations are equally plausible, ask the user which installation to use.
2. Translate the request into explicit geometry, units, materials, frequency, sources, polarisation, angular conventions, solver, mesh, requests, export formats, and parallelism. State any consequential assumptions.
3. Create a separate work directory. Preserve source Lua, generated `.cfx`, and logs. Never overwrite an original model unless explicitly requested.
4. Use a CADFEKO Lua script to build or modify the model. For FEKO 2021 patterns and known compatibility details, read [references/cadfeko-2021.md](references/cadfeko-2021.md).
5. Run CADFEKO non-interactively and verify that `.cfx`, `.cfm`, and `.pre` exist. Do not trust exit code 0 alone.
6. Launch `runfeko` from the model directory using only the basename; FEKO 2021 PREFEKO may reject a path with error 30005.
7. Establish persistent monitoring before handing control back. Monitor the relevant process group, `.out`, expected exports, and progress timestamps. Do not start a duplicate solve when `runfeko`, `mpiexec`, or FEKO MPI workers for the model are alive.
8. Validate completion from `.out` and expected exports. Treat process exit without `.ffe` or the requested artifact as incomplete.
9. After successful completion, verify the expected result files structurally, not only by existence. For `.ffe`, require a non-zero size and the expected request/data-block count. Then delete only the completed job's matching `.str` recovery file to reclaim disk space. Preserve `.str` whenever the solve is active, interrupted, failed, or the requested results are missing or incomplete.
10. Report exact model assumptions, output paths, solver state, warnings, result validation, `.str` cleanup, and whether results are complete or still running.

## Persistent monitoring contract

- Treat a request such as "run it", "wait until it finishes", or "report when complete" as requiring monitoring for the entire job lifecycle, not merely launching a background process.
- Use a product-supported recurring monitor, thread automation, durable goal, or equivalent callback when available. Keep a machine-readable job manifest containing the model, process identifiers, start time, last progress time, expected outputs, and completion criteria.
- Continue monitoring even if the user sends unrelated messages or temporarily stops interacting. Only an explicit request to stop, cancel, or detach monitoring ends this obligation.
- Notify the user when the job completes, fails, stalls beyond a reasonable interval, loses its solver process, or requires a decision. Include validation and cleanup results in the completion notification.
- Do not treat a visible terminal, detached shell, log file, or OS background process as a notification mechanism. These may execute the job but cannot by themselves satisfy the reporting obligation.
- Before ending a turn while a job is active, verify that a durable monitor capable of returning an event to the conversation is active. If the current environment has no such mechanism, keep the turn polling when practical or explicitly state that proactive follow-up is unavailable; never imply that a background script will automatically notify the conversation.

## Reusable resources

- Start new PEC-cylinder monostatic RCS jobs from [scripts/cylinder_rcs.lua](scripts/cylinder_rcs.lua); copy it into the job directory and edit the parameter block.
- Discover Windows FEKO installations with `scripts/Find-Feko.ps1`; use `-All` to list every validated candidate instead of selecting the newest one.
- Check a running or completed job with `scripts/Get-FekoJobStatus.ps1 -ModelBase <path-without-extension>`.
- Read [references/cadfeko-2021.md](references/cadfeko-2021.md) when targeting FEKO 2021.x or diagnosing API/version differences.

## Safety and execution rules

- Never uninstall FEKO, modify its installation tree, remove licence files, or recursively delete FEKO data.
- Keep `FEKO_USER_HOME` unchanged when writable. If a restricted environment blocks it, point it to a per-job writable directory and disclose this.
- Request approval before launching a resource-intensive solve when cost, licence use, runtime, or machine responsiveness is uncertain.
- Use a conservative core count unless the user requests all cores. Record the chosen count.
- Avoid embedding usernames, licence server values, proprietary geometry, or local absolute paths in publishable resources.
- Never embed a machine-specific FEKO installation path in a reusable skill or template. Resolve executable paths once per environment and pass them into job scripts or launch commands.
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
