Class {
	#name : #GtGitProjectRepositoryUri,
	#superclass : #Object,
	#instVars : [
		'scheme',
		'organization',
		'project',
		'segments',
		'uri'
	],
	#category : #'GToolkit4Git-Loader'
}

{ #category : #accessing }
GtGitProjectRepositoryUri >> icebergDirectory [
	^ self icebergRootDirectory / self organization / self project
]

{ #category : #testing }
GtGitProjectRepositoryUri >> icebergDirectoryExists [
	^ self icebergDirectory exists
]

{ #category : #accessing }
GtGitProjectRepositoryUri >> icebergRootDirectory [
	^ IceLibgitRepository repositoriesLocation
]

{ #category : #testing }
GtGitProjectRepositoryUri >> isDefined [
	^ self scheme isNotNil
		and: [ self organization isNotNil and: [ self project isNotNil ] ]
]

{ #category : #testing }
GtGitProjectRepositoryUri >> isGitHubScheme [
	^ self scheme = 'github'
]

{ #category : #accessing }
GtGitProjectRepositoryUri >> organization [

	^ organization
]

{ #category : #accessing }
GtGitProjectRepositoryUri >> project [

	^ project
]

{ #category : #accessing }
GtGitProjectRepositoryUri >> scheme [

	^ scheme
]

{ #category : #accessing }
GtGitProjectRepositoryUri >> segments [

	^ segments
]

{ #category : #accessing }
GtGitProjectRepositoryUri >> uri [

	^ uri
]

{ #category : #accessing }
GtGitProjectRepositoryUri >> uri: aString [
	| aSlashSplit |
	aSlashSplit := $/ split: aString.

	uri := aString.
	scheme := ($: split: aSlashSplit first) first.
	organization := aSlashSplit third.
	project := aSlashSplit fourth.
	segments := aSlashSplit allButFirst: 4
]
