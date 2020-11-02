Class {
	#name : #GtGitAddRepositoryStencil,
	#superclass : #BrStencil,
	#instVars : [
		'pager',
		'pagerContainer',
		'dropdown',
		'repoGroup'
	],
	#category : #GToolkit4Git
}

{ #category : #accessing }
GtGitAddRepositoryStencil >> create [
	^ self pagerContainer 
]

{ #category : #accessing }
GtGitAddRepositoryStencil >> dropdown: aDropdown [ 
	dropdown := aDropdown
]

{ #category : #accessing }
GtGitAddRepositoryStencil >> githubPage [
	|container button stencil|
	stencil := GtGitGithubPageFormStencil new.
	stencil dropdown: dropdown.
	stencil repoGroup: repoGroup.
	^ stencil create.
]

{ #category : #accessing }
GtGitAddRepositoryStencil >> initialPage [
	|container button local label|
	label := BrLabel new.
	label look: BrGlamorousLabelLook; text: 'Import Git'.
	
	button := BrButton new.
	button label: 'clone'; beHuge; hExact: 100.
	button look: BrGlamorousButtonWithLabelLook.
	button action: [ self openGithubPage ].
	
	
	local := BrButton new.
	local label: 'local'; beHuge; hExact: 100.
	local look: BrGlamorousButtonWithLabelLook.
	local action: [ self openLocalPage ].
	
	container := BrPagerPageElement new.
	container weight: 1.0;
		layout: BlLinearLayout vertical alignCenter.

	label margin: (BlInsets top: 20).
	button margin: (BlInsets top: 20).
	local margin: (BlInsets top: 10 bottom: 10).

	container addChild: label.
	container addChild: button.
	container addChild: local.
	^ container.
	
]

{ #category : #accessing }
GtGitAddRepositoryStencil >> localPage [
	|fileBrowser container |
	container := BlElement new
		viewModel: BrPagerPageModel new;
		layout: (BlGridLayout new columnCount: 2);
		padding: (BlInsets all: 8).
	container
		constraintsDo: [ :c | 
			c horizontal matchParent.
			c vertical matchParent ].
	fileBrowser := BrFileSelector new.
	fileBrowser hMatchParent.
	fileBrowser vMatchParent.
	fileBrowser buttonLabel: 'Import'.
	fileBrowser okAction: [:filePath | 
		|repo|
		repo := IceRepositoryCreator new
			location: filePath;
			createRepository.
			repo register.
			Iceberg announcer announce: (IceRepositoryAnnouncement for: repo).
		dropdown ifNotNil: [
			dropdown enqueueTask:
				(BlTaskAction new
					action:[ dropdown dispatchEvent: 
						(BrDropdownHideWish new anchor: dropdown) ])]].
		
	fileBrowser fileFilterBlock: [:aFileReference | aFileReference isDirectory 
		and: [(FileSystemDirectoryEntry reference: aFileReference) isHidden not] ].
	container addChild: fileBrowser.
	^ container
	
]

{ #category : #accessing }
GtGitAddRepositoryStencil >> openGithubPage [
	"self pager viewModel removePagesAfter: self pager viewModel pages first."
	self pager addPage: self githubPage.
	self pager smoothScrollToLast.
]

{ #category : #accessing }
GtGitAddRepositoryStencil >> openLocalPage [
	"self pager viewModel removePagesAfter: self pager viewModel pages first."
	self pager addPage: self localPage.
	self pager smoothScrollToLast.
]

{ #category : #accessing }
GtGitAddRepositoryStencil >> pager [
	^ pager
]

{ #category : #accessing }
GtGitAddRepositoryStencil >> pagerContainer [
	pagerContainer ifNil: [
		pager := BrPager new.
		pager matchParent.
		pagerContainer := BlElement new.
		pagerContainer constraintsDo: 
			[:c | c horizontal exact: 480. 
			c vertical exact: 400].
		pagerContainer addChild: pager.
		pager addPage: self initialPage].
	^ pagerContainer
]

{ #category : #accessing }
GtGitAddRepositoryStencil >> repoGroup: aGtGitRepositoryGroup [
	repoGroup := aGtGitRepositoryGroup
]
