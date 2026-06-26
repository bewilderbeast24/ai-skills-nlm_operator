param(
    [Parameter(Mandatory = $true)]
    [string]$Path
)

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

$allowedArtifactTypes = @(
    "audio",
    "video",
    "report",
    "inforgraphic",
    "slides",
    "quiz",
    "flashcards",
    "data_table",
    "mindmap"
)

function Assert-HasProperty {
    param(
        [object]$Object,
        [string]$Name,
        [string]$Context
    )

    if (-not ($Object.PSObject.Properties.Name -contains $Name)) {
        throw "$Context missing required property '$Name'."
    }
}

function Assert-ArrayProperty {
    param(
        [object]$Object,
        [string]$Name,
        [string]$Context
    )

    Assert-HasProperty -Object $Object -Name $Name -Context $Context
    $value = $Object.$Name
    if ($null -eq $value) {
        throw "$Context property '$Name' must be an array, not null."
    }
    if ($value -isnot [System.Array]) {
        throw "$Context property '$Name' must be an array."
    }
}

if (-not (Test-Path -LiteralPath $Path -PathType Leaf)) {
    throw "Registry file not found: $Path"
}

$content = Get-Content -Raw -LiteralPath $Path
if ($content.TrimStart() -notmatch "^\[") {
    throw "Registry root must be a JSON array."
}
$parsed = $content | ConvertFrom-Json
if ($parsed -is [System.Array]) {
    $registry = $parsed
} else {
    $registry = @($parsed)
}

for ($i = 0; $i -lt $registry.Count; $i++) {
    $notebook = $registry[$i]
    $context = "Notebook[$i]"

    foreach ($property in @("notebook-id", "title", "source_count", "notebook_alias_name")) {
        Assert-HasProperty -Object $notebook -Name $property -Context $context
    }

    foreach ($property in @("source_details", "label_details", "note_details", "studio_artifact_details")) {
        Assert-ArrayProperty -Object $notebook -Name $property -Context $context
    }

    for ($j = 0; $j -lt $notebook.source_details.Count; $j++) {
        $source = $notebook.source_details[$j]
        $sourceContext = "$context.source_details[$j]"
        foreach ($property in @("id", "title", "type", "url", "source_alias_name")) {
            Assert-HasProperty -Object $source -Name $property -Context $sourceContext
        }
    }

    for ($j = 0; $j -lt $notebook.label_details.Count; $j++) {
        $label = $notebook.label_details[$j]
        $labelContext = "$context.label_details[$j]"
        foreach ($property in @("label_id", "label_name", "lable_alias_name", "emoji", "source_ids")) {
            Assert-HasProperty -Object $label -Name $property -Context $labelContext
        }
        if ($label.source_ids -isnot [System.Array]) {
            throw "$labelContext.source_ids must be an array."
        }
    }

    for ($j = 0; $j -lt $notebook.note_details.Count; $j++) {
        $note = $notebook.note_details[$j]
        $noteContext = "$context.note_details[$j]"
        foreach ($property in @("note_id", "note_title", "note_content", "preview")) {
            Assert-HasProperty -Object $note -Name $property -Context $noteContext
        }
    }

    for ($j = 0; $j -lt $notebook.studio_artifact_details.Count; $j++) {
        $artifact = $notebook.studio_artifact_details[$j]
        $artifactContext = "$context.studio_artifact_details[$j]"
        foreach ($property in @("artifact_id", "type", "status", "custom_instructions", "visual_style_prompt")) {
            Assert-HasProperty -Object $artifact -Name $property -Context $artifactContext
        }
        if ($allowedArtifactTypes -notcontains $artifact.type) {
            throw "$artifactContext.type has invalid value '$($artifact.type)'."
        }
    }
}

Write-Host "Registry validation passed for $($registry.Count) notebook records."
