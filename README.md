# FEKO Agent Skill

An open-source agent skill for automating Altair FEKO modelling, meshing, solver setup, batch execution, monitoring, and result validation.

The skill primarily uses CADFEKO Lua APIs and FEKO command-line tools. It includes a tested FEKO 2021.x workflow, a parameterised dual-polarisation monostatic RCS example, and a PowerShell job-status checker.

## Capabilities

- Build and modify CADFEKO models with Lua.
- Configure plane-wave sweeps, orthogonal polarisations, monostatic RCS, and MLFMM.
- Run CADFEKO scripts non-interactively and launch `runfeko` safely.
- Monitor MPI solver processes and distinguish an empty placeholder `.ffe` from a completed result.
- Diagnose common FEKO 2021.x automation issues, including PREFEKO error 30005.

## Install

Copy the `feko` directory into your agent's skills directory.

For Codex on Windows:

```powershell
Copy-Item -Recurse .\feko "$HOME\.codex\skills\feko"
```

Restart or reload the agent, then invoke the skill with a request such as:

```text
Use $feko to create a dual-polarised monostatic RCS sweep for a PEC cylinder.
```

## Requirements

- A separately installed and licensed Altair FEKO distribution.
- CADFEKO Lua API and FEKO command-line tools available locally.
- PowerShell for the bundled Windows status checker.

FEKO is proprietary software and is not included in this repository.

## Validation

The skill structure is checked with OpenAI's `skill-creator` validator. The bundled CADFEKO 2021.x modelling pattern was exercised against FEKO 2021.1.

## Disclaimer

This is an independent community project. It is not affiliated with, endorsed by, or sponsored by Altair Engineering. Altair and FEKO may be trademarks of their respective owner.

## License

Apache License 2.0. See [LICENSE](LICENSE).

