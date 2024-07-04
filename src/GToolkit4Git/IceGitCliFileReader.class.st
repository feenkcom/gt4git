Class {
	#name : #IceGitCliFileReader,
	#superclass : #TonelReader,
	#traits : 'TIceRepositoryReader',
	#classTraits : 'TIceRepositoryReader classTrait',
	#instVars : [
		'iceVersion'
	],
	#category : #'GToolkit4Git-Libgit-CLI'
}

{ #category : #accessing }
IceGitCliFileReader class >> id [
	^#cliFiletree
]

{ #category : #accessing }
IceGitCliFileReader class >> on: aCommitOrTree iceVersion: iceVersion [
	^ (self on: aCommitOrTree fileSystem) 
		iceVersion: iceVersion; 
		yourself
]

{ #category : #accessing }
IceGitCliFileReader >> fileUtils [
	^ IceLibgitTonelFileUtils
]

{ #category : #accessing }
IceGitCliFileReader >> iceVersion [
	^ iceVersion
]

{ #category : #accessing }
IceGitCliFileReader >> iceVersion: anObject [
	| repository packageDirectoryName |
	iceVersion := anObject.
	repository := iceVersion commit repository.
	package := iceVersion package.

	packageDirectoryName := iceVersion commit writerClass directoryNameFor: package.
	self
		packageDirectory: (repository subdirectoryPath / packageDirectoryName) pathString
]

{ #category : #accessing }
IceGitCliFileReader >> loadVersionInfo [
	^ info := self iceVersion info
]

{ #category : #accessing }
IceGitCliFileReader >> package [
	^ MCPackage named: self iceVersion packageName
]

{ #category : #accessing }
IceGitCliFileReader >> packageDirectory: aDirectoryName [
	packageDirectory := stream resolvePath: aDirectoryName
]

{ #category : #accessing }
IceGitCliFileReader >> packageNameFromPackageDirectory [
	^ iceVersion packageName
]
