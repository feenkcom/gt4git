Class {
	#name : #GtGitGithubPageFormStencil,
	#superclass : #BrStencil,
	#instVars : [
		'ownerEditor',
		'projectEditor',
		'aDropdown',
		'repoGroup'
	],
	#category : #GToolkit4Git
}

{ #category : #accessing }
GtGitGithubPageFormStencil >> addOwnerContainer [
	|container|
	container := BlElement new.
	container viewModel: BrPagerPageModel new;
	look: BrWidgetContainerLook.
	ownerEditor := BrEditableLabel new
		look: BrGlamorousEditableLabelLook new glamorousRegularFontAndSize;
		text: 'Owner'.
	ownerEditor switchToEditor.
	container addChild: ownerEditor.
	^ container
	
]

{ #category : #accessing }
GtGitGithubPageFormStencil >> addProjectContainer [
	|container|
	container := BlElement new.
	container viewModel: BrPagerPageModel new;
	look: BrWidgetContainerLook.
	projectEditor := BrEditableLabel new
		look: BrGlamorousEditableLabelLook new glamorousRegularFontAndSize;
		text: 'Project'.
	projectEditor switchToEditor.
	container addChild: projectEditor.
	^ container
	
]

{ #category : #accessing }
GtGitGithubPageFormStencil >> create [
	^ self createMainContainer
]

{ #category : #accessing }
GtGitGithubPageFormStencil >> createCloneButton [
	|filler cloneButton|
	cloneButton := BrButton new.
	cloneButton look: (BrGlamorousButtonRectangularLook + (BrGlamorousButtonLabelLook new selectedColor: Color black)).
	cloneButton label: 'Clone'.
	cloneButton action: [ 
		|repo|	
		repo := IceRepositoryCreator new 
				remote: (IceGitRemote url: ownerEditor text asString);
				location: self projectLocation ;
				createRepository.
		repo register.
		repoGroup addRepository: repo.
		Iceberg announcer announce: (IceRepositoryAnnouncement for: repo).
		aDropdown ifNotNil: [
			aDropdown enqueueTask:
				(BlTaskAction new
					action:[ aDropdown dispatchEvent: 
						(BrDropdownHideWish new anchor: aDropdown) ])]].
	filler := BlElement new.
	cloneButton constraintsDo: [:c | c grid vertical alignTop. c grid horizontal alignRight].
	^ {filler . cloneButton}
]

{ #category : #accessing }
GtGitGithubPageFormStencil >> createMainContainer [
	|container|
	container := BrPagerPageElement new
			weight: 1.0;
			layout: (BlGridLayout new columnCount: 2);
			padding: (BlInsets all: 8).
	container addChildren: self createUrl.
	container addChildren: self createCloneButton.
	^ container.
]

{ #category : #accessing }
GtGitGithubPageFormStencil >> createUrl [
	|label |
	label := BrLabel new text:'Git URL'.
	label look: BrGlamorousLabelLook.
	
	ownerEditor := BrEditableLabel new
		look: BrGlamorousEditableLabelLook new glamorousRegularFontAndSize;
		text: ''.
	ownerEditor switchToEditor.
	ownerEditor hMatchParent.
	ownerEditor vExact: 23.
	label constraintsDo: [:c | c grid vertical alignCenter].
	ownerEditor constraintsDo: [:c | c grid vertical alignCenter].
	^ {label . ownerEditor}
	
]

{ #category : #accessing }
GtGitGithubPageFormStencil >> dropdown: anObject [ 
	aDropdown := anObject
]

{ #category : #accessing }
GtGitGithubPageFormStencil >> projectLocation [
	|url owner project |
	url := ownerEditor text asString.
	url := url copyReplaceAll: 'git@github.com:' with: ''.
	url := url copyReplaceAll: '.git' with: ''.
	owner := (url findTokens: '/') first.
	project := (url findTokens: '/') last.
	^ IceLibgitRepository repositoriesLocation 
		/ owner
		/ project
]

{ #category : #accessing }
GtGitGithubPageFormStencil >> repoGroup: aGtGitRepositoryGroup [
	repoGroup := aGtGitRepositoryGroup
]
