package main

import (
	"encoding/json"
	"fmt"
	"io"
	"io/ioutil"
	"os"
	"path/filepath"
	"regexp"
)

//
// STRUCTS
//

type PackageMetadata struct {
	Id                   string
	Name                 string
	Description          string
	Type                 string
	Version              string
	Dependencies         []string
	EnvironmentVariables map[string]interface{}
	Overrides            []string
}

type PlatformPackage struct {
	Path            string
	PackageMetadata PackageMetadata
}

//
// HELPERS
//

func check(e error) {
	if e != nil {
		panic(e)
	}
}

func copy(srcFile, dstFile string) error {
	out, err := os.Create(dstFile)
	if err != nil {
		return err
	}

	defer out.Close()

	in, err := os.Open(srcFile)
	if err != nil {
		return err
	}
	defer in.Close()
	if err != nil {
		return err
	}

	_, err = io.Copy(out, in)
	if err != nil {
		return err
	}

	return nil
}

//
// MAIN
//

func getAllPackages(platformPath string) []PlatformPackage {
	var packages []PlatformPackage
	filepath.WalkDir(platformPath, func(p string, info os.DirEntry, err error) error {
		if err != nil {
			return err
		}
		if filepath.Base(p) == "package-metadata.json" {
			packageMetadata, err := ioutil.ReadFile(p)
			check(err)

			var packageMetadataJson PackageMetadata
			json.Unmarshal(packageMetadata, &packageMetadataJson)
			packages = append(packages, PlatformPackage{Path: p, PackageMetadata: packageMetadataJson})
		}
		return nil
	})
	return packages
}

func overridePackages(platformDir string, platformPackages, implementationPackages []PlatformPackage) {

	for _, implementationPackage := range implementationPackages {

		implementationPackagePath := filepath.Dir(implementationPackage.Path)
		packageFolderName := filepath.Base(implementationPackagePath)
		overridePackageRoot := filepath.Join(platformDir, packageFolderName)

		err := os.MkdirAll(overridePackageRoot, 0755)
		check(err)

		var implementationPackageOverrides []string
		if implementationPackage.PackageMetadata.Overrides != nil {
			implementationPackageOverrides = implementationPackage.PackageMetadata.Overrides
		}

		filepath.WalkDir(implementationPackagePath, func(path string, info os.DirEntry, err error) error {
			if err != nil {
				return err
			}
			relativePackageFilePath, err := filepath.Rel(implementationPackagePath, path)
			check(err)

			if info.IsDir() {
				if relativePackageFilePath != "." {
					overrideDir := filepath.Join(overridePackageRoot, relativePackageFilePath)
					if _, err := os.Stat(overrideDir); os.IsNotExist(err) {
						err = os.Mkdir(overrideDir, 0755)
						check(err)
					}
				}
			} else {
				shouldOverride := implementationPackageOverrides == nil

				for _, override := range implementationPackageOverrides {
					match, _ := regexp.MatchString(override, relativePackageFilePath)
					if match {
						shouldOverride = true
						break
					}
				}
				if shouldOverride {
					err = copy(path, filepath.Join(overridePackageRoot, relativePackageFilePath))
					check(err)
				}
			}

			return nil
		})
	}
}

func main() {
	fmt.Println("Overriding configs...")
	platformPath := "./"
	implementationPath := "/implementation"

	platformPackages := getAllPackages(platformPath)
	implementationPackages := getAllPackages(implementationPath)

	overridePackages(platformPath, platformPackages, implementationPackages)
}
