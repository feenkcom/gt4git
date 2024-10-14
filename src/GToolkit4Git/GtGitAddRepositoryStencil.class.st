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
GtGitAddRepositoryStencil >> initialPage [
	^ BrVerticalPane new fitContent
		addChild: (BrSimpleList new
				itemStencil: [ BrLabel new
						vFitContent;
						hMatchParent;
						aptitude: BrGlamorousLabelAptitude
								+ (BrStyleCommonAptitude new
										hovered: [ :aStyle | aStyle background: BrGlamorousColors hoveredListItemColor ]) ];
				itemDataBinder: [ :anItemElement :anItemObject :anItemIndex | 
					anItemElement
						text: anItemObject first;
						id: anItemObject second;
						when: BlClickEvent do: anItemObject third ];
				fitContent;
				padding: (BlInsets all: 3);
				items: {{'Clone a remote repository'.
							#'git-remote'.
							[ self openRemotePage ]}.
						{'Load a local repository'.
							#'git-local'.
							[ self openLocalPage ]}.
						{'Create a new repository'.
							#'git-initial'.
							[ self openInitialize ]}})
]

{ #category : #accessing }
GtGitAddRepositoryStencil >> initializePage [
	| fileBrowser |
	fileBrowser := BrFileSelector new margin: (BlInsets all: 5).

	fileBrowser vExact: 400.
	fileBrowser hExact: 464.

	fileBrowser
		buttonLabel: 'Initialize';
		buttonId: #'git-initialize-button'.
	fileBrowser
		okAction: [ :filePath | 
			| repo |
			filePath hasChildren ifFalse: [ filePath ensureDelete ].
			repo := IceRepository repositoryClass creatorClass new
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
		repo := IceRepository repositoryClass creatorClass new
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
GtGitAddRepositoryStencil >> openInitialize [

	container removeChildren.
	container addChild: self initializePage  as: #'git-initialize-page'
]

{ #category : #accessing }
GtGitAddRepositoryStencil >> openLocalPage [

	container removeChildren.
	container addChild: self localPage as: #'git-local-page'
]

{ #category : #accessing }
GtGitAddRepositoryStencil >> openRemotePage [

	container removeChildren.
	container addChild: self remotePage as: #'git-remote-page'
]

{ #category : #accessing }
GtGitAddRepositoryStencil >> remotePage [
	^ GtGitRemoteRepositoryForm new
		dropdown: dropdown;
		onCreated: self onCreated;
		asElement
]
