Class {
	#name : #IceGitCliPlatform,
	#superclass : #Object,
	#instVars : [
		'gitExecutable',
		'signalClass'
	],
	#classVars : [
		'current'
	],
	#category : #'GToolkit4Git-Libgit-CLI-Support'
}

{ #category : #accessing }
IceGitCliPlatform class >> current [
	^ current ifNil: [ current := self new ]
]

{ #category : #accessing }
IceGitCliPlatform >> gitExecutable [
	^ gitExecutable
]

{ #category : #accessing }
IceGitCliPlatform >> gitExecutable: anExecutablePath [
	gitExecutable := anExecutablePath
]

{ #category : #accessing }
IceGitCliPlatform >> gitVersion [
	^ self repositoryClass new
		location: FileLocator home;
		gitVersion
]

{ #category : #initialization }
IceGitCliPlatform >> initialize [
	super initialize.
	self gitExecutable: 'git'
]

{ #category : #accessing }
IceGitCliPlatform >> repositoryClass [
	^ IceGitCliRepository
]

{ #category : #accessing }
IceGitCliPlatform >> signalClass [
	^ signalClass
]

{ #category : #accessing }
IceGitCliPlatform >> signalClass: aClass [
	signalClass := aClass
]
