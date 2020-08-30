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
	|container button|
	button := BrButton new.
	button label: 'github'.
	button look: BrGlamorousButtonWithLabelLook.
	button action: [ self openGithubPage ].
	button constraints frame horizontal alignCenter.
	button constraints frame vertical alignCenter.
	
	container := BlElement new
		viewModel: BrPagerPageModel new;
		layout: BlFrameLayout new;
		look: BrVerticalFlowLook new.
	container addChild: button.
	^ container.
	
]

{ #category : #accessing }
GtGitAddRepositoryStencil >> openGithubPage [
	"self pager viewModel removePagesAfter: self pager viewModel pages first."
	self assert: dropdown isNotNil.
	self pager addPage: self githubPage.
	self pager smoothScrollToLast.
]

{ #category : #accessing }
GtGitAddRepositoryStencil >> pager [
	^ pager
]

{ #category : #accessing }
GtGitAddRepositoryStencil >> pagerContainer [
	pagerContainer ifNil: [
		self assert: dropdown isNotNil.
		pager := BrPager new.
		pagerContainer := BlElement new.
		pagerContainer constraintsDo: 
			[:c | c horizontal exact: 400. 
			c vertical exact: 100].
		pagerContainer addChild: pager.
		pager addPage: self initialPage].
	^ pagerContainer
]

{ #category : #accessing }
GtGitAddRepositoryStencil >> repoGroup: aGtGitRepositoryGroup [
	repoGroup := aGtGitRepositoryGroup
]
