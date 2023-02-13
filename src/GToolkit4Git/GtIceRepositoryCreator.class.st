Class {
	#name : #GtIceRepositoryCreator,
	#superclass : #Object,
	#instVars : [
		'location',
		'remote',
		'url',
		'subdirectory',
		'repository',
		'isBareRepository'
	],
	#category : #'GToolkit4Git-Libgit-replace'
}

{ #category : #accessing }
GtIceRepositoryCreator class >> defaultSubdirectory [
	^ ''
]

{ #category : #private }
GtIceRepositoryCreator class >> isGitRoot: aReference [
	^ aReference isDirectory
		and: [ (aReference directoriesMatching: '.git') notEmpty
				and: [ (aReference / '.git' / 'config') exists ] ]
]

{ #category : #actions }
GtIceRepositoryCreator >> createNewRepositoryNamed: aString [
	| locationToUse |
	self validate.
	locationToUse := self locationToUse.
	(locationToUse exists and: [ locationToUse hasChildren ])
		ifTrue: [ IceError signal: ('{1} is not empty.' format: {locationToUse fullName}) ].
	locationToUse ensureCreateDirectory.
	self subdirectory
		ifNotEmpty: [ (locationToUse resolve: self subdirectory) ensureCreateDirectory ].	
	repository := GtIceGitRepository new
		name: aString;
		location: locationToUse;
		initBare: isBareRepository;
		yourself.
"	self addProjectFileTo: repository.
	self addPropertiesFileTo: repository.
	repository workingCopy refreshProject."
	^ repository
]

{ #category : #'private - accessing' }
GtIceRepositoryCreator >> defaultLocation [
	| remoteToUse |
	remoteToUse := self remoteToUse.
	^ IceLibgitRepository repositoriesLocation 
		/ remoteToUse organizer 
		/ remoteToUse projectName
]

{ #category : #initialization }
GtIceRepositoryCreator >> initialize [
	super initialize.
	"ensureProjectFile := false."
	isBareRepository := false
]

{ #category : #private }
GtIceRepositoryCreator >> location [
	^location
]

{ #category : #accessing }
GtIceRepositoryCreator >> location: aFileRef [
	location := aFileRef 
]

{ #category : #'private - accessing' }
GtIceRepositoryCreator >> locationToUse [
	^ self location ifNil: [ self defaultLocation ]
]

{ #category : #accessing }
GtIceRepositoryCreator >> remote [
	^remote
]

{ #category : #'private - accessing' }
GtIceRepositoryCreator >> remoteToUse [
	self remote ifNotNil: [ ^ self remote ].
	self url ifNotNil: [ ^ self halt "IceGitRemote url: self url" ].
	^ nil
]

{ #category : #accessing }
GtIceRepositoryCreator >> subdirectory [
	^ subdirectory ifNil: [ self class defaultSubdirectory ]
]

{ #category : #accessing }
GtIceRepositoryCreator >> url [
	^url
]

{ #category : #private }
GtIceRepositoryCreator >> validate [
	self validateLocation.
	self validateAlreadyPresentAndNotGit.
	self validateNotDuplicated
]

{ #category : #private }
GtIceRepositoryCreator >> validateAlreadyPresentAndNotGit [
	"Validate if I will add a local repository (url isNil and location isNotNil)... 
	 testing the local directory actually exists"	
	(self remoteToUse isNil
		and: [ self location notNil
		and: [ self location exists
		and: [ (self class isGitRoot: self location) not ] ] ])
		ifTrue: [ 
			IceError signal: ('"{1}" is not a git directory' format: {self location fullName}) ]
]

{ #category : #private }
GtIceRepositoryCreator >> validateLocation [
	(self location isNil 
		and: [ self remoteToUse isNil ])
		ifTrue: [ IceError signal: 'No location/url or remote defined.' ]
]

{ #category : #private }
GtIceRepositoryCreator >> validateNotDuplicated [
]
