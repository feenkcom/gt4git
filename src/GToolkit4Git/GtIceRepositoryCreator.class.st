Class {
	#name : #GtIceRepositoryCreator,
	#superclass : #Object,
	#instVars : [
		'location',
		'remote',
		'url',
		'subdirectory',
		'repository',
		'isBareRepository',
		'ensureProjectFile',
		'branchName'
	],
	#category : #'GToolkit4Git-Libgit-replace'
}

{ #category : #accessing }
GtIceRepositoryCreator class >> defaultSubdirectory [
	^ ''
]

{ #category : #'as yet unclassified' }
GtIceRepositoryCreator class >> fromUrl: aUrl to: aFileReference [
	^ self new 
		remote: (IceGitRemote url: aUrl);
  location: aFileReference;
  createRepository
]

{ #category : #private }
GtIceRepositoryCreator class >> isGitRoot: aReference [
	^ aReference isDirectory
		and: [ (aReference directoriesMatching: '.git') notEmpty
				and: [ (aReference / '.git' / 'config') exists ] ]
]

{ #category : #accessing }
GtIceRepositoryCreator >> addLocalRepository [
	self shouldBeImplemented
]

{ #category : #accessing }
GtIceRepositoryCreator >> cloneRepository [
	self executeGitClone.
	self repository location: self locationToUse.
		
	self commitishName 
		ifNotNil: [ self repository switchToCommitishNamed: self commitishName ].
	self repository pluginManager repositoryWillBeCreated: self repository.	

	self doEnsureProject.
	self repository workingCopy initializePackagesFromRepository.
		
	self repository pluginManager repositoryWasCreated: self repository.
	^ self repository
]

{ #category : #accessing }
GtIceRepositoryCreator >> commitishName: aName [
	branchName := aName
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

{ #category : #accessing }
GtIceRepositoryCreator >> createRepository [
	^ [
		self validate.
		self isCloning
			ifTrue: [ self cloneRepository ]
			ifFalse: [ self addLocalRepository ] ]
	on: IceDuplicatedRepository 
	do: [ :e | 
		"This is a HACK to allow process to recover from here"
		e signal ]
]

{ #category : #'private - accessing' }
GtIceRepositoryCreator >> defaultLocation [
	| remoteToUse |
	remoteToUse := self remoteToUse.
	^ IceLibgitRepository repositoriesLocation 
		/ remoteToUse organizer 
		/ remoteToUse projectName
]

{ #category : #accessing }
GtIceRepositoryCreator >> ensureProjectFile [
	ensureProjectFile := true
]

{ #category : #accessing }
GtIceRepositoryCreator >> executeGitClone [
	| repo cloneOptions checkoutOptions callbacks |
	location exists
		ifTrue: [ IceCloneLocationAlreadyExists signalFor: location ].
	
	[location ensureCreateDirectory.
	
	repo := GtIceGitRepository on: location.
	cloneOptions := repo cloneOptionsStructureClass withCredentialsProvider: (IceCredentialsProvider defaultForRemoteUrl: url).

	"Keeping references, because if not the GC take them."
	checkoutOptions := cloneOptions checkoutOptions.
	callbacks := cloneOptions fetchOptions callbacks.
	callbacks transferProgress: IceGitTransferProgress new.
	
	checkoutOptions checkoutStrategy: LGitCheckoutStrategyEnum git_checkout_force.
	checkoutOptions progressCallback: IceGitCheckoutProgress new.

	repo clone: url options: cloneOptions.

	(LGitRemote of: repo named: 'origin')
		lookup;
		setUrl: url.
		
	] on: LGitCallReturnHandler , IceWrongUrl do: [ :error |
		location exists ifTrue: [ location ensureDeleteAll ].
		error acceptError: (IceLibgitErrorVisitor onContext: self) ].
]

{ #category : #initialization }
GtIceRepositoryCreator >> initialize [
	super initialize.
	ensureProjectFile := false.
	isBareRepository := false
]

{ #category : #accessing }
GtIceRepositoryCreator >> isCloning [
	^ self remoteToUse notNil
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

{ #category : #accessing }
GtIceRepositoryCreator >> remote: aString [
	remote := aString
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
GtIceRepositoryCreator >> subdirectory: aString [
	subdirectory := aString
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
