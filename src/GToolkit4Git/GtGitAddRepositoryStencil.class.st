Class {
	#name : #GtGitAddRepositoryStencil,
	#superclass : #BrStencil,
	#instVars : [
		'dropdown',
		'repoGroup',
		'onCreated',
		'container'
	],
	#category : #'GToolkit4Git-Inspector Integration'
}

{ #category : #accessing }
GtGitAddRepositoryStencil >> container [
	container ifNil: [
		container := self initialPage ].
	^ container
]

{ #category : #accessing }
GtGitAddRepositoryStencil >> create [
	^ self container 
]

{ #category : #accessing }
GtGitAddRepositoryStencil >> dropdown: aDropdown [ 
	dropdown := aDropdown
]

{ #category : #accessing }
GtGitAddRepositoryStencil >> githubPage [
	| stencil|
	stencil := GtGitGithubPageFormStencil new.
	stencil dropdown: dropdown.
	stencil onCreated: self onCreated.
	^ stencil create.
]

{ #category : #accessing }
GtGitAddRepositoryStencil >> initialPage [
	^ BrVerticalPane new
		addChild: (BrLabel new
				aptitude: BrGlamorousLabelAptitude;
				text: 'Import a Git repository';
				margin: (BlInsets all: 5));
		addChild: (BrHorizontalPane new
				addChild: (BrButton new
							label: 'remotely';
							aptitude: BrGlamorousButtonWithLabelAptitude;
							action: [ self openGithubPage ];
							margin: (BlInsets all: 5))
					as: #'git-remote';
				addChild: (BrButton new
							label: 'locally';
							aptitude: BrGlamorousButtonWithLabelAptitude;
							action: [ self openLocalPage ];
							margin: (BlInsets all: 5))
					as: #'git-local';
				fitContent);
		addChild: (BrLabel new
				aptitude: BrGlamorousLabelAptitude;
				text: 'or initialize a new one';
				margin: (BlInsets all: 5));
		addChild: (BrButton new
					label: 'initialize';
					aptitude: BrGlamorousButtonWithLabelAptitude;
					action: [ self openInitialize ];
					margin: (BlInsets all: 5))
			as: #'git-initial';
		fitContent
]

{ #category : #accessing }
GtGitAddRepositoryStencil >> initializePage [
	| fileBrowser |
	fileBrowser := BrFileSelector new margin: (BlInsets all: 5).

	fileBrowser vExact: 400.
	fileBrowser hExact: 464.

	fileBrowser buttonLabel: 'Initialize'.
	fileBrowser
		okAction: [ :filePath | 
			| repo |
			filePath hasChildren ifFalse: [filePath ensureDelete].
			repo := IceRepositoryCreator new
					location: filePath;
					subdirectory: 'src';
					createNewRepositoryNamed: filePath basenameWithoutExtension.
			repo register.
			Iceberg announcer announce: (IceRepositoryAnnouncement for: repo).
			self onCreated value: repo.
			dropdown
				ifNotNil: [ dropdown
						enqueueTask: (BlTaskAction new
								action: [ dropdown dispatchEvent: (BrDropdownHideWish new anchor: dropdown) ]) ] ].

	fileBrowser
		fileFilterBlock: [ :aFileReference | 
			aFileReference isDirectory
				and: [ (FileSystemDirectoryEntry reference: aFileReference) isHidden not ] ].
	^ fileBrowser
]

{ #category : #accessing }
GtGitAddRepositoryStencil >> localPage [

	| fileBrowser |
	fileBrowser := BrFileSelector new margin: (BlInsets all: 5).

	fileBrowser vExact: 400.
	fileBrowser hExact: 464.

	fileBrowser buttonLabel: 'Import'.
	fileBrowser okAction: [ :filePath | 
		| repo |
		repo := IceRepositoryCreator new
			        location: filePath;
			        createRepository.
		repo register.
		Iceberg announcer announce: (IceRepositoryAnnouncement for: repo).
		self onCreated value: repo.
		dropdown ifNotNil: [ 
			dropdown enqueueTask: (BlTaskAction new action: [ 
					 dropdown dispatchEvent:
						 (BrDropdownHideWish new anchor: dropdown) ]) ] ].

	fileBrowser fileFilterBlock: [ :aFileReference | 
		aFileReference isDirectory and: [ 
			(FileSystemDirectoryEntry reference: aFileReference) isHidden not ] ].
	^ fileBrowser
]

{ #category : #accessing }
GtGitAddRepositoryStencil >> onCreated [

	^ onCreated ifNil: [ [ :repo |  ] ]
]

{ #category : #accessing }
GtGitAddRepositoryStencil >> onCreated: aBlock [
	onCreated := aBlock
]

{ #category : #accessing }
GtGitAddRepositoryStencil >> openGithubPage [

	container removeChildren.
	container addChild: self githubPage as: #'git-github-page'
]

{ #category : #accessing }
GtGitAddRepositoryStencil >> openInitialize [

	container removeChildren.
	container addChild: self initializePage  as: #'git-initialize-page'
]

{ #category : #accessing }
GtGitAddRepositoryStencil >> openLocalPage [

	container removeChildren.
	container addChild: self localPage as: #'git-local-page'
]
