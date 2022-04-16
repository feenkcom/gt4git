Class {
	#name : #GtGitGithubPageFormStencil,
	#superclass : #BrStencil,
	#instVars : [
		'ownerEditor',
		'projectEditor',
		'aDropdown',
		'onCreated'
	],
	#category : #'GToolkit4Git-Inspector Integration'
}

{ #category : #accessing }
GtGitGithubPageFormStencil >> create [
	^ self createMainContainer
]

{ #category : #accessing }
GtGitGithubPageFormStencil >> createCloneButton [

	| cloneButton |
	cloneButton := BrButton new.
	cloneButton aptitude: BrGlamorousButtonRectangularAptitude
		+ (BrGlamorousButtonLabelAptitude new selectedColor: Color black).
	cloneButton label: 'Clone'.
	cloneButton action: [ 
		| repo |
		repo := IceRepositoryCreator new
			        remote: (IceGitRemote url: ownerEditor text asString);
			        location: self projectLocation;
			        createRepository.
		repo register.
		aDropdown ifNotNil: [ 
			aDropdown enqueueTask: (BlTaskAction new action: [ 
					 aDropdown dispatchEvent:
						 (BrDropdownHideWish new anchor: aDropdown) ]) ].
		self onCreated value: repo ].
	cloneButton constraintsDo: [ :c | 
		c grid vertical alignTop.
		c grid horizontal alignRight ].
	^ cloneButton
]

{ #category : #accessing }
GtGitGithubPageFormStencil >> createMainContainer [
	|container|
	container := BrHorizontalPane new
			padding: (BlInsets all: 5); vFitContent; hExact: 300.
	container addChildren: self createUrl.
	container addChild: self createCloneButton.
	^ container.
]

{ #category : #accessing }
GtGitGithubPageFormStencil >> createUrl [

	| label |
	label := BrLabel new
		         text: 'Git URL: ';
		         aptitude: BrGlamorousLabelAptitude;
		         margin: (BlInsets right: 5).

	ownerEditor := BrEditableLabel new
		               aptitude:
			               BrGlamorousEditableLabelAptitude new
				               glamorousRegularFontAndSize;
		               text: ''.
	ownerEditor switchToEditor.
	ownerEditor hMatchParent.
	ownerEditor vExact: 23.
	label constraintsDo: [ :c | c grid vertical alignCenter ].
	ownerEditor constraintsDo: [ :c | c grid vertical alignCenter ].
	^ { 
		  label.
		  ownerEditor }
]

{ #category : #accessing }
GtGitGithubPageFormStencil >> dropdown: anObject [ 
	aDropdown := anObject
]

{ #category : #accessing }
GtGitGithubPageFormStencil >> onCreated [

	^ onCreated ifNil: [ [ :repo |  ] ]
]

{ #category : #accessing }
GtGitGithubPageFormStencil >> onCreated: aBlock [
	onCreated := aBlock
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
