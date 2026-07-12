# CADFEKO 2021.x notes

Use the legacy collection hierarchy visible in macros recorded by the installed release, for example `project.Geometry`, `project.SolutionConfigurations`, and `project.SolutionSettings`.

## Reliable API patterns

```lua
local app = cf.GetApplication()
local project = app:NewProject()
local cylinder = project.Geometry:AddCylinder(cf.Point(0, 0, 0), "0.5", "1.0")
```

Set a single frequency through the standard configuration's `Frequency` properties. Set a directional plane-wave sweep with `DefinitionMethod = cf.Enums.PlaneWaveDefinitionMethodEnum.Multiple`, `StartTheta`, `EndTheta`, `ThetaIncrement`, and matching phi fields.

For the GUI option **Calculate orthogonal polarisations**, set:

```lua
planeWaveProperties.CalculateOrthogonalPolarisationsEnabled = true
```

For monostatic RCS, create a far-field request with:

```lua
farFieldProperties.CalculationDirection =
    cf.Enums.FarFieldCalculationDirectionEnum.FromPlaneWave
```

Enable ASCII far-field export with `Advanced.ExportSettings.ASCIIEnabled = true`; FEKO writes `.ffe` after the corresponding request is solved.

Select MLFMM through `SolverSettings` and verify the `.out` file contains `DATA FOR THE MLFMM`.

## Command-line behaviour

Run automation scripts with:

```text
cadfeko.exe --non-interactive --run-script model.lua
```

Some restricted environments prevent CADFEKO from writing its default user configuration. In that case set `FEKO_USER_HOME` to a writable per-job folder before launch.

Change into the model directory before calling `runfeko`. Pass the basename, not an absolute `.cfx` path, to avoid PREFEKO error 30005.

## Official references

- PlaneWave API: https://help.altair.com/feko/topics/feko/user_guide/appendix/api_cadfeko_auto_generated/object/planewave.htm
- GeometryCollection API: https://help.altair.com/feko/topics/feko/user_guide/appendix/api_cadfeko_auto_generated/collection/geometrycollection.htm
- CADFEKO command-line options: https://2021.help.altair.com/2021.1/feko/topics/feko/user_guide/cadfeko/command_line_options_feko_r.htm

