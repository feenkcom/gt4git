Class {
	#name : #GtGitAddRepositoryStencil,
	#superclass : #BrStencil,
	#instVars : [
		'pager',
		'pagerContainer'
	],
	#category : #GToolkit4Git
}

{ #category : #accessing }
GtGitAddRepositoryStencil >> create [
	^ self pagerContainer 
]

{ #category : #accessing }
GtGitAddRepositoryStencil >> githubPage [
	|container button|
	^ GtGitGithubPageFormStencil new create.
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
		pager := BrPager new.
		pagerContainer := BlElement new.
		pagerContainer constraintsDo: 
			[:c | c horizontal exact: 200. 
			c vertical exact: 300].
		pagerContainer addChild: pager.
		pager addPage: self initialPage].
	^ pagerContainer
]
