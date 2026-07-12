-- Parameterised FEKO 2021.x example: PEC cylinder, dual-pol monostatic RCS.
-- Copy into a job directory and edit this block before running CADFEKO.
local outputCfx = [[C:/feko_jobs/cylinder/cylinder_rcs.cfx]]
local radiusMetres = "0.5"
local heightMetres = "1.0"
local frequencyHz = "3e9"
local thetaStart = "0"
local thetaEnd = "90"
local thetaIncrement = "1"
local phi = "0"
local dualPolarisation = true

local app = cf.GetApplication()
local project = app:NewProject()

local projectProperties = project:GetProperties()
projectProperties.ModelAttributes.Unit = cf.Enums.ModelUnitEnum.Metres
project:SetProperties(projectProperties)

local cylinder = project.Geometry:AddCylinder(
    cf.Point(0, 0, 0), radiusMetres, heightMetres)
cylinder.Label = "PEC_Cylinder"

local configuration = project.SolutionConfigurations[1]
configuration.Label = "Monostatic_RCS"

local frequencyProperties = configuration.Frequency:GetProperties()
frequencyProperties.Start = frequencyHz
configuration.Frequency:SetProperties(frequencyProperties)

local waveProperties = cf.PlaneWave.GetDefaultProperties()
waveProperties.DefinitionMethod = cf.Enums.PlaneWaveDefinitionMethodEnum.Multiple
waveProperties.StartTheta = thetaStart
waveProperties.EndTheta = thetaEnd
waveProperties.ThetaIncrement = thetaIncrement
waveProperties.StartPhi = phi
waveProperties.EndPhi = phi
waveProperties.PhiIncrement = "1"
waveProperties.PolarisationAngle = "0"
waveProperties.CalculateOrthogonalPolarisationsEnabled = dualPolarisation
waveProperties.Label = "PlaneWaveSweep"
configuration.Sources:AddPlaneWave(waveProperties)

local farFieldProperties = cf.FarField.GetDefaultProperties()
farFieldProperties.CalculationDirection =
    cf.Enums.FarFieldCalculationDirectionEnum.FromPlaneWave
farFieldProperties.Advanced.ExportSettings.ASCIIEnabled = true
farFieldProperties.Advanced.ExportSettings.OutFileEnabled = false
farFieldProperties.Label = "Monostatic_RCS"
configuration.FarFields:Add(farFieldProperties)

local solver = project.SolutionSettings.SolverSettings
local solverProperties = solver:GetProperties()
solverProperties.MLFMMACASettings.ModelSolutionSolveType =
    cf.Enums.ModelSolutionSolveTypeEnum.MLFMM
solver:SetProperties(solverProperties)

project.Mesher:Mesh()
app:SaveAs(outputCfx)
print("MODEL_BUILT_OK: " .. outputCfx)

