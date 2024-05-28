"
I am GtIceRepositorySwitcher, a tool to control experiments with Libgit-CLI.

Based on a SSH url in the form git@github.com:owner/project.git I create IceRepository objects.

Option 1  back end

- useLibgit2
- useLibgitCLI

Option 2 directory

- useSystem (default)
- useTemp

Actions

- loadAndCreate (import existing on disk git repository)
- cloneAndCreate

- tool (rudimentary UI)

- register (with system, for git tool)

- deleteDirectory

- switch: (toggle a functioning, registerer repository between the two implementations)



 
"
Class {
	#name : #GtIceRepositorySwitcher,
	#superclass : #Object,
	#instVars : [
		'icebergLocation',
		'sshUrl',
		'iceRepository',
		'creator'
	],
	#category : #'GToolkit4Git-Libgit-CLI'
}

{ #category : #operations }
GtIceRepositorySwitcher >> cloneAndCreate [
	"Clone a git repository using its SSH url,
	load it and create an Iceberg repository object"

	iceRepository := self creator
		fromUrl: self sshUrl to: self directory.

	iceRepository name: self projectName.

	^ self iceRepository 
]

{ #category : #accessing }
GtIceRepositorySwitcher >> creator [
	"Return the creator helper to use"
	
	^ creator
		ifNil: [ self error: 'Creator not set, #useLibgit2 or #useLibgitCLI first' ]
]

{ #category : #operations }
GtIceRepositorySwitcher >> deleteDirectory [
	"Delete the whole local directory.
	Be careful, there is no way back."

	self directory exists ifTrue: [ self directory deleteAll ]
]

{ #category : #accessing }
GtIceRepositorySwitcher >> directory [
	"Return our on disk git directory"
	
	^ self icebergLocation / self owner / self projectName
]

{ #category : #operations }
GtIceRepositorySwitcher >> forget [
	"Forget our repository by unregistering from the system."

	self iceRepository ifNil: [ ^ self ].

	self iceRepository forget
]

{ #category : #accessing }
GtIceRepositorySwitcher >> iceRepository [
	"Return the Iceberg repository that I created"
	
	^ iceRepository
]

{ #category : #accessing }
GtIceRepositorySwitcher >> icebergLocation [
	"Return the location in which I search for or clone on disk git repositories.
	This defaults to the system Iceberg location next to the image"

	^ icebergLocation
		ifNil: [ icebergLocation := FileLocator localDirectory / 'iceberg' ]
]

{ #category : #initialization }
GtIceRepositorySwitcher >> icebergLocation: aFileReferenceOrNil [
	"Explicitly set the top level Iceberg location to use.
	Shortcuts are #useSystem (the default) and #useTemp"
	
	icebergLocation := aFileReferenceOrNil
]

{ #category : #operations }
GtIceRepositorySwitcher >> loadAndCreate [
	"Given an existing on disk git repository, 
	load it and create an Iceberg repository object"
	
	iceRepository := self creator new
		location: self directory;
		createRepository.

	iceRepository name: self projectName.

	^ self iceRepository
]

{ #category : #initialization }
GtIceRepositorySwitcher >> lookup: aRepositoryName [
	"Lookup the registered Iceberg repository named aRepositoryName"
	
	| existingRepository |
	existingRepository := IceRepository repositoryNamed: aRepositoryName.
	
	existingRepository 
		ifNil: [ ^ self error: ('repository named {1} not found' format: { aRepositoryName }) ].
	existingRepository isMissing 
		ifTrue: [ ^ self error: ('repository named {1} is missing/broken' format: { aRepositoryName }) ].
	
	^ existingRepository.
]

{ #category : #initialization }
GtIceRepositorySwitcher >> named: aRepositoryName [
	"Initialize from the registered Iceberg repository named aRepositoryName"
	
	iceRepository := self lookup: aRepositoryName.
	
	self sshUrl: iceRepository originUrl.
	self icebergLocation: iceRepository location parent parent
]

{ #category : #accessing }
GtIceRepositorySwitcher >> owner [
	"Return the owner name as extracted from our SSH url"
	
	^ (IceGitRemote url: self sshUrl) owner
]

{ #category : #accessing }
GtIceRepositorySwitcher >> projectName [
	"Return the project name as extracted from our SSH url"

	^ (IceGitRemote url: self sshUrl) projectName
]

{ #category : #operations }
GtIceRepositorySwitcher >> register [
	"Register the created repository with the system.
	The logic here allows switching, replacing an existing repository"
	
	| index |
	self iceRepository 
		ifNil: [ self error: 'Repository not yet created, use #loadAndCreate, #cloneAndCreate or #named:' ].
	index := IceRepository registry 
				findFirst: [ :each | each name = self projectName ].
	index isZero
		ifTrue: [ self iceRepository register ]
		ifFalse: [ 
			IceRepository registry at: index put: self iceRepository.
			Iceberg announcer 
				announce: (IceRepositoryCreated repository: self iceRepository). ]
]

{ #category : #accessing }
GtIceRepositorySwitcher >> sshUrl [
	"Return my main SSH url in the form git@github.com:owner/project.git"
	
	^ sshUrl
]

{ #category : #initialization }
GtIceRepositorySwitcher >> sshUrl: aString [
	"Set the main URL, expected to be in the form git@github.com:owner/project.git
	Needed even when not cloning to extract owner and project name"
	
	sshUrl := aString
]

{ #category : #operations }
GtIceRepositorySwitcher >> switch: aRepositoryName [
	"Look up a functioning, registered Iceberg repository named aRepositoryName
	and switch its implementation from Libgit2 to Libgit-CLI and vice versa"

	| existingRepository |
	existingRepository := self lookup: aRepositoryName.

	self sshUrl: existingRepository originUrl.
	self icebergLocation: existingRepository location parent parent.
	
	existingRepository isGitCliRepository
		ifTrue: [ self useLibgit2 ]
		ifFalse: [ self useLibgitCLI ].
		
	self loadAndCreate.
	
	self register
]

{ #category : #operations }
GtIceRepositorySwitcher >> tool [
	"Return a GtGitRepository instance on our Iceberg repository.
	This offers a rudimentary GT views/actions based UI"

	self iceRepository 
		ifNil: [ self error: 'Repository not yet created, use #loadAndCreate, #cloneAndCreate or #named:' ].
	^ GtGitRepository fromIcebergRepository: self iceRepository
]

{ #category : #initialization }
GtIceRepositorySwitcher >> useLibgit2 [
	"Set our repository creator to use the Iceberg Libgit2 FFI library" 

	creator := IceRepositoryCreator
]

{ #category : #initialization }
GtIceRepositorySwitcher >> useLibgitCLI [
	"Set our repository creator to use the Iceberg Libgit-CLI library"
	
	creator := GtIceRepositoryCreator
]

{ #category : #initialization }
GtIceRepositorySwitcher >> useSystem [
	"Switch to the main system iceberg location.
	This is a default"
	
	self icebergLocation: nil
]

{ #category : #initialization }
GtIceRepositorySwitcher >> useTemp [
	"The default is to use the main system iceberg location.
	Switch to a temporary directory"
	
	self icebergLocation: FileLocator temp / 'iceberg'.
	self icebergLocation ensureCreateDirectory
]
