allprojects {
    repositories {
        google()
        mavenCentral()
    }
}

val newBuildDir: Directory = rootProject.layout.buildDirectory.dir("../../build").get()
rootProject.layout.buildDirectory.value(newBuildDir)

subprojects {
    val newSubprojectBuildDir: Directory = newBuildDir.dir(project.name)
    project.layout.buildDirectory.value(newSubprojectBuildDir)
}

// Avoid forcing evaluation of the :app project here because it triggers
// project configuration (and the Android NDK check) prematurely.
// If you need to depend on tasks from :app, depend on tasks at execution time
// or configure task dependencies instead of forcing project evaluation.
// project.evaluationDependsOn(":app")

tasks.register<Delete>("clean") {
    delete(rootProject.layout.buildDirectory)
}
