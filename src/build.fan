using build
class Build : build::BuildPod
{
  new make()
  {
    version = Version.fromStr((scriptDir + `version`).readAllLines.first)
    podName = "diff"
    summary = "Comparison library, which allows to find differences between two sequences of objects of any type"
    srcDirs = [`test/`, `fan/`]
    depends = ["sys 1.0"]
  }
}
