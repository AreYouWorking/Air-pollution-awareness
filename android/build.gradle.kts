import com.android.build.gradle.BaseExtension

allprojects {
    repositories {
        google()
        mavenCentral()
    }
    subprojects {
        afterEvaluate {
            if (plugins.hasPlugin("com.android.application") || plugins.hasPlugin("com.android.library")) {
                extensions.findByType(BaseExtension::class.java)?.let { androidExt ->
                    if (androidExt.namespace == null) {
                        androidExt.namespace = name
                    }
                }
            }

            // Task to ensure namespace and remove package attribute from XML
            tasks.register("fixManifestsAndNamespace") {
                doLast {
                    val buildGradleFile = project.file("${project.projectDir}/build.gradle.kts")
                    val manifestFile = project.file("${project.projectDir}/src/main/AndroidManifest.xml")

                    // Ensure namespace in build.gradle.kts
                    if (buildGradleFile.exists() && manifestFile.exists()) {
                        val buildGradleContent = buildGradleFile.readText(Charsets.UTF_8)
                        val manifestContent = manifestFile.readText(Charsets.UTF_8)

                        val packageRegex = Regex("""package="([^"]+)"""")
                        val packageName = packageRegex.find(manifestContent)?.groups?.get(1)?.value

                        if (!buildGradleContent.contains("namespace") && packageName != null) {
                            println("Setting namespace in $buildGradleFile")
                            val updatedBuildGradleContent = buildGradleContent.replaceFirst(
                                Regex("""android\s*\{"""),
                                "android {\n    namespace = \"$packageName\""
                            )
                            buildGradleFile.writeText(updatedBuildGradleContent, Charsets.UTF_8)
                        }
                    }

                    // Remove package attribute from AndroidManifest.xml
                    val manifests = project.fileTree(mapOf("dir" to project.projectDir, "includes" to listOf("**/AndroidManifest.xml")))

                    manifests.forEach { file ->
                        val content = file.readText(Charsets.UTF_8)
                        if (content.contains("package=")) {
                            println("Removing package attribute from $file")
                            val updatedContent = content.replace(Regex("""package="[^"]*""""), "")
                            file.writeText(updatedContent, Charsets.UTF_8)
                        }
                    }
                }
            }

            // Ensure the task runs before the build process
            tasks.matching { it.name.startsWith("preBuild") }.configureEach {
                dependsOn(tasks.named("fixManifestsAndNamespace"))
            }
        }
    }
}

val newBuildDir: Directory = rootProject.layout.buildDirectory.dir("../../build").get()
rootProject.layout.buildDirectory.value(newBuildDir)

subprojects {
    val newSubprojectBuildDir: Directory = newBuildDir.dir(project.name)
    project.layout.buildDirectory.value(newSubprojectBuildDir)
}
subprojects {
    project.evaluationDependsOn(":app")
}

tasks.register<Delete>("clean") {
    delete(rootProject.layout.buildDirectory)
}
